import 'package:get/get.dart';

import 'package:xlist/storages/index.dart';

class SettingDocumentController extends GetxController {
  // 用户自定义的文档支持类型
  final documentSupportTypes =
      Get.find<PreferencesStorage>().documentSupportTypes.val.obs;

  @override
  void onInit() {
    super.onInit();
  }

  /// 切换文档支持类型
  /// [type] 文档类型
  void toggleDocumentSupportType(String type) {
    final _documentSupportTypes = documentSupportTypes.value;
    _documentSupportTypes.contains(type)
        ? _documentSupportTypes.remove(type)
        : _documentSupportTypes.add(type);

    // 更新偏好设置
    documentSupportTypes.value = _documentSupportTypes;
    documentSupportTypes.refresh();
    Get.find<PreferencesStorage>().documentSupportTypes.val =
        _documentSupportTypes;
  }
}
