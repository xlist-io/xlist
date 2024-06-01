import 'package:get/get.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class BrowserService extends GetxService {
  static BrowserService get to => Get.find();

  late final InAppBrowser _inAppBrowser;
  late final ChromeSafariBrowser _chromeSafariBrowser;

  @override
  void onInit() {
    super.onInit();

    // Init
    _inAppBrowser = DeupInAppBrowser();
    _chromeSafariBrowser = DeupChromeSafariBrowser();
  }

  // Open Browser
  open(String url) {
    // Android
    if (GetPlatform.isAndroid) {
      _inAppBrowser.openUrlRequest(urlRequest: URLRequest(url: WebUri(url)));
    }

    // IOS
    if (GetPlatform.isIOS) {
      _chromeSafariBrowser.open(url: WebUri(url));
    }
  }
}

class DeupChromeSafariBrowser extends ChromeSafariBrowser {
  @override
  void onOpened() {}

  // @override
  // void onCompletedInitialLoad() {}

  @override
  void onClosed() {}
}

class DeupInAppBrowser extends InAppBrowser {
  @override
  Future onBrowserCreated() async {}

  @override
  Future onLoadStart(url) async {}

  @override
  Future onLoadStop(url) async {}

  @override
  void onLoadError(url, code, message) {}

  @override
  void onProgressChanged(progress) {}

  @override
  void onExit() {}
}
