import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tabib_soft_company/main_development.dart';
import 'package:tabib_soft_company/features/home/notifications/presentation/screens/notification_screen.dart';

class MessagingConfig {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<String> getDeviceToken() async {
    String? fcmToken;

    if (Platform.isIOS) {
      // On iOS we need to see an APN token is available first
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken != null) {
        fcmToken = await FirebaseMessaging.instance.getToken();
        return fcmToken!;
      } else {
        // add a delay and retry getting APN token
        await Future<void>.delayed(const Duration(
          seconds: 3,
        ));
        apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken != null) {
          fcmToken = await FirebaseMessaging.instance.getToken();
          return fcmToken!;
        }
      }
    } else {
      // android platform
      fcmToken = await FirebaseMessaging.instance.getToken();
      return fcmToken!;
    }

    return '';
  }

  static Future<void> createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> initFirebaseMessaging() async {
    await createNotificationChannel();

    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    final NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse payload) {
        log("payload1: ${payload.payload.toString()}");

        final Map<String, dynamic> data =
            jsonDecode(payload.payload.toString());

        handleNotification(navigatorKey.currentContext!, data);
        return;
      },
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      log('User granted provisional permission');
    } else {
      log('User declined or has not accepted permission');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage event) async {
      log("message received");
      try {
        final RemoteNotification? notification = event.notification;
        log(notification!.body.toString());
        log(notification.title.toString());

        final body = notification.body;

        await flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              channelDescription:
                  'This channel is used for important notifications.',
              icon: '@mipmap/ic_launcher',
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: event.data.toString(),
        );

        handleNotification(navigatorKey.currentContext!, event.data);
      } catch (err) {
        log(err.toString());
      }
    });

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        handleNotification(navigatorKey.currentContext!, message.data);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotification(navigatorKey.currentContext!, message.data);
    });
  }

  @pragma('vm:entry-point')
  static Future<void> messageHandler(RemoteMessage message) async {
    log('background message ${message.notification!.body}');
    handleNotification(navigatorKey.currentContext!, message.data);
  }
}

void handleNotification(BuildContext context, Map<String, dynamic> data) {
  try {
    final String? route = data['route']?.toString();

    // If payload explicitly targets notifications, or no route provided,
    // open the Notifications screen.
    if (route == null || route.isEmpty || route.toLowerCase().contains('notif')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
      );
      return;
    }

    // TODO: handle other in-app routes (posProfileScreen, productDetailsScreen, etc.)
  } catch (e, st) {
    log('handleNotification error: $e');
    log(st.toString());
  }
}
