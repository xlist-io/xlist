import 'dart:ui';
import 'dart:math';

import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:vivysub_utils/vivysub_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:subtitle_wrapper_package/data/models/subtitle.dart';

import 'package:xlist/models/index.dart';
import 'package:xlist/services/index.dart';
import 'package:xlist/storages/index.dart';
import 'package:xlist/constants/index.dart';
import 'package:xlist/database/entity/index.dart';

// 公共工具类
class CommonUtils {
  /// 格式化文件大小
  /// [size] 文件大小
  static String formatFileSize(int size) {
    if (size < 1024) {
      return '${size}B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(2)}KB';
    } else if (size < 1024 * 1024 * 1024) {
      return '${(size / 1024 / 1024).toStringAsFixed(2)}MB';
    } else {
      return '${(size / 1024 / 1024 / 1024).toStringAsFixed(2)}GB';
    }
  }

  /// 格式化文件名
  /// [name] 文件名
  static String formatFileNme(String name) {
    return p.basenameWithoutExtension(name);
  }

  /// 获取随机数
  ///
  /// [min] 最小值
  /// [max] 最大值
  static randomInt(int min, int max) {
    return min + (max - min) * (Random().nextDouble());
  }

  /// 格式化 ijk track 信息
  /// [track] track 信息
  static String formatIjkTrack(String track) {
    return capitalize(track == 'und' ? '未知' : track);
  }

  /// 首字母大写
  /// [str] 字符串
  static String capitalize(String str) {
    return str.substring(0, 1).toUpperCase() + str.substring(1);
  }

  /// 获取背景颜色
  static Color get backgroundColor => Get.isDarkMode
      ? Color.fromARGB(255, 18, 18, 18)
      : Color.fromARGB(255, 242, 242, 247);

  /// 获取导航栏 icon 大小
  static double get navIconSize => isPad ? 25 : 70.sp;

  /// 是否为平板
  static bool get isPad =>
      DeviceInfoService.to.isIpad ||
      MediaQuery.of(Get.context!).size.shortestSide >= 600;

  /// 获取导航栏返回按钮
  static Widget get backButton => CupertinoButton(
        padding: EdgeInsets.zero,
        alignment: Alignment.centerLeft,
        child: Icon(CupertinoIcons.chevron_back, size: isPad ? 30 : 80.sp),
        onPressed: () => Get.back(),
      );

  /// 获取直链下载地址
  ///
  /// [path]     文件路径
  /// [userInfo] 用户信息
  /// [object]   对象信息
  static String getDownloadLink(
    String path, {
    required ObjectModel object,
    required UserModel userInfo,
  }) {
    String encodePath = '';
    final basePath = userInfo.basePath;
    final serverUrl = Get.find<UserStorage>().serverUrl.val;

    // encode path
    '${basePath}${path}${object.name}'.split('/').forEach((v) {
      if (v.isNotEmpty) encodePath += '/${Uri.encodeComponent(v)}';
    });

    // 获取签名
    final sign = (object.sign != null && object.sign!.isNotEmpty)
        ? '?sign=${object.sign}'
        : '';

    return '${serverUrl}/d${encodePath}${sign}';
  }

  /// 排序对象列表
  /// [list] 对象列表
  /// [sortType] 排序方式
  static sortObjectList(List<ObjectModel> list, int sortType) {
    // 获取所有文件夹 & 文件
    final folders = <ObjectModel>[];
    final files = <ObjectModel>[];

    // 优化文件类型提取
    for (final value in list) {
      value.type == FileType.FOLDER ? folders.add(value) : files.add(value);
    }

    // 时间降序
    if (sortType == SortType.TIME_DESC) {
      folders.sort((a, b) => b.modified!.compareTo(a.modified!));
      files.sort((a, b) => b.modified!.compareTo(a.modified!));
    }

    // 时间升序
    if (sortType == SortType.TIME_ASC) {
      folders.sort((a, b) => a.modified!.compareTo(b.modified!));
      files.sort((a, b) => a.modified!.compareTo(b.modified!));
    }

    // 名称降序
    if (sortType == SortType.NAME_DESC) {
      folders.sort((a, b) => b.name!.compareTo(a.name!));
      files.sort((a, b) => b.name!.compareTo(a.name!));
    }

    // 名称升序
    if (sortType == SortType.NAME_ASC) {
      folders.sort((a, b) => a.name!.compareTo(b.name!));
      files.sort((a, b) => a.name!.compareTo(b.name!));
    }

    return [...folders, ...files];
  }

