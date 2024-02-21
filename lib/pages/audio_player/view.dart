import 'dart:math';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:xlist/gen/index.dart';
import 'package:xlist/helper/index.dart';
import 'package:xlist/common/index.dart';
import 'package:xlist/constants/index.dart';
import 'package:xlist/components/index.dart';
import 'package:xlist/pages/audio_player/index.dart';

class AudioPlayerPage extends GetView<AudioPlayerController> {
  const AudioPlayerPage({Key? key}) : super(key: key);

  /// 构建下拉按钮
  Widget _buildPullDownButton() {
    List<PullDownMenuEntry> items = [];

    // 收藏
    items.add(PullDownMenuItem(
      title: 'favorite'.tr,
      onTap: () => controller.favorite(),
    ));

    items.addAll([
      PullDownMenuItem(
        title: 'play_speed'.tr,
        onTap: () => controller.changeSpeed(),
      ),
      PullDownMenuItem(
        title: 'pull_down_copy_link'.tr,
        onTap: () => controller.copyLink(),
      ),
      PullDownMenuItem(
        title: 'pull_down_download_file'.tr,
        onTap: () => controller.download(),
      ),
    ]);

    return PullDownButton(
      itemBuilder: (context) => items,
      buttonBuilder: (context, showMenu) => CupertinoButton(
        onPressed: showMenu,
        padding: EdgeInsets.zero,
        alignment: Alignment.centerRight,
        child: Icon(
          CupertinoIcons.ellipsis_circle,
          size: CommonUtils.navIconSize,
        ),
      ),
    );
  }

  // NavigationBar
  CupertinoNavigationBar _buildNavigationBar() {
    return CupertinoNavigationBar(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      border: Border.all(width: 0, color: Colors.transparent),
      transitionBetweenRoutes: false,
      leading: CupertinoButton(
        padding: EdgeInsets.zero,
        alignment: Alignment.centerLeft,
        child: Icon(CupertinoIcons.chevron_down,
            size: CommonUtils.isPad ? 25 : 70.sp),
        onPressed: () => Get.back(),
      ),
      trailing: _buildPullDownButton(),
    );
  }

