import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:charset/charset.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:audio_service/audio_service.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:subtitle_wrapper_package/subtitle_wrapper_package.dart';

import 'package:xlist/gen/index.dart';
import 'package:xlist/helper/index.dart';
import 'package:xlist/models/index.dart';
import 'package:xlist/common/utils.dart';
import 'package:xlist/services/index.dart';
import 'package:xlist/storages/index.dart';
import 'package:xlist/constants/index.dart';
import 'package:xlist/repositorys/index.dart';
import 'package:xlist/helper/fijk_helper.dart';
import 'package:xlist/database/entity/index.dart';

class VideoPlayerController extends SuperController {
  final object = ObjectModel().obs;
  final userInfo = UserModel().obs; // 用户信息
  final httpHeaders = Map<String, String>().obs;
  final serverId = Get.find<UserStorage>().serverId.val.obs;
  final isLoading = true.obs; // 是否正在加载
  final isAutoPaused = false.obs; // 是否自动暂停
  final subtitles = <Subtitle>[].obs; // 字幕
  final subtitleNameList = <String>[].obs; // 字幕文件名列表
  final subtitleName = ''.obs; // 当前字幕文件名
  final audioTracks = <Map<String, String>>[].obs; // 音轨
  final timedTextTracks = <Map<String, String>>[].obs; // 字幕
  final showTimedText = true.obs; // 是否显示内置字幕
  final currentName = ''.obs; // 当前播放文件名
  final currentIndex = 0.obs; // 当前播放文件下标
  final showPlaylist = false.obs; // 是否显示播放列表
  final fijkViewKey = GlobalKey(); // 播放器 key
  final thumbnail = ''.obs; // 视频缩略图

  // 自动播放
  final isAutoPlay = Get.find<PreferencesStorage>().isAutoPlay.val;

  // 后台播放
  final isBackgroundPlay = Get.find<PreferencesStorage>().isBackgroundPlay.val;

  // 播放模式
  final playMode = Get.find<PreferencesStorage>().playMode;

  // 获取参数
  final String path = Get.arguments['path'] ?? '';
  final String name = Get.arguments['name'] ?? '';
  List<ObjectModel> objects = Get.arguments['objects'] ?? [];

  // 下载页面点击
  final String file = Get.arguments['file'] ?? '';
  final int downloadId = Get.arguments['downloadId'] ?? 0;

  // 初始化播放器
  final FijkPlayer player = FijkPlayer();
  final audioHandler = PlayerNotificationService.to.audioHandler;

  Timer? _timer;
  int _progressId = 0; // 进度表 ID
  final currentPos = Duration.zero.obs;
  StreamSubscription? _currentPosSubs;
  MediaItem? _mediaItem;

  @override
  void onInit() async {
    super.onInit();

    // 过滤掉非视频文件
    objects = objects.where((o) => PreviewHelper.isVideo(o.name!)).toList();
    userInfo.value = await UserRepository.me(); // 获取用户信息

    // 当前播放文件名
    currentName.value = name;
    currentIndex.value = objects.indexWhere((o) => o.name == name); // 当前播放文件下标
    showPlaylist.value = objects.length > 1; // 是否显示播放列表

    // PlayerNotificationService
    audioHandler.initializeStreamController(player, showPlaylist.value, true);
    audioHandler.playbackState.addStream(audioHandler.streamController.stream);
    audioHandler.setVideoFunctions(
        player.start, player.pause, player.seekTo, player.stop);

    // 获取视频播放地址
    if (file.isEmpty) {
      try {
        object.value = await ObjectRepository.get(path: '${path}${name}');
        httpHeaders.value = await DriverHelper.getHeaders(
            object.value.provider, object.value.rawUrl);
      } catch (e) {
        SmartDialog.showToast('toast_get_object_fail'.tr);
        return;
      }
    } else {
      final download = await DatabaseService.to.database.downloadDao
          .findDownloadById(downloadId);
      object.value = ObjectModel.fromJson({
        'name': download?.name,
        'type': download?.type,
        'size': download?.size,
        'raw_url': 'file://${file}',
      });

      // 尝试更新一下字幕
      ObjectRepository.get(path: '${path}${name}').then((value) {
        updateSubtitleNameList(value.related ?? []);
      });
    }

    // 获取字幕文件名列表
    updateSubtitleNameList(object.value.related ?? []);
    thumbnail.value = object.value.thumb ?? '';

    // 获取服务器 id
    if (Get.arguments['serverId'] != null) {
      serverId.value = Get.arguments['serverId'] ?? 0;
    }

    // 更新播放进度
    await updateProgress();

    // 初始化播放器
    await FijkHelper.setFijkOption(player, headers: httpHeaders);
    await player.setOption(FijkOption.playerCategory, 'seek-at-start',
        currentPos.value.inMilliseconds);
    await player.setDataSource(object.value.rawUrl ?? '', autoPlay: isAutoPlay);

    // Listener
    player.addListener(_fijkValueListener);

    // 监听播放进度
    _currentPosSubs = player.onCurrentPosUpdate.listen((v) {
      currentPos.value = v;
    });

    // 加入最近浏览
    await CommonUtils.addRecent(object.value, path, name);

    // 绑定进度监听
    DownloadService.to.bindBackgroundIsolate((id, status, progress) {});
    isLoading.value = false; // 加载完成
  }

