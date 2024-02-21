part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  // notfound
  static const NOTFOUND = _Paths.NOTFOUND;

  static const SPLASH = _Paths.SPLASH;
  static const HOMEPAGE = _Paths.HOMEPAGE;
  static const DETAIL = _Paths.DETAIL;
  static const SEARCH = _Paths.SEARCH;
  static const DIRECTORY = _Paths.DIRECTORY;
  static const DOCUMENT = _Paths.DOCUMENT;
  static const FILE = _Paths.FILE;
  static const IMAGE_PREVIEW = _Paths.IMAGE_PREVIEW;
  static const VIDEO_PLAYER = _Paths.VIDEO_PLAYER;
  static const AUDIO_PLAYER = _Paths.AUDIO_PLAYER;

  // Settings
  static const SETTING = _Paths.SETTING;
  static const SETTING_SERVER = _Paths.SETTING + _Paths.SERVER;
  static const SETTING_DOWNLOAD = _Paths.SETTING + _Paths.DOWNLOAD;
  static const SETTING_ABOUT = _Paths.SETTING + _Paths.ABOUT;
  static const SETTING_RECENT = _Paths.SETTING + _Paths.RECENT;
  static const SETTING_FAVORITE = _Paths.SETTING + _Paths.FAVORITE;
  static const SETTING_PREVIEW_IMAGE = _Paths.SETTING + _Paths.PREVIEW_IMAGE;
  static const SETTING_PREVIEW_AUDIO = _Paths.SETTING + _Paths.PREVIEW_AUDIO;
  static const SETTING_PREVIEW_VIDEO = _Paths.SETTING + _Paths.PREVIEW_VIDEO;
  static const SETTING_PREVIEW_DOCUMENT =
      _Paths.SETTING + _Paths.PREVIEW_DOCUMENT;
}

abstract class _Paths {
  static const SPLASH = '/';
  static const NOTFOUND = '/notfound';
  static const HOMEPAGE = '/homepage';
  static const DETAIL = '/detail';
  static const SEARCH = '/search';
  static const DIRECTORY = '/directory';
  static const DOCUMENT = '/document';
  static const FILE = '/file';
  static const IMAGE_PREVIEW = '/image/preview';
  static const VIDEO_PLAYER = '/video/player';
  static const AUDIO_PLAYER = '/audio/player';

  // Settings
  static const SETTING = '/setting';
  static const SERVER = '/server';
  static const DOWNLOAD = '/download';
  static const ABOUT = '/about';
  static const RECENT = '/recent';
  static const FAVORITE = '/favorite';
  static const PREVIEW_IMAGE = '/preview/image';
  static const PREVIEW_AUDIO = '/preview/audio';
  static const PREVIEW_VIDEO = '/preview/video';
  static const PREVIEW_DOCUMENT = '/preview/document';
}
