import 'package:get/get.dart';
import 'package:keframe/keframe.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:xlist/gen/index.dart';
import 'package:xlist/common/index.dart';
import 'package:xlist/helper/index.dart';
import 'package:xlist/models/index.dart';
import 'package:xlist/components/index.dart';
import 'package:xlist/components/object_grid/object_grid_item.dart';

class ObjectGridComponent extends StatefulWidget {
  final String path;
  final String tag;
  final String source;
  final UserModel userInfo;
  final List<ObjectModel> objects;
  final bool isShowPreview;

  const ObjectGridComponent({
    Key? key,
    required this.path,
    required this.tag,
    required this.userInfo,
    required this.objects,
    required this.source,
    required this.isShowPreview,
  }) : super(key: key);

  @override
  _ObjectGridComponentState createState() => _ObjectGridComponentState();
}

class _ObjectGridComponentState extends State<ObjectGridComponent> {
  String get path => widget.path;
  List<ObjectModel> get objects => widget.objects;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (objects.isEmpty) {
      return SliverToBoxAdapter(
        child: Column(
          children: [
            SizedBox(height: 350.h),
            Assets.images.empty.image(width: 700.r),
            SizedBox(height: 50.h),
            Text('no_data'.tr, style: Get.textTheme.bodyMedium),
          ],
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: CommonUtils.isPad ? 130 : 300.w,
          mainAxisExtent: 160,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => FrameSeparateWidget(
            index: index,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => ObjectHelper.click(
                path: path,
                type: objects[index].type!,
                name: objects[index].name!,
                objects: objects,
              ),
              onLongPress: () async {
                await HapticFeedback.selectionClick();
                BottomSheetHelper.showBarBottomSheet(
                  MoreBottomSheet(
                    path: path,
                    tag: widget.tag,
                    userInfo: widget.userInfo,
                    object: objects[index],
                    source: widget.source,
                  ),
                );
              },
              child: ObjectGridItem(
                object: objects[index],
                isShowPreview: widget.isShowPreview,
              ),
            ),
          ),
          childCount: objects.length,
        ),
      ),
    );
  }
}
