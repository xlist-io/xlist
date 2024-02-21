import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:xlist/common/index.dart';
import 'package:xlist/helper/index.dart';
import 'package:xlist/constants/index.dart';
import 'package:xlist/pages/file/index.dart';

class FilePage extends GetView<FileController> {
  const FilePage({Key? key}) : super(key: key);

  // NavigationBar
  CupertinoNavigationBar _buildNavigationBar() {
    return CupertinoNavigationBar(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      border: Border.all(width: 0, color: Colors.transparent),
      leading: CommonUtils.backButton,
    );
  }

  /// 构建图标
  Widget _buildIcon() {
    return Icon(
      FileType.getIcon(controller.object.value.type ?? 0, controller.name),
      size: 130.sp,
      color: Get.theme.primaryColor,
    );
  }

  /// 文件信息
  Widget _buildFileInfo() {
    final fileSize = CommonUtils.formatFileSize(controller.object.value.size!);

    return Column(
      children: [
        SizedBox(height: 200.h),
        _buildIcon(),
        SizedBox(height: 20.h),
        Text(
          controller.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Get.textTheme.bodyLarge,
        ),
        SizedBox(height: 5.h),
        Text(
          '${'file_size'.tr}: ${fileSize}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Get.textTheme.bodySmall,
        ),
      ],
    );
  }

  // 页面
  Widget _buildPageInfo() {
    if (controller.isLoading.isTrue) {
      return Center(child: CupertinoActivityIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 50.w),
            child: _buildFileInfo(),
          ),
          SizedBox(height: 500.h),
          Column(
            children: [
              Text(
                'file_unsupported_description'.tr,
                style: Get.textTheme.bodySmall,
              ),
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 100.r),
                child: ButtonHelper.createElevatedButton(
                  'download'.tr,
                  onPressed: () => controller.download(),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Text(
                  'pull_down_copy_link'.tr,
                  style: Get.textTheme.bodyMedium,
                ),
                onPressed: () => controller.copyLink(),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: _buildNavigationBar(),
      child: Obx(() => _buildPageInfo()),
    );
  }
}
