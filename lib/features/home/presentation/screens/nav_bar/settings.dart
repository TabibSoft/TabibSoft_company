// lib/features/home/presentation/screens/nav_bar/settings.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/core/utils/cache/cache_helper.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_app_bar_widget.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_nav_bar_widget.dart';
import 'package:tabib_soft_company/features/auth/presentation/screens/login/login_screen.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/engineer_cubit.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<EngineerCubit>().fetchEngineers();
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'تأكيد تسجيل الخروج',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[800],
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'مش ناوي تغير رأيك يعني !!!',
          style: TextStyle(
            fontSize: 16,
            color: Colors.blueGrey[600],
          ),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // 1. Delete FCM Token to stop notifications
      await FirebaseMessaging.instance.deleteToken();

      // 2. Clear all user session data
      await CacheHelper.removeData(key: 'loginToken');
      await CacheHelper.removeData(key: 'userName');
      await CacheHelper.removeData(key: 'userId');
      await CacheHelper.removeData(key: 'userRoles');

      if (!context.mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ ألوان التصميم المحفوظ
    const mainBlueColor = Color(0xFF16669E);
    const sheetColor = Color(0xFFF5F7FA);
    const borderColor = Color(0xFF20AAC9);
    const shadowBlue = Color(0xff104D9D);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: mainBlueColor,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 20),

              /// الشعار العلوي
              Center(
                child: Image.asset(
                  'assets/images/pngs/TS_Logo0.png',
                  width: 110,
                  height: 110,
                  fit: BoxFit.contain,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),

              const SizedBox(height: 20),

              /// الشيت الأبيض السفلي
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: sheetColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 30),
                    child: Center(
                      child: SizedBox(
                        height: 300,
                        width: double.infinity,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            /// ظل الكارت الأزرق
                            Positioned(
                              left: 0,
                              top: 15,
                              child: Container(
                                width: MediaQuery.of(context).size.width - 40,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: shadowBlue,
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.25),
                                      offset: const Offset(4, 6),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            /// كارت تسجيل الخروج الأبيض
                            Padding(
                              padding: const EdgeInsets.only(top: 25, left: 20),
                              child: Container(
                                height: 190,
                                width: MediaQuery.of(context).size.width - 6,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  border:
                                      Border.all(color: borderColor, width: 4),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'تسجيل الخروج من التطبيق',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 25),

                                    /// زر تسجيل الخروج بنفس ستايل المرجع
                                    GestureDetector(
                                      onTap: () => _logout(context),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 36, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.15),
                                                blurRadius: 6,
                                                offset: const Offset(0, 3)),
                                          ],
                                        ),
                                        child: const Text(
                                          'تسجيل الخروج',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        /// ✅ الـ Bottom Nav كما هو بدون تغيير
      ),
    );
  }
}
