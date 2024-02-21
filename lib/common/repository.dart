import 'package:dio/dio.dart';
import 'package:xlist/services/dio_service.dart';

class Repository {
  Repository() {}

  // Dio.get
  static Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? parameters,
  }) {
    return DioService.to.dio.get(path, queryParameters: parameters);
  }

  // Dio.post
  static Future<Response<T>> post<T>(String path,
      {dynamic data, Options? options}) {
    return DioService.to.dio.post(path, data: data, options: options);
  }
}