  /// 封面图
  Widget _buildCover() {
    return Hero(
      tag: 'cover',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50.r),
        child: CachedNetworkImage(
          imageUrl: controller.object.value.thumb ?? '',
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              CupertinoActivityIndicator(radius: 13.0),
          errorWidget: (context, url, error) => Assets.common.logo.image(),
        ),
      ),
    );
  }

  /// 构建单个文件
  Widget _buildSingleFile() {
    return Container(
      key: PageStorageKey('single'),
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(top: CommonUtils.isPad ? 20 : 100.h),
      child: Column(
        children: [
          Container(
            width: CommonUtils.isPad ? 300 : 700.r,
            height: CommonUtils.isPad ? 300 : 700.r,
            child: _buildCover(),
          ),
          SizedBox(height: 50.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 50.w),
            child: Text(
              CommonUtils.formatFileNme(controller.currentName.value),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 播放列表
  Widget _buildPlaylist() {
    return Container(
      key: PageStorageKey('playlist'),
      padding: EdgeInsets.only(
          top: CommonUtils.isPad ? 20 : 100.h, left: 50.w, right: 50.w),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: CommonUtils.isPad ? 150 : 300.r,
                height: CommonUtils.isPad ? 150 : 300.r,
                child: _buildCover(),
              ),
              SizedBox(width: 50.w),
              Expanded(
                child: Text(
                  CommonUtils.formatFileNme(controller.currentName.value),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 60.h),
          Expanded(
            child: ListView.builder(
              physics: AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              itemCount: controller.objects.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => controller.changePlaylist(index),
                  child: Container(
                    height: CommonUtils.isPad ? 50 : 100.h,
                    child: Text(
                      CommonUtils.formatFileNme(
                          controller.objects[index].name!),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Get.textTheme.titleMedium?.copyWith(
                        color: controller.currentIndex.value == index
                            ? Get.theme.primaryColor
                            : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 播放进度
  Widget _buildFijkSlider() {
    // 计算进度时间
    double duration = controller.duration.value.inMilliseconds.toDouble();
    double currentValue = controller.seekPos > 0
        ? controller.seekPos
        : controller.currentPos.value.inMilliseconds.toDouble();
    currentValue = min(currentValue, duration);
    currentValue = max(currentValue, 0);

    // 计算缓存进度
    double cacheValue = controller.bufferPos.value.inMilliseconds.toDouble();
    cacheValue = min(cacheValue, duration);
    cacheValue = max(cacheValue, 0);

    if (controller.duration.value.inMilliseconds == 0) {
      return NewFijkSlider(
        colors: NewFijkSliderColors(
          cursorColor: Get.theme.primaryColor,
          playedColor: Get.theme.primaryColor,
        ),
        onChangeEnd: (double value) {},
        value: 0,
        onChanged: (double value) {},
      );
    }

    return NewFijkSlider(
      colors: NewFijkSliderColors(
        cursorColor: Get.theme.primaryColor,
        playedColor: Get.theme.primaryColor,
      ),
      value: currentValue,
      cacheValue: cacheValue,
      min: 0.0,
      max: duration,
      onChanged: (v) {
        controller.seekPos = v;
      },
      onChangeEnd: (v) {
        if (controller.seekPos.toInt() == -1) return;
        controller.player.seekTo(v.toInt());
        controller.currentPos.value = Duration(
          milliseconds: controller.seekPos.toInt(),
        );
        controller.seekPos = -1;
      },
    );
  }

  /// 播放时间
  Widget _buildDuration() {
    return Container(
      height: 70.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 500.w,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 50.w),
            child: Obx(
              () => Text(
                FijkHelper.formatDuration(controller.currentPos.value),
              ),
            ),
          ),
          Container(
            width: 500.w,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 50.w),
            child: Obx(
              () => Text(
                FijkHelper.formatDuration(controller.duration.value),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建播放器控制按钮
  Widget _buildControlButton() {
    return Container(
      height: 120.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CupertinoButton(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.zero,
            child: Icon(
              CupertinoIcons.backward_end_alt_fill,
              size: CommonUtils.isPad ? 50 : 100.sp,
              color: Get.isDarkMode ? Colors.white : Colors.black87,
            ),
            onPressed: () {
              final _ct = controller;
              if (_ct.playMode.value == PlayMode.SHUFFLE) {
                _ct.changePlaylist(Random().nextInt(_ct.objects.length));
                return;
              }

              _ct.currentIndex.value == 0
                  ? _ct.changePlaylist(_ct.objects.length - 1)
                  : _ct.changePlaylist(_ct.currentIndex.value - 1);
            },
          ),
          CupertinoButton(
            alignment: Alignment.center,
            padding: EdgeInsets.zero,
            child: Obx(
              () => Icon(
                controller.isPlaying.value
                    ? CupertinoIcons.pause_fill
                    : CupertinoIcons.play_fill,
                size: CommonUtils.isPad ? 65 : 150.sp,
                color: Get.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            onPressed: () {
              controller.isPlaying.value
                  ? controller.player.pause()
                  : controller.player.start();
            },
          ),
          CupertinoButton(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.zero,
            child: Icon(
              CupertinoIcons.forward_end_alt_fill,
              size: CommonUtils.isPad ? 50 : 100.sp,
              color: Get.isDarkMode ? Colors.white : Colors.black87,
            ),
            onPressed: () {
              final _ct = controller;
              if (_ct.playMode.value == PlayMode.SHUFFLE) {
                _ct.changePlaylist(Random().nextInt(_ct.objects.length));
                return;
              }

              _ct.currentIndex.value == _ct.objects.length - 1
                  ? _ct.changePlaylist(0)
                  : _ct.changePlaylist(_ct.currentIndex.value + 1);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: _buildNavigationBar(),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              height: 1150.h,
              child: Obx(
                () => TabBarView(
                  controller: controller.tabController,
                  children: [_buildSingleFile(), _buildPlaylist()],
                ),
              ),
            ),
            SizedBox(height: 50.h),
            Container(
              height: 30.h,
              padding: EdgeInsets.symmetric(horizontal: 50.w),
              child: Obx(() => _buildFijkSlider()),
            ),
            _buildDuration(),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlButton(),
                  SizedBox(height: 50.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 100.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Obx(
                          () => CupertinoButton(
                            alignment: Alignment.centerLeft,
                            child: Icon(
                              PlayMode.getIcon(controller.playMode.value),
                              size: CommonUtils.isPad ? 30 : 70.sp,
                              color: Get.isDarkMode
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                            onPressed: () {
                              controller.playMode.value =
                                  controller.playMode.value == PlayMode.SHUFFLE
                                      ? PlayMode.LIST_LOOP
                                      : controller.playMode.value + 1;
                            },
                          ),
                        ),
                        Obx(
                          () => CupertinoButton(
                            alignment: Alignment.center,
                            child: Icon(
                              CupertinoIcons.list_bullet,
                              size: CommonUtils.isPad ? 30 : 70.sp,
                              color: controller.isPlaylist.value
                                  ? Get.theme.primaryColor
                                  : Get.isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                            ),
                            onPressed: () {
                              controller.isPlaylist.value =
                                  !controller.isPlaylist.value;
                              controller.tabController.index =
                                  controller.isPlaylist.value ? 1 : 0;
                            },
                          ),
                        ),
                        Obx(
                          () => CupertinoButton(
                            alignment: Alignment.centerRight,
                            child: Icon(
                              CupertinoIcons.clock,
                              size: CommonUtils.isPad ? 30 : 70.sp,
                              color:
                                  controller.timerDuration.value.inSeconds > 0
                                      ? Get.theme.primaryColor
                                      : Get.isDarkMode
                                          ? Colors.white
                                          : Colors.black87,
                            ),
                            onPressed: () => controller.timedShutdown(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
