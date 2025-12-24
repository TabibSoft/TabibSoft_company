import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:tabib_soft_company/core/export.dart';

class DioFactory {
  DioFactory._();

  static Dio? dio;

  static Dio getDio() {
    const Duration timeOut = Duration(seconds: 60);

    if (dio == null) {
      dio = Dio();
      dio!
        ..options.connectTimeout = timeOut
        ..options.receiveTimeout = timeOut;
      addDioInterceptor();
      return dio!;
    } else {
      return dio!;
    }
  }

  static void addDioInterceptor() {
    dio?.interceptors.addAll([
      PrettyDioLogger(
        requestBody: true,
        requestHeader: true,
        responseHeader: true,
        maxWidth: 200, // Increased to prevent URL splitting
      ),
      CookieInterceptor(),
    ]);
  }
}

class CookieInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final String token = CacheHelper.getString(key: 'loginToken');

    if (token != '') {
      options.headers['Authorization'] = 'Bearer $token';
    }

    super.onRequest(options, handler);
  }
}
