import 'package:get/get.dart';

import 'package:xlist/storages/index.dart';

class SettingVideoController extends GetxController {
  // 用户自定义的视频支持类型
  final videoSupportTypes =
      Get.find<PreferencesStorage>().videoSupportTypes.val.obs;

  @override
  void onInit() {
    super.onInit();
  }

  /// 切换视频支持类型
  /// [type] 视频类型
  void toggleVideoSupportType(String type) {
    final _videoSupportTypes = videoSupportTypes.value;
    _videoSupportTypes.contains(type)
        ? _videoSupportTypes.remove(type)
        : _videoSupportTypes.add(type);

    // 更新偏好设置
    videoSupportTypes.value = _videoSupportTypes;
    videoSupportTypes.refresh();
    Get.find<PreferencesStorage>().videoSupportTypes.val = _videoSupportTypes;
  }
}
