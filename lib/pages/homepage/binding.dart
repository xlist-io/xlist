import 'package:get/get.dart';

import 'package:xlist/pages/homepage/index.dart';

class HomepageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomepageController>(() => HomepageController());
  }
}
