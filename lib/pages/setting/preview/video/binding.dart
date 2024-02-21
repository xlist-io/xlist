import 'package:get/get.dart';

import 'package:xlist/pages/setting/preview/video/index.dart';

class SettingVideoBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SettingVideoController>(SettingVideoController());
  }
}
