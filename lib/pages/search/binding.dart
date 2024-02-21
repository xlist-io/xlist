import 'package:get/get.dart';

import 'package:xlist/pages/search/index.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchController>(() => SearchController());
  }
}
