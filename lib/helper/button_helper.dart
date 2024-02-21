import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:xlist/common/index.dart';
import 'package:xlist/helper/index.dart';
import 'package:xlist/storages/index.dart';
import 'package:xlist/constants/index.dart';

class ButtonHelper {
  /// 创建一个默认的按钮
  /// [text] 按钮文本
  /// [onPressed] 按钮点击事件
  /// [backgroundColor] 按钮背景颜色
  static createElevatedButton(
    String text, {
    required Function? onPressed,
    Color? backgroundColor,
    double? borderRadius,
  }) {
    return ElevatedButton(
      child: Text(
        text,
        style: Get.textTheme.titleMedium?.copyWith(
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        splashFactory: NoSplash.splashFactory,
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 30.r),
        ),
        minimumSize: const Size.fromHeight(50),
      ),
      onPressed: onPressed as void Function()?,
    );
  }

  /// 构建下拉按钮
  static Widget createPullDownButton({
    required dynamic controller,
    required String path,
    required String source,
    required String pageTag,
  }) {
    List<PullDownMenuEntry> items = [];

    // 上传
    if (controller.userInfo.value.permission != null &&
        PermissionHelper.canWrite(controller.userInfo.value)) {
      items.addAll([
        PullDownMenuItem(
          title: 'pull_down_new_file'.tr,
          icon: CupertinoIcons.doc,
          onTap: () => ObjectHelper.createFile(
            path: path,
            source: source,
            pageTag: pageTag,
            password: controller.password,
          ),
        ),
        PullDownMenuItem(
          title: 'pull_down_new_folder'.tr,
          icon: CupertinoIcons.folder,
          onTap: () => ObjectHelper.mkdir(
            path: path,
            source: source,
            pageTag: pageTag,
          ),
        ),
        PullDownMenuDivider.large(),
        PullDownMenuItem(
          title: 'pull_down_upload_file'.tr,
          icon: CupertinoIcons.doc_on_clipboard,
          onTap: () => ObjectHelper.uploadFile(
            path: path,
            source: source,
            pageTag: pageTag,
            password: controller.password,
          ),
        ),
        PullDownMenuItem(
          title: 'pull_down_upload_image'.tr,
          icon: CupertinoIcons.photo_on_rectangle,
          onTap: () => ObjectHelper.upload(
            type: FileType.IMAGE,
            path: path,
            source: source,
            pageTag: pageTag,
            password: controller.password,
          ),
        ),
        PullDownMenuItem(
          title: 'pull_down_upload_video'.tr,
          icon: CupertinoIcons.videocam_circle,
          onTap: () => ObjectHelper.upload(
            type: FileType.VIDEO,
            path: path,
            source: source,
            pageTag: pageTag,
            password: controller.password,
          ),
        ),
        PullDownMenuDivider.large(),
      ]);
    }

    // 刷新
    items.add(PullDownMenuItem(
      title: 'pull_down_refresh'.tr,
      icon: CupertinoIcons.refresh,
      onTap: () async => await controller.getObjectList(),
    ));

    // 强制刷新, 只有有可写权限的用户才能看到
    if (controller.userInfo.value.permission != null &&
        PermissionHelper.canWrite(controller.userInfo.value)) {
      items.add(PullDownMenuItem(
        title: 'pull_down_force_refresh'.tr,
        icon: CupertinoIcons.refresh_circled,
        onTap: () async => await controller.getObjectList(refresh: true),
      ));
    }

    // 布局方式
    final layoutType = controller.layoutType.value;

    // 布局
    items.addAll([
      PullDownMenuDivider.large(),
      PullDownMenuItem(
        title: 'pull_down_list'.tr,
        icon: layoutType == LayoutType.LIST ? CupertinoIcons.checkmark : null,
        onTap: () async {
          controller.layoutType.value = LayoutType.LIST;
          Get.find<PreferencesStorage>().layoutType.val = LayoutType.LIST;
        },
      ),
      PullDownMenuItem(
        title: 'pull_down_grid'.tr,
        icon: layoutType == LayoutType.GRID ? CupertinoIcons.checkmark : null,
        onTap: () async {
          controller.layoutType.value = LayoutType.GRID;
          Get.find<PreferencesStorage>().layoutType.val = LayoutType.GRID;
        },
      ),
    ]);

    // 目前选择的排序方式
    final sortType = controller.sortType.value;

    // 排序
    items.addAll([
      PullDownMenuDivider.large(),
      PullDownMenuItem(
        title: 'pull_down_time'.tr,
        icon: [0, 1].contains(sortType)
            ? (sortType == 0
                ? CupertinoIcons.chevron_down
                : CupertinoIcons.chevron_up)
            : null,
        onTap: () async {
          sortType == 0
              ? controller.sortType.value = 1
              : controller.sortType.value = 0;
          Get.find<PreferencesStorage>().sortType.val =
              controller.sortType.value;
          await controller.getObjectList();
        },
      ),
      PullDownMenuItem(
        title: 'pull_down_name'.tr,
        icon: [2, 3].contains(sortType)
            ? (sortType == 2
                ? CupertinoIcons.chevron_down
                : CupertinoIcons.chevron_up)
            : null,
        onTap: () async {
          sortType == 3
              ? controller.sortType.value = 2
              : controller.sortType.value = 3;
          Get.find<PreferencesStorage>().sortType.val =
              controller.sortType.value;
          await controller.getObjectList();
        },
      ),
    ]);

    return PullDownButton(
      itemBuilder: (context) => items,
      buttonBuilder: (context, showMenu) => CupertinoButton(
        onPressed: showMenu,
        padding: EdgeInsets.zero,
        alignment: Alignment.centerRight,
        child: Icon(
          CupertinoIcons.ellipsis_circle,
          size: CommonUtils.navIconSize,
        ),
      ),
    );
  }
}
