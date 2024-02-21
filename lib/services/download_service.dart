import 'dart:ui';
import 'dart:isolate';

import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

// Download Isolate
const port = 'downloader_port';

typedef DownloadIsolateCallback = void Function(
  String id,
  int status,
  int progress,
);

// Download used https://pub.dev/packages/flutter_downloader
class DownloadService extends GetxService {
  static DownloadService get to => Get.find();

  // Init
  Future<DownloadService> init() async {
    await FlutterDownloader.initialize(debug: kDebugMode, ignoreSsl: true);
    return this;
  }

  // 绑定下载回调监听
  bindBackgroundIsolate(DownloadIsolateCallback callback) {
    ReceivePort _port = ReceivePort();
    bool isSuccess =
        IsolateNameServer.registerPortWithName(_port.sendPort, port);

    if (!isSuccess) {
      unbindBackgroundIsolate();
      bindBackgroundIsolate(callback);
      return;
    }
    _port.listen((dynamic data) {
      callback(data[0], data[1], data[2]);
    });
    FlutterDownloader.registerCallback(downloadCallback);
  }

  // 解绑下载回调监听
  unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping(port);
  }
}

// 下载回调
@pragma('vm:entry-point')
void downloadCallback(String id, int status, int progress) {
  final SendPort? send = IsolateNameServer.lookupPortByName(port);
  send?.send([id, status, progress]);
}
