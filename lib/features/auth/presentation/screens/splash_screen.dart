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
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24.r),
            bottomRight: Radius.circular(24.r),
          ),
          child: Stack(
            children: [
              // خلفية بتدرج لوني أزرق مثل الكود المحفوظ
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xff104D9D),
                      Color(0xFF20AAC9),
                    ],
                  ),
                ),
              ),

              // اللوجو الخلفي الكبير (Watermark)
              Positioned(
                top: 80.h,
                left: 60.w,
                child: SizedBox(
                  width: 350.w,
                  height: 380.h,
                  child: Image.asset(
                    'assets/images/pngs/TS_Logo0.png',
                    fit: BoxFit.contain,
                    // إذا أردت تلوينه استخدم color: Colors.white.withOpacity(...)
                  ),
                ),
              ),

              // المحتوى العمودي: اللوغو الأبيض والنص في الأسفل
              Column(
                children: [
                  const Spacer(flex: 4),
                  // اللوغو الأبيض (مربّع قليل التدوير) - محاذاة مركزية
                  Center(
                    child: SizedBox(
                      width: 500.w,
                      height: 200.h,
                      child: Image.asset(
                        'assets/images/pngs/TS_Logo1.png',
                        fit: BoxFit.contain,
                        // في حال الـ SVG ملون بالفعل باللون الأبيض فلا حاجة للـ color
                        // في حال احتجت تجبر اللون: uncomment السطر التالي
                        // color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),

                  // نص "حقوق النشر" مثل التصميم - لون فاتح
                  Padding(
                    padding: EdgeInsets.only(bottom: 30.h),
                    child: Text(
                      'All Rights Reserved © AhmedElshora 2025',
                      style: AppStyle.font13_400Weight.copyWith(
                        color: AppColor.borderContainerColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
