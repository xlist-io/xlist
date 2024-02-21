import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:xlist/common/index.dart';

class TextFieldHelper {
  static createCupertino({
    TextEditingController? controller,
    String title = '',
    String placeholder = '',
    bool isRequired = false,
    EdgeInsetsGeometry? padding,
    TextInputType keyboardType = TextInputType.text,
  }) {
    Widget _title = Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: CommonUtils.isPad ? 15 : 35.sp,
            color: Get.theme.colorScheme.onBackground.withOpacity(0.9),
          ),
        ),
        SizedBox(width: CommonUtils.isPad ? 5 : 10.w),
        isRequired
            ? Text('*', style: TextStyle(color: Colors.red))
            : SizedBox(),
      ],
    );

    return Container(
      padding: padding ??
          EdgeInsets.only(
            left: CommonUtils.isPad ? 15 : 30.r,
            right: CommonUtils.isPad ? 15 : 30.r,
            top: CommonUtils.isPad ? 10 : 30.r,
            bottom: 0.r,
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title.isEmpty ? SizedBox() : _title,
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              isDense: true,
              hintText: placeholder,
              hintStyle:
                  Get.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]!),
              contentPadding: EdgeInsets.only(top: 10.h, bottom: 20.h),
              fillColor: Colors.transparent,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }
}
