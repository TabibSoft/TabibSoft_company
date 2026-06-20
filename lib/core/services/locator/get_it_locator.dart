import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:tabib_soft_company/core/export.dart';
import 'package:tabib_soft_company/features/app_gate/export.dart';
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
import 'package:tabib_soft_company/features/sales/sales_admin/data/repos/requirements_repo.dart';
import 'package:tabib_soft_company/features/sales/sales_admin/presentation/cubit/requirements_cubit.dart';
import 'package:tabib_soft_company/features/sales/today_calls/data/repo/today_call_repo.dart';
import 'package:tabib_soft_company/features/sales/today_calls/presentation/cubit/today_call_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/data/repo/add_customer/add_customer_repo.dart';
import 'package:tabib_soft_company/features/technical_support/data/repo/add_customer/product_repo.dart';
import 'package:tabib_soft_company/features/technical_support/data/repo/customer/customer_repo.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/add_customer/add_cusomer_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/add_customer/product_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/customer_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/visits/data/repo/visit_repository.dart';
import 'package:tabib_soft_company/features/technical_support/data/repo/whatsapp_repository.dart';
import 'package:tabib_soft_company/features/technical_support/visits/presentation/cubits/visit_cubit.dart';
import 'package:tabib_soft_company/features/human_resources/data/repo/hr_profile_repo.dart';
import 'package:tabib_soft_company/features/human_resources/data/repo/hr_leave_repo.dart';
import 'package:tabib_soft_company/features/human_resources/data/repo/hr_labor_law_repo.dart';
import 'package:tabib_soft_company/features/human_resources/data/repo/hr_bonus_repo.dart';
import 'package:tabib_soft_company/features/human_resources/data/repo/hr_deficit_repo.dart';
import 'package:tabib_soft_company/features/human_resources/data/repo/hr_remote_work_repo.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/cubits/hr_profile_cubit.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/cubits/hr_leave_cubit.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/cubits/hr_remote_work_cubit.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/cubits/hr_labor_law_cubit.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/cubits/hr_bonus_cubit.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/cubits/hr_deficit_cubit.dart';

class ServicesLocator {
  static final GetIt locator = GetIt.instance;

