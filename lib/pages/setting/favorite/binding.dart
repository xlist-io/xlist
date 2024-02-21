import 'package:get/get.dart';

import 'package:xlist/pages/setting/favorite/index.dart';

class FavoriteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FavoriteController>(() => FavoriteController());
  }
}
