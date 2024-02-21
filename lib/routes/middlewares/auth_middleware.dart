import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';

import 'package:xlist/routes/app_pages.dart';
import 'package:xlist/storages/user_storage.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // 可以在这里进行跳转前的逻辑处理
    // 判断登录
    // ...

    UserStorage _storage = Get.find<UserStorage>();
    if (GetUtils.isNullOrBlank(_storage.serverId.val)!) {
      return RouteSettings(name: Routes.HOMEPAGE);
    }
  }
}
