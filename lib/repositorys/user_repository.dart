import 'package:get/get.dart';

import 'package:xlist/models/user.dart';
import 'package:xlist/common/index.dart';
import 'package:xlist/storages/index.dart';

class UserRepository extends Repository {
  UserRepository();

  // 获取对象列表
  static Future<UserModel> me() async {
    final url = Get.find<UserStorage>().serverUrl.val;
    final response = await Repository.get('${url}/api/me');

    if (response.data['code'] != 200) {
      throw Exception(response.data['message']);
    }

    return UserModel.fromJson(response.data['data']);
  }
}
