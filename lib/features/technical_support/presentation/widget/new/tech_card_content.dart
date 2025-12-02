import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/customer_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/screen/support_home/problem_details_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/problem/problem_model.dart';

class TechCardContent extends StatelessWidget {
  final ProblemModel issue;
  final VoidCallback? onDetailsPressed;

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
    final Color statusColor =
        _hexToColor(issue.porblemColor ?? issue.statusColor);
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

                  // المنتجات أو نوع الحالة (الجزء المُعدّل)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/images/pngs/specialization.png',
                          width: 24.r,
                          height: 24.r,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // إذا كان فيه منتجات → نعرضها
                            if (issue.products != null &&
                                issue.products!.isNotEmpty)
                              Wrap(
                                spacing: 8.w,
                                runSpacing: 6.h,
                                children: issue.products!
                                    .take(3) // أول 3 منتجات فقط
                                    .map((product) {
                                  final String name = product is Map
                                      ? (product['name'] ??
                                          product['productName'] ??
                                          product['title'] ??
                                          'منتج')
                                      : product.toString();

                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12.w, vertical: 6.h),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20.r),
                                      border: Border.all(
                                          color: statusColor, width: 1.2),
                                    ),
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: statusColor,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              )
                            else
                              // إذا مفيش منتجات → نعرض نوع الحالة
                              Row(
                                children: [
                                  Text(
                                    issue.problemtype ?? 'نوع التخصص غير متاح',
                                    style: TextStyle(
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'نوع التخصص غير متاح',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color.fromARGB(
                                          255, 231, 110, 110),
                                    ),
                                  )
                                ],
                              ),

                            // إذا كان فيه أكتر من 3 منتجات → نعرض +عدد
                            if (issue.products != null &&
                                issue.products!.length > 3)
                              Padding(
                                padding: EdgeInsets.only(top: 6.h),
                                child: Text(
                                  '+${issue.products!.length - 3} منتجات أخرى',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // عنوان المشكلة أو تفاصيلها
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
                          issue.problemDetails ??
                              issue.problemAddress ??
                              'لا توجد تفاصيل',
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // زر "تفاصيل" في الأسفل
          Positioned(
            left: 110.w,
            bottom: 10.h,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF20AAC9), Color(0xFF1E96BA)],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF20AAC9).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: onDetailsPressed ??
                      () async {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProblemDetailsScreen(issue: issue),
                          ),
                        );

                        if (result == true && context.mounted) {
                          context.read<CustomerCubit>().resetPagination();
                          context
                              .read<CustomerCubit>()
                              .fetchTechSupportIssues();
                        }
                      },
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 36.w, vertical: 12.h),
                    child: Text(
                      'تفاصيل',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
