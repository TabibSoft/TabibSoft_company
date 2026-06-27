import 'package:tabib_soft_company/core/export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tabib_soft_company/features/home/presentation/widgets/adhkar_global_overlay.dart';

import 'core/cubit/internet/internet_cubit.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  final AppRouter appRouter;
  final RouteLogger routeLogger;
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({
    super.key,
    required this.appRouter,
    required this.routeLogger,
    required this.navigatorKey,
  });

  @override
  Widget build(BuildContext context) {
    return buildAppWithProviders(
      child: BlocListener<InternetCubit, InternetState>(
        listener: (context, state) {
          if (state is ConnectedState) {
            ServicesLocator.introAppCubit.initApp();

            // TODO create widget for connected
          }
          if (state is NotConnectedState) {
            showToast(
              msg: 'الانترنت غير مستقر حاليا',
              state: ToastedStates.error,
              // context: context,
              // style: ToastificationStyle.flatColored,
            );
            // TODO create widget for not connected
          }
        },
        child: ScreenUtilInit(
          designSize: const Size(428, 926),
          minTextAdapt: true,
          splitScreenMode: true,
          child: MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            navigatorObservers: [
              routeLogger,
            ],
            builder: (context, child) {
              return AdhkarGlobalOverlay(child: child!);
            },
            title: 'tabib_soft_company App',
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar', 'EG'),
              Locale('en', 'US'),
            ],
            locale: const Locale('ar', 'EG'),
            theme: ThemeData(
              scaffoldBackgroundColor: AppColor.backGroundColor,
              fontFamily: 'Amiri',
              textTheme: ThemeData.light().textTheme.apply(
                    fontFamily: 'Amiri',
                  ),
            ),
            onGenerateRoute: appRouter.onGenerateRoute,
          ),
        ),
      ),
    );
  }
}
