import 'package:get/get.dart';

import 'package:xlist/pages/setting/download/index.dart';

class DownloadBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DownloadController>(() => DownloadController());
  }
}
