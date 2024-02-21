import 'package:get_storage/get_storage.dart';

class CommonStorage {
  // 通用存储
  static final _prefBox = () => GetStorage();

  // 存储上一次剪切板的数据
  final clipboardText = ''.val('clipboardText', getBox: _prefBox);
  final themeMode = 'system'.val('themeMode', getBox: _prefBox);
}
