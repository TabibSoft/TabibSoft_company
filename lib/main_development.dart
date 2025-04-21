import 'dart:async';
import 'dart:developer';

import 'package:tabib_soft_company/app.dart';
import 'package:flutter/material.dart';
import 'app_initi.dart';
import 'core/navigation/app_router.dart';
import 'core/utils/route_observer.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    logFlutterError(details);
  };
  runZonedGuarded(
    () async {
      await initializeApp(); 

      runApp(
        MyApp(
          appRouter: AppRouter(),
          routeLogger: RouteLogger(),
        ),
      );
    },
    (error, stackTrace) {
      logDartError(error, stackTrace);
      log(stackTrace.toString(), name: 'main');
    },
  );
}

void logFlutterError(FlutterErrorDetails details) {
  debugPrint('E.L.S.H.O.R.A Flutter Error: ${details.exception}');
  debugPrint('E.L.S.H.O.R.A Stack trace: ${details.stack}');
}

void logDartError(Object error, StackTrace stackTrace) {
  debugPrint('E.L.S.H.O.R.A Dart Error: $error');
  debugPrint('E.L.S.H.O.R.A Stack trace: $stackTrace');
}






// import 'dart:async';
// import 'dart:developer';

// import 'package:tabib_soft_company/app.dart';
// import 'package:flutter/material.dart';

// import 'app_initi.dart';
// import 'core/navigation/app_router.dart';
// import 'core/utils/route_observer.dart';

// void main() async {
//   FlutterError.onError = (FlutterErrorDetails details) {
//     FlutterError.dumpErrorToConsole(details);

//     logFlutterError(details);
//   };
//   runZonedGuarded(
//     () async {
//       await initializeApp();

//       runApp(
//         MyApp(
//           appRouter: AppRouter(),
//           routeLogger: RouteLogger(),
//         ),
//       );
//     },
//     (error, stackTrace) {
//       logDartError(error, stackTrace);
//       log(stackTrace.toString(), name: 'main');
//       // FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
//     },
//   );
// }

// void logFlutterError(FlutterErrorDetails details) {
//   debugPrint('E.L.S.H.O.R.A Flutter Error: ${details.exception}');
//   debugPrint('E.L.S.H.O.R.A Stack trace: ${details.stack}');
// }

// void logDartError(Object error, StackTrace stackTrace) {
//   debugPrint('E.L.S.H.O.R.A Dart Error: $error');
//   debugPrint('E.L.S.H.O.R.A Stack trace: $stackTrace');
// }
