import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tabib_soft_company/core/utils/cache/cache_helper.dart';
import 'package:tabib_soft_company/features/auth/presentation/screens/login/login_screen.dart';
import 'package:tabib_soft_company/features/home/presentation/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// التحقق من حالة تسجيل الدخول عن طريق قراءة التوكن من SharedPreferences
  void checkLoginStatus() {
    String token = CacheHelper.getString(key: 'loginToken');
    if (token.isNotEmpty) {
      // إذا كان التوكن موجود ينتقل المستخدم إلى الصفحة الرئيسية
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      // إن لم يكن موجود ينتقل المستخدم إلى شاشة تسجيل الدخول
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // تأخير لمدة 5 ثوانٍ ثم التحقق من حالة تسجيل الدخول
    Timer(const Duration(seconds: 5), checkLoginStatus);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topRight,
            colors: [
              Color(0xFF88C8F3),
              Color(0xFF90F398),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -70,
              left: -200,
              child: Transform.rotate(
                angle: 65.44 * (3.141592653589793 / 180),
                child: Opacity(
                  opacity: 0.5,
                  child: Container(
                    width: 500,
                    height: 380,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1BBCFC),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      width: 150,
                      height: 150,
                      child: Image.asset(
                        'assets/images/pngs/tabibLogo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                const Text(
                  'All Rights Reserved © TabibSoft 2025',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
