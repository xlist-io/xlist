import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:xlist/gen/index.dart';
import 'package:xlist/common/index.dart';
import 'package:xlist/services/index.dart';
import 'package:xlist/pages/setting/about/index.dart';

class AboutPage extends GetView<AboutController> {
  const AboutPage({Key? key}) : super(key: key);

  // NavigationBar
  CupertinoNavigationBar _buildNavigationBar() {
    return CupertinoNavigationBar(
      backgroundColor: CommonUtils.backgroundColor,
      border: Border.all(width: 0, color: Colors.transparent),
      leading: CommonUtils.backButton,
      middle: Text('about'.tr),
    );
  }

  Widget _buildListTile({
    required String title,
    required IconData icon,
    CupertinoListTileChevron? trailing = const CupertinoListTileChevron(),
    String additionalInfo = '',
    Function()? onTap,
  }) {
    return CupertinoListTile(
      title: Text(title, style: Get.textTheme.bodyLarge),
      padding: EdgeInsets.only(left: 15, right: 10),
      leading: Icon(
        icon,
        size: CommonUtils.navIconSize,
        color: Get.theme.primaryColor,
      ),
      leadingToTitle: 5,
      additionalInfo: Container(
        width: 500.w,
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

  /// 信息
  Widget _buildInfo() {
    return Obx(
      () => CupertinoListSection.insetGrouped(
        backgroundColor: CommonUtils.backgroundColor,
        dividerMargin: 20,
        additionalDividerMargin: 30,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onDoubleTap: () {
              controller.showVersion.toggle();
            },
            child: _buildListTile(
              title: 'version'.tr,
              icon: Icons.info_outline_rounded,
              additionalInfo: 'v${controller.version.value}',
              trailing: null,
            ),
          ),
          _buildListTile(
            title: 'GitHub',
            icon: Icons.code_rounded,
            additionalInfo: 'xlist-io/xlist',
            onTap: () => BrowserService.to.open(
              'https://github.com/xlist-io/xlist',
            ),
          ),
        ],
      ),
    );
  }

  /// 版权信息
  Widget _buildCopyRight() {
    return Container(
      padding: EdgeInsets.only(bottom: 30),
      child: Column(children: [
        Text(
          '© 2023 xlist.io',
          style: Get.textTheme.bodyLarge?.copyWith(
            color: Colors.grey,
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: _buildNavigationBar(),
      backgroundColor: CommonUtils.backgroundColor,
      child: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 100.h),
                Center(
                    child: Assets.common.logoTransparent.image(width: 600.w)),
                _buildInfo(),
                Expanded(child: Container()),
                Obx(() => _buildCopyRight()),
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                    child: Assets.common.logoTransparent.image(width: 300.w)),
                _buildInfo(),
                Expanded(child: Container()),
                Obx(() => _buildCopyRight()),
              ],
            );
          }
        },
      ),
    );
  }
}
