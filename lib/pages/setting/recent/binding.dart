import 'package:get/get.dart';

import 'package:xlist/pages/setting/recent/index.dart';

class RecentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RecentController>(() => RecentController());
  }
}
