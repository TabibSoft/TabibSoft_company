import 'package:dio/dio.dart';
import 'package:tabib_soft_company/core/export.dart';
import 'package:get_it/get_it.dart';
import 'package:tabib_soft_company/features/auth/data/repos/login_repo.dart';
import 'package:tabib_soft_company/features/auth/presentation/cubits/login_cubit.dart';

class ServicesLocator {
  static final GetIt locator = GetIt.instance;

  static void setup() {
    // Dio & ApiService
    final Dio dio = DioFactory.getDio();
    locator.registerLazySingleton<ApiService>(() => ApiService(dio));

    // intro app
    locator.registerLazySingleton<IntroAppCubit>(() => IntroAppCubit());

     // LoginRepository
    locator.registerLazySingleton<LoginRepository>(
      () => LoginRepository(apiService: locator<ApiService>()),
    );
    
    // LoginCubit
    locator.registerFactory<LoginCubit>(
      () => LoginCubit(repository: locator<LoginRepository>()),
    );
  }

  static IntroAppCubit get introAppCubit => locator<IntroAppCubit>();
  static LoginCubit get loginCubit => locator<LoginCubit>();
}
