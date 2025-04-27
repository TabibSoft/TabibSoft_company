import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tabib_soft_company/core/export.dart';
import 'package:tabib_soft_company/core/helpers/extensions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void checkLoginStatus() {
    String token = CacheHelper.getString(key: 'loginToken');
    if (token.isNotEmpty) {
      context.pushReplacementNamed(homeScreen);
    } else {
      context.pushReplacementNamed(loginScreen);
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), checkLoginStatus);
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
                    width: 500.w,
                    height: 380.h,
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
                      width: 200.w,
                      height: 200.h,
                      child: Image.asset(
                        'assets/images/pngs/tabibLogo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'All Rights Reserved © AhmedElshora 2025',
                  style: AppStyle.font13_400Weight.copyWith(
                    color: AppColor.borderContainerColor,
                  ),
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