  /// todo 切到后台, 播放其他 app 声音源再暂停, 再切回来, 会自动播放, 但是声音消失了
  void _fijkValueListener() async {
    FijkValue value = player.value;

    // Android 有些情况下会拿不到播放时间, 特殊处理一下
    if (_mediaItem != null && _mediaItem!.duration != value.duration) {
      _playerNotificationHandler();
    }

    // 屏幕常亮切换
    if (value.state == FijkState.started) Wakelock.enable();
    if (value.state == FijkState.paused) Wakelock.disable();

    // 播放预加载完成
    if (value.state == FijkState.prepared) {
      if (value.duration.inMilliseconds > 0) _playerNotificationHandler();
      final trackInfo = await player.getTrackInfo(); // 获取音轨信息
      final _audioTracks = <Map<String, String>>[];
      final _timedTextTracks = <Map<String, String>>[];
      for (var index = 0; index < trackInfo.length; index++) {
        final track = trackInfo[index];
        if (track['type'] == IjkPlayerTrackType.AUDIO) {
          _audioTracks.add({
            'index': index.toString(),
            'title': CommonUtils.formatIjkTrack(track['title']),
            'language': track['language'],
            'info': track['info'],
          });
        } else if (track['type'] == IjkPlayerTrackType.TIMEDTEXT) {
          _timedTextTracks.add({
            'index': index.toString(),
            'title': CommonUtils.formatIjkTrack(track['title']),
            'language': track['language'],
            'info': track['info'],
          });
        }
      }
      audioTracks.value = _audioTracks;
      timedTextTracks.value = _timedTextTracks;
    }

    // 播放完成
    if (value.state == FijkState.completed) {
      currentPos.value = Duration.zero;

      // 更新播放进度 - 重置
      await DatabaseService.to.database.progressDao.updateProgress(
        ProgressEntity(
          id: _progressId,
          serverId: serverId.value,
          path: path,
          name: currentName.value,
          currentPos: currentPos.value.inMilliseconds,
        ),
      );

      // 列表循环
      if (playMode.val == PlayMode.LIST_LOOP && showPlaylist.isTrue) {
        player.seekTo(0);
        currentIndex.value == objects.length - 1
            ? changePlaylist(0)
            : changePlaylist(currentIndex.value + 1);
        return;
      }

      // 单集循环
      if (playMode.val == PlayMode.SINGLE_LOOP && showPlaylist.isTrue) {
        player.seekTo(0);
        player.start();
        return;
      }
    }
  }

  /// 通知栏控制器
  void _playerNotificationHandler() {
    _mediaItem = MediaItem(
      id: '${path}${currentName.value}',
      title: CommonUtils.formatFileNme(currentName.value),
      duration: player.value.duration,
      artUri: object.value.thumb != null && object.value.thumb!.isNotEmpty
          ? Uri.parse(object.value.thumb!)
          : Uri.parse('https://s2.loli.net/2023/07/05/viCwFoLceMtAB3m.jpg'),
      artHeaders: httpHeaders,
    );

    // Add media
    audioHandler.mediaItem.add(_mediaItem);
  }

