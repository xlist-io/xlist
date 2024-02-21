import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:xlist/gen/index.dart';
import 'package:xlist/common/index.dart';
import 'package:xlist/storages/index.dart';
import 'package:xlist/pages/setting/index.dart';
import 'package:xlist/pages/homepage/index.dart';
import 'package:xlist/database/entity/index.dart';
import 'package:xlist/helper/bottom_sheet_helper.dart';
import 'package:xlist/pages/setting/server/index.dart';
import 'package:xlist/components/bottom_sheet/add_server_bottom_sheet.dart';

class ServerPage extends GetView<ServerController> {
  const ServerPage({Key? key}) : super(key: key);

  // NavigationBar
  CupertinoNavigationBar _buildNavigationBar() {
    return CupertinoNavigationBar(
      backgroundColor: CommonUtils.backgroundColor,
      border: Border.all(width: 0, color: Colors.transparent),
      leading: CommonUtils.backButton,
      middle: Text('server'.tr),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        alignment: Alignment.centerRight,
        child: Text('setting_server_new'.tr),
        onPressed: () async {
          final result =
              await BottomSheetHelper.showBottomSheet(AddServerBottomSheet());

          if (result == null) return;
          if (!(result is ServerEntity)) return;

          // 重置首页信息
          if (controller.serverList.isEmpty) {
            Get.find<UserStorage>().serverId.val = result.id!;
            Get.find<UserStorage>().serverUrl.val = result.url;

            // 重置首页信息
            final _homepageController = Get.find<HomepageController>();
            _homepageController.serverId.value = result.id!;
            await _homepageController.resetUserToken(result);
            _homepageController.getObjectList();

            // 重置设置页面信息
            final _settingController = Get.find<SettingController>();
            _settingController.serverId.value = result.id!;
            _settingController.serverInfo.value = result;

            // 重置服务器信息
            controller.serverId.value = result.id!;
          }
          controller.getServerList();
        },
      ),
    );
  }

  /// 列表项
  Widget _buildItem(int index) {
    final server = controller.serverList[index];
    return CupertinoListSection.insetGrouped(
      backgroundColor: CommonUtils.backgroundColor,
      margin: CommonUtils.isPad
          ? EdgeInsets.symmetric(horizontal: 20, vertical: 5)
          : EdgeInsets.symmetric(horizontal: 50.w, vertical: 15.h),
      children: [
        Container(
          height: CommonUtils.isPad ? 75 : 150.h,
          width: double.infinity,
          child: Slidable(
            endActionPane: ActionPane(
              motion: ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) => controller.switchServer(server),
                  backgroundColor: Get.theme.primaryColor,
                  icon: CupertinoIcons.arrow_right_arrow_left,
                  label: 'switch'.tr,
                ),
                SlidableAction(
                  onPressed: (context) => controller.deleteServer(server.id!),
                  backgroundColor: Colors.red,
                  icon: CupertinoIcons.delete,
                  label: 'delete'.tr,
                ),
              ],
            ),
            child: Row(
              children: [
                SizedBox(width: CommonUtils.isPad ? 20 : 50.w),
                Icon(
                  FontAwesomeIcons.server,
                  size: CommonUtils.navIconSize,
                  color: server.id == controller.serverId.value
                      ? Get.theme.primaryColor
                      : Colors.grey,
                ),
                SizedBox(width: CommonUtils.isPad ? 20 : 50.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: CommonUtils.isPad ? 15 : 30.h),
                    Text(
                      server.url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Get.textTheme.titleMedium,
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      server.username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Get.textTheme.bodySmall,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListView() {
    if (controller.serverList.isEmpty) {
      return Center(
        child: Column(
          children: [
            SizedBox(height: 490.h),
            Assets.images.empty.image(width: 700.r),
            SizedBox(height: 30.h),
            Text('no_data'.tr, style: Get.textTheme.bodyMedium),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: controller.serverList.length,
      itemBuilder: (context, index) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          index == 0
              ? Container(
                  padding: CommonUtils.isPad
                      ? EdgeInsets.only(left: 40, top: 30.h, bottom: 10.h)
                      : EdgeInsets.only(left: 80.w, top: 30.h, bottom: 10.h),
                  child: Text(
                    'setting_server_title'.tr,
                    style: Get.textTheme.bodySmall,
                  ),
                )
              : SizedBox(),
          _buildItem(index),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: _buildNavigationBar(),
      backgroundColor: CommonUtils.backgroundColor,
      child: Obx(
        () => controller.isFirstLoading.isTrue
            ? Center(child: CupertinoActivityIndicator())
            : _buildListView(),
      ),
    );
  }
}
