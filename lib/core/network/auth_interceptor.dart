import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // إضافة token إلى header إذا كان موجوداً
    final accessToken = await _secureStorage.read(key: 'token');
    if (accessToken != null && !options.path.contains('/auth/')) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // تجديد token عند انتهاء الصلاحية
      final newToken = await _refreshToken();
      if (newToken != null) {
        // إعادة محاولة الطلب الأصلي
        final response = await _retryRequest(err.requestOptions, newToken);
        return handler.resolve(response);
      }
    }
    handler.next(err);
  }

  Future<String?> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      if (refreshToken == null) return null;

      final dio = Dio();
      final response = await dio.post(
        'http://161.97.64.130:8081/api/auth/token/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['data']['access_token'];
        final newRefreshToken = response.data['data']['refresh_token'];

        await _secureStorage.write(key: 'access_token', value: newAccessToken);
        await _secureStorage.write(
          key: 'refresh_token',
          value: newRefreshToken,
        );

        return newAccessToken;
      }
    } catch (e) {
      print('Token refresh failed: $e');
    }
    return null;
  }

  Future<Response<dynamic>> _retryRequest(
    RequestOptions requestOptions,
    String newToken,
  ) async {
    final options = Options(
      method: requestOptions.method,
      headers: {'Authorization': 'Bearer $newToken'},
    );

    final dio = Dio();
    return dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}
