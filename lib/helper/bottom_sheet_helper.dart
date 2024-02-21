import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BottomSheetHelper {
  /// 显示底部弹窗 - 无顶部控制器
  /// [child] is a widget
  static showBottomSheet(
    Widget child, {
    bool expand = true,
    bool useRootNavigator = true,
  }) async {
    return showCupertinoModalBottomSheet(
      expand: expand,
      useRootNavigator: useRootNavigator,
      context: Get.context!,
      backgroundColor: Colors.transparent,
      builder: (context) => child,
    );
  }

  /// 显示底部弹窗 - 带有顶部控制器
  /// [child] is a widget
  static showBarBottomSheet(Widget child) async {
    return showBarModalBottomSheet(
      context: Get.context!,
      bounce: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      topControl: Container(
        width: 135.r,
        height: 10.r,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(15.r),
        ),
      ),
      builder: (context) => child,
    );
  }
}
