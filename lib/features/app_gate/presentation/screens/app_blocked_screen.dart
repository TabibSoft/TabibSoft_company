import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';

class AppBlockedScreen extends StatelessWidget {
  const AppBlockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: TechColors.primaryDark,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: TechColors.premiumGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    padding: EdgeInsets.all(30.r),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                    child: Icon(
                      Icons.lock_outline_rounded,
                      size: 80.sp,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: 40.h),

                  // Title
                  Text(
                    'الخدمة غير متاحة',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),

                  // Message
                  Text(
                    'عذراً، التطبيق غير متاح حالياً.\nيرجى التواصل مع الإدارة للمزيد من المعلومات.',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white.withOpacity(0.7),
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 60.h),

                  // Exit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        SystemNavigator.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.15),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'إغلاق التطبيق',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
