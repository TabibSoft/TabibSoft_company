// lib/features/home/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:tabib_soft_company/core/utils/cache/cache_helper.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';
import 'package:tabib_soft_company/features/home/presentation/widgets/home_features_grid.dart';
import 'package:tabib_soft_company/features/home/presentation/widgets/home_header.dart';
import 'package:tabib_soft_company/features/home/presentation/widgets/home_notification_button.dart';
import 'package:tabib_soft_company/features/home/presentation/widgets/home_settings_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const Color primaryColor = AppColor.primaryColor;
  static const Color accentColor = AppColor.accentColor;
  static const Color lightBg = AppColor.lightBg;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final userName = CacheHelper.getString(key: 'userName');
    final rawRoles = CacheHelper.getString(key: 'userRoles');
    final userRoles = (rawRoles.isNotEmpty) ? rawRoles.split(',') : <String>[];

    final bool isAdmin = userRoles.contains('ADMIN');
    final bool isModerator = userRoles.contains('MODERATOR');
    final bool isTracker = userRoles.contains('TRACKER');

    // تحديد العنوان
    String title;
    if (isAdmin || userRoles.contains('MANAGEMENT')) {
      title = 'أهلا بالإدارة ${userName.isNotEmpty ? userName : 'المستخدم'}';
    } else if (userRoles.contains('SALSE')) {
      title = 'أهلاً السيلز اللعيب ${userName.isNotEmpty ? userName : ''}';
    } else if (userRoles.contains('PROGRAMMER')) {
      title = 'ملك الكودينج ${userName.isNotEmpty ? userName : ''}';
    } else if (userRoles.contains('SUPPORT')) {
      title = 'وحش الدعم ${userName.isNotEmpty ? userName : ''}';
    } else if (isModerator) {
      title = 'الوســـيط ${userName.isNotEmpty ? userName : ''}';
    } else if (isTracker) {
      title = 'ملك المتابعة ${userName.isNotEmpty ? userName : ''}';
    } else {
      title = 'أهلاً ${userName.isNotEmpty ? userName : 'المستخدم'}';
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: HomeScreen.lightBg,
        body: SafeArea(
          child: Stack(
            children: [
              // الخلفية العلوية
              HomeHeader(title: title),

              // زر الإعدادات
              const HomeSettingsButton(),

              // زر الإشعارات مع النقطة الحمراء
              const HomeNotificationButton(),

              // Grid الأزرار //
              HomeFeaturesGrid(userRoles: userRoles),
            ],
          ),
        ),
      ),
    );
  }
}
