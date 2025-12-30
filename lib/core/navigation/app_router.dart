import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/core/export.dart';
import 'package:tabib_soft_company/features/auth/presentation/screens/login/login_screen.dart';
import 'package:tabib_soft_company/features/auth/presentation/screens/splash_screen.dart';
import 'package:tabib_soft_company/features/home/presentation/screens/home_screen.dart';
import 'package:tabib_soft_company/features/sales/today_calls/presentation/screens/taday_calls_screen.dart';

class AppRouter {
  Route? onGenerateRoute(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments;

    switch (routeSettings.name) {
      case splashScreen:
        return MaterialPageRoute(
          builder: (_) {
            return const SplashScreen();
          },
        );
      case loginScreen:
        return MaterialPageRoute(
          builder: (_) {
            return BlocProvider(
              create: (_) => ServicesLocator.loginCubit,
              child: const LoginScreen(),
            );
          },
        );

      case homeScreen:
        return MaterialPageRoute(
          builder: (_) {
            return const HomeScreen();
          },
        );

      case todayCallsScreen:
        return MaterialPageRoute(
          builder: (_) {
            return const TodayCallsScreen();
          },
        );
    }

    return null;
  }
}
