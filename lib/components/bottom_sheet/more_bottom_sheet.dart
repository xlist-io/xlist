import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:xlist/common/index.dart';
import 'package:xlist/helper/index.dart';
import 'package:xlist/models/index.dart';
import 'package:xlist/storages/index.dart';
import 'package:xlist/constants/index.dart';
import 'package:xlist/routes/app_pages.dart';

class MoreBottomSheet extends StatefulWidget {
  final String path;
  final String tag;
  final String source;
  final UserModel userInfo;
  final ObjectModel object;

  const MoreBottomSheet({
    Key? key,
    required this.path,
    required this.tag,
    required this.userInfo,
    required this.object,
    required this.source,
  }) : super(key: key);

  @override
  _MoreBottomSheetState createState() => _MoreBottomSheetState();
}

class _MoreBottomSheetState extends State<MoreBottomSheet> {
  ObjectModel get object => widget.object;
  String get source => widget.source;

  /// 构建图标
  Widget _buildIcon() {
    return Icon(
      FileType.getIcon(object.type ?? 0, object.name ?? ''),
      size: CommonUtils.isPad ? 50 : 100.sp,
      color: Get.theme.primaryColor,
    );
  }

  /// 构建标题
  Widget _buildTitle() {
    return Container(
      child: Row(
        children: [
          Row(
            children: [
              _buildIcon(),
              SizedBox(width: CommonUtils.isPad ? 10 : 20.w),
              Container(
                width: 900.w,
                child: Text(
                  object.name ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Get.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  /// 构建列表项
  /// [title] 标题
  /// [icon] 图标
  /// [onTap] 点击事件
  /// [color] 颜色
  Widget _buildListItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return CupertinoListSection.insetGrouped(
      backgroundColor: CommonUtils.backgroundColor,
      margin: EdgeInsets.only(top: 10, left: 10, right: 10),
      hasLeading: false,
      children: [
        CupertinoListTile(
          title: Text(
            title,
            style: Get.textTheme.bodyLarge?.copyWith(color: color),
          ),
          trailing: Icon(
            icon,
            color: Get.theme.primaryColor,
            size: CommonUtils.isPad ? 20 : 65.sp,
          ),
          onTap: onTap,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * .56,
      padding: EdgeInsets.all(30.r),
      color: CommonUtils.backgroundColor,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildTitle(),
            SizedBox(height: 30.h),
            PermissionHelper.canRename(widget.userInfo)
                ? _buildListItem(
                    title: 'rename'.tr,
                    icon: CupertinoIcons.pencil,
                    onTap: () async {
                      Get.back();
                      await ObjectHelper.rename(
                        path: widget.path,
                        object: object,
                        source: source,
                        pageTag: widget.tag,
                      );
                    },
                  )
                : SizedBox(),
            object.isDir!
                ? SizedBox()
                : _buildListItem(
                    title: 'download'.tr,
                    icon: CupertinoIcons.cloud_download,
                    onTap: () {
                      Get.back();
                      DownloadHelper.file(widget.path, object.name!,
                          object.type!, object.size!);
                    },
                  ),
            _buildListItem(
              title: 'pull_down_copy_link'.tr,
              icon: CupertinoIcons.link,
              onTap: () {
                Get.back();
                ObjectHelper.copyLink(
                  widget.path,
                  object: object,
                  userInfo: widget.userInfo,
                );
              },
            ),
            _buildListItem(
              title: 'favorite'.tr,
              icon: CupertinoIcons.star,
              onTap: () async {
                Get.back();
                await CommonUtils.addFavorite(
                    object, widget.path, object.name!);
              },
            ),
            PermissionHelper.canMove(widget.userInfo)
                ? _buildListItem(
                    title: 'move'.tr,
                    icon: CupertinoIcons.folder,
                    onTap: () {
                      Get.back();
                      Get.toNamed(Routes.DIRECTORY, arguments: {
                        'srcDir': widget.path,
                        'srcObject': object,
                        'root': true,
                        'tag': widget.tag,
                        'source': source,
                      });
                    },
                  )
                : SizedBox(),
            PermissionHelper.canCopy(widget.userInfo)
                ? _buildListItem(
                    title: 'copy'.tr,
                    icon: CupertinoIcons.doc_on_doc,
                    onTap: () {
                      Get.back();
                      Get.toNamed(Routes.DIRECTORY, arguments: {
                        'srcDir': widget.path,
                        'srcObject': object,
                        'root': true,
                        'isCopy': true,
                        'tag': widget.tag,
                        'source': source,
                      });
                    },
                  )
                : SizedBox(),
            PermissionHelper.canDelete(widget.userInfo)
                ? _buildListItem(
                    title: 'delete'.tr,
                    color: Colors.red,
                    icon: CupertinoIcons.trash,
                    onTap: () async {
                      Get.back();
                      await ObjectHelper.remove(
                        path: widget.path,
                        name: object.name!,
                        source: widget.source,
                        pageTag: widget.tag,
                      );
                    },
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
