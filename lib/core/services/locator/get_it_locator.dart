import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:tabib_soft_company/core/export.dart';
import 'package:tabib_soft_company/features/auth/data/repos/login_repo.dart';
import 'package:tabib_soft_company/features/auth/presentation/cubits/login_cubit.dart';
import 'package:tabib_soft_company/features/modirator/data/repo/add_subscription_repo.dart';
import 'package:tabib_soft_company/features/modirator/data/repo/payment_method_repository.dart';
import 'package:tabib_soft_company/features/modirator/presentation/cubits/add_subscription_cubit.dart';
import 'package:tabib_soft_company/features/modirator/presentation/cubits/payment_method_cubit.dart';
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
import 'package:tabib_soft_company/features/home/notifications/data/repo/notification_repo.dart';
import 'package:tabib_soft_company/features/home/notifications/presentation/cubits/notification_cubit.dart';
import 'package:tabib_soft_company/features/sales/today_calls/data/repo/today_call_repo.dart';
import 'package:tabib_soft_company/features/sales/today_calls/presentation/cubit/today_call_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/data/repo/add_customer/add_customer_repo.dart';
import 'package:tabib_soft_company/features/technical_support/data/repo/add_customer/product_repo.dart';
import 'package:tabib_soft_company/features/technical_support/data/repo/customer/customer_repo.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/add_customer/add_cusomer_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/add_customer/product_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/customer_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/visits/data/repo/visit_repository.dart';
import 'package:tabib_soft_company/features/technical_support/visits/presentation/cubits/visit_cubit.dart';

class ServicesLocator {
  static final GetIt locator = GetIt.instance;

  static void setup() {
    // Dio & ApiService
    final Dio dio = DioFactory.getDio();
    locator.registerLazySingleton<ApiService>(() => ApiService(dio));

    // intro app
    locator.registerLazySingleton<IntroAppCubit>(() => IntroAppCubit());

    // Login
    locator.registerLazySingleton<LoginReposetory>(() => LoginReposetory(locator()));
    locator.registerFactory<LoginCubit>(() => LoginCubit(locator<LoginReposetory>()));

    // Customer
    locator.registerLazySingleton<CustomerRepository>(() => CustomerRepository(locator<ApiService>()));
    locator.registerFactory<CustomerCubit>(() => CustomerCubit(locator<CustomerRepository>()));

    // Engineer
    locator.registerLazySingleton<EngineerRepository>(() => EngineerRepository(locator<ApiService>()));
    locator.registerFactory<EngineerCubit>(() => EngineerCubit(locator<EngineerRepository>()));

    // Task & Report
    locator.registerLazySingleton<TaskRepository>(() => TaskRepository(locator<ApiService>()));
    locator.registerFactory<TaskCubit>(() => TaskCubit(locator<TaskRepository>()));

    locator.registerLazySingleton<ReportRepository>(() => ReportRepository(locator<ApiService>()));
    locator.registerFactory<ReportCubit>(() => ReportCubit(locator<ReportRepository>()));

    // Sales
    locator.registerLazySingleton<SalesRepository>(() => SalesRepository(locator<ApiService>()));
    locator.registerFactory<SalesCubit>(() => SalesCubit(locator<SalesRepository>()));

    // Add Customer
    locator.registerLazySingleton<AddCustomerRepository>(() => AddCustomerRepository(locator<ApiService>()));
    locator.registerFactory<AddCustomerCubit>(() => AddCustomerCubit(locator<AddCustomerRepository>()));

    // Product
    locator.registerLazySingleton<ProductRepository>(() => ProductRepository(locator<ApiService>()));
    locator.registerFactory<ProductCubit>(() => ProductCubit(locator<ProductRepository>()));

    // Sales Details
    locator.registerLazySingleton<SalesDetailsRepository>(() => SalesDetailsRepository(locator<ApiService>()));
    locator.registerFactory<SalesDetailsCubit>(() => SalesDetailsCubit(locator<SalesDetailsRepository>()));

    // Add Note
    locator.registerLazySingleton<AddNoteRepository>(() => AddNoteRepository(locator<ApiService>()));
    locator.registerFactory<AddNoteCubit>(() => AddNoteCubit(locator<AddNoteRepository>()));

    // Notifications
    locator.registerLazySingleton<NotificationRepository>(() => NotificationRepository(locator<ApiService>()));
    locator.registerFactory<NotificationCubit>(() => NotificationCubit(locator<NotificationRepository>()));

    // Today Calls
    locator.registerLazySingleton<TodayCallsRepository>(() => TodayCallsRepository(locator<ApiService>()));
    locator.registerFactory<TodayCallsCubit>(() => TodayCallsCubit(locator<TodayCallsRepository>()));

    // Subscription
    locator.registerLazySingleton<SubscriptionRepository>(
      () => SubscriptionRepository(locator<ApiService>()),
    );
    locator.registerFactory<AddSubscriptionCubit>(
      () => AddSubscriptionCubit(locator<SubscriptionRepository>()),
    );

    // Payment Methods
    locator.registerLazySingleton<PaymentMethodRepository>(
      () => PaymentMethodRepository(locator<ApiService>()),
    );
    locator.registerFactory<PaymentMethodCubit>(
      () => PaymentMethodCubit(locator<PaymentMethodRepository>()),
    );

    // Visit Repository & Cubit
    locator.registerLazySingleton<VisitRepository>(
      () => VisitRepository(locator<ApiService>()),
    );
    locator.registerFactory<VisitCubit>(
      () => VisitCubit(locator<VisitRepository>()),
    );
  }

  // Getters
  static IntroAppCubit get introAppCubit => locator<IntroAppCubit>();
  static LoginCubit get loginCubit => locator<LoginCubit>();
  static CustomerCubit get customerCubit => locator<CustomerCubit>();
  static EngineerCubit get engineerCubit => locator<EngineerCubit>();
  static TaskCubit get taskCubit => locator<TaskCubit>();
  static ReportCubit get reportCubit => locator<ReportCubit>();
  static SalesCubit get salesCubit => locator<SalesCubit>();
  static AddCustomerCubit get addCustomerCubit => locator<AddCustomerCubit>();
  static ProductCubit get productCubit => locator<ProductCubit>();
  static AddNoteCubit get addNoteCubit => locator<AddNoteCubit>();
  static NotificationCubit get notificationCubit => locator<NotificationCubit>();
  static TodayCallsCubit get todayCallsCubit => locator<TodayCallsCubit>();
  static AddSubscriptionCubit get addSubscriptionCubit => locator<AddSubscriptionCubit>();
  static PaymentMethodCubit get paymentMethodCubit => locator<PaymentMethodCubit>();
  static VisitCubit get visitCubit => locator<VisitCubit>();
}
