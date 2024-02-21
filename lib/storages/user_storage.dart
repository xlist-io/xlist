import 'package:get_storage/get_storage.dart';

class UserStorage {
  // 初始化偏好设置存储
  static final _prefBox = () => GetStorage('UserStorage');

  // Init
  Future<UserStorage> init() async {
    await GetStorage.init('UserStorage');
    return this;
  }

  final id = ''.val('id', getBox: _prefBox); // UserId
  final token = ''.val('token', getBox: _prefBox); // Token
  final serverId = 0.val('serverId', getBox: _prefBox); // ServerId
  final serverUrl = ''.val('serverUrl', getBox: _prefBox); // serverUrl
}
