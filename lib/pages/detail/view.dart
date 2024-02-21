import 'package:get/get.dart';
import 'package:keframe/keframe.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:xlist/common/index.dart';
import 'package:xlist/helper/index.dart';
import 'package:xlist/constants/index.dart';
import 'package:xlist/components/index.dart';
import 'package:xlist/pages/detail/index.dart';

class DetailPage extends StatelessWidget {
  final String? tag;
  final String? previousPageTitle;
  DetailController get controller => Get.find<DetailController>(tag: tag);

  /// 构造函数
  DetailPage({Key? key, this.tag, this.previousPageTitle}) : super(key: key) {
    Get.put<DetailController>(DetailController(), tag: tag);
  }

  // NavigationBar
  CupertinoNavigationBar _buildNavigationBar() {
    return CupertinoNavigationBar(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      border: Border.all(width: 0, color: Colors.transparent),
      leading: CommonUtils.backButton,
      middle: Text(
        controller.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Obx(
        () => ButtonHelper.createPullDownButton(
          controller: controller,
          path: '${controller.path}${controller.name}',
          source: PageSource.DETAIL,
          pageTag: tag ?? '',
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

    return SizeCacheWidget(
      child: controller.layoutType.value == LayoutType.GRID
          ? ObjectGridComponent(
              tag: tag ?? '',
              source: PageSource.DETAIL,
              userInfo: controller.userInfo.value,
              path: '${controller.path}${controller.name}/',
              objects: controller.objects.value,
              isShowPreview: controller.isShowPreview.value,
            )
          : ObjectListComponent(
              tag: tag ?? '',
              source: PageSource.DETAIL,
              userInfo: controller.userInfo.value,
              path: '${controller.path}${controller.name}/',
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
        HeaderLocator.sliver(),
        SliverPadding(
          padding: EdgeInsets.symmetric(
              horizontal: CommonUtils.isPad ? 20 : 50.r, vertical: 30.r),
          sliver: SliverToBoxAdapter(
            child: SearchComponent(
              path: '${controller.path}${controller.name}',
            ),
          ),
        ),
        SliverPadding(
          padding:
              EdgeInsets.symmetric(horizontal: CommonUtils.isPad ? 15 : 30.r),
          sliver: Obx(() => _buildSliverList()),
        ),
        FooterLocator.sliver(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: _buildNavigationBar(),
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
