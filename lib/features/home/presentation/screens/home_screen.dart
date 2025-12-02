// lib/features/home/presentation/screens/home_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // إضافة BlocBuilder
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tabib_soft_company/core/utils/cache/cache_helper.dart';
import 'package:tabib_soft_company/features/home/notifications/presentation/screens/notification_screen.dart';
import 'package:tabib_soft_company/features/home/notifications/presentation/cubits/notification_cubit.dart'; // إضافة
import 'package:tabib_soft_company/features/home/notifications/presentation/cubits/notification_state.dart'; // إضافة
import 'package:tabib_soft_company/features/management/presentation/screens/management_screen.dart';
import 'package:tabib_soft_company/features/modirator/presentation/screens/mediator_screen.dart';
import 'package:tabib_soft_company/features/programmers/presentation/screens/programmers_screen.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/screens/sales_home_screen.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/screen/support_home/technical_support_choise_screen.dart'
    show TechnicalSupportChoiseScreen;
import 'package:tabib_soft_company/features/home/presentation/screens/nav_bar/settings.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color primaryColor = Color(0xFF0F5FA8);
  static const Color accentColor = Color(0xFF19A7CE);
  static const Color lightBg = Color(0xFFF4F9FC);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
        backgroundColor: lightBg,
        body: SafeArea(
          child: Stack(
            children: [
              // الخلفية العلوية
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: size.height * 0.36,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFEFF9FF), Color(0xFFDFF6FB)],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: size.width * 0.05,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Image.asset(
                          'assets/images/pngs/TS Logo Final 1.png',
                          width: size.width * 0.67,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),

              // زر الإعدادات
              Positioned(
                top: 12,
                left: 12,
                child: GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SettingsScreen())),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: Image.asset('assets/images/pngs/settings.png',
                        width: 26, height: 26),
                  ),
                ),
              ),

              // زر الإشعارات مع النقطة الحمراء
              Positioned(
                top: 12,
                right: 12,
                child: BlocBuilder<NotificationCubit, NotificationState>(
                  builder: (context, state) {
                    final bool hasUnread = state.hasUnreadNotifications;

                    return GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const NotificationsScreen())),
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2))
                              ],
                            ),
                            child: const Icon(Icons.notifications,
                                color: Color.fromARGB(221, 64, 144, 197),
                                size: 26),
                          ),
                          // النقطة الحمراء
                          if (hasUnread)
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Grid الأزرار
              Positioned(
                top: size.height * 0.30,
                left: 16,
                right: 16,
                bottom: 20,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 6))
                    ],
                  ),
                  child: GridView.count(
                    physics: const BouncingScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.03,
                    children: [
                      // الإدارة
                      _buildFeatureTile(
                        context: context,
                        iconPath: 'assets/images/pngs/manager.png',
                        label: 'الإدارة',
                        enabled: isAdmin || userRoles.contains('MANAGEMENT'),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ManagementScreen())),
                        primaryColor: accentColor,
                      ),

                      // المبيعات
                      _buildFeatureTile(
                        context: context,
                        iconPath: 'assets/images/pngs/sales.png',
                        label: 'المبيعات',
                        enabled: isAdmin || userRoles.contains('SALSE'),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SalesHomeScreen())),
                        primaryColor: primaryColor,
                      ),

                      // المبرمجين
                      _buildFeatureTile(
                        context: context,
                        iconPath: 'assets/images/pngs/developers.png',
                        label: 'المبرمجين',
                        enabled: isAdmin || userRoles.contains('PROGRAMMER'),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ProgrammersScreen())),
                        primaryColor: primaryColor,
                      ),

                      // الدعم الفني
                      _buildFeatureTile(
                        context: context,
                        iconPath: 'assets/images/pngs/technical_support.png',
                        label: 'الدعم الفني',
                        enabled: isAdmin || userRoles.contains('SUPPORT'),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const TechnicalSupportChoiseScreen())),
                        primaryColor: accentColor,
                      ),

                      // الوسيط
                      _buildFeatureTile(
                        context: context,
                        iconPath:
                            'assets/images/pngs/icons8-find-user-40 1.png',
                        label: 'الوسيط',
                        enabled: isAdmin || isModerator,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ModeratorScreen())),
                        primaryColor: accentColor,
                      ),

                      // المتابعة
                      _buildFeatureTile(
                        context: context,
                        iconPath:
                            'assets/images/pngs/icons8-scroll-up-40 1.png',
                        label: 'المتابعة',
                        enabled: isAdmin || isTracker,
                        onTap: () {
                          if (isAdmin || isTracker) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('شاشة المتابعة قيد التطوير')),
                            );
                          }
                        },
                        primaryColor: primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required BuildContext context,
    required String iconPath,
    required String label,
    required VoidCallback onTap,
    required bool enabled,
    required Color primaryColor,
  }) {
    return HomeButton(
      iconPath: iconPath,
      label: label,
      onTap: onTap,
      enabled: enabled,
      primaryColor: primaryColor,
    );
  }
}

// HomeButton بدون تغيير
class HomeButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final Color primaryColor;

  const HomeButton({
    super.key,
    required this.iconPath,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.primaryColor = HomeScreen.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return InkWell(
      onTap: enabled ? onTap : () => _showToast(context),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding:
            EdgeInsets.symmetric(vertical: size.width * 0.04, horizontal: 12),
        decoration: BoxDecoration(
          color:
              enabled ? primaryColor.withOpacity(0.12) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                enabled ? primaryColor.withOpacity(0.18) : Colors.grey.shade300,
            width: 1.6,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: enabled
                    ? primaryColor.withOpacity(0.14)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                iconPath,
                width: size.width * 0.12,
                height: size.width * 0.12,
                color: enabled ? null : Colors.grey,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: size.height * 0.015),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: enabled ? primaryColor.darken(0.1) : Colors.grey,
                fontSize: size.width * 0.048,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showToast(BuildContext context) {
    final responses = [
      'إنت بتعمل إيه هنا؟',
      'لو ضغطت تاني هنبلغ الإدارة',
      'ده مش ليك يا نجم',
      'حاول في مكان تاني يا بطل',
      'بس يا بــابــا'
    ];
    final random = Random().nextInt(responses.length);
    Fluttertoast.showToast(
      msg: responses[random],
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}

extension ColorBrightness on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    return Color.fromARGB(
      alpha,
      (red * (1 - amount)).round(),
      (green * (1 - amount)).round(),
      (blue * (1 - amount)).round(),
    );
  }
}
