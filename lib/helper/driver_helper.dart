import 'package:xlist/constants/index.dart';

class DriverHelper {
  /// 默认请求头
  static const Map<String, String> DEFAULT_HEADERS = {
    'User-Agent':
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
    'Accept-Language': 'zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7'
  };

  /// 获取请求头
  /// [provider] 云盘提供商
  /// [url] 下载地址
  static Map<String, String> getHeaders(String? provider, String? url) {
    Map<String, String> headers = {};
    if (provider == null) return DEFAULT_HEADERS;

    // 获取域名
    String host = '';
    if (url != null) host = Uri.parse(url).host;

    // 阿里云盘
    if (provider.startsWith(Provider.ALIYUN_DRIVE) ||
        host.contains('aliyundrive.net')) {
      headers = {'Referer': 'https://www.aliyundrive.com/'};
    }

    // 百度网盘
    if (provider.startsWith(Provider.BAIDU) || host.contains('baidupcs.com')) {
      headers = {'User-Agent': 'pan.baidu.com'};
    }

    return Map.from(DEFAULT_HEADERS)..addAll(headers);
  }
}
