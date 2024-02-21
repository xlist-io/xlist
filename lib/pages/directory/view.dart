import 'package:get/get.dart';
import 'package:keframe/keframe.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:xlist/gen/index.dart';
import 'package:xlist/common/index.dart';
import 'package:xlist/helper/index.dart';
import 'package:xlist/constants/index.dart';
import 'package:xlist/routes/app_pages.dart';
import 'package:xlist/pages/directory/index.dart';
import 'package:xlist/components/object_list/object_list_item.dart';

class DirectoryPage extends GetView<DirectoryController> {
  final String? tag;
  final String? previousPageTitle;
  DirectoryController get controller => Get.find<DirectoryController>(tag: tag);

  /// 构造函数
  DirectoryPage({
    Key? key,
    this.tag,
    this.previousPageTitle,
  }) : super(key: key) {
    Get.put<DirectoryController>(DirectoryController(), tag: tag);
  }

  /// 构建下拉菜单
  Widget _buildPullDownButton() {
    List<PullDownMenuEntry> items = [];

    // 新建文件夹
    if (controller.userInfo.value.permission != null &&
        PermissionHelper.canWrite(controller.userInfo.value)) {
      items.addAll([
        PullDownMenuItem(
          title: 'pull_down_new_folder'.tr,
          icon: CupertinoIcons.folder,
          onTap: () => ObjectHelper.mkdir(
            path: controller.path,
            source: PageSource.DIRECTORY,
            pageTag: tag ?? '',
          ),
        ),
        PullDownMenuDivider.large(),
      ]);
    }

    // 刷新
    items.addAll([
      PullDownMenuItem(
        title: 'pull_down_refresh'.tr,
        icon: CupertinoIcons.refresh,
        onTap: () async => await controller.getDirectoryList(),
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

  // NavigationBar
  CupertinoNavigationBar _buildNavigationBar() {
    return CupertinoNavigationBar(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      border: Border.all(width: 0, color: Colors.transparent),
      leading: CupertinoButton(
        padding: EdgeInsets.zero,
        alignment: Alignment.centerLeft,
        child: controller.root
            ? Icon(FontAwesomeIcons.xmark, size: CommonUtils.navIconSize)
            : Icon(
                CupertinoIcons.chevron_back,
                size: CommonUtils.isPad ? 30 : 80.sp,
              ),
        onPressed: () => Get.back(),
      ),
      middle: Text(
        controller.pageTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Container(
        width: 270.w,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Obx(() => _buildPullDownButton()),
            SizedBox(width: 15.w),
            CupertinoButton(
              padding: EdgeInsets.zero,
              alignment: Alignment.centerRight,
              child: Text(controller.isCopy ? 'copy'.tr : 'move'.tr),
              onPressed: controller.moveOrCopy,
            )
          ],
        ),
      ),
    );
  }

  /// SliverList
  Widget _buildSliverList() {
    if (controller.isFirstLoading.isTrue) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 500.h),
          child: CupertinoActivityIndicator(),
        ),
      );
    }

    if (controller.objects.isEmpty) {
      return SliverToBoxAdapter(
        child: Column(
          children: [
            SizedBox(height: 500.h),
            Assets.images.empty.image(width: 600.r),
            SizedBox(height: 30.h),
            Text(
              'directory_empty_description'.tr,
              style: Get.textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) => FrameSeparateWidget(
          index: index,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              final object = controller.objects[index];
              final path =
                  '${controller.root ? '' : controller.path}/${object.name}';
              Get.to(
                () => DirectoryPage(tag: path),
                routeName: '${Routes.DIRECTORY}${path}',
                arguments: {
                  'path': path,
                  'object': object,
                  'tag': controller.tag,
                  'srcDir': controller.srcDir,
                  'srcObject': controller.srcObject,
                  'isCopy': controller.isCopy,
                  'source': controller.source,
                },
              );
            },
            child: Column(
              children: [
                ObjectListItem(
                  object: controller.objects[index],
                  isShowPreview: controller.isShowPreview.value,
                ),
                CommonUtils.isPad
                    ? Divider(height: 1.r, indent: 90, endIndent: 10)
                    : Container(
                        padding: EdgeInsets.only(top: 20.r),
                        child: Divider(
                            height: 1.r, indent: 190.r, endIndent: 15.r),
                      ),
              ],
            ),
          ),
        ),
        childCount: controller.objects.length,
      ),
    );
  }

  // ScrollView
  // Replace to [NestedScrollView]
  Widget _buildCustomScrollView() {
    return CustomScrollView(
      shrinkWrap: false,
      controller: controller.scrollController,
      slivers: <Widget>[
        HeaderLocator.sliver(),
        Obx(
          () => SliverPadding(
            padding:
                EdgeInsets.symmetric(horizontal: CommonUtils.isPad ? 15 : 30.r),
            sliver: SizeCacheWidget(child: _buildSliverList()),
          ),
        ),
        FooterLocator.sliver(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildNavigationBar(),
      body: SafeArea(
        child: EasyRefresh(
          controller: controller.easyRefreshController,
          header: CupertinoHeader(
              position: IndicatorPosition.locator, safeArea: false),
          footer: CupertinoFooter(position: IndicatorPosition.locator),
          onRefresh: () async {
            await HapticFeedback.selectionClick();
            await controller.getDirectoryList();
            controller.easyRefreshController.finishRefresh();
            controller.easyRefreshController.resetFooter();
          },
          child: _buildCustomScrollView(),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: CommonUtils.isPad ? 80 : 130.h,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(width: 1.r, color: Get.theme.dividerColor),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 50.r, vertical: 30.r),
          child: Row(
            children: [
              Icon(
                FileType.getIcon(
                  controller.srcObject.type ?? 0,
                  controller.srcObject.name ?? '',
                ),
                size: CommonUtils.isPad ? 60 : 100.sp,
                color: Get.theme.primaryColor,
              ),
              SizedBox(width: 20.w),
              Container(
                width: 860.w,
                child: Text(
                  controller.srcObject.name ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Get.textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
