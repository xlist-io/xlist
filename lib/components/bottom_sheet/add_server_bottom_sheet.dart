import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart' hide Response;
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:xlist/common/index.dart';
import 'package:xlist/helper/index.dart';
import 'package:xlist/storages/index.dart';
import 'package:xlist/services/index.dart';
import 'package:xlist/constants/index.dart';
import 'package:xlist/repositorys/index.dart';
import 'package:xlist/database/entity/index.dart';

class AddServerBottomSheet extends StatefulWidget {
  const AddServerBottomSheet({Key? key}) : super(key: key);

  @override
  _AddServerBottomSheetState createState() => _AddServerBottomSheetState();
}

class _AddServerBottomSheetState extends State<AddServerBottomSheet> {
  TextEditingController _urlController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  // 是否是有效的服务器地址
  bool _isUrlValid = false;
  ServerEntity? _server;
  List<ServerEntity> _serverList = [];

  @override
  void initState() {
    super.initState();
    _getServerList(); // 获取服务器列表
  }

  // 获取服务器列表
  void _getServerList() async {
    _serverList = await DatabaseService.to.database.serverDao.findAllServer();
    setState(() {});
  }

  /// 测试匿名用户
  Future<bool> _testGuestUser({bool showToast = true}) async {
    String url = _urlController.text.trim();

    // 去除最后一个 /
    if (url.endsWith('/')) url = url.substring(0, url.length - 1);

    // 判断是否是 http 或者 https 开头
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      SmartDialog.showToast('add_server_toast_url_invalid'.tr);
      return false;
    }

    // 获取匿名用户信息
    try {
      final response = await Dio().get('${url}/api/me');
      if (response.data['code'] == 200) {
        _isUrlValid = true;
        _server = ServerEntity(
            url: url, type: ServerType.ALIST, username: 'guest', password: '');
      } else {
        _isUrlValid = false;
      }
    } catch (e) {
      _isUrlValid = false;
    }

    setState(() {});
    if (showToast)
      _isUrlValid
          ? SmartDialog.showToast('add_server_toast_pass'.tr)
          : SmartDialog.showToast('add_server_toast_anonymous_fail'.tr);

