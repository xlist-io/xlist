import 'package:get/get.dart';

import 'package:xlist/pages/setting/preview/image/index.dart';

class SettingImageBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SettingImageController>(SettingImageController());
  }
}