  /// ass to srt
  /// [content] 字幕内容
  static Future<List<Subtitle>> ass2srt(String content) async {
    final assParser = AssParser(content: content); // 解析 ass

    // 字幕
    List<Subtitle> subtitles = [];
    List<Section> sections = assParser.getSections();

    // 循环处理字幕数据
    for (var section in sections) {
      if (section.name != '[Events]') continue;

      for (var entity in section.body.sublist(1)) {
        final value = entity.value['value'];
        if (value['Start'] == null || value['End'] == null) continue;

        // 正则表达式 匹配时间
        final regExp =
            RegExp(r'(\d{1,2}):(\d{2}):(\d{2})\.(\d+)', caseSensitive: false);

        // 开始时间
        final startTimeMatch = regExp.allMatches(value['Start']).toList().first;
        final startTimeHours = int.parse(startTimeMatch.group(1)!);
        final startTimeMinutes = int.parse(startTimeMatch.group(2)!);
        final startTimeSeconds = int.parse(startTimeMatch.group(3)!);
        final startTimeMilliseconds =
            int.parse(startTimeMatch.group(4)!.padRight(3, '0'));

        // 结束时间
        final endTimeMatch = regExp.allMatches(value['End']).toList().first;
        final endTimeHours = int.parse(endTimeMatch.group(1)!);
        final endTimeMinutes = int.parse(endTimeMatch.group(2)!);
        final endTimeSeconds = int.parse(endTimeMatch.group(3)!);
        final endTimeMilliseconds =
            int.parse(endTimeMatch.group(4)!.padRight(3, '0'));

        final startTime = Duration(
          hours: startTimeHours,
          minutes: startTimeMinutes,
          seconds: startTimeSeconds,
          milliseconds: startTimeMilliseconds,
        );

        final endTime = Duration(
          hours: endTimeHours,
          minutes: endTimeMinutes,
          seconds: endTimeSeconds,
          milliseconds: endTimeMilliseconds,
        );

        subtitles.add(
          Subtitle(
            startTime: startTime,
            endTime: endTime,
            text: value['Text']
                .toString()
                .replaceAll(RegExp(r'({.+?})'), '')
                .replaceAll('\\N', '\n')
                .trim(),
          ),
        );
      }
    }

    return subtitles;
  }

  /// 加入最近浏览
  /// [object] 对象
  /// [path] 路径
  /// [name] 名称
  static Future<void> addRecent(
    ObjectModel object,
    String path,
    String name,
  ) async {
    final serverId = Get.find<UserStorage>().serverId.val;

    // 查询是否存在
    final recent = await DatabaseService.to.database.recentDao
        .findRecentByServerIdAndPath(serverId, path, name);

    // 更新 or 创建
    if (recent != null) {
      await DatabaseService.to.database.recentDao.updateRecent(
        RecentEntity(
          id: recent.id,
          serverId: serverId,
          path: path,
          name: name,
          type: recent.type,
          size: recent.size,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    } else {
      await DatabaseService.to.database.recentDao.insertRecent(
        RecentEntity(
          serverId: serverId,
          path: path,
          name: name,
          type: object.type!,
          size: object.size!,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }
  }

  /// 加入收藏
  ///
  /// [object] 对象
  /// [path] 路径
  /// [name] 名称
  static Future<void> addFavorite(
    ObjectModel object,
    String path,
    String name,
  ) async {
    final serverId = Get.find<UserStorage>().serverId.val;

    // 查询是否存在
    final favorite = await DatabaseService.to.database.favoriteDao
        .findFavoriteByServerIdAndPath(serverId, path, name);

    // 更新 or 创建
    if (favorite != null) {
      await DatabaseService.to.database.favoriteDao.updateFavorite(
        FavoriteEntity(
          id: favorite.id,
          serverId: serverId,
          path: path,
          name: name,
          type: favorite.type,
          size: favorite.size,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    } else {
      await DatabaseService.to.database.favoriteDao.insertFavorite(
        FavoriteEntity(
          serverId: serverId,
          path: path,
          name: name,
          type: object.type!,
          size: object.size!,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }

    SmartDialog.showToast('toast_favorite_success'.tr);
  }
}
