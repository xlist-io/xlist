import 'package:get/get.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:xlist/models/index.dart';
import 'package:xlist/storages/index.dart';
import 'package:xlist/routes/app_pages.dart';
import 'package:xlist/pages/setting/index.dart';
import 'package:xlist/pages/homepage/index.dart';
import 'package:xlist/database/entity/index.dart';
import 'package:xlist/services/database_service.dart';

class ServerController extends GetxController {
  final serverList = <ServerEntity>[].obs;
  final isFirstLoading = true.obs; // 是否是第一次加载
  final serverId = Get.find<UserStorage>().serverId.val.obs;
  final _homepageController = Get.find<HomepageController>();
  final _settingController = Get.find<SettingController>();

  @override
  void onInit() async {
    super.onInit();

    // 获取服务器信息
    serverList.value =
        await DatabaseService.to.database.serverDao.findAllServer();

    // 加载完成
    isFirstLoading.value = false;
  }

  /// 获取服务器列表
  void getServerList() async {
    serverList.value =
        await DatabaseService.to.database.serverDao.findAllServer();
  }

  /// 切换服务器
  void switchServer(ServerEntity server) async {
    final ok = await showOkCancelAlertDialog(
      context: Get.context!,
      title: 'dialog_prompt_title'.tr,
      message: 'dialog_switch_message'.tr,
      okLabel: 'confirm'.tr,
      cancelLabel: 'cancel'.tr,
    );
    if (ok != OkCancelResult.ok) return;

    // 本地用户信息
    final userStorage = Get.find<UserStorage>();

    // 获取当前服务器信息
    final token = userStorage.token.val;
    final serverId = userStorage.serverId.val;
    final serverUrl = userStorage.serverUrl.val;

    try {
      SmartDialog.showLoading();
      userStorage.token.val = '';
      userStorage.serverId.val = server.id!;
      userStorage.serverUrl.val = server.url;

      // 重置首页信息
      _homepageController.serverId.value = server.id!;

      // 用户信息
      final userInfo =
          await _homepageController.resetUserToken(server, force: true);
      if (userInfo.id == null) throw 'toast_get_user_info_fail'.tr;

      _homepageController.getObjectList();
      Get.until((route) => Get.currentRoute == Routes.HOMEPAGE);

      // 重置设置页面信息
      _settingController.serverId.value = server.id!;
      _settingController.serverInfo.value = server;

      SmartDialog.dismiss();
      SmartDialog.showToast('toast_switch_success'.tr);
    } catch (e) {
      userStorage.token.val = token;
      userStorage.serverId.val = serverId;
      userStorage.serverUrl.val = serverUrl;
      _homepageController.serverId.value = serverId;
      SmartDialog.dismiss();
      SmartDialog.showToast(e.toString());
    }
  }

  /// 删除服务器
  void deleteServer(int id) async {
    final ok = await showOkCancelAlertDialog(
      context: Get.context!,
      title: 'dialog_prompt_title'.tr,
      message: 'dialog_remove_message'.tr,
      okLabel: 'confirm'.tr,
      cancelLabel: 'cancel'.tr,
    );
    if (ok != OkCancelResult.ok) return;

    // 删除数据
    await DatabaseService.to.database.serverDao.deleteServerById(id);
    await DatabaseService.to.database.recentDao.deleteRecentByServerId(id);
    await DatabaseService.to.database.progressDao.deleteProgressByServerId(id);
    await DatabaseService.to.database.passwordManagerDao
        .deletePasswordManagerByServerId(id);

    // 删除本地数据
    if (serverId.value == id) {
      Get.find<UserStorage>().id.val = '';
      Get.find<UserStorage>().token.val = '';
      Get.find<UserStorage>().serverId.val = 0;
      Get.find<UserStorage>().serverUrl.val = '';
      serverId.value = 0;
    }

    // 如果删除的是当前服务器
    if (_homepageController.serverId.value == id) {
      _homepageController.serverId.value = 0;
      _homepageController.userInfo.value = UserModel();
      _homepageController.objects.clear();
    }

    // 设置页面
    if (_settingController.serverId.value == id) {
      _settingController.serverId.value = 0;
      _settingController.serverInfo.value =
          ServerEntity(url: '', type: 0, username: '', password: '');
    }

    getServerList();
  }
}
