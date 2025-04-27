import 'package:tabib_soft_company/core/cubit/internet/internet_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/core/services/locator/get_it_locator.dart';
import 'package:tabib_soft_company/features/auth/presentation/cubits/login_cubit.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/engineer_cubit.dart';
import 'package:tabib_soft_company/features/sales/presentation/cubit/details/sales_details_cubit.dart';
import 'package:tabib_soft_company/features/sales/presentation/cubit/inistallation/installation_cubit.dart';
import 'package:tabib_soft_company/features/sales/presentation/cubit/sales_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/add_customer/add_cusomer_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/add_customer/product_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/customer_cubit.dart';

Widget buildAppWithProviders({required Widget child}) {
  return MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) => InternetCubit()..checkStreamConnection(),
      ),
      BlocProvider<CustomerCubit>(
        create: (_) => ServicesLocator.locator<CustomerCubit>(),
      ),
      BlocProvider<EngineerCubit>(
        create: (_) => ServicesLocator.locator<EngineerCubit>(),
      ),
      BlocProvider<SalesCubit>(
        create: (_) => ServicesLocator.locator<SalesCubit>(),
      ),
      BlocProvider<AddCustomerCubit>(
        create: (_) => ServicesLocator.locator<AddCustomerCubit>(),
      ),
      BlocProvider<ProductCubit>(
        create: (_) => ServicesLocator.locator<ProductCubit>(),
      ),
      BlocProvider<SalesDetailCubit>(
        create: (_) => ServicesLocator.locator<SalesDetailCubit>(),
      ),
         BlocProvider<LoginCubit>(
        create: (_) => ServicesLocator.locator<LoginCubit>(),
      ),
          BlocProvider<InstallationCubit>(
        create: (_) => ServicesLocator.locator<InstallationCubit>(),
      ),
    ],
    child: child,
  );
}
