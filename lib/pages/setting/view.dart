import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:xlist/common/index.dart';
import 'package:xlist/storages/index.dart';
import 'package:xlist/routes/app_pages.dart';
import 'package:xlist/pages/setting/index.dart';
import 'package:xlist/pages/homepage/index.dart';

class SettingPage extends GetView<SettingController> {
  const SettingPage({Key? key}) : super(key: key);

  // NavigationBar
  CupertinoNavigationBar _buildNavigationBar() {
    return CupertinoNavigationBar(
      backgroundColor: CommonUtils.backgroundColor,
      border: Border.all(width: 0, color: Colors.transparent),
      leading: CupertinoButton(
        padding: EdgeInsets.zero,
        alignment: Alignment.centerLeft,
        child: Icon(FontAwesomeIcons.xmark, size: CommonUtils.navIconSize),
        onPressed: () => Get.back(),
      ),
      middle: Text('setting'.tr),
    );
  }

  /// ListTile
  /// [title] 标题
  /// [icon] 图标
  /// [onTap] 点击事件
  /// [additionalInfo] 附加信息
  Widget _buildListTile({
    required String title,
    required IconData icon,
    double? iconSize,
    Color? iconColor,
    Function()? onTap,
    Widget trailing = const CupertinoListTileChevron(),
    String additionalInfo = '',
  }) {
    return CupertinoListTile(
      title: Row(
        children: [
          Text(title, style: Get.textTheme.bodyLarge),
          SizedBox(width: 10),
        ],
      ),
      padding: EdgeInsets.only(left: 15, right: 10),
      leading: Icon(
        icon,
        size: iconSize ?? CommonUtils.navIconSize,
        color: iconColor ?? Get.theme.primaryColor,
      ),
      leadingToTitle: 5,
      additionalInfo: additionalInfo.isEmpty
          ? SizedBox()
          : Container(
              width: 400.w,
              alignment: Alignment.centerRight,
              child: Text(
                additionalInfo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Get.textTheme.bodyLarge?.copyWith(color: Colors.grey),
              ),
            ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 通用高级功能列表项
    final favorite = [
      _buildListTile(
        title: 'favorite'.tr,
        icon: Icons.star_rounded,
        onTap: () => Get.toNamed(Routes.SETTING_FAVORITE),
      ),
    ];

    final recent = [
      _buildListTile(
        title: 'recent'.tr,
        icon: Icons.history_rounded,
        onTap: () => Get.toNamed(Routes.SETTING_RECENT),
      ),
    ];

    final mediaPreview = [
      _buildListTile(
        title: 'setting_preview_image'.tr,
        icon: Icons.perm_media_rounded,
        trailing: Obx(
          () => CupertinoSwitch(
            value: controller.isShowPreview.value,
            onChanged: (value) {
              controller.isShowPreview.value = value;
              Get.find<PreferencesStorage>().isShowPreview.val = value;
              Get.find<HomepageController>().isShowPreview.value = value;
            },
          ),
        ),
      ),
    ];

    return CupertinoPageScaffold(
      navigationBar: _buildNavigationBar(),
      backgroundColor: CommonUtils.backgroundColor,
      child: Container(
        height: Get.height,
        padding: EdgeInsets.only(bottom: 20.h),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Obx(
                () => CupertinoListSection.insetGrouped(
                  backgroundColor: CommonUtils.backgroundColor,
                  dividerMargin: 20,
                  additionalDividerMargin: 30,
                  header: Container(
                    padding: EdgeInsets.only(left: 15),
                    alignment: Alignment.centerLeft,
                    child: Text('general'.tr, style: Get.textTheme.bodySmall),
                  ),
                  children: [
                    _buildListTile(
                      title: 'server'.tr,
                      icon: Icons.cloud,
                      additionalInfo: controller.serverInfo.value.username,
                      onTap: () => Get.toNamed(Routes.SETTING_SERVER),
                    ),
                    _buildListTile(
                      title: 'setting_theme'.tr,
                      icon: Icons.color_lens,
                      additionalInfo: controller.themeModeText.value,
                      onTap: () => controller.changeTheme(),
                    ),
                    ...favorite,
                    ...recent,
                    _buildListTile(
                      title: 'download_manager'.tr,
                      icon: Icons.download_rounded,
                      onTap: () => Get.toNamed(Routes.SETTING_DOWNLOAD),
                    ),
                  ],
                ),
              ),
              CupertinoListSection.insetGrouped(
                backgroundColor: CommonUtils.backgroundColor,
                dividerMargin: 20,
                additionalDividerMargin: 30,
                header: Container(
                  padding: EdgeInsets.only(left: 15),
                  alignment: Alignment.centerLeft,
                  child: Text('preview'.tr, style: Get.textTheme.bodySmall),
                ),
                children: [
                  _buildListTile(
                    title: 'document'.tr,
                    icon: Icons.description_rounded,
                    onTap: () => Get.toNamed(Routes.SETTING_PREVIEW_DOCUMENT),
                  ),
                  _buildListTile(
                    title: 'image'.tr,
                    icon: Icons.image_rounded,
                    onTap: () => Get.toNamed(Routes.SETTING_PREVIEW_IMAGE),
                  ),
                  _buildListTile(
                    title: 'video'.tr,
                    icon: Icons.video_collection_rounded,
                    onTap: () => Get.toNamed(Routes.SETTING_PREVIEW_VIDEO),
                  ),
                  _buildListTile(
                    title: 'audio'.tr,
                    icon: Icons.library_music,
                    onTap: () => Get.toNamed(Routes.SETTING_PREVIEW_AUDIO),
                  ),
                  _buildListTile(
                    title: 'setting_autoplay'.tr,
                    icon: Icons.play_circle_outline_rounded,
                    trailing: Obx(
                      () => CupertinoSwitch(
                        value: controller.isAutoPlay.value,
                        onChanged: (value) {
                          controller.isAutoPlay.value = value;
                          Get.find<PreferencesStorage>().isAutoPlay.val = value;
                        },
                      ),
                    ),
                  ),
                  _buildListTile(
                    title: 'setting_hardware'.tr,
                    icon: Icons.hardware_rounded,
                    trailing: Obx(
                      () => CupertinoSwitch(
                        value: controller.isHardwareDecode.value,
                        onChanged: (value) {
                          controller.isHardwareDecode.value = value;
                          Get.find<PreferencesStorage>().isHardwareDecode.val =
                              value;
                        },
                      ),
                    ),
                  ),
                  ...mediaPreview,
                  _buildListTile(
                    title: 'setting_background_playback'.tr,
                    icon: Icons.personal_video_rounded,
                    trailing: Obx(
                      () => CupertinoSwitch(
                        value: controller.isBackgroundPlay.value,
                        onChanged: (value) {
                          controller.isBackgroundPlay.value = value;
                          Get.find<PreferencesStorage>().isBackgroundPlay.val =
                              value;
                        },
                      ),
                    ),
                  ),
                ],
              ),
              CupertinoListSection.insetGrouped(
                backgroundColor: CommonUtils.backgroundColor,
                dividerMargin: 20,
                additionalDividerMargin: 30,
                children: [
                  _buildListTile(
                    title: 'feedback'.tr,
                    icon: Icons.feedback_rounded,
                    onTap: () => launchUrl(
                      Uri.parse(
                          'mailto:hello@gaozihang.com?subject=${'app_name'.tr}, v${controller.version.value}}'),
                    ),
                  ),
                  _buildListTile(
                    title: 'setting_review'.tr,
                    icon: Icons.stars_rounded,
                    additionalInfo: 'setting_review_description'.tr,
                    onTap: () => controller.inAppReview.openStoreListing(
                      appStoreId: '6448833200',
                    ),
                  ),
                  _buildListTile(
                    title: 'about'.tr,
                    icon: Icons.info_rounded,
                    onTap: () => Get.toNamed(Routes.SETTING_ABOUT),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
