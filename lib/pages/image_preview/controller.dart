import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:xlist/common/index.dart';
import 'package:xlist/helper/index.dart';
import 'package:xlist/models/index.dart';
import 'package:xlist/services/index.dart';
import 'package:xlist/storages/index.dart';
import 'package:xlist/constants/index.dart';
import 'package:xlist/repositorys/index.dart';

class ImagePreviewController extends GetxController {
  final imageUrls = <String>[].obs;
  final imageHeaders = <String, String>{}.obs;
  final userInfo = UserModel().obs; // 用户信息
  final serverUrl = Get.find<UserStorage>().serverUrl.val;

  // 获取参数
  final String path = Get.arguments['path'] ?? '';
  final String name = Get.arguments['name'] ?? '';
  List<ObjectModel> objects = Get.arguments['objects'] ?? [];

  // 图片控制器
  final currentIndex = 0.obs;
  final isDragUpdate = false.obs;
  late PageController pageController;

  @override
  void onInit() async {
    super.onInit();

    // 过滤非图片
    objects = objects.where((o) => PreviewHelper.isImage(o.name!)).toList();
    userInfo.value = await UserRepository.me(); // 获取用户信息

    // 初始化图片控制器
    currentIndex.value = objects.indexWhere((e) => e.name == name);
    pageController = PageController(initialPage: currentIndex.value);

    // 获取头信息
    final object = await ObjectRepository.get(path: '${path}${name}');
    imageHeaders.value =
        await DriverHelper.getHeaders(object.provider, object.rawUrl);

    // 获取图片链接, 115 hack
    if (object.provider!.startsWith(Provider.Cloud115)) {
      for (var i = 0; i < objects.length; i++) {
        final _response =
            await ObjectRepository.get(path: '${path}${objects[i].name}');
        imageUrls.add(_response.rawUrl!);
      }
    } else {
      imageUrls.value = objects.map((o) {
        return CommonUtils.getDownloadLink(
          path,
          object: o,
          userInfo: userInfo.value,
        );
      }).toList();
    }

    // 加入最近浏览
    await CommonUtils.addRecent(object, path, name);

    // 添加当前图片
    if (imageUrls.isEmpty) imageUrls.add(object.rawUrl!);
  }

  /// 页面切换
  /// [index] 当前页面索引
  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  /// 显示更多操作
  void moreActionSheet() async {
    final value = await showModalActionSheet(
      context: Get.overlayContext!,
      actions: [
        SheetAction(label: 'pull_down_copy_link'.tr, key: 'copy'),
        SheetAction(label: 'pull_down_save_image'.tr, key: 'save'),
      ],
      cancelLabel: 'cancel'.tr,
    );
    if (value == null) return;
    if (value == 'save') await saveImage();
    if (value == 'copy') copyLink();
  }

  /// 复制链接
  void copyLink() {
    Clipboard.setData(ClipboardData(
      text: CommonUtils.getDownloadLink(
        path,
        object: objects[currentIndex.value],
        userInfo: userInfo.value,
      ),
    ));
    SmartDialog.showToast('toast_copy_success'.tr);
  }

  /// 保存图片
  Future<void> saveImage() async {
    try {
      SmartDialog.showLoading();
      final response = await DioService.to.dio.get(
        imageUrls[currentIndex.value],
        options: Options(
          responseType: ResponseType.bytes,
          headers: imageHeaders,
        ),
      );

      final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
      );

      SmartDialog.dismiss();
      if (result['isSuccess'] == false) throw 'toast_save_image_fail'.tr;
      SmartDialog.showToast('toast_save_success'.tr);
    } catch (e) {}
  }
}
