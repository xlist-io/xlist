import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:xlist/common/index.dart';
import 'package:xlist/constants/index.dart';
import 'package:xlist/pages/setting/preview/audio/index.dart';

class SettingAudioPage extends GetView<SettingAudioController> {
  const SettingAudioPage({Key? key}) : super(key: key);

  // NavigationBar
  CupertinoNavigationBar _buildNavigationBar() {
    return CupertinoNavigationBar(
      backgroundColor: CommonUtils.backgroundColor,
      border: Border.all(width: 0, color: Colors.transparent),
      leading: CommonUtils.backButton,
      middle: Text('audio'.tr),
    );
  }

  /// ListTile
  /// [title] 标题
  /// [leading] 图标
  /// [onTap] 点击事件
  Widget _buildListTile({
    required String title,
    required Widget? leading,
    required Function() onTap,
  }) {
    return CupertinoListTile(
      title: Text(title, style: Get.textTheme.bodyLarge),
      padding: EdgeInsets.only(left: 15, right: 10),
      leading: leading,
      leadingToTitle: 5,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: _buildNavigationBar(),
      backgroundColor: CommonUtils.backgroundColor,
      child: Container(
        height: Get.height,
        padding: EdgeInsets.only(bottom: 20.h),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: CupertinoListSection.insetGrouped(
            backgroundColor: CommonUtils.backgroundColor,
            dividerMargin: 20,
            additionalDividerMargin: 30,
            header: Container(
              padding: EdgeInsets.only(left: 15),
              alignment: Alignment.centerLeft,
              child: Text(
                'setting_preview_audio_title'.tr,
                style: Get.textTheme.bodySmall,
              ),
            ),
            children: [
              for (var type in kSupportPreviewAudioTypes)
                _buildListTile(
                  title: type,
                  leading: Obx(
                    () => controller.audioSupportTypes.contains(type)
                        ? Icon(
                            CupertinoIcons.checkmark_alt,
                            size: CommonUtils.navIconSize,
                            color: Get.theme.primaryColor,
                          )
                        : SizedBox(),
                  ),
                  onTap: () => controller.toggleAudioSupportType(type),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