  /// 切换播放列表文件
  /// [index] 下标
  void changePlaylist(int index) async {
    final _object = objects[index];
    if (_object.name == currentName.value) {
      SmartDialog.showToast('toast_current_play_file'.tr);
      return;
    }

    // 获取视频播放地址
    SmartDialog.showLoading();
    try {
      object.value = await ObjectRepository.get(path: '${path}${_object.name}');
    } catch (e) {
      SmartDialog.dismiss();
      SmartDialog.showToast(e.toString());
      return;
    }

    // 更新初始化信息
    currentIndex.value = index;
    currentName.value = _object.name!;
    isAutoPaused.value = false;
    subtitles.clear();
    audioTracks.clear();
    timedTextTracks.clear();

    // 获取字幕文件名列表
    updateSubtitleNameList(object.value.related ?? []);

    // 重置播放器信息
    SmartDialog.dismiss();
    player.reset().then((value) async {
      currentPos.value = Duration.zero;
      await updateProgress(); // 更新播放进度

      // 更新封面
      final _cover = PreviewHelper.isAudio(_object.name!)
          ? Assets.common.logo.image()
          : (_object.thumb != null && _object.thumb!.isNotEmpty)
              ? Image.network(_object.thumb ?? '', headers: httpHeaders)
              : null;
      await player.setCover(_cover?.image);

      // 初始化播放器
      await FijkHelper.setFijkOption(player, headers: httpHeaders);
      await player.setOption(FijkOption.playerCategory, 'seek-at-start',
          currentPos.value.inMilliseconds);
      await player.setDataSource(object.value.rawUrl!, autoPlay: true);

      // 加入最近浏览
      await CommonUtils.addRecent(object.value, path, _object.name!);
      SmartDialog.showToast('toast_switch_success'.tr);
    });
  }

  /// 切换音轨
  void changeAudioTrack({String? value}) async {
    if (value == null) {
      value = await showModalActionSheet(
        context: Get.overlayContext!,
        title: 'video_switch_audio'.tr,
        actions: [
          ...audioTracks.map(
            (v) => SheetAction(
              label: '${v['title']}(${v['language']})',
              key: v['index'],
            ),
          ),
        ],
        cancelLabel: 'cancel'.tr,
      );
    }

    if (value != null) {
      final track = await player.getSelectedTrack(IjkPlayerTrackType.AUDIO);
      if (track == int.parse(value)) {
        SmartDialog.showToast('toast_current_audio_track'.tr);
        return;
      }

      player.pause();
      Future.delayed(Duration(milliseconds: 500), () {
        player.selectTrack(int.parse(value!));
        player.seekTo(currentPos.value.inMilliseconds);
        player.start();
        SmartDialog.showToast('toast_switch_success'.tr);
      });
    }
  }

  /// 更新字幕文件名列表
  void updateSubtitleNameList(List<ObjectModel> related) {
    subtitleNameList.clear();
    related.forEach((v) {
      final ext = p.extension(v.name!).toLowerCase();
      if (ext == '.vtt' || ext == '.srt' || ext == '.ass') {
        subtitleNameList.add(v.name!);
      }
    });
  }

  /// 切换字幕
  void changeSubtitle({String? value}) async {
    if (value == null) {
      value = await showModalActionSheet(
        context: Get.overlayContext!,
        materialConfiguration: MaterialModalActionSheetConfiguration(),
        title: 'video_switch_subtitle'.tr,
        actions: [
          ...subtitleNameList.map(
            (v) => SheetAction(label: v, key: v),
          ),
          ...timedTextTracks.map(
            (v) => SheetAction(
              label: '${v['title']}(${v['language']})',
              key: 'internal::${v['index']}',
            ),
          ),
          SheetAction(
            label: 'fijkplayer_subtitle_close'.tr,
            key: 'close',
            isDestructiveAction: true,
          ),
        ],
        cancelLabel: 'cancel'.tr,
      );
    }
    if (value == null) return;

    // 关闭字幕
    if (value == 'close') {
      showTimedText.value = false;
      subtitles.value = [];
      subtitles.refresh();
      SmartDialog.showToast('toast_subtitle_closed'.tr);
      return;
    }

    // 切换内置字幕
    if (value.startsWith('internal::')) {
      final _value = value.replaceAll('internal::', '');
      final track = await player.getSelectedTrack(IjkPlayerTrackType.TIMEDTEXT);
      if (track == int.parse(_value)) {
        if (showTimedText.value) {
          SmartDialog.showToast('toast_current_subtitle'.tr);
        }

        if (!showTimedText.value) {
          SmartDialog.showToast('toast_switch_success'.tr);
        }

        showTimedText.value = true; // 显示字幕
        return;
      }

      player.pause();
      Future.delayed(Duration(milliseconds: 500), () async {
        await player.selectTrack(int.parse(_value));
        await player.seekTo(currentPos.value.inMilliseconds);
        await player.start();

        showTimedText.value = true; // 显示字幕
        SmartDialog.showToast('toast_switch_success'.tr);
      });
      return;
    }

    try {
      SmartDialog.showLoading(msg: 'toast_switch_loading'.tr);
      final _object = await ObjectRepository.get(path: '${path}${value}');
      final response = await DioService.to.dio.get(
        _object.rawUrl!,
        options: Options(
          headers: httpHeaders,
          responseDecoder: (List<int> responseBytes, RequestOptions options,
              ResponseBody responseBody) {
            String _data = '';
            try {
              _data = hasUtf32Bom(responseBytes)
                  ? utf32.decode(responseBytes)
                  : (hasUtf16Bom(responseBytes)
                      ? utf16.decode(responseBytes)
                      : utf8.decode(responseBytes));
            } catch (e) {
              _data = gbk.decode(responseBytes);
            }
            return _data;
          },
        ),
      );

      // 获取文件后缀
      final ext = p.extension(value).toLowerCase();

      // ass 单独处理
      if (ext == '.ass') {
        showTimedText.value = false;
        subtitles.value = await CommonUtils.ass2srt(response.data);
        subtitles.refresh();

        SmartDialog.dismiss();
        SmartDialog.showToast('toast_switch_success'.tr);
        return;
      }

      // 字幕类型
      final subtitleType =
          ext == '.vtt' ? SubtitleType.webvtt : SubtitleType.srt;

      // 解析字幕文件
      final data = await SubtitleDataRepository(
        subtitleController: SubtitleController(
          subtitlesContent: response.data,
          subtitleType: subtitleType,
        ),
      ).getSubtitles();

      showTimedText.value = false;
      subtitles.value = data.subtitles;
      subtitles.refresh();

      SmartDialog.dismiss();
      SmartDialog.showToast('toast_switch_success'.tr);
    } catch (e) {
      SmartDialog.dismiss();
      SmartDialog.showToast('toast_switch_subtitle_fail'.tr);
    }
  }

