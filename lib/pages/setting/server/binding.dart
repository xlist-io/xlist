import 'package:get/get.dart';

import 'package:xlist/pages/setting/server/index.dart';

class ServerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ServerController>(ServerController());
  }
}
