// lib/features/home/presentation/screens/nav_bar/settings.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/core/utils/cache/cache_helper.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';
import 'package:tabib_soft_company/core/utils/constant/app_style.dart';
import 'package:tabib_soft_company/features/auth/presentation/screens/login/login_screen.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/screens/human_resources_screen.dart';
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
          style: AppStyle.font20_600Weight.copyWith(color: Colors.blueGrey[800]),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'مش ناوي تغير رأيك يعني !!!',
          style: AppStyle.font16_700Weight.copyWith(color: Colors.blueGrey[600]),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseMessaging.instance.deleteToken();

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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColor.primaryColor, // استخدام اللون الأساسي من AppColor
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
                    color: Color(0xFFF5F7FA), // sheetColor
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 30),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          /// كارت الموارد البشرية (الجديد)
                          _buildHRCard(context),

                          const SizedBox(height: 25),

                          /// كارت تسجيل الخروج
                          _buildLogoutCard(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// كارت الموارد البشرية
  Widget _buildHRCard(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        /// الظل
        Positioned(
          left: 0,
          top: 15,
          child: Container(
            width: MediaQuery.of(context).size.width - 40,
            height: 135,
            decoration: BoxDecoration(
              color: const Color(0xff104D9D),
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

        /// الكارت الرئيسي
        Padding(
          padding: const EdgeInsets.only(top: 25, left: 20),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HumanResourcesScreen(),
                ),
              );
            },
            child: Container(
              height: 135,
              width: MediaQuery.of(context).size.width - 6,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColor.accentColor, width: 4),
              ),
              child: Row(
                children: [
                  /// أيقونة
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColor.accentColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.people_alt_rounded,
                      size: 42,
                      color: AppColor.accentColor,
                    ),
                  ),

                  const SizedBox(width: 20),

                  /// النص
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'الموارد البشرية',
                          style: AppStyle.font20_600Weight.copyWith(
                            color: AppColor.titleColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'إدارة طلباتك وتقاريرك',
                          style: AppStyle.font16_700Weight.copyWith(
                            color: AppColor.subTitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColor.accentColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// كارت تسجيل الخروج (محدث)
  Widget _buildLogoutCard(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          top: 15,
          child: Container(
            width: MediaQuery.of(context).size.width - 40,
            height: 190,
            decoration: BoxDecoration(
              color: const Color(0xff104D9D),
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

        Padding(
          padding: const EdgeInsets.only(top: 25, left: 20),
          child: Container(
            height: 190,
            width: MediaQuery.of(context).size.width - 6,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColor.accentColor, width: 4),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'تسجيل الخروج من التطبيق',
                  style: AppStyle.font20_600Weight,
                ),
                const SizedBox(height: 25),

                GestureDetector(
                  onTap: () => _logout(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 36, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      'تسجيل الخروج',
                      style: AppStyle.font14_400Weight.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}