import 'package:get/get.dart';
import 'package:keframe/keframe.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart' hide SearchController;

import 'package:xlist/common/index.dart';
import 'package:xlist/helper/index.dart';
import 'package:xlist/models/index.dart';
import 'package:xlist/pages/search/index.dart';
import 'package:xlist/components/object_grid/object_grid_item.dart';
import 'package:xlist/components/object_list/object_list_item.dart';

class SearchPage extends GetView<SearchController> {
  const SearchPage({Key? key}) : super(key: key);

  /// 构建导航栏
  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: CommonUtils.isPad ? 20 : 50.w)
            .copyWith(bottom: 20.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: CommonUtils.isPad ? Get.width - 90 : 850.w,
              child: CupertinoSearchTextField(
                placeholder: 'search'.tr,
                autofocus: true,
                controller: controller.searchController,
                style: Get.textTheme.bodyLarge,
                onChanged: controller.onChanged,
              ),
            ),
            Container(
              width: CommonUtils.isPad ? 50 : 100.w,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerRight,
                child: Text('取消'),
                onPressed: () => Get.back(),
              ),
            )
          ],
        ),
      ),
    );
  }

  // SliverList
  Widget _buildSliverList() {
    if (CommonUtils.isPad) {
      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 5),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 160,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.0,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final search = controller.searchList[index];
              return FrameSeparateWidget(
                index: index,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    final basePath = controller.userInfo.value.basePath!;
                    final path =
                        basePath != '/' && search.parent!.startsWith(basePath)
                            ? search.parent!.replaceFirst(RegExp(basePath), '')
                            : search.parent;

                    // 跳转到目录页
                    ObjectHelper.click(
                      path: '${path == '/' ? '' : path}/',
                      type: search.type!,
                      name: search.name!,
                      objects: [
                        ObjectModel.fromJson({
                          'name': search.name,
                          'type': search.type,
                          'is_dir': search.isDir,
                          'size': search.size,
                        }),
                      ],
                    );
                  },
                  child: ObjectGridItem(
                    isShowPreview: controller.isShowPreview.value,
                    object: ObjectModel.fromJson(
                      {
                        'name': search.name,
                        'type': search.type,
                        'is_dir': search.isDir,
                        'size': search.size,
                      },
                    ),
                  ),
                ),
              );
            },
            childCount: controller.searchList.length,
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final search = controller.searchList[index];
          return FrameSeparateWidget(
            index: index,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                final basePath = controller.userInfo.value.basePath!;
                final path =
                    basePath != '/' && search.parent!.startsWith(basePath)
                        ? search.parent!.replaceFirst(RegExp(basePath), '')
                        : search.parent;

                // 跳转到目录页
                ObjectHelper.click(
                  path: '${path == '/' ? '' : path}/',
                  type: search.type!,
                  name: search.name!,
                  objects: [
                    ObjectModel.fromJson({
                      'name': search.name,
                      'type': search.type,
                      'is_dir': search.isDir,
                      'size': search.size,
                    }),
                  ],
                );
              },
              child: Column(
                children: [
                  ObjectListItem(
                    isShowPreview: controller.isShowPreview.value,
                    object: ObjectModel.fromJson(
                      {
                        'name': search.name,
                        'type': search.type,
                        'is_dir': search.isDir,
                        'size': search.size,
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 20.r),
                    child: Divider(height: 1.r, indent: 190.r, endIndent: 15.r),
                  ),
                ],
              ),
            ),
          );
        },
        childCount: controller.searchList.length,
      ),
    );
  }

  // ScrollView
  // Replace to [NestedScrollView]
  Widget _buildCustomScrollView() {
    return CustomScrollView(
      shrinkWrap: false,
      physics: GetPlatform.isAndroid ? BouncingScrollPhysics() : null,
      controller: controller.scrollController,
      slivers: <Widget>[
        _buildSearchBar(),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 30.r),
          sliver: SizeCacheWidget(child: Obx(() => _buildSliverList())),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(child: _buildCustomScrollView()),
    );
  }
}
