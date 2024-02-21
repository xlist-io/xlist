import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:highlight/languages/all.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:xlist/common/index.dart';
import 'package:xlist/helper/index.dart';
import 'package:xlist/models/index.dart';
import 'package:xlist/services/index.dart';
import 'package:xlist/storages/index.dart';
import 'package:xlist/constants/index.dart';
import 'package:xlist/repositorys/index.dart';

class DocumentController extends GetxController {
  final object = ObjectModel().obs;
  final userInfo = UserModel().obs; // 用户信息
  final httpHeaders = Map<String, String>().obs;
  final serverId = Get.find<UserStorage>().serverId.val;
  final isLoading = true.obs; // 是否正在加载
  final progress = 0.0.obs;

  // 获取参数
  final String path = Get.arguments['path'] ?? '';
  final String name = Get.arguments['name'] ?? '';

  // 文件类型
  String get fileType => p.extension(name).replaceAll('.', '').toLowerCase();

  // 是否是代码类型文件
  CodeController? codeController;

  // WebView
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      transparentBackground: !Get.isDarkMode,
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
    ),
    android: AndroidInAppWebViewOptions(useHybridComposition: true),
    ios: IOSInAppWebViewOptions(allowsInlineMediaPlayback: true),
  );

  @override
  void onInit() async {
    super.onInit();

    // 获取文档地址
    object.value = await ObjectRepository.get(path: '${path}${name}');
    userInfo.value = await UserRepository.me(); // 获取用户信息
    httpHeaders.value = await DriverHelper.getHeaders(
        object.value.provider, object.value.rawUrl);

    // 如果是代码类型文件
    if (PreviewHelper.isCode(name) && !PreviewHelper.isHtml(name)) {
      final response = await DioService.to.dio.get(
        object.value.rawUrl!,
        options: Options(headers: httpHeaders),
      );

      codeController = CodeController(
        text: response.data.toString(),
        language: allLanguages[kCodeLanguages[fileType]] ?? javascript,
      );
    }

    // 加入最近浏览
    await CommonUtils.addRecent(object.value, path, name);

    // 加载完成
    isLoading.value = false;

    // 绑定进度监听
    DownloadService.to.bindBackgroundIsolate((id, status, progress) {});
  }

  /// 收藏
  void favorite() async {
    await CommonUtils.addFavorite(object.value, path, name);
  }

  /// 复制链接
  void copyLink() {
    Clipboard.setData(ClipboardData(
      text: CommonUtils.getDownloadLink(
        path,
        object: object.value,
        userInfo: userInfo.value,
      ),
    ));
    SmartDialog.showToast('toast_copy_success'.tr);
  }

  /// 下载文件
  void download() async {
    DownloadHelper.file(path, name, object.value.type!, object.value.size!);
  }

  /// WebView 加载进度
  onProgressChanged(controller, p) {
    progress.value = p / 100;
  }

  @override
  void onClose() {
    super.onClose();

    // 取消进度监听
    DownloadService.to.unbindBackgroundIsolate();
  }
}