  /// 更新本地播放进度
  Future<void> updateProgress() async {
    final progress = await DatabaseService.to.database.progressDao
        .findProgressByServerIdAndPath(serverId.value, path, currentName.value);

    if (progress != null) {
      _progressId = progress.id!;
      currentPos.value = Duration(milliseconds: progress.currentPos);
    } else {
      _progressId =
          await DatabaseService.to.database.progressDao.insertProgress(
        ProgressEntity(
          serverId: serverId.value,
          path: path,
          name: currentName.value,
          currentPos: 0,
        ),
      );
    }

    // 每五秒记录一下播放进度
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      await DatabaseService.to.database.progressDao.updateProgress(
        ProgressEntity(
          id: _progressId,
          serverId: serverId.value,
          path: path,
          name: currentName.value,
          currentPos: currentPos.value.inMilliseconds,
        ),
      );
    });
  }

  /// 收藏
  void favorite() async {
    await CommonUtils.addFavorite(object.value, path, currentName.value);
  }

  /// 复制链接
  void copyLink() {
    Clipboard.setData(ClipboardData(
      text: CommonUtils.getDownloadLink(
        path,
        object: object.value,
        userInfo: userInfo.value,
      ),
    ));
    SmartDialog.showToast('toast_copy_success'.tr);
  }

  /// 下载文件
  void download() async {
    DownloadHelper.file(
        path, currentName.value, object.value.type!, object.value.size!);
  }

  @override
  void onPaused() {
    if (player.value.state == FijkState.started && !isBackgroundPlay) {
      isAutoPaused.value = true;
      player.pause();
    }
  }

  @override
  void onResumed() {
    // 判断大小超过 30g 的大文件
    final isLargeFile = object.value.size! > 30 * 1024 * 1024 * 1024;

    // if player is started and auto paused
    if (player.value.state == FijkState.started && isLargeFile) {
      isAutoPaused.value = true;
      player.pause();
    }

    // fix player seekTo bug
    Future.delayed(Duration(milliseconds: 500), () async {
      if (isLargeFile) await player.seekTo(currentPos.value.inMilliseconds);

      if (player.value.state == FijkState.paused && isAutoPaused.isTrue) {
        isAutoPaused.value = false;
        player.start();
      }
    });
  }

  @override
  void onInactive() {}

  @override
  void onDetached() {}

  @override
  void onHidden() {}

  @override
  void onClose() {
    super.onClose();

    _timer?.cancel();
    _currentPosSubs?.cancel();
    audioHandler.streamController.add(PlaybackState());
    audioHandler.streamController.close();
    player.removeListener(_fijkValueListener);
    player.release();

    DownloadService.to.unbindBackgroundIsolate();
    Wakelock.disable();
  }
}
