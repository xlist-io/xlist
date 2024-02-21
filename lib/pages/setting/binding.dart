import 'package:get/get.dart';

import 'package:xlist/pages/setting/index.dart';

class SettingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingController>(() => SettingController());
  }
}
