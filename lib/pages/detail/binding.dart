import 'package:get/get.dart';

import 'package:xlist/pages/detail/index.dart';

class DetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailController>(() => DetailController());
  }
}
