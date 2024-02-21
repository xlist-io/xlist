import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:xlist/common/index.dart';
import 'package:xlist/routes/app_pages.dart';

class SearchComponent extends StatelessWidget {
  final String path;
  SearchComponent({Key? key, required this.path}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        Get.isDarkMode ? Color.fromARGB(255, 42, 42, 45) : Colors.grey[200];
    final color = Get.isDarkMode ? Colors.grey[500] : Colors.grey[600];

    return GestureDetector(
      onTap: () => Get.toNamed(Routes.SEARCH, arguments: {'path': path}),
      child: Container(
        height: CommonUtils.isPad ? 38 : 90.h,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          children: [
            SizedBox(width: 10),
            Icon(
              CupertinoIcons.search,
              size: CommonUtils.isPad ? 23 : 55.sp,
              color: color,
            ),
            SizedBox(width: 5),
            Text(
              'search'.tr,
              style: Get.textTheme.bodyLarge?.copyWith(color: color),
            )
          ],
        ),
      ),
    );
  }
}
