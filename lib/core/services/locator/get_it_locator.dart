import 'package:dio/dio.dart';
import 'package:tabib_soft_company/core/export.dart';
import 'package:get_it/get_it.dart';
import 'package:tabib_soft_company/features/auth/data/repos/login_repo.dart';
import 'package:tabib_soft_company/features/auth/presentation/cubits/login_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/data/repo/customer/add_customer_repo.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/add_customer_cubit.dart';

class ServicesLocator {
  static final GetIt locator = GetIt.instance;

  static void setup() {
    // Dio & ApiService
    final Dio dio = DioFactory.getDio();
    locator.registerLazySingleton<ApiService>(() => ApiService(dio));

    // intro app
    locator.registerLazySingleton<IntroAppCubit>(() => IntroAppCubit());

    // LoginRepository
    locator.registerLazySingleton<LoginReposetory>(
      () => LoginReposetory(locator<Dio>()),
    );

    // LoginCubit
    locator.registerFactory<LoginCubit>(
      () => LoginCubit(locator<LoginReposetory>()),
    );

    // CustomerRepository
    locator.registerLazySingleton<CustomerRepository>(
      () => CustomerRepository(locator<ApiService>()),
    );

    // CustomerCubit
    locator.registerFactory<CustomerCubit>(
      () => CustomerCubit(locator<CustomerRepository>()),
    );
  }

  static IntroAppCubit get introAppCubit => locator<IntroAppCubit>();
  static LoginCubit get loginCubit => locator<LoginCubit>();
  static CustomerCubit get customerCubit => locator<CustomerCubit>();
}
