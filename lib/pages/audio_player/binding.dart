import 'package:get/get.dart';

import 'package:xlist/pages/audio_player/index.dart';

class AudioPlayerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AudioPlayerController>(() => AudioPlayerController());
  }
}
