import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:xlist/storages/index.dart';
import 'package:xlist/constants/index.dart';
import 'package:xlist/database/entity/index.dart';
import 'package:xlist/services/database_service.dart';

class SettingController extends GetxController {
  final version = ''.obs; // 版本号
  final serverId = Get.find<UserStorage>().serverId.val.obs;
  final serverInfo =
      ServerEntity(url: '', type: 0, username: '', password: '').obs;

  // 自动播放
  final isAutoPlay = Get.find<PreferencesStorage>().isAutoPlay.val.obs;

  // 后台播放
  final isBackgroundPlay =
      Get.find<PreferencesStorage>().isBackgroundPlay.val.obs;

  // 硬件解码
  final isHardwareDecode =
      Get.find<PreferencesStorage>().isHardwareDecode.val.obs;

  // 显示预览图
  final isShowPreview = Get.find<PreferencesStorage>().isShowPreview.val.obs;

  // 主题
  final themeModeText = ''.obs;
  final InAppReview inAppReview = InAppReview.instance;

  @override
  void onInit() async {
    super.onInit();

    // 获取当前版本号
    final packageInfo = await PackageInfo.fromPlatform();
    version.value = packageInfo.version;

    // 获取当前服务器信息
    serverInfo.value = (await DatabaseService.to.database.serverDao
            .findServerById(serverId.value)) ??
        ServerEntity(url: '', type: 0, username: '无', password: '');

    // 获取当前主题模式
    themeModeText.value =
        ThemeModeTextMap[Get.find<CommonStorage>().themeMode.val]!;
  }

  /// 更换主题
  void changeTheme() async {
    final value = await showModalActionSheet(
      context: Get.overlayContext!,
      actions: [
        SheetAction(label: '跟随系统', key: 'system'),
        SheetAction(label: '明亮', key: 'light'),
        SheetAction(label: '深邃', key: 'dark'),
      ],
      cancelLabel: '取消',
    );

    if (value != null) {
      Get.changeThemeMode(ThemeModeMap[value]!);
      themeModeText.value = ThemeModeTextMap[value]!;
      Get.find<CommonStorage>().themeMode.val = value;
      Future.delayed(Duration(milliseconds: 200), () {
        Get.forceAppUpdate();
      });
    }
  }
}
