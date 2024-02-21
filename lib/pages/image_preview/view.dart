import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:xlist/pages/image_preview/index.dart';

class ImagePreviewPage extends GetView<ImagePreviewController> {
  const ImagePreviewPage({Key? key}) : super(key: key);

  /// 页面指示器
  Widget _buildExtendedPageIndicator() {
    return Positioned(
      left: 0,
      right: 50.r,
      bottom: 60.r,
      child: AnimatedOpacity(
        opacity: controller.isDragUpdate.value ? 0.0 : 1,
        duration: Duration(milliseconds: 300),
        child: Container(
          alignment: Alignment.bottomRight,
          child: Text(
            '${controller.currentIndex.value + 1}/${controller.objects.length}',
            style: Get.textTheme.bodySmall?.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  /// 图片
  /// [url] 图片地址
  Widget _buildNetworkImage(String url) {
    return SingleChildScrollView(
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.fitWidth,
        httpHeaders: controller.imageHeaders,
        placeholder: (context, url) => CupertinoActivityIndicator(),
        errorWidget: (context, url, error) => Column(
          children: [
            Icon(
              CupertinoIcons.wifi_exclamationmark,
              size: 100.sp,
              color: Colors.grey,
            ),
            SizedBox(height: 10.h),
            Text(
              error.toString(),
              style: Get.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// 图片预览
  Widget _buildPhotoViewGallery() {
    if (controller.imageHeaders.isEmpty) {
      return Center(child: CupertinoActivityIndicator());
    }

    return PhotoViewGallery.builder(
      wantKeepAlive: true,
      pageController: controller.pageController,
      onPageChanged: controller.onPageChanged,
      itemCount: controller.imageUrls.length,
      builder: (context, index) {
        return PhotoViewGalleryPageOptions.customChild(
          minScale: PhotoViewComputedScale.contained * 1.0,
          maxScale: PhotoViewComputedScale.covered * 2.0,
          child: Obx(
            () => Center(
              child: _buildNetworkImage(controller.imageUrls[index]),
            ),
          ),
        );
      },
      backgroundDecoration: BoxDecoration(color: Colors.transparent),
      loadingBuilder: (context, event) =>
          Center(child: CupertinoActivityIndicator()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DismissiblePage(
      onDismissed: () => Get.back(),
      isFullScreen: true,
      direction: DismissiblePageDismissDirection.vertical,
      backgroundColor: Colors.black,
      startingOpacity: 1.0,
      onDragUpdate: (details) {
        controller.isDragUpdate.value = details.opacity != 1.0;
      },
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () => Get.back(),
          onLongPress: () => controller.moreActionSheet(),
          child: CupertinoPageScaffold(
            backgroundColor: Colors.transparent,
            child: DefaultTextStyle(
              style: TextStyle(color: Colors.white),
              child: Obx(
                () => Stack(
                  children: [
                    _buildPhotoViewGallery(),
                    _buildExtendedPageIndicator(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
