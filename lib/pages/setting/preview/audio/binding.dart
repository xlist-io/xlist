import 'package:get/get.dart';

import 'package:xlist/pages/setting/preview/audio/index.dart';

class SettingAudioBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SettingAudioController>(SettingAudioController());
  }
}
