import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:easy_refresh/easy_refresh.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:xlist/models/user.dart';
import 'package:xlist/common/index.dart';
import 'package:xlist/models/index.dart';
import 'package:xlist/services/index.dart';
import 'package:xlist/storages/index.dart';
import 'package:xlist/repositorys/index.dart';
import 'package:xlist/database/entity/index.dart';

class HomepageController extends GetxController {
  final userInfo = UserModel().obs; // 用户信息
  final objects = <ObjectModel>[].obs; // Object 数据
  final isFirstLoading = true.obs; // 是否是第一次加载
  final serverId = Get.find<UserStorage>().serverId.val.obs;
  final sortType = Get.find<PreferencesStorage>().sortType.val.obs; // 排序方式
  final layoutType = Get.find<PreferencesStorage>().layoutType.val.obs; // 布局方式

  // 显示预览图
  final isShowPreview = Get.find<PreferencesStorage>().isShowPreview.val.obs;

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

    // 获取服务器信息
    final server = await DatabaseService.to.database.serverDao
        .findServerById(serverId.value);
    if (server != null) {
      await resetUserToken(server);

      // 获取目录密码
      final passwordManager = await DatabaseService
          .to.database.passwordManagerDao
          .findPasswordManagerByPath(server.id!, '/');
      if (passwordManager != null && passwordManager.isNotEmpty) {
        password = passwordManager.last.password;
      }

      // 获取数据
      await getObjectList();
    }

    // 加载完成
    isFirstLoading.value = false;

    // 绑定进度监听
    DownloadService.to.bindBackgroundIsolate((id, status, progress) {});
  }

  /// 获取对象列表
  Future<void> getObjectList({bool refresh = false}) async {
    try {
      final response = await ObjectRepository.getList(
        path: '/',
        password: password,
        refresh: refresh,
      );

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
        if (text == null) return;

        // 更新本地数据库密码
        await DatabaseService.to.database.passwordManagerDao
            .insertPasswordManager(PasswordManagerEntity(
                serverId: serverId.value, path: '/', password: text.first));

        // 重新获取数据
        password = text.first;
        await getObjectList();
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

  /// 重置用户 token
  /// 用于切换服务器后，重置用户 token
  /// [server] 服务器信息
  /// [force] 是否强制刷新
  Future<UserModel> resetUserToken(
    ServerEntity server, {
    bool force = false,
  }) async {
    try {
      userInfo.value = await UserRepository.me();
    } catch (e) {}

    // 如果可以获取到用户信息, 不需要重新获取 token
    final userId = Get.find<UserStorage>().id.val;
    if (userInfo.value.id != null &&
        userInfo.value.id.toString() == userId &&
        !force) {
      return userInfo.value;
    }

    String token = '';
    UserModel _userInfo = UserModel();
    try {
      Response response = await Repository.post(
        '${server.url}/api/auth/login',
        data: {'username': server.username, 'password': server.password},
      );

      // 2FA 验证
      if (response.data['code'] == 402) {
        SmartDialog.dismiss();
        final data = await showTextInputDialog(
          context: Get.context!,
          title: 'add_server_dialog_2fa_title'.tr,
          okLabel: 'confirm'.tr,
          cancelLabel: 'cancel'.tr,
          textFields: [
            DialogTextField(hintText: 'add_server_dialog_2fa_hint'.tr),
          ],
        );
        if (data == null || data.isEmpty) return _userInfo;
        if (data.first.isEmpty) return _userInfo;

        // 重新获取 token
        response = await Repository.post(
          '${server.url}/api/auth/login',
          data: {
            'username': server.username,
            'password': server.password,
            'otp_code': data.first
          },
        );
      }

      if (response.data['code'] != 200) {
        throw Exception(response.data['message']);
      }

      token = response.data['data']['token'];
    } catch (e) {}

    // 更新 token
    Get.find<UserStorage>().token.val = token;

    // 获取用户信息
    try {
      _userInfo = await UserRepository.me();
      Get.find<UserStorage>().id.val = userInfo.value.id.toString();
    } catch (e) {
      SmartDialog.showToast(e.toString());
    }

    // 更新用户信息
    if (_userInfo.id != null) userInfo.value = _userInfo;
    return _userInfo;
  }

  @override
  void onClose() {
    super.onClose();

    // 解绑进度监听
    DownloadService.to.unbindBackgroundIsolate();
  }
}
