import 'package:get/get.dart';

import 'package:xlist/pages/file/index.dart';

class FileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FileController>(() => FileController());
  }
}
