import 'package:get/get.dart';

import 'package:xlist/pages/document/index.dart';

class DocumentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DocumentController>(() => DocumentController());
  }
}