  static void setup() {
    // Dio & ApiService
    final Dio dio = DioFactory.getDio();
    locator.registerLazySingleton<ApiService>(() => ApiService(dio));

    // intro app
    locator.registerLazySingleton<IntroAppCubit>(() => IntroAppCubit());

    // App Gate
    locator.registerFactory<AppGateCubit>(() => AppGateCubit());

    // Login
    locator.registerLazySingleton<LoginReposetory>(
        () => LoginReposetory(locator()));
    locator.registerFactory<LoginCubit>(
        () => LoginCubit(locator<LoginReposetory>()));

    // Customer
    locator.registerLazySingleton<CustomerRepository>(
        () => CustomerRepository(locator<ApiService>()));
    locator.registerFactory<CustomerCubit>(
        () => CustomerCubit(locator<CustomerRepository>()));

    // Engineer
    locator.registerLazySingleton<EngineerRepository>(
        () => EngineerRepository(locator<ApiService>()));
    locator.registerFactory<EngineerCubit>(
        () => EngineerCubit(locator<EngineerRepository>()));

    // Task & Report
    locator.registerLazySingleton<TaskRepository>(
        () => TaskRepository(locator<ApiService>()));
    locator
        .registerFactory<TaskCubit>(() => TaskCubit(locator<TaskRepository>()));

    locator.registerLazySingleton<ReportRepository>(
        () => ReportRepository(locator<ApiService>()));
    locator.registerFactory<ReportCubit>(
        () => ReportCubit(locator<ReportRepository>()));

    // Sales
    locator.registerLazySingleton<SalesRepository>(
        () => SalesRepository(locator<ApiService>()));
    locator.registerFactory<SalesCubit>(
        () => SalesCubit(locator<SalesRepository>()));

    // Add Customer
    locator.registerLazySingleton<AddCustomerRepository>(
        () => AddCustomerRepository(locator<ApiService>()));
    locator.registerFactory<AddCustomerCubit>(
        () => AddCustomerCubit(locator<AddCustomerRepository>()));

    // Product
    locator.registerLazySingleton<ProductRepository>(
        () => ProductRepository(locator<ApiService>()));
    locator.registerFactory<ProductCubit>(
        () => ProductCubit(locator<ProductRepository>()));

    // Sales Details
    locator.registerLazySingleton<SalesDetailsRepository>(
        () => SalesDetailsRepository(locator<ApiService>()));
    locator.registerFactory<SalesDetailsCubit>(
        () => SalesDetailsCubit(locator<SalesDetailsRepository>()));

    // Add Note
    locator.registerLazySingleton<AddNoteRepository>(
        () => AddNoteRepository(locator<ApiService>()));
    locator.registerFactory<AddNoteCubit>(
        () => AddNoteCubit(locator<AddNoteRepository>()));

    // Notifications
    locator.registerLazySingleton<NotificationRepository>(
        () => NotificationRepository(locator<ApiService>()));
    locator.registerFactory<NotificationCubit>(
        () => NotificationCubit(locator<NotificationRepository>()));

    // Today Calls
    locator.registerLazySingleton<TodayCallsRepository>(
        () => TodayCallsRepository(locator<ApiService>()));
    locator.registerFactory<TodayCallsCubit>(
        () => TodayCallsCubit(locator<TodayCallsRepository>()));

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

    // HR Profile
    locator.registerLazySingleton<HrProfileRepository>(
      () => HrProfileRepository(locator<ApiService>()),
    );
    locator.registerFactory<HrProfileCubit>(
      () => HrProfileCubit(locator<HrProfileRepository>()),
    );

    // HR Leave
    locator.registerLazySingleton<HrLeaveRepository>(
      () => HrLeaveRepository(locator<ApiService>()),
    );
    locator.registerFactory<HrLeaveCubit>(
      () => HrLeaveCubit(locator<HrLeaveRepository>()),
    );

    // HR Remote Work
    locator.registerLazySingleton<HrRemoteWorkRepository>(
      () => HrRemoteWorkRepository(locator<ApiService>()),
    );
    locator.registerFactory<HrRemoteWorkCubit>(
      () => HrRemoteWorkCubit(locator<HrRemoteWorkRepository>()),
    );

    // HR Labor Law
    locator.registerLazySingleton<HrLaborLawRepository>(
      () => HrLaborLawRepository(locator<ApiService>()),
    );
    locator.registerFactory<HrLaborLawCubit>(
      () => HrLaborLawCubit(locator<HrLaborLawRepository>()),
    );

    // HR Types - Bonuses & Deficits
    locator.registerLazySingleton<HrBonusRepository>(
      () => HrBonusRepository(locator<ApiService>()),
    );
    locator.registerFactory<HrBonusCubit>(
      () => HrBonusCubit(locator<HrBonusRepository>()),
    );

    locator.registerLazySingleton<HrDeficitRepository>(
      () => HrDeficitRepository(locator<ApiService>()),
    );
    locator.registerFactory<HrDeficitCubit>(
      () => HrDeficitCubit(locator<HrDeficitRepository>()),
    );

    // Visit Repository & Cubit
    locator.registerLazySingleton<VisitRepository>(
      () => VisitRepository(locator<ApiService>()),
    );
    locator.registerFactory<VisitCubit>(
      () => VisitCubit(locator<VisitRepository>()),
    );

    // WhatsApp
    locator.registerLazySingleton<WhatsAppRepository>(
      () => WhatsAppRepository(),
    );

    // Sales Admin Requirements
    locator.registerLazySingleton<RequirementsRepository>(
      () => RequirementsRepository(locator<ApiService>()),
    );
    locator.registerFactory<RequirementsCubit>(
      () => RequirementsCubit(locator<RequirementsRepository>()),
    );
  }

  // Getters
  static IntroAppCubit get introAppCubit => locator<IntroAppCubit>();
  static AppGateCubit get appGateCubit => locator<AppGateCubit>();
  static LoginCubit get loginCubit => locator<LoginCubit>();
  static CustomerCubit get customerCubit => locator<CustomerCubit>();
  static EngineerCubit get engineerCubit => locator<EngineerCubit>();
  static TaskCubit get taskCubit => locator<TaskCubit>();
  static ReportCubit get reportCubit => locator<ReportCubit>();
  static SalesCubit get salesCubit => locator<SalesCubit>();
  static AddCustomerCubit get addCustomerCubit => locator<AddCustomerCubit>();
  static ProductCubit get productCubit => locator<ProductCubit>();
  static AddNoteCubit get addNoteCubit => locator<AddNoteCubit>();
  static NotificationCubit get notificationCubit =>
      locator<NotificationCubit>();
  static TodayCallsCubit get todayCallsCubit => locator<TodayCallsCubit>();
  static AddSubscriptionCubit get addSubscriptionCubit =>
      locator<AddSubscriptionCubit>();
  static PaymentMethodCubit get paymentMethodCubit =>
      locator<PaymentMethodCubit>();
  static VisitCubit get visitCubit => locator<VisitCubit>();
  static RequirementsCubit get requirementsCubit =>
      locator<RequirementsCubit>();
  static HrProfileCubit get hrProfileCubit => locator<HrProfileCubit>();
  static HrLeaveCubit get hrLeaveCubit => locator<HrLeaveCubit>();
  static HrRemoteWorkCubit get hrRemoteWorkCubit =>
      locator<HrRemoteWorkCubit>();
  static HrLaborLawCubit get hrLaborLawCubit => locator<HrLaborLawCubit>();
  static HrBonusCubit get hrBonusCubit => locator<HrBonusCubit>();
  static HrDeficitCubit get hrDeficitCubit => locator<HrDeficitCubit>();
}
