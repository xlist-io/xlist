import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:xlist/common/index.dart';
import 'package:xlist/helper/index.dart';
import 'package:xlist/models/index.dart';
import 'package:xlist/services/index.dart';
import 'package:xlist/storages/index.dart';
import 'package:xlist/repositorys/index.dart';

class FileController extends GetxController {
  final object = ObjectModel().obs;
  final userInfo = UserModel().obs; // 用户信息
  final serverId = Get.find<UserStorage>().serverId.val;
  final isLoading = true.obs; // 是否正在加载

  // 获取参数
  final String path = Get.arguments['path'] ?? '';
  final String name = Get.arguments['name'] ?? '';

  @override
  void onInit() async {
    super.onInit();

    // 获取文件信息
    object.value = await ObjectRepository.get(path: '${path}${name}');
    userInfo.value = await UserRepository.me(); // 获取用户信息
    isLoading.value = false;

    // 加入最近浏览
    await CommonUtils.addRecent(object.value, path, name);

    // 绑定进度监听
    DownloadService.to.bindBackgroundIsolate((id, status, progress) {});
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

  @override
  void onClose() {
    super.onClose();

    // 取消进度监听
    DownloadService.to.unbindBackgroundIsolate();
  }
}
