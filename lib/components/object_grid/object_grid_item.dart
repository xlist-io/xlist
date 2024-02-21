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

class ObjectGridItem extends StatefulWidget {
  final ObjectModel object;
  final bool isShowPreview;

  const ObjectGridItem({
    Key? key,
    required this.object,
    required this.isShowPreview,
  }) : super(key: key);

  @override
  _ObjectGridItemState createState() => _ObjectGridItemState();
}

class _ObjectGridItemState extends State<ObjectGridItem>
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
            width: 65,
            height: 65,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: object.thumb!,
                fit: BoxFit.cover,
                placeholder: (context, url) => CupertinoActivityIndicator(),
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
                      size: 20,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                )
              : Container(),
        ],
      );
    }

    return Icon(
      FileType.getIcon(object.type ?? 0, object.name ?? ''),
      size: 65,
      color: Get.theme.primaryColor,
    );
  }

  /// 构建列表项
  Widget _buildTitleAndTime() {
    // 格式化时间
    final modified = object.modified == null
        ? ''
        : '${Jiffy.parseFromDateTime(object.modified!).format(pattern: 'yyyy/MM/dd')}';

    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          child: Text(
            object.name ?? '',
            maxLines: 2,
            textAlign: TextAlign.center,
            style: Get.textTheme.bodyLarge,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(height: 7.h),
        Text(
          modified,
          style: Get.textTheme.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${object.isDir! ? '∞' : CommonUtils.formatFileSize(object.size!)}',
          style: Get.textTheme.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        _buildIcon(),
        SizedBox(height: 20.h),
        _buildTitleAndTime(),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
