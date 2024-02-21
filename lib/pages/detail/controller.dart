import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';

import 'package:xlist/common/index.dart';
import 'package:xlist/models/index.dart';
import 'package:xlist/services/index.dart';
import 'package:xlist/storages/index.dart';
import 'package:xlist/repositorys/index.dart';
import 'package:xlist/pages/homepage/index.dart';
import 'package:xlist/database/entity/index.dart';

class DetailController extends GetxController {
  final userInfo = UserModel().obs; // 用户信息
  final objects = <ObjectModel>[].obs; // Object 数据
  final isFirstLoading = true.obs; // 是否是第一次加载
  final serverId = Get.find<UserStorage>().serverId.val;
  final sortType = Get.find<PreferencesStorage>().sortType.val.obs; // 排序方式
  final layoutType = Get.find<PreferencesStorage>().layoutType.val.obs; // 布局方式

  // 显示预览图
  final isShowPreview = Get.find<PreferencesStorage>().isShowPreview.val.obs;

  // 获取参数
  final String path = Get.arguments['path'];
  final String name = Get.arguments['name'];

  // ScrollController
  final ScrollController scrollController = ScrollController();
  EasyRefreshController easyRefreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  // 目录密码
  String password = '';

  @override
  void onInit() async {
    super.onInit();

    // 获取目录密码
    final passwordManager = await DatabaseService.to.database.passwordManagerDao
        .findPasswordManagerByPath(serverId, '${path}${name}');
    if (passwordManager != null && passwordManager.isNotEmpty) {
      password = passwordManager.last.password;
    }

    // 获取用户信息
    try {
      userInfo.value = await UserRepository.me();
    } catch (e) {}

    // 加载完成
    await getObjectList();
    isFirstLoading.value = false;

    // 绑定进度监听
    DownloadService.to.bindBackgroundIsolate((id, status, progress) {});
  }

  /// 获取对象列表
  Future<void> getObjectList({bool refresh = false}) async {
    try {
      final response = await ObjectRepository.getList(
        path: '${path}${name}',
        password: password,
        refresh: refresh,
      );

      // 未登录, 强制刷新 token
      if (response['code'] == 401) {
        final server = await DatabaseService.to.database.serverDao
            .findServerById(serverId);
        if (server != null) {
          userInfo.value = await Get.find<HomepageController>()
              .resetUserToken(server, force: true);
          await getObjectList(refresh: refresh);
          return;
        }
      }

      // 权限校验
      if (response['code'] == 403) {
        final text = await showTextInputDialog(
          context: Get.context!,
          title: 'detail_dialog_password_title'.tr,
          message: 'detail_dialog_password_message'.tr,
          okLabel: 'confirm'.tr,
          cancelLabel: 'cancel'.tr,
          textFields: [
            DialogTextField(hintText: 'detail_dialog_password_hint'.tr),
          ],
        );
        if (text == null) {
          Get.back();
          return;
        }

        // 更新本地数据库密码
        await DatabaseService.to.database.passwordManagerDao
            .insertPasswordManager(
          PasswordManagerEntity(
              serverId: serverId, path: '${path}${name}', password: text.first),
        );

        password = text.first;
        await getObjectList(refresh: refresh);
        return;
      }

      // 格式化数据
      final data = FsListModel.fromJson(response['data']);

      // 排序
      final _list =
          CommonUtils.sortObjectList(data.content ?? [], sortType.value);

      objects.clear(); // 清空数据
      objects.addAll(_list);
      objects.refresh(); // 刷新数据
    } catch (e) {}
  }

  @override
  void onClose() {
    super.onClose();

    // 解绑进度监听
    DownloadService.to.unbindBackgroundIsolate();
  }
}
