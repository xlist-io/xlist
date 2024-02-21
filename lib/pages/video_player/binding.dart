import 'package:get/get.dart';

import 'package:xlist/pages/video_player/index.dart';

class VideoPlayerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VideoPlayerController>(() => VideoPlayerController());
  }
}
