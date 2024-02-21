import 'package:get/get.dart';

import 'package:xlist/pages/splash/index.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SplashController>(SplashController());
  }
}
