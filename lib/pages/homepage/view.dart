import 'package:get/get.dart';
import 'package:keframe/keframe.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:xlist/common/index.dart';
import 'package:xlist/helper/index.dart';
import 'package:xlist/storages/index.dart';
import 'package:xlist/constants/index.dart';
import 'package:xlist/components/index.dart';
import 'package:xlist/routes/app_pages.dart';
import 'package:xlist/pages/homepage/index.dart';
import 'package:xlist/database/entity/index.dart';
import 'package:xlist/services/browser_service.dart';

class Homepage extends GetView<HomepageController> {
  const Homepage({Key? key}) : super(key: key);

  /// NavigationBar
  Widget _buildSliverNavigationBar() {
    return CupertinoSliverNavigationBar(
      backgroundColor:
          Get.isDarkMode ? Color.fromARGB(255, 18, 18, 18) : Colors.white,
      border: Border.all(width: 0, color: Colors.transparent),
      leading: CupertinoButton(
        padding: EdgeInsets.zero,
        alignment: Alignment.centerLeft,
        child: Container(
          width: 190.w,
          child: Row(
            children: [
              Icon(CupertinoIcons.umbrella_fill, size: CommonUtils.navIconSize),
              SizedBox(width: 15.w),
              // Text('设置', style: TextStyle(fontSize: 50.sp)),
            ],
          ),
        ),
        onPressed: () => Get.toNamed(Routes.SETTING)
            ?.then((value) => controller.getObjectList()),
      ),
      largeTitle: Text(
        'homepage_title'.tr,
        style: TextStyle(color: Get.theme.textTheme.bodyLarge?.color),
      ),
      trailing: Obx(
        () => ButtonHelper.createPullDownButton(
          controller: controller,
          path: '/',
          source: PageSource.HOMEPAGE,
          pageTag: tag ?? '',
        ),
      ),
    );
  }

  /// 无设置服务器
  Widget _buildEmptyServer() {
    return Column(
      children: [
        SizedBox(height: 500.h),
        Text(
          'homepage_empty_server_title'.tr,
          style: Get.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        CupertinoButton(
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.help_outline_rounded,
                size: CommonUtils.isPad ? 20 : 50.sp,
              ),
              SizedBox(width: 5.w),
              Text('homepage_empty_server_help'.tr),
            ],
          ),
          onPressed: () => BrowserService.to.open('https://alist.nn.ci'),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 100.r),
          child: ButtonHelper.createElevatedButton(
            'homepage_empty_server_button'.tr,
            onPressed: () async {
              final result = await BottomSheetHelper.showBottomSheet(
                AddServerBottomSheet(),
              );
              if (result == null) return;
              if (!(result is ServerEntity)) return;

              // 重置本地信息
              Get.find<UserStorage>().serverId.val = result.id!;
              Get.find<UserStorage>().serverUrl.val = result.url;

              // 重置首页信息
              controller.serverId.value = result.id!;
              await controller.resetUserToken(result);
              controller.getObjectList();
            },
          ),
        ),
      ],
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

    return SizeCacheWidget(
      child: controller.layoutType.value == LayoutType.GRID
          ? ObjectGridComponent(
              tag: '',
              source: PageSource.HOMEPAGE,
              userInfo: controller.userInfo.value,
              path: '/',
              objects: controller.objects.value,
              isShowPreview: controller.isShowPreview.value,
            )
          : ObjectListComponent(
              tag: '',
              source: PageSource.HOMEPAGE,
              userInfo: controller.userInfo.value,
              path: '/',
              objects: controller.objects.value,
              isShowPreview: controller.isShowPreview.value,
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
        _buildSliverNavigationBar(),
        HeaderLocator.sliver(),
        SliverPadding(
          padding:
              EdgeInsets.symmetric(horizontal: CommonUtils.isPad ? 20 : 50.r)
                  .copyWith(bottom: 30.h),
          sliver: SliverToBoxAdapter(child: SearchComponent(path: '/')),
        ),
        Obx(
          () => SliverPadding(
            padding:
                EdgeInsets.symmetric(horizontal: CommonUtils.isPad ? 15 : 30.r),
            sliver: controller.serverId.value == 0 &&
                    controller.isFirstLoading.isFalse
                ? SliverToBoxAdapter(child: _buildEmptyServer())
                : _buildSliverList(),
          ),
        ),
        FooterLocator.sliver(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: EasyRefresh(
          controller: controller.easyRefreshController,
          header: CupertinoHeader(
              position: IndicatorPosition.locator, safeArea: false),
          footer: CupertinoFooter(position: IndicatorPosition.locator),
          onRefresh: () async {
            await HapticFeedback.selectionClick();
            await controller.getObjectList();
            controller.easyRefreshController.finishRefresh();
            controller.easyRefreshController.resetFooter();
          },
          child: _buildCustomScrollView(),
        ),
      ),
    );
  }
}
