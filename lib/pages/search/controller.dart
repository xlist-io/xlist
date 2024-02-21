import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:xlist/models/index.dart';
import 'package:xlist/services/index.dart';
import 'package:xlist/storages/index.dart';
import 'package:xlist/repositorys/index.dart';

class SearchController extends GetxController {
  static const pageSize = 100;
  final userInfo = UserModel().obs; // 用户信息
  final searchList = <FsSearchModel>[].obs; // Object 数据
  final serverId = Get.find<UserStorage>().serverId.val;

  // 显示预览图
  final isShowPreview = Get.find<PreferencesStorage>().isShowPreview.val.obs;

  TextEditingController searchController = TextEditingController();
  ScrollController scrollController = ScrollController();

  // 获取参数
  final String path = Get.arguments['path'];
  String password = ''; // 目录密码

  @override
  void onInit() async {
    super.onInit();

    // 获取目录密码
    final passwordManager = await DatabaseService.to.database.passwordManagerDao
        .findPasswordManagerByPath(serverId, path);
    if (passwordManager != null && passwordManager.isNotEmpty) {
      password = passwordManager.last.password;
    }

    // 获取用户信息
    userInfo.value = await UserRepository.me();
  }

  /// 搜索
  void onChanged(String value) async {
    await getSearchObjectList(value);
  }

  /// 获取搜索数据
  Future<void> getSearchObjectList(String keywords) async {
    try {
      final response = await ObjectRepository.search(
        page: 1,
        pageSize: pageSize,
        password: password,
        keywords: keywords,
        parent: path,
      );

      searchList.clear(); // 清空数据
      searchList.addAll(response);
      searchList.refresh(); // 刷新数据
    } catch (e) {}
  }
}
