import 'package:get/get.dart';
import 'package:path/path.dart' as p;

import 'package:xlist/constants/index.dart';
import 'package:xlist/storages/preferences_storage.dart';

class PreviewHelper {
  /// 图片类型是否支持预览
  /// [name] 文件名称
  static bool isImage(String name) {
    final imageSupportTypes =
        Get.find<PreferencesStorage>().imageSupportTypes.val;
    final ext = p.extension(name).replaceAll('.', '').toLowerCase();
    return imageSupportTypes.contains(ext);
  }

  /// 视频类型是否支持预览
  /// [name] 文件名称
  static bool isVideo(String name) {
    final videoSupportTypes =
        Get.find<PreferencesStorage>().videoSupportTypes.val;
    final ext = p.extension(name).replaceAll('.', '').toLowerCase();
    return videoSupportTypes.contains(ext);
  }

  /// 音频类型是否支持预览
  /// [name] 文件名称
  static bool isAudio(String name) {
    final audioSupportTypes =
        Get.find<PreferencesStorage>().audioSupportTypes.val;
    final ext = p.extension(name).replaceAll('.', '').toLowerCase();
    return audioSupportTypes.contains(ext);
  }

  /// 文档类型是否支持预览
  /// [name] 文件名称
  static bool isDocument(String name) {
    final documentSupportTypes =
        Get.find<PreferencesStorage>().documentSupportTypes.val;
    final ext = p.extension(name).replaceAll('.', '').toLowerCase();

    // Android 只支持代码和 pdf 预览
    if (GetPlatform.isAndroid) return isCode(name) || ext == 'pdf';
    return documentSupportTypes.contains(ext);
  }

  /// 代码类型是否支持预览
  /// [name] 文件名称
  static bool isCode(String name) {
    final documentSupportTypes =
        Get.find<PreferencesStorage>().documentSupportTypes.val;

    // 两个数组的交集 kSupportPreviewCodeTypes
    final intersection = documentSupportTypes
        .toSet()
        .intersection(kSupportPreviewCodeTypes.toSet());

    final ext = p.extension(name).replaceAll('.', '').toLowerCase();
    return intersection.contains(ext);
  }

  /// 是否是 HTML
  /// [name] 文件名称
  static bool isHtml(String name) {
    final ext = p.extension(name).replaceAll('.', '').toLowerCase();
    return ext == 'html' || ext == 'htm';
  }
}
