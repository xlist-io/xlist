import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:audio_wave/audio_wave.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:xlist/gen/index.dart';
import 'package:xlist/helper/index.dart';
import 'package:xlist/common/index.dart';
import 'package:xlist/storages/index.dart';
import 'package:xlist/pages/video_player/index.dart';
import 'package:xlist/components/fijkplayer/default_panel.dart';

class VideoPlayerPage extends GetView<VideoPlayerController> {
  const VideoPlayerPage({Key? key}) : super(key: key);

  /// 构建下拉按钮
  Widget _buildPullDownButton() {
    List<PullDownMenuEntry> items = [];

    // 收藏
    items.add(PullDownMenuItem(
      title: 'favorite'.tr,
      onTap: () => controller.favorite(),
    ));

    // 切换字幕
    if (controller.subtitleNameList.isNotEmpty ||
        controller.timedTextTracks.isNotEmpty) {
      items.add(PullDownMenuItem(
        title: 'video_switch_subtitle'.tr,
        onTap: () => controller.changeSubtitle(),
      ));
    }

    // 切换音轨
    if (controller.audioTracks.isNotEmpty &&
        controller.audioTracks.length > 1) {
      items.add(PullDownMenuItem(
        title: 'video_switch_audio'.tr,
        onTap: () => controller.changeAudioTrack(),
      ));
    }

    items.addAll([
      PullDownMenuItem(
        title: 'pull_down_copy_link'.tr,
        onTap: () => controller.copyLink(),
      ),
      PullDownMenuItem(
        title: 'pull_down_download_file'.tr,
        onTap: () => controller.download(),
      ),
    ]);

    return PullDownButton(
      itemBuilder: (context) => items,
      buttonBuilder: (context, showMenu) => CupertinoButton(
        onPressed: showMenu,
        padding: EdgeInsets.zero,
        alignment: Alignment.centerRight,
        child: Icon(
          CupertinoIcons.ellipsis_circle,
          size: CommonUtils.navIconSize,
        ),
      ),
    );
  }

  // NavigationBar
  CupertinoNavigationBar _buildNavigationBar() {
    return CupertinoNavigationBar(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      border: Border.all(width: 0, color: Colors.transparent),
      leading: CommonUtils.backButton,
      middle: Obx(
        () => Text(
          CommonUtils.formatFileNme(controller.currentName.value),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing: Obx(() => _buildPullDownButton()),
    );
  }

  /// FijkView
  /// [imageProvider] 视频封面
  Widget _buildFijkView({ImageProvider? imageProvider}) {
    // 音频封面特殊处理一下
    if (imageProvider == null && PreviewHelper.isAudio(controller.name)) {
      imageProvider = Assets.common.logo.image().image;
    }

    return FijkView(
      player: controller.player,
      key: controller.fijkViewKey,
      cover: imageProvider,
      fit: FijkFit.cover,
      color: Colors.black,
      panelBuilder: (FijkPlayer player, FijkData data, BuildContext context,
          Size viewSize, Rect texturePos) {
        return Obx(
          () => FijkDefaultPanel(
            player: player,
            buildContext: context,
            viewSize: viewSize,
            texturePos: texturePos,
            subtitles: controller.subtitles.value,
            subtitleNameList: controller.subtitleNameList.value,
            audioTracks: controller.audioTracks.value,
            timedTextTracks: controller.timedTextTracks.value,
            showPlaylist: controller.showPlaylist.value,
            showTimedText: controller.showTimedText.value,
            playerTitle: controller.currentName.value,
          ),
        );
      },
    );
  }

  // 视频播放器
  Widget _buildVideoPlayer() {
    if (controller.thumbnail.isEmpty) return _buildFijkView();
    return CachedNetworkImage(
      imageUrl: controller.thumbnail.value,
      cacheKey: '${controller.path}${controller.name}',
      httpHeaders: controller.httpHeaders,
      imageBuilder: (context, imageProvider) =>
          _buildFijkView(imageProvider: imageProvider),
      errorWidget: (context, url, error) => _buildFijkView(),
    );
  }

  /// ListTile
  /// [title] 标题
  /// [additionalInfo] 右侧信息
  Widget _buildListTile({
    required String title,
    required String additionalInfo,
  }) {
    return CupertinoListTile(
      title: Text(title, style: Get.textTheme.bodyLarge),
      padding: CommonUtils.isPad
          ? EdgeInsets.only(left: 10, right: 10)
          : EdgeInsets.only(left: 40.w, right: 30.w),
      additionalInfo: Container(
        width: MediaQuery.of(Get.context!).orientation == Orientation.portrait
            ? 500.w
            : 150.w,
        alignment: Alignment.centerRight,
        child: Text(
          additionalInfo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Get.textTheme.bodyLarge?.copyWith(color: Colors.grey),
        ),
      ),
    );
  }

  // 简介
  Widget _buildDescription() {
    // 去除最后一个 /
    String path = controller.path;
    if (path != '/' && controller.path.endsWith('/')) {
      path = controller.path.substring(0, controller.path.length - 1);
    }

    // 文件大小
    final filesize = CommonUtils.formatFileSize(controller.object.value.size!);

    // 文件类型
    final fileType = p
        .extension(controller.currentName.value)
        .replaceAll('.', '')
        .toUpperCase();

    // 格式化时间
    final modified = controller.object.value.modified == null
        ? '-'
        : Jiffy.parseFromDateTime(controller.object.value.modified!)
            .format(pattern: 'yyyy/MM/dd');

    // 挂载类型
    final provider = controller.object.value.provider == null
        ? '-'
        : controller.object.value.provider;

    // 是否是横屏
    final isLandscape =
        MediaQuery.of(Get.context!).orientation == Orientation.landscape;

    return SingleChildScrollView(
      child: Column(
        children: [
          isLandscape
              ? Container()
              : Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                          horizontal: isLandscape ? 10.w : 35.w, vertical: 30.h)
                      .copyWith(top: 35.h),
                  child: Text(
                    CommonUtils.formatFileNme(controller.currentName.value),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Get.textTheme.bodyLarge,
                  ),
                ),
          CupertinoListSection.insetGrouped(
            backgroundColor: CommonUtils.backgroundColor,
            dividerMargin: 0.w,
            additionalDividerMargin: 0.w,
            margin: EdgeInsets.symmetric(
                    horizontal: isLandscape ? 10.w : 30.w, vertical: 10.h)
                .copyWith(bottom: 50.h),
            hasLeading: false,
            children: [
              _buildListTile(title: 'directory'.tr, additionalInfo: path),
              _buildListTile(title: 'mount_type'.tr, additionalInfo: provider!),
              _buildListTile(title: 'modify_time'.tr, additionalInfo: modified),
              _buildListTile(title: 'file_type'.tr, additionalInfo: fileType),
              _buildListTile(title: 'file_size'.tr, additionalInfo: filesize),
            ],
          )
        ],
      ),
    );
  }

