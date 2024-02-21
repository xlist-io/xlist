import 'package:get/get.dart';

import 'package:xlist/storages/index.dart';

class SettingAudioController extends GetxController {
  // 用户自定义的音频支持类型
  final audioSupportTypes =
      Get.find<PreferencesStorage>().audioSupportTypes.val.obs;

  @override
  void onInit() {
    super.onInit();
  }

  /// 切换音频支持类型
  /// [type] 音频类型
  void toggleAudioSupportType(String type) {
    final _audioSupportTypes = audioSupportTypes.value;
    _audioSupportTypes.contains(type)
        ? _audioSupportTypes.remove(type)
        : _audioSupportTypes.add(type);

    // 更新偏好设置
    audioSupportTypes.value = _audioSupportTypes;
    audioSupportTypes.refresh();
    Get.find<PreferencesStorage>().audioSupportTypes.val = _audioSupportTypes;
  }
}
