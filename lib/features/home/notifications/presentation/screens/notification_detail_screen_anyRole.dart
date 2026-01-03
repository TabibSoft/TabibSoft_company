import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';
import 'package:tabib_soft_company/features/home/notifications/data/model/notification_model.dart';

class NotificationDetailScreenAnyRole extends StatelessWidget {
  final NotificationModel notification;

  const NotificationDetailScreenAnyRole({
    super.key,
    required this.notification,
  });

  String _formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy - hh:mm a', 'ar').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = _formatDate(notification.date);

    return Scaffold(
      backgroundColor: TechColors.surfaceLight,
      body: Stack(
        children: [
          // Premium Header
          Container(
            height: 300.h,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: TechColors.premiumGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -60,
                  right: -60,
                  child: Container(
                    width: 200.r,
                    height: 200.r,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // AppBar
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Expanded(
                        child: Text(
                          'تفاصيل الإشعار',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(width: 48.w),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                // Logo
                Hero(
                  tag: 'app_logo',
                  child: Image.asset(
                    'assets/images/pngs/TS_Logo0.png',
                    width: 120.w,
                    height: 70.h,
                    color: Colors.white,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 40.h),
                // Detail Card
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 20.w),
                    padding: EdgeInsets.all(24.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10.r),
                                decoration: BoxDecoration(
                                  color: TechColors.accentCyan.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.notifications_active_rounded,
                                    color: TechColors.accentCyan, size: 24.r),
                              ),
                              SizedBox(width: 14.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'إشعار من النظام',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  Text(
                                    'هام',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w800,
                                      color: TechColors.errorRed,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 24.h),
                          Divider(color: Colors.grey[100], thickness: 1.5),
                          SizedBox(height: 24.h),
                          Text(
                            notification.title ?? 'بدون عنوان',
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                              color: TechColors.primaryDark,
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            notification.body ?? 'لا يوجد محتوى',
                            style: TextStyle(
                              fontSize: 16.sp,
                              height: 1.8,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 40.h),
                          Container(
                            padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(
                              color: TechColors.surfaceLight,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_month_rounded,
                                    color: TechColors.accentCyan, size: 20.r),
                                SizedBox(width: 10.w),
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: TechColors.primaryMid,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
