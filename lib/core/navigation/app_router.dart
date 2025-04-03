import 'package:flutter/material.dart';
import 'package:tabib_soft_company/core/export.dart';
import 'package:tabib_soft_company/features/auth/presentation/screens/splash_screen.dart';

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
    }

    return null;
  }
}
