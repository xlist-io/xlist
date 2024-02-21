import 'package:get/get.dart';
import 'package:keframe/keframe.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:xlist/gen/index.dart';
import 'package:xlist/common/index.dart';
import 'package:xlist/helper/index.dart';
import 'package:xlist/models/index.dart';
import 'package:xlist/components/index.dart';
import 'package:xlist/components/object_list/object_list_item.dart';

class ObjectListComponent extends StatefulWidget {
  final String path;
  final String tag;
  final String source;
  final UserModel userInfo;
  final List<ObjectModel> objects;
  final bool isShowPreview;

  const ObjectListComponent({
    Key? key,
    required this.path,
    required this.tag,
    required this.userInfo,
    required this.objects,
    required this.source,
    required this.isShowPreview,
  }) : super(key: key);

  @override
  _ObjectListComponentState createState() => _ObjectListComponentState();
}

class _ObjectListComponentState extends State<ObjectListComponent> {
  String get path => widget.path;
  List<ObjectModel> get objects => widget.objects;

  @override
  void initState() {
    super.initState();
  }

  /// 构建侧滑按钮
  List<Widget> _buildSlidableAction(ObjectModel object) {
    return [
      SlidableAction(
        flex: 1,
        onPressed: (context) async {
          await HapticFeedback.selectionClick();
          BottomSheetHelper.showBarBottomSheet(
            MoreBottomSheet(
              path: path,
              tag: widget.tag,
              userInfo: widget.userInfo,
              object: object,
              source: widget.source,
            ),
          );
        },
        backgroundColor: Colors.grey,
        foregroundColor: Colors.white,
        icon: CupertinoIcons.ellipsis_circle,
        label: 'more'.tr,
      ),
      SlidableAction(
        flex: 1,
        onPressed: (context) =>
            CommonUtils.addFavorite(object, widget.path, object.name!),
        backgroundColor: Get.theme.primaryColor,
        foregroundColor: Colors.white,
        icon: CupertinoIcons.star,
        label: 'favorite'.tr,
      ),
    ];
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

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) => FrameSeparateWidget(
          index: index,
          child: GestureDetector(
            onTap: () => ObjectHelper.click(
              path: path,
              type: objects[index].type!,
              name: objects[index].name!,
              objects: objects,
            ),
            child: Slidable(
              startActionPane: PermissionHelper.canDelete(widget.userInfo)
                  ? ActionPane(
                      motion: ScrollMotion(),
                      children: [
                        SlidableAction(
                          flex: 1,
                          onPressed: (context) async {
                            await ObjectHelper.remove(
                              path: widget.path,
                              name: objects[index].name!,
                              source: widget.source,
                              pageTag: widget.tag,
                            );
                          },
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          icon: CupertinoIcons.delete,
                          label: 'delete'.tr,
                        )
                      ],
                    )
                  : null,
              endActionPane: ActionPane(
                motion: ScrollMotion(),
                children: _buildSlidableAction(objects[index]),
              ),
              child: Column(
                children: [
                  ObjectListItem(
                    object: objects[index],
                    isShowPreview: widget.isShowPreview,
                  ),
                  Container(
                    padding: EdgeInsets.only(top: CommonUtils.isPad ? 0 : 20.r),
                    child: CommonUtils.isPad
                        ? Divider(height: 1.r, indent: 90, endIndent: 10)
                        : Divider(height: 1.r, indent: 190.r, endIndent: 15.r),
                  ),
                ],
              ),
            ),
          ),
        ),
        childCount: objects.length,
      ),
    );
  }
}
