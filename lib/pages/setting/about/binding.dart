import 'package:get/get.dart';

import 'package:xlist/pages/setting/about/index.dart';

class AboutBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AboutController>(AboutController());
  }
}
