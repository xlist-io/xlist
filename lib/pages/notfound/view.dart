import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:xlist/routes/app_pages.dart';

class NotfoundPage extends StatelessWidget {
  const NotfoundPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(10.r),
          child: GestureDetector(
            child: Center(child: Text('返回首页')),
            onTap: () => Get.offAllNamed(Routes.SPLASH),
          ),
        ),
      ),
    );
  }
}
