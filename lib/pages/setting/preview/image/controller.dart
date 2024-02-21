import 'package:get/get.dart';

import 'package:xlist/storages/index.dart';

class SettingImageController extends GetxController {
  // 用户自定义的图片支持类型
  final imageSupportTypes =
      Get.find<PreferencesStorage>().imageSupportTypes.val.obs;

  @override
  void onInit() {
    super.onInit();
  }

  /// 切换图片支持类型
  /// [type] 图片类型
  void toggleImageSupportType(String type) {
    final _imageSupportTypes = imageSupportTypes.value;
    _imageSupportTypes.contains(type)
        ? _imageSupportTypes.remove(type)
        : _imageSupportTypes.add(type);

    // 更新偏好设置
    imageSupportTypes.value = _imageSupportTypes;
    imageSupportTypes.refresh();
    Get.find<PreferencesStorage>().imageSupportTypes.val = _imageSupportTypes;
  }
}
