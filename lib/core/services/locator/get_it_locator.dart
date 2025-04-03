import 'package:dio/dio.dart';
import 'package:tabib_soft_company/core/export.dart';
import 'package:get_it/get_it.dart';

class ServicesLocator {
  static final GetIt locator = GetIt.instance;

  static void setup() {
    // Dio & ApiService
    final Dio dio = DioFactory.getDio();
    locator.registerLazySingleton<ApiService>(() => ApiService(dio));

    // intro app
    locator.registerLazySingleton<IntroAppCubit>(() => IntroAppCubit());
  }

  static IntroAppCubit get introAppCubit => locator<IntroAppCubit>();
}
