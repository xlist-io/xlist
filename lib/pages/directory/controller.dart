import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';

import 'package:xlist/models/index.dart';
import 'package:xlist/helper/index.dart';
import 'package:xlist/services/index.dart';
import 'package:xlist/storages/index.dart';
import 'package:xlist/constants/index.dart';
import 'package:xlist/repositorys/index.dart';
import 'package:xlist/database/entity/index.dart';

class DirectoryController extends GetxController {
  final userInfo = UserModel().obs; // 用户信息
  final objects = <ObjectModel>[].obs; // Object 目录数据
  final isFirstLoading = true.obs; // 是否是第一次加载
  final serverId = Get.find<UserStorage>().serverId.val;

  // 显示预览图
  final isShowPreview = Get.find<PreferencesStorage>().isShowPreview.val.obs;

  // 获取参数
  String path = Get.arguments['path'] ?? '/';
  final ObjectModel currentObject = Get.arguments['object'] ?? ObjectModel();
  final String tag = Get.arguments['tag'] ?? '';
  final bool isCopy = Get.arguments['isCopy'] ?? false;
  final bool root = Get.arguments['root'] ?? false;
  final String source = Get.arguments['source'] ?? '';
  final String srcDir = Get.arguments['srcDir'] ?? '';
  final ObjectModel srcObject = Get.arguments['srcObject'] ?? ObjectModel();

  // ScrollController
  final ScrollController scrollController = ScrollController();
  EasyRefreshController easyRefreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  // 目录密码
  String password = '';
  late String pageTitle;

  @override
  void onInit() async {
    super.onInit();

    // 设置页面标题
    pageTitle = root ? 'directory_root_title'.tr : currentObject.name ?? '';

    // 获取目录密码
    final passwordManager = await DatabaseService.to.database.passwordManagerDao
        .findPasswordManagerByPath(serverId, path);
    if (passwordManager != null && passwordManager.isNotEmpty) {
      password = passwordManager.last.password;
    }

    // 获取用户信息
    userInfo.value = await UserRepository.me();
    await getDirectoryList();

    // 加载完成
    isFirstLoading.value = false;
  }

  /// 获取目录列表
  Future<void> getDirectoryList() async {
    try {
      final response =
          await ObjectRepository.getDirs(path: path, password: password);

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
            .insertPasswordManager(PasswordManagerEntity(
                serverId: serverId, path: path, password: text.first));

        password = text.first;
        await getDirectoryList();
        return;
      }

      // 格式化数据
      objects.clear(); // 清空数据
      objects.addAll(formatData(response));
      objects.refresh(); // 刷新数据
    } catch (e) {
      print(e);
    }
  }

  /// 格式化数据
  List<ObjectModel> formatData(dynamic response) {
    final List<FsDirsModel> dirs = [];
    final data = response['data'] ?? [];
    data.map((d) => dirs.add(FsDirsModel.fromJson(d))).toList();

    return dirs
        .map(
          (d) => ObjectModel.fromJson(
            {
              'name': d.name,
              'is_dir': true,
              'type': FileType.FOLDER,
              'size': 0,
              'modified': d.modified?.toIso8601String(),
            },
          ),
        )
        .toList();
  }

  /// 移动和复制
  Future<void> moveOrCopy() async {
    if (isCopy) {
      return await ObjectHelper.copy(
        srcDir: srcDir,
        dstDir: path,
        name: srcObject.name!,
        source: source,
        pageTag: tag,
      );
    }

    // 移动文件
    return await ObjectHelper.move(
      srcDir: srcDir,
      dstDir: path,
      name: srcObject.name!,
      source: source,
      pageTag: tag,
    );
  }
}