  // 播放列表
  Widget _buildPlayList() {
    return ListView.separated(
      shrinkWrap: true,
      separatorBuilder: (context, index) => Divider(
        height: 0.5,
        indent: CommonUtils.isPad ? 10 : 30.w,
        endIndent: CommonUtils.isPad ? 10 : 30.w,
      ),
      itemCount: controller.objects.length,
      itemBuilder: (context, index) {
        final object = controller.objects[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 播放模式按钮切换
            index == 0 && controller.showPlaylist.isTrue
                ? _buildPlayModeButton()
                : SizedBox.shrink(),
            CupertinoListTile(
              title: Container(
                width: 800.w,
                child: Text(
                  CommonUtils.formatFileNme(object.name!),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Get.textTheme.bodyLarge,
                ),
              ),
              trailing: index == controller.currentIndex.value
                  ? _buildPlayIcon()
                  : null,
              onTap: () => controller.changePlaylist(index),
            ),
          ],
        );
      },
    );
  }

  /// 播放模式按钮 - 列表循环, 单集循环, 播完暂停
  Widget _buildPlayModeButton() {
    final isLandscape =
        MediaQuery.of(Get.context!).orientation == Orientation.landscape;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: CommonUtils.isPad ? 0 : 30.w,
        vertical: isLandscape ? 20.h : 30.h,
      ),
      child: ToggleSwitch(
        customWidths: [50, 50, 50],
        inactiveBgColor: CommonUtils.backgroundColor,
        cornerRadius: 15,
        initialLabelIndex: controller.playMode.val,
        totalSwitches: 3,
        labels: ['', '', ''],
        customIcons: [
          Icon(CupertinoIcons.repeat, size: 20),
          Icon(CupertinoIcons.repeat_1, size: 20),
          Icon(CupertinoIcons.stop_circle, size: 20),
        ],
        onToggle: (index) {
          controller.playMode.val = index!;
        },
      ),
    );
  }

  // 正在播放动画
  Widget _buildPlayIcon() {
    final bar =
        (f) => AudioWaveBar(heightFactor: f, color: Get.theme.primaryColor);

    // 是否是横屏
    final isLandscape =
        MediaQuery.of(Get.context!).orientation == Orientation.landscape;

    return AudioWave(
      height: 60.r,
      width: 60.r,
      spacing: CommonUtils.isPad && !isLandscape ? 3.5 : 1.5,
      animationLoop: 3,
      beatRate: Duration(milliseconds: 150),
      bars: [bar(0.0), bar(0.3), bar(0.5), bar(0.3), bar(0.7), bar(0.2)],
    );
  }

  // 竖屏信息
  Widget _buildPortraitInfo(Widget videoPlayer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            height: CommonUtils.isPad ? 700.h : 520.h, child: videoPlayer),
        Container(
          constraints: BoxConstraints.expand(height: 120.h),
          child: TabBar(
            tabs: [
              Tab(text: 'video_tab_introduction'.tr),
              Tab(text: 'video_tab_playlist'.tr),
            ],
            labelColor: Get.textTheme.bodyLarge?.color,
            unselectedLabelColor: Get.textTheme.bodyLarge?.color,
            indicatorColor: Get.theme.primaryColor,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 5.r,
            labelStyle: Get.textTheme.titleMedium,
            unselectedLabelStyle: Get.textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: Container(
            child: TabBarView(
              children: [
                _buildDescription(),
                _buildPlayList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 横屏页面信息
  Widget _buildLandscapeInfo(Widget videoPlayer) {
    return Row(
      children: [
        Container(width: 780.w, child: videoPlayer),
        Expanded(
          child: Column(
            children: [
              SizedBox(height: 30.h),
              _buildDescription(),
              Divider(height: 1.r, indent: 10, endIndent: 10),
              SizedBox(height: 20.h),
              Expanded(child: _buildPlayList()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPageInfo() {
    if (controller.object.value.rawUrl == null) {
      return Column(
        children: [
          SizedBox(height: 600.h),
          Center(child: CupertinoActivityIndicator()),
        ],
      );
    }

    final videoPlayer = _buildVideoPlayer();
    return OrientationBuilder(
      builder: (context, orientation) {
        return Obx(
          () => orientation == Orientation.portrait
              ? DefaultTabController(
                  length: 2,
                  child: _buildPortraitInfo(videoPlayer),
                )
              : _buildLandscapeInfo(videoPlayer),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: _buildNavigationBar(),
      backgroundColor: CommonUtils.backgroundColor,
      child: Obx(() => _buildPageInfo()),
    );
  }
}
