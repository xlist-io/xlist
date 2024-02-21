import 'package:get/get.dart';

import 'package:xlist/pages/setting/preview/document/index.dart';

class SettingDocumentBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SettingDocumentController>(SettingDocumentController());
  }
}
