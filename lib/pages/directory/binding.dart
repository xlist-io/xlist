import 'package:get/get.dart';

import 'package:xlist/pages/directory/index.dart';

class DirectoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DirectoryController>(() => DirectoryController());
  }
}
