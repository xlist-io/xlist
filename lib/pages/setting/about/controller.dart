import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutController extends GetxController {
  final version = ''.obs; // 版本号
  final showVersion = true.obs; // 显示版本号
  final isStoreChannel = false.obs; // 是否应用商店渠道

  @override
  void onInit() async {
    super.onInit();

    final packageInfo = await PackageInfo.fromPlatform();
    version.value = packageInfo.version;
  }
}
