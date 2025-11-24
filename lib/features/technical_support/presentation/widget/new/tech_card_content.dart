import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/customer_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/screen/support_home/problem_details_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/problem/problem_model.dart';

class TechCardContent extends StatelessWidget {
  final ProblemModel issue;
  final VoidCallback? onDetailsPressed; // اختياري: إذا أردت فتح شاشة تفاصيل

  const TechCardContent({
    super.key,
    required this.issue,
    this.onDetailsPressed,
  });

  void _makePhoneCall(BuildContext context) async {
    final phone = issue.customerPhone ?? issue.phone;
    if (phone != null && phone.isNotEmpty && phone != 'غير متوفر') {
      final Uri url = Uri(scheme: 'tel', path: phone);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    }
  }

  Color _hexToColor(String? hex, {Color fallback = const Color(0xFF6BABFA)}) {
    if (hex == null || hex.isEmpty) return fallback;
    final cleaned = hex.replaceAll('#', '').trim();
    try {
      if (cleaned.length == 6) {
        return Color(int.parse('FF$cleaned', radix: 16));
      } else if (cleaned.length == 8) {
        return Color(int.parse(cleaned, radix: 16));
      }
    } catch (_) {}
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _hexToColor(issue.porblemColor);
    final Color textColor =
        statusColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // الخلفية الزرقاء الخارجية
          Positioned(
            left: 0,
            top: 13.h,
            child: Container(
              width: 390.w,
              height: 275.h,
              decoration: BoxDecoration(
                color: const Color(0xff104D9D),
                borderRadius: BorderRadius.circular(25.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    offset: Offset(4.w, 6.h),
                    blurRadius: 12.r,
                  ),
                ],
              ),
            ),
          ),

          // البطاقة البيضاء الرئيسية
          Padding(
            padding: EdgeInsets.only(top: 23.h, left: 20.w, right: 0.w),
            child: Container(
              height: 250.h,
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 30.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.r),
                border: Border.all(color: const Color(0xff20AAC9), width: 4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // الاسم + أيقونة العميل
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/pngs/new_person.png',
                        width: 38.w,
                        height: 38.h,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          issue.customerName ?? 'غير معروف',
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // SizedBox(height: 5.h),

                  // رقم الهاتف + أيقونة الاتصال
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _makePhoneCall(context),
                        child: Image.asset(
                          'assets/images/pngs/new_call.png',
                          width: 34.w,
                          height: 34.h,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          issue.customerPhone ?? issue.phone ?? 'غير متوفر',
                          style: TextStyle(
                            fontSize: 19.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey[850],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // SizedBox(height: 10.h),

                  // نوع المشكلة (جديد، جاري، تم الحل...)
                  Row(children: [
                    Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                          color: statusColor, shape: BoxShape.circle),
                      child: Image.asset(
                        'assets/images/pngs/specialization.png',
                        width: 24.r,
                        height: 24.r,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        issue.problemtype ?? 'غير محدد',
                        style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                            color: statusColor),
                      ),
                    ),
                  ]),
                  // SizedBox(height: 10.h),

                  // مكان المشكلة (الأبلكيشن، السيرفر، إلخ)
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: const Color(0xffFF9800),
                        size: 34.r,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          issue.problemAddress ?? 'غير محدد',
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // SizedBox(height: 5.h),
                ],
              ),
            ),
          ),

          // زر "تفاصيل" في الأسفل
          Positioned(
            left: 110.w,
            bottom: 10.h,
            child: GestureDetector(
              onTap: onDetailsPressed ??
                  () {
                    // افتح شاشة التفاصيل أو dialog هنا
                    // مثال:
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(issue.customerName ?? 'تفاصيل المشكلة'),
                        content: Text(
                            issue.problemDetails ?? 'لا توجد تفاصيل إضافية'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('إغلاق'),
                          ),
                        ],
                      ),
                    );
                  },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 36.w, vertical: 14.h),

                child: TextButton(
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProblemDetailsScreen(issue: issue),
                      ),
                    );

                    // إذا رجع true → يعني تم حفظ شيء → نعيد تحميل البيانات
                    if (result == true) {
                      context.read<CustomerCubit>().resetPagination();
                      context.read<CustomerCubit>().fetchTechSupportIssues();
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text(
                    'تفاصيل',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),

                // Text(
                //   'تفاصيل',
                //   style: TextStyle(
                //     color: Colors.white,
                //     fontSize: 19.sp,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
