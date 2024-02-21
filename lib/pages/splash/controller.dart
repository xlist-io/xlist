import 'dart:async';

import 'package:get/get.dart';
import 'package:fijkplayer/fijkplayer.dart';

import 'package:xlist/common/index.dart';
import 'package:xlist/storages/index.dart';
import 'package:xlist/constants/index.dart';
import 'package:xlist/routes/app_pages.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();

    // Jump to LandingPage after 10ms
    Timer(const Duration(milliseconds: 10), () => complete());
  }

  void complete() async {
    if (!CommonUtils.isPad) await FijkPlugin.setOrientationPortrait();

    // 布局方式
    final layoutType = Get.find<PreferencesStorage>().layoutType.val;
    if (layoutType == LayoutType.UNKNOWN) {
      Get.find<PreferencesStorage>().layoutType.val =
          CommonUtils.isPad ? LayoutType.GRID : LayoutType.LIST;
    }

    // 跳转到首页
    Get.offAndToNamed(Routes.HOMEPAGE);
  }
}
