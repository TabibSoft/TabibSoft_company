import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tabib_soft_company/core/services/firebase/firebase_notification/notification.dart';
import 'package:tabib_soft_company/core/utils/bloc_observer.dart';
import 'package:tabib_soft_company/firebase_options.dart';

import 'core/services/locator/get_it_locator.dart';
import 'core/utils/cache/cache_helper.dart';

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await CacheHelper.init();

  ServicesLocator.setup();
  await ScreenUtil.ensureScreenSize();
  // print\(.*?\);

   await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  MessagingConfig.initFirebaseMessaging();

  FirebaseMessaging.onBackgroundMessage(MessagingConfig.messageHandler);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  Bloc.observer = AppBlocObserver();
}
