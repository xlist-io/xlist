import 'package:get/get.dart';
import 'package:keframe/keframe.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:xlist/gen/index.dart';
import 'package:xlist/common/index.dart';
import 'package:xlist/helper/index.dart';
import 'package:xlist/constants/index.dart';
import 'package:xlist/database/entity/index.dart';
import 'package:xlist/pages/setting/recent/index.dart';

class RecentPage extends GetView<RecentController> {
  const RecentPage({Key? key}) : super(key: key);

  // NavigationBar
  CupertinoNavigationBar _buildNavigationBar() {
    return CupertinoNavigationBar(
      backgroundColor: CommonUtils.backgroundColor,
      border: Border.all(width: 0, color: Colors.transparent),
      leading: CommonUtils.backButton,
      middle: Text('setting_recent_title'.tr),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        child: Text('setting_recent_clear'.tr),
        onPressed: () => controller.clearRecent(),
      ),
    );
  }

  /// 构建图标
  /// [type] 文件类型
  /// [name] 文件名
  Widget _buildIcon(int type, String name) {
    return Icon(
      FileType.getIcon(type, name),
      size: CommonUtils.isPad ? 60 : 130.sp,
      color: Get.theme.primaryColor,
    );
  }

  /// 列表项
  Widget _buildItem(RecentEntity entity) {
    String path = entity.path;
    if (entity.path.endsWith('/')) {
      path = entity.path.substring(0, entity.path.length - 1);
    }

    return CupertinoListSection.insetGrouped(
      backgroundColor: CommonUtils.backgroundColor,
      margin: EdgeInsets.zero,
      children: [
        Container(
          height: CommonUtils.isPad ? 80 : 170.h,
          width: double.infinity,
          child: Slidable(
            endActionPane: ActionPane(
              motion: ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) => controller.deleteRecent(entity),
                  backgroundColor: Colors.red,
                  icon: CupertinoIcons.delete,
                  label: 'delete'.tr,
                ),
              ],
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async => ObjectHelper.click(
                path: entity.path,
                type: entity.type,
                name: entity.name,
                objects: await controller.getObjectList(entity),
              ),
              child: Row(
                children: [
                  SizedBox(width: CommonUtils.isPad ? 15 : 30.w),
                  _buildIcon(entity.type, entity.name),
                  SizedBox(width: CommonUtils.isPad ? 10 : 20.w),
                  Container(
                    width: 750.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: CommonUtils.isPad ? 15 : 30.h),
                        Text(
                          entity.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Get.textTheme.bodyLarge,
                        ),
                        SizedBox(height: 7.h),
                        Text(
                          '${CommonUtils.formatFileSize(entity.size)}${path.isNotEmpty ? ' - $path' : ''}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Get.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // SliverList
  Widget _buildSliverList() {
    return PagedSliverList<int, RecentEntity>.separated(
      pagingController: controller.pagingController,
      separatorBuilder: (context, index) => SizedBox(height: 30.h),
      builderDelegate: PagedChildBuilderDelegate<RecentEntity>(
        animateTransitions: false,
        noItemsFoundIndicatorBuilder: (context) => _buildEmptyData(),
        firstPageProgressIndicatorBuilder: (context) => _buildLoading(),
        newPageProgressIndicatorBuilder: (context) => _buildLoading(),
        itemBuilder: (context, item, index) {
          return FrameSeparateWidget(
            index: index,
            child: _buildItem(item),
          );
        },
      ),
    );
  }

  /// Loading
  Widget _buildLoading() {
    return Center(child: CupertinoActivityIndicator());
  }

  /// EmptyData
  Widget _buildEmptyData() {
    return Column(
      children: [
        SizedBox(height: 500.h),
        Assets.images.empty.image(width: 600.r),
        SizedBox(height: 30.h),
        Text('setting_recent_empty'.tr, style: Get.textTheme.bodyLarge),
      ],
    );
  }

  // ScrollView
  // Replace to [NestedScrollView]
  Widget _buildCustomScrollView() {
    return CustomScrollView(
      shrinkWrap: false,
      physics: AlwaysScrollableScrollPhysics(),
      controller: controller.scrollController,
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Obx(
            () => controller.isEmpty.isFalse
                ? Container(
                    padding: CommonUtils.isPad
                        ? EdgeInsets.only(left: 40, top: 30.h, bottom: 10.h)
                        : EdgeInsets.only(left: 80.w, top: 30.h, bottom: 10.h),
                    child: Text(
                      'setting_recent_description'.tr,
                      style: Get.textTheme.bodySmall,
                    ),
                  )
                : SizedBox(),
          ),
        ),
        SliverPadding(
          padding:
              EdgeInsets.symmetric(horizontal: 50.r).copyWith(bottom: 50.h),
          sliver: SizeCacheWidget(child: _buildSliverList()),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: _buildNavigationBar(),
      backgroundColor: CommonUtils.backgroundColor,
      child: _buildCustomScrollView(),
    );
  }
}
