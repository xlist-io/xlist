import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:xlist/helper/index.dart';

/// 页面来源
class PageSource {
  static const HOMEPAGE = 'homepage';
  static const DETAIL = 'detail';
  static const DIRECTORY = 'directory';
}

/// 服务器类型
class ServerType {
  static const ALIST = 0;
  static const FTP = 1;
  static const SFTP = 2;
  static const SMB = 3;
}

/// 排序类型
class SortType {
  static const TIME_DESC = 0;
  static const TIME_ASC = 1;
  static const NAME_DESC = 2;
  static const NAME_ASC = 3;
}

/// 播放模式
class PlayMode {
  static const LIST_LOOP = 0;
  static const SINGLE_LOOP = 1;
  static const PLAY_PAUSE = 2;
  static const SHUFFLE = 3;

  static const playModeIcons = {
    PlayMode.LIST_LOOP: CupertinoIcons.repeat,
    PlayMode.SINGLE_LOOP: CupertinoIcons.repeat_1,
    PlayMode.PLAY_PAUSE: CupertinoIcons.stop_circle,
    PlayMode.SHUFFLE: CupertinoIcons.shuffle
  };

  static getIcon(int mode) {
    return playModeIcons[mode];
  }
}

/// 布局方式
class LayoutType {
  static const UNKNOWN = 0;
  static const LIST = 1;
  static const GRID = 2;
}

/// 文件类型
class FileType {
  static const UNKNOWN = 0;
  static const FOLDER = 1;
  static const VIDEO = 2;
  static const AUDIO = 3;
  static const TEXT = 4;
  static const IMAGE = 5;

  /// 获取文件类型图标
  /// [type] 文件类型
  static getIcon(int type, String name) {
    if (type == FileType.FOLDER) return FontAwesomeIcons.solidFolder;
    if (PreviewHelper.isImage(name)) return FontAwesomeIcons.solidFileImage;
    if (PreviewHelper.isVideo(name)) return FontAwesomeIcons.solidFileVideo;
    if (PreviewHelper.isAudio(name)) return FontAwesomeIcons.solidFileAudio;
    if (PreviewHelper.isDocument(name)) return FontAwesomeIcons.solidFileLines;

    return FileTypeIcons[type];
  }
}

/// 文件类型图标
const FileTypeIcons = [
  FontAwesomeIcons.solidFile,
  FontAwesomeIcons.solidFolder,
  FontAwesomeIcons.solidFileVideo,
  FontAwesomeIcons.solidFileAudio,
  FontAwesomeIcons.solidFileLines,
  FontAwesomeIcons.solidFileImage,
];

const ThemeModeMap = {
  'system': ThemeMode.system,
  'light': ThemeMode.light,
  'dark': ThemeMode.dark,
};

const ThemeModeTextMap = {
  'system': '跟随系统',
  'light': '明亮',
  'dark': '深邃',
};

class Provider {
  static const String ALIYUN_DRIVE = 'Aliyundrive';
  static const String BAIDU = 'Baidu';
  static const String Cloud115 = '115';
}

class IjkPlayerTrackType {
  static const int VIDEO = 1;
  static const int AUDIO = 2;
  static const int TIMEDTEXT = 3;
}
