import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get_instance/src/extension_instance.dart';

// DeviceInfo
class DeviceInfoService extends GetxService {
  static DeviceInfoService get to => Get.find();

  // iosInfo
  late IosDeviceInfo _iosInfo;
  IosDeviceInfo get iosInfo => _iosInfo;

  // androidInfo
  late AndroidDeviceInfo _androidInfo;
  AndroidDeviceInfo get androidInfo => _androidInfo;

  // Init
  Future<DeviceInfoService> init() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (GetPlatform.isIOS) _iosInfo = await deviceInfo.iosInfo;
      if (GetPlatform.isAndroid) _androidInfo = await deviceInfo.androidInfo;
    } catch (e) {}
    return this;
  }

  // isIpad
  bool get isIpad =>
      GetPlatform.isIOS &&
      _iosInfo.utsname.machine!.toLowerCase().contains('ipad');
}
