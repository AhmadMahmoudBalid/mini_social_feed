import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'auth_interceptor.dart';

class ApiClient {
  final Dio _dio;

  ApiClient() : _dio = Dio() {
    _dio.options.baseUrl = 'http://161.97.64.130:8081/api';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.interceptors.add(AuthInterceptor());
  }

  Dio get dio => _dio;
}

void setupDependencies() {
  GetIt.I.registerSingleton<ApiClient>(ApiClient());
}
