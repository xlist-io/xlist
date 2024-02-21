import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:xlist/gen/index.dart';
import 'package:xlist/helper/index.dart';
import 'package:xlist/models/index.dart';
import 'package:xlist/common/index.dart';
import 'package:xlist/constants/index.dart';

class ObjectListItem extends StatefulWidget {
  final ObjectModel object;
  final bool isShowPreview;

  const ObjectListItem({
    Key? key,
    required this.object,
    required this.isShowPreview,
  }) : super(key: key);

  @override
  _ObjectListItemState createState() => _ObjectListItemState();
}

class _ObjectListItemState extends State<ObjectListItem>
    with AutomaticKeepAliveClientMixin {
  ObjectModel get object => widget.object;

  /// 构建图标
  Widget _buildIcon() {
    if (widget.isShowPreview &&
        object.thumb != null &&
        object.thumb!.isNotEmpty) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: CommonUtils.isPad ? 60 : 130.sp,
            height: CommonUtils.isPad ? 60 : 130.sp,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.r),
              child: CachedNetworkImage(
                imageUrl: object.thumb!,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    CupertinoActivityIndicator(radius: 8.0),
                errorWidget: (context, url, error) =>
                    Assets.common.logo.image(),
              ),
            ),
          ),
          PreviewHelper.isVideo(object.name ?? '')
              ? Positioned(
                  bottom: 0,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.all(2.r),
                    child: Icon(
                      CupertinoIcons.video_camera_solid,
                      size: CommonUtils.isPad ? 20 : 35.sp,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                )
              : SizedBox(),
        ],
      );
    }

    return Icon(
      FileType.getIcon(object.type ?? 0, object.name ?? ''),
      size: CommonUtils.isPad ? 60 : 130.sp,
      color: Get.theme.primaryColor,
    );
  }

  /// 构建列表项
  Widget _buildTitleAndTime() {
    // 格式化时间
    final modified = object.modified == null
        ? ''
        : '${Jiffy.parseFromDateTime(object.modified!).format(pattern: 'yyyy/MM/dd')} - ';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: object.isDir! ? 750.w : 800.w,
          child: Text(
            object.name ?? '',
            maxLines: 2,
            style: Get.textTheme.bodyLarge,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(height: 7.h),
        Text(
          '${modified}${object.isDir! ? '∞' : CommonUtils.formatFileSize(object.size!)}',
          style: Get.textTheme.bodySmall,
        ),
      ],
    );
  }

  /// 构建箭头
  Widget _buildChevron() {
    if (object.isDir != true) return SizedBox();
    return Padding(
      padding: EdgeInsets.only(right: 20.r),
      child: CupertinoListTileChevron(),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin

    return Container(
      padding: EdgeInsets.only(
          top: CommonUtils.isPad ? 5 : 20.r,
          bottom: CommonUtils.isPad ? 5 : 10.r),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.only(left: CommonUtils.isPad ? 15 : 30.r),
            child: Row(
              children: [
                _buildIcon(),
                SizedBox(width: CommonUtils.isPad ? 15 : 30.w),
                _buildTitleAndTime(),
              ],
            ),
          ),
          _buildChevron(),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
