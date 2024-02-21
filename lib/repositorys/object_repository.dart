import 'package:dio/dio.dart';
import 'package:get/get.dart' hide MultipartFile;

import 'package:xlist/common/index.dart';
import 'package:xlist/models/index.dart';
import 'package:xlist/services/index.dart';
import 'package:xlist/storages/index.dart';
import 'package:xlist/pages/homepage/index.dart';

class ObjectRepository extends Repository {
  ObjectRepository();

  /// 获取对象信息
  static Future<ObjectModel> get({
    required String path,
    String password = '',
    int retry = 0,
  }) async {
    final url = Get.find<UserStorage>().serverUrl.val;
    final response = await Repository.post(
      '${url}/api/fs/get',
      data: {
        'path': path,
        'password': password,
      },
    );

    // 未登录
    if (response.data['code'] == 401 && retry < 3) {
      final _serverId = Get.find<UserStorage>().serverId.val;
      final server =
          await DatabaseService.to.database.serverDao.findServerById(_serverId);
      if (server != null) {
        final _controller = Get.find<HomepageController>();
        await _controller.resetUserToken(server, force: true);
        return await ObjectRepository.get(
            path: path, password: password, retry: retry + 1);
      }
    }

    // 获取失败 重试三次
    if (response.data['code'] != 200 && retry < 3) {
      return await ObjectRepository.get(
          path: path, password: password, retry: retry + 1);
    }

    // 错误信息
    if (response.data['code'] != 200) throw Exception(response.data['message']);
    return ObjectModel.fromJson(response.data['data']);
  }

  /// 获取对象列表
  static Future<dynamic> getList({
    required String path,
    int page = 1,
    int pageSize = 0,
    String password = '',
    bool refresh = false,
  }) async {
    final url = Get.find<UserStorage>().serverUrl.val;
    final response = await Repository.post(
      '${url}/api/fs/list',
      data: {
        'path': path,
        'page': page,
        'per_page': pageSize,
        'password': password,
        'refresh': refresh,
      },
    );

    return response.data;
  }

  /// 重命名
  /// [path] 文件路径
  /// [name] 文件名称
  static Future<dynamic> rename({
    required String path,
    required String name,
  }) async {
    final url = Get.find<UserStorage>().serverUrl.val;
    final response = await Repository.post(
      '${url}/api/fs/rename',
      data: {'path': path, 'name': name},
    );

    return response.data;
  }

  /// 移动
  /// [srcDir] 源路径
  /// [dstDir] 目标路径
  /// [name] 文件名称
  static Future<dynamic> move({
    required String srcDir,
    required String dstDir,
    required String name,
  }) async {
    final url = Get.find<UserStorage>().serverUrl.val;
    final response = await Repository.post(
      '${url}/api/fs/move',
      data: {
        'src_dir': srcDir,
        'dst_dir': dstDir,
        'names': [name]
      },
    );

    return response.data;
  }

  /// 复制
  /// [srcDir] 源路径
  /// [dstDir] 目标路径
  /// [name] 文件名称
  static Future<dynamic> copy({
    required String srcDir,
    required String dstDir,
    required String name,
  }) async {
    final url = Get.find<UserStorage>().serverUrl.val;
    final response = await Repository.post(
      '${url}/api/fs/copy',
      data: {
        'src_dir': srcDir,
        'dst_dir': dstDir,
        'names': [name]
      },
    );

    return response.data;
  }

  /// 删除
  /// [path] 文件路径
  /// [name] 文件名称
  static Future<dynamic> remove({
    required String path,
    required String name,
  }) async {
    final url = Get.find<UserStorage>().serverUrl.val;
    final response = await Repository.post(
      '${url}/api/fs/remove',
      data: {
        'dir': path,
        'names': [name]
      },
    );

    return response.data;
  }

  /// 新建文件夹
  /// [path] 文件路径
  static Future<dynamic> mkdir({
    required String path,
  }) async {
    final url = Get.find<UserStorage>().serverUrl.val;
    final response = await Repository.post(
      '${url}/api/fs/mkdir',
      data: {'path': path},
    );

    return response.data;
  }

  /// 上传文件
  static Future<dynamic> put({
    required List<int> fileData,
    required String fileName,
    required String remotePath,
    String password = '',
  }) async {
    final url = Get.find<UserStorage>().serverUrl.val;
    final response = await DioService.to.dio.put(
      '${url}/api/fs/put',
      options: Options(
        contentType: 'multipart/form-data',
        headers: {
          'File-Path': Uri.encodeComponent('${remotePath}/${fileName}'),
          'Password': password,
          'Content-Length': fileData.length,
        },
      ),
      data: MultipartFile.fromBytes(fileData).finalize(),
    );

    return response.data;
  }

  // 获取目录列表
  static Future<dynamic> getDirs({
    required String path,
    String password = '',
    bool force_root = false,
  }) async {
    final url = Get.find<UserStorage>().serverUrl.val;
    final response = await Repository.post(
      '${url}/api/fs/dirs',
      data: {
        'path': path,
        'password': password,
        'force_root': force_root,
      },
    );

    return response.data;
  }

  /// 搜索
  static Future<List<FsSearchModel>> search({
    required String keywords,
    required int page,
    required int pageSize,
    required String parent,
    required String password,
  }) async {
    final url = Get.find<UserStorage>().serverUrl.val;
    final response = await Repository.post(
      '${url}/api/fs/search',
      data: {
        'keywords': keywords,
        'page': page,
        'per_page': pageSize,
        'parent': parent,
        'password': password,
      },
    );

    final List<FsSearchModel> models = [];
    final data = response.data['data']['content'] ?? [];
    data.map((d) => models.add(FsSearchModel.fromJson(d))).toList();

    return models;
  }
}