    // 返回是否有效
    return _isUrlValid;
  }

  /// 测试服务器地址和用户名
  Future<bool> _testUrlAndUser({bool showToast = true}) async {
    try {
      String url = _urlController.text.trim();
      String username = _usernameController.text.trim();
      String password = _passwordController.text.trim();

      // 检查是否填写完整
      if (url.isEmpty) {
        if (showToast) SmartDialog.showToast('add_server_toast_url_empty'.tr);
        return false;
      }

      // 如果没有填用户名
      if (username.isEmpty && password.isEmpty) {
        return _testGuestUser(showToast: showToast);
      }

      // 去除最后一个 /
      if (url.endsWith('/')) url = url.substring(0, url.length - 1);

      // 判断是否是 http 或者 https 开头
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        SmartDialog.showToast('add_server_toast_url_invalid'.tr);
        return false;
      }

      // 登录测试
      Response response = await Dio().post(
        '${url}/api/auth/login',
        data: {'username': username, 'password': password},
      );

      // 2FA 验证
      if (response.data['code'] == 402) {
        SmartDialog.dismiss();
        final data = await showTextInputDialog(
          context: Get.context!,
          title: 'add_server_dialog_2fa_title'.tr,
          okLabel: 'confirm'.tr,
          cancelLabel: 'cancel'.tr,
          textFields: [
            DialogTextField(hintText: 'add_server_dialog_2fa_hint'.tr),
          ],
        );
        if (data == null || data.isEmpty) return false;
        if (data.first.isEmpty) return false;

        // 重新登录
        SmartDialog.showLoading();
        response = await Dio().post('${url}/api/auth/login', data: {
          'username': username,
          'password': password,
          'otp_code': data.first
        });

        // 2FA 验证失败
        if (response.data['code'] == 402) {
          throw Exception('add_server_toast_2fa_error'.tr);
        }
      }

      if (response.data['code'] != 200) {
        throw Exception(response.data['message']);
      }

      // 获取 token
      final token = response.data['data']['token'];

      // 如果是第一个服务器，保存 token
      if (_serverList.isEmpty && !showToast && token != null) {
        Get.find<UserStorage>().token.val = token;
        Get.find<UserStorage>().serverUrl.val = url;

        // 获取用户信息
        final userInfo = await UserRepository.me();
        Get.find<UserStorage>().id.val = userInfo.id.toString();
      }

      _isUrlValid = token != null;
      _server = ServerEntity(
        url: url,
        type: ServerType.ALIST,
        username: username,
        password: password,
      );
    } catch (e) {
      final error = e.toString().replaceAll('DioError ', '');
      SmartDialog.showToast(error);
      _isUrlValid = false;
    }

    setState(() {});
    SmartDialog.dismiss();
    if (showToast)
      _isUrlValid
          ? SmartDialog.showToast('add_server_toast_pass'.tr)
          : SmartDialog.showToast('add_server_toast_url_user_invalid'.tr);

    // 返回是否有效
    return _isUrlValid;
  }

  /// 保存服务器信息
  void _saveServer() async {
    SmartDialog.showLoading();
    if (!await _testUrlAndUser(showToast: false)) {
      SmartDialog.showToast('add_server_toast_url_user_invalid'.tr);
      SmartDialog.dismiss();
      return;
    }

    // 保存服务器信息
    final serverId =
        await DatabaseService.to.database.serverDao.insertServer(_server!);

    // 提示信息
    SmartDialog.dismiss();
    SmartDialog.showToast('toast_save_success'.tr);
    Get.back(
      result: ServerEntity(
        id: serverId,
        url: _server!.url,
        type: _server!.type,
        username: _server!.username,
        password: _server!.password,
      ),
    );
  }

  /// 构建导航栏
  CupertinoNavigationBar _buildNavigationBar() {
    return CupertinoNavigationBar(
      backgroundColor: CommonUtils.backgroundColor,
      transitionBetweenRoutes: false,
      border: Border.all(width: 0, color: Colors.transparent),
      leading: CupertinoButton(
        padding: EdgeInsets.zero,
        alignment: Alignment.centerLeft,
        child: Text('close'.tr),
        onPressed: () => Get.back(),
      ),
      middle: Text('add_server_title'.tr, style: Get.textTheme.titleMedium),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        alignment: Alignment.centerRight,
        child: Text('test'.tr),
        onPressed: _testUrlAndUser,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: _buildNavigationBar(),
      backgroundColor: CommonUtils.backgroundColor,
      child: SingleChildScrollView(
        child: Column(
          children: [
            CupertinoListSection.insetGrouped(
              backgroundColor: CommonUtils.backgroundColor,
              dividerMargin: 0.r,
              additionalDividerMargin: CommonUtils.isPad ? 15 : 20.r,
              hasLeading: false,
              header: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  'add_server_section_header'.tr,
                  style: Get.textTheme.bodySmall,
                ),
              ),
              footer: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  'add_server_section_footer'.tr,
                  style: Get.textTheme.bodySmall,
                ),
              ),
              children: [
                TextFieldHelper.createCupertino(
                  controller: _urlController,
                  title: 'add_server_textfield_url'.tr,
                  placeholder: 'add_server_textfield_url_hint'.tr,
                  isRequired: true,
                  keyboardType: TextInputType.url,
                ),
                TextFieldHelper.createCupertino(
                  controller: _usernameController,
                  title: 'add_server_textfield_username'.tr,
                  placeholder: 'add_server_textfield_username_hint'.tr,
                ),
                TextFieldHelper.createCupertino(
                  controller: _passwordController,
                  title: 'add_server_textfield_password'.tr,
                  placeholder: 'add_server_textfield_password_hint'.tr,
                  padding: EdgeInsets.only(
                    left: CommonUtils.isPad ? 15 : 30.r,
                    right: CommonUtils.isPad ? 15 : 30.r,
                    top: CommonUtils.isPad ? 10 : 30.r,
                    bottom: CommonUtils.isPad ? 5 : 20.r,
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 100.r, vertical: 30.r),
              child: ButtonHelper.createElevatedButton(
                'save'.tr,
                onPressed: _saveServer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
