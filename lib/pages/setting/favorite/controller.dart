import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:xlist/common/index.dart';
import 'package:xlist/models/index.dart';
import 'package:xlist/services/index.dart';
import 'package:xlist/storages/index.dart';
import 'package:xlist/constants/index.dart';
import 'package:xlist/repositorys/index.dart';
import 'package:xlist/database/entity/index.dart';

class FavoriteController extends GetxController {
  static const pageSize = 20;
  final isEmpty = true.obs; // 是否为空
  final serverId = Get.find<UserStorage>().serverId.val;
  List<FavoriteEntity> get favoriteList => pagingController.itemList!; // 最近浏览数据

  ScrollController scrollController = ScrollController();
  final PagingController<int, FavoriteEntity> pagingController =
      PagingController(firstPageKey: 0);

  @override
  void onInit() async {
    pagingController.addPageRequestListener((currentPage) {
      getFavoriteListData(currentPage);
    });

    super.onInit();
  }

  /// 获取收藏列表
  /// [currentIndex] 当前游标
  Future<void> getFavoriteListData(int currentIndex) async {
    try {
      final _favoriteList = await DatabaseService.to.database.favoriteDao
          .findFavoriteByServerId(serverId, pageSize, currentIndex);

      // 判断是否为空
      if (currentIndex == 0) isEmpty.value = _favoriteList.isEmpty;
      final isLastPage = _favoriteList.length < pageSize;
      isLastPage
          ? pagingController.appendLastPage(_favoriteList)
          : pagingController.appendPage(
              _favoriteList, currentIndex + _favoriteList.length);
    } catch (e) {
      SmartDialog.showToast(e.toString());
    }
  }

  /// 删除收藏文件
  /// [entity] 收藏实体
  Future<void> deleteFavorite(FavoriteEntity entity) async {
    final ok = await showOkCancelAlertDialog(
      context: Get.context!,
      title: 'dialog_prompt_title'.tr,
      message: 'dialog_remove_message'.tr,
      okLabel: 'confirm'.tr,
      cancelLabel: 'cancel'.tr,
    );
    if (ok != OkCancelResult.ok) return;

    try {
      await DatabaseService.to.database.favoriteDao
          .deleteFavoriteById(entity.id!);
      favoriteList.remove(entity);
      pagingController.notifyListeners();

      isEmpty.value = favoriteList.isEmpty;
      SmartDialog.showToast('toast_remove_success'.tr);
    } catch (e) {
      SmartDialog.showToast(e.toString());
    }
  }

  /// 清空收藏
  Future<void> clearFavorite() async {
    final ok = await showOkCancelAlertDialog(
      context: Get.context!,
      title: 'dialog_prompt_title'.tr,
      message: 'dialog_remove_message_all'.tr,
      okLabel: 'confirm'.tr,
      cancelLabel: 'cancel'.tr,
    );
    if (ok != OkCancelResult.ok) return;

    try {
      final _id = serverId;
      await DatabaseService.to.database.favoriteDao
          .deleteFavoriteByServerId(_id);

      // 清空数据
      favoriteList.clear();
      pagingController.notifyListeners();

      isEmpty.value = favoriteList.isEmpty;
      SmartDialog.showToast('toast_remove_success_all'.tr);
    } catch (e) {
      SmartDialog.showToast(e.toString());
    }
  }

  /// 获取对象列表
  ///
  /// [entity] 收藏实体
  Future<List<ObjectModel>> getObjectList(FavoriteEntity entity) async {
    List<ObjectModel> _objects = [
      ObjectModel.fromJson({
        'name': entity.name,
        'type': entity.type,
        'is_dir': entity.type == FileType.FOLDER,
        'size': entity.size,
      }),
    ];
    if (entity.type == FileType.FOLDER) return [];

    try {
      SmartDialog.showLoading();
      final _sortType = Get.find<PreferencesStorage>().sortType.val;
      final response = await ObjectRepository.getList(path: entity.path);
      if (response['code'] == 200) {
        final data = FsListModel.fromJson(response['data']);
        _objects = CommonUtils.sortObjectList(data.content ?? [], _sortType);
      }
      SmartDialog.dismiss();
    } catch (e) {
      SmartDialog.dismiss();
    }

    return _objects;
  }
}
