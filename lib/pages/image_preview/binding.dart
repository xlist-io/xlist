import 'package:get/get.dart';

import 'package:xlist/pages/image_preview/index.dart';

class ImagePreviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImagePreviewController>(() => ImagePreviewController());
  }
}
