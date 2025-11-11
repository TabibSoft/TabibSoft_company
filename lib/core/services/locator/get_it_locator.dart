import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:tabib_soft_company/core/export.dart';
import 'package:tabib_soft_company/features/auth/data/repos/login_repo.dart';
import 'package:tabib_soft_company/features/auth/presentation/cubits/login_cubit.dart';
import 'package:tabib_soft_company/features/programmers/data/repo/engineer_repo.dart';
import 'package:tabib_soft_company/features/programmers/data/repo/report_repository.dart';
import 'package:tabib_soft_company/features/programmers/data/repo/task_repository.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/engineer_cubit.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/report_cubit.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/task_cubit.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/data/repos/notes/add_note_repository.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/data/repos/notes/sales_details_repo.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/data/repos/sales_repo.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/cubits/notes/add_note_cubit.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/cubits/notes/sales_details_cubit.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/cubits/sales_cubit.dart';
import 'package:tabib_soft_company/features/sales/notifications/data/repo/notification_repo.dart';
import 'package:tabib_soft_company/features/sales/notifications/presentation/cubits/notification_cubit.dart';
import 'package:tabib_soft_company/features/sales/today_calls/data/repo/today_call_repo.dart';
import 'package:tabib_soft_company/features/sales/today_calls/presentation/cubit/today_call_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/data/repo/add_customer/add_customer_repo.dart';
import 'package:tabib_soft_company/features/technical_support/data/repo/add_customer/product_repo.dart';
import 'package:tabib_soft_company/features/technical_support/data/repo/customer/customer_repo.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/add_customer/add_cusomer_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/add_customer/product_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/customer_cubit.dart';

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
      () => LoginReposetory(locator()),
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

    // EngineerRepository
    locator.registerLazySingleton<EngineerRepository>(
      () => EngineerRepository(locator<ApiService>()),
    );

    // EngineerCubit
    locator.registerFactory<EngineerCubit>(
      () => EngineerCubit(locator<EngineerRepository>()),
    );

    // TaskRepository
    locator.registerLazySingleton<TaskRepository>(
      () => TaskRepository(locator<ApiService>()),
    );

    // TaskCubit
    locator.registerFactory<TaskCubit>(
      () => TaskCubit(locator<TaskRepository>()),
    );

    // ReportRepository
    locator.registerLazySingleton<ReportRepository>(
      () => ReportRepository(locator<ApiService>()),
    );

    // ReportCubit
    locator.registerFactory<ReportCubit>(
      () => ReportCubit(locator<ReportRepository>()),
    );

    // Sales
    locator.registerFactory<SalesCubit>(
      () => SalesCubit(locator<SalesRepository>()),
    );

    locator.registerLazySingleton<SalesRepository>(
      () => SalesRepository(locator<ApiService>()),
    );

    // // SalesDetailCubit (التعليقات دي خليها إذا مش محتاجها حالياً)
    // locator.registerFactory<SalesDetailCubit>(
    //   () => SalesDetailCubit(locator<SalesDetailsRepository>()),
    // );

    // // InstallationRepository (إذا محتاجها في المستقبل)
    // locator.registerLazySingleton<InstallationRepository>(
    //   () => InstallationRepository(locator<ApiService>()),
    // );

    // // InstallationCubit
    // locator.registerFactory<InstallationCubit>(
    //   () => InstallationCubit(locator<InstallationRepository>()),
    // );

    // Add Customer
    locator.registerLazySingleton<AddCustomerRepository>(
      () => AddCustomerRepository(locator<ApiService>()),
    );
    locator.registerFactory<AddCustomerCubit>(
      () => AddCustomerCubit(locator<AddCustomerRepository>()),
    );

    // Product
    locator.registerLazySingleton<ProductRepository>(
      () => ProductRepository(locator<ApiService>()),
    );
    locator.registerFactory<ProductCubit>(
      () => ProductCubit(locator<ProductRepository>()),
    );

    // SalesDetails (التسجيل الوحيد هنا)
    locator.registerFactory<SalesDetailsCubit>(
      () => SalesDetailsCubit(locator<SalesDetailsRepository>()),
    );

    locator.registerLazySingleton<SalesDetailsRepository>(
      () => SalesDetailsRepository(locator<ApiService>()),
    );

    // Add Note
    locator.registerLazySingleton<AddNoteRepository>(
      () => AddNoteRepository(locator<ApiService>()),
    );

    locator.registerFactory<AddNoteCubit>(
      () => AddNoteCubit(locator<AddNoteRepository>()),
    );

    // Notifications
    locator.registerLazySingleton<NotificationRepository>(
      () => NotificationRepository(locator<ApiService>()),
    );

    locator.registerFactory<NotificationCubit>(
      () => NotificationCubit(locator<NotificationRepository>()),
    );

    // Today Calls
    locator.registerLazySingleton<TodayCallsRepository>(
      () => TodayCallsRepository(locator<ApiService>()),
    );

    locator.registerFactory<TodayCallsCubit>(
      () => TodayCallsCubit(locator<TodayCallsRepository>()),
    );
  }

  static IntroAppCubit get introAppCubit => locator<IntroAppCubit>();
  static LoginCubit get loginCubit => locator<LoginCubit>();
  static CustomerCubit get customerCubit => locator<CustomerCubit>();
  static EngineerCubit get engineerCubit => locator<EngineerCubit>();
  static TaskCubit get taskCubit => locator<TaskCubit>();
  static ReportCubit get reportCubit => locator<ReportCubit>();
  static SalesCubit get salesCubit => locator<SalesCubit>();
  // static SalesDetailCubit get salesDetailCubit => locator<SalesDetailCubit>();
  static AddCustomerCubit get addCustomerCubit => locator<AddCustomerCubit>();
  static ProductCubit get productCubit => locator<ProductCubit>();
  // static InstallationCubit get installationCubit => locator<InstallationCubit>();

  static AddNoteCubit get addNoteCubit => locator<AddNoteCubit>();
  static NotificationCubit get notificationCubit =>
      locator<NotificationCubit>(); // Added
  static TodayCallsCubit get todayCallsCubit =>
      locator<TodayCallsCubit>(); // Added
}