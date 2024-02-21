import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ToastComponent extends StatelessWidget {
  final String message;
  ToastComponent({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 15.h),
        margin: EdgeInsets.all(30.r),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          message,
          style: Get.textTheme.bodyMedium?.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
