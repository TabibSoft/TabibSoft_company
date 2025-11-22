import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/core/cubit/internet/internet_cubit.dart';
import 'package:tabib_soft_company/core/services/locator/get_it_locator.dart';
import 'package:tabib_soft_company/features/auth/presentation/cubits/login_cubit.dart';
import 'package:tabib_soft_company/features/modirator/presentation/cubits/add_subscription_cubit.dart';
import 'package:tabib_soft_company/features/modirator/presentation/cubits/payment_method_cubit.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/engineer_cubit.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/report_cubit.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/task_cubit.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/cubits/notes/add_note_cubit.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/cubits/notes/sales_details_cubit.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/cubits/sales_cubit.dart';
import 'package:tabib_soft_company/features/home/notifications/presentation/cubits/notification_cubit.dart';
import 'package:tabib_soft_company/features/sales/today_calls/presentation/cubit/today_call_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/add_customer/add_cusomer_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/add_customer/product_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/customer_cubit.dart';

// جديد: استيراد AddSubscriptionCubit

Widget buildAppWithProviders({required Widget child}) {
  return MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => InternetCubit()..checkStreamConnection()),

      BlocProvider<CustomerCubit>(create: (_) => ServicesLocator.customerCubit),
      BlocProvider<EngineerCubit>(create: (_) => ServicesLocator.engineerCubit),
      BlocProvider<TaskCubit>(create: (_) => ServicesLocator.taskCubit),
      BlocProvider<ReportCubit>(create: (_) => ServicesLocator.reportCubit),
      BlocProvider<SalesCubit>(create: (_) => ServicesLocator.salesCubit),
      BlocProvider<AddCustomerCubit>(create: (_) => ServicesLocator.addCustomerCubit),
      BlocProvider<ProductCubit>(create: (_) => ServicesLocator.productCubit),
      BlocProvider<LoginCubit>(create: (_) => ServicesLocator.loginCubit),

      BlocProvider<SalesDetailsCubit>(create: (_) => ServicesLocator.locator<SalesDetailsCubit>()),
      BlocProvider<AddNoteCubit>(create: (_) => ServicesLocator.addNoteCubit),
      BlocProvider<NotificationCubit>(create: (_) => ServicesLocator.notificationCubit),
      BlocProvider<TodayCallsCubit>(create: (_) => ServicesLocator.todayCallsCubit),

      // ==================== جديد: إضافة AddSubscriptionCubit ====================
      BlocProvider<AddSubscriptionCubit>(
        create: (_) => ServicesLocator.addSubscriptionCubit,
      ),

      BlocProvider<PaymentMethodCubit>(
  create: (_) => ServicesLocator.paymentMethodCubit,
),
    ],
    child: child,
  );
}