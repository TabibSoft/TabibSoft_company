import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tabib_soft_company/features/programmers/data/model/customization_task_model.dart';

class TaskCardSkeleton extends StatelessWidget {
  const TaskCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 13.h,
            child: Container(
              width: 390.w,
              height: 220.h,
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
          Padding(
            padding: EdgeInsets.only(top: 23.h, left: 20.w, right: 0.w),
            child: Container(
              height: 190.h,
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.r),
                border: Border.all(color: const Color(0xff20AAC9), width: 4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      height: 24.h, width: 250.w, color: Colors.grey[300]),
                  SizedBox(height: 12.h),
                  Container(
                      height: 18.h, width: 200.w, color: Colors.grey[300]),
                  SizedBox(height: 10.h),
                  Container(
                      height: 18.h, width: 180.w, color: Colors.grey[300]),
                  const Spacer(),
                  Container(
                      width: 100.w, height: 32.h, color: Colors.grey[300]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final Customization customization;
  final VoidCallback onDetailsTap;

  const TaskCard({
    super.key,
    required this.customization,
    required this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    // تنسيق التاريخ
    String formattedDeadline = '';
    if (customization.deadLine != null && customization.deadLine!.isNotEmpty) {
      try {
        final date = DateTime.parse(customization.deadLine!);
        formattedDeadline = '${date.day}/${date.month}/${date.year}';
      } catch (e) {
        formattedDeadline = customization.deadLine!;
      }
    }

    // تحديد اللون من situationStatus
    Color statusColor = const Color(0xff0000ff);
    String statusName = 'مهمة';

    if (customization.situationStatus != null) {
      statusName = customization.situationStatus!.name.isNotEmpty
          ? customization.situationStatus!.name
          : 'مهمة';

      if (customization.situationStatus!.color.isNotEmpty) {
        try {
          statusColor = Color(
            int.parse(
              '0xff${customization.situationStatus!.color.replaceAll('#', '')}',
            ),
          );
        } catch (e) {
          statusColor = const Color(0xff0000ff);
        }
      }
    }

    // حساب عدد المهام المنجزة
    final totalReports = customization.reports.length;
    final finishedReports =
        customization.reports.where((r) => r.finished).length;
    final progress = totalReports > 0 ? finishedReports / totalReports : 0.0;

    // عنوان المهمة (أول تقرير أو رسالة افتراضية)
    String taskTitle = 'مهمة برمجية';
    if (customization.reports.isNotEmpty) {
      taskTitle = customization.reports.first.name;
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // الظل الخلفي الأزرق
          Positioned(
            left: 0,
            top: 13.h,
            child: Container(
              width: 390.w,
              height: 260.h,
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
          // الكارد الأساسي
          Padding(
            padding: EdgeInsets.only(top: 23.h, left: 20.w, right: 0.w),
            child: Container(
              height: 240.h,
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.r),
                border: Border.all(color: const Color(0xff20AAC9), width: 4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // عنوان المهمة
                  Row(
                    children: [
                      Icon(
                        Icons.task_alt,
                        color: const Color(0xff178CBB),
                        size: 28.r,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          taskTitle,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // اسم المهندس
                  if (customization.engName.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.engineering_rounded,
                          color: const Color(0xff178CBB),
                          size: 24.r,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            customization.engName,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                  if (customization.engName.isNotEmpty) SizedBox(height: 10.h),

                  // التقدم
                  if (totalReports > 0)
                    Row(
                      children: [
                        Icon(
                          Icons.pie_chart,
                          color: Colors.green,
                          size: 24.r,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'التقدم: $finishedReports من $totalReports',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 8.h,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    progress == 1.0
                                        ? Colors.green
                                        : const Color(0xff178CBB),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                  if (totalReports > 0) SizedBox(height: 10.h),

                  // الموعد النهائي
                  if (formattedDeadline.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          color: Colors.red,
                          size: 22.r,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          'الموعد: $formattedDeadline',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),

                  const Spacer(),

                  // حالة المشروع
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: statusColor,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 10.r,
                          color: statusColor,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          statusName,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // زر التفاصيل
          Positioned(
            left: 110.w,
            bottom: -5.h,
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
                  onTap: onDetailsTap,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 36.w,
                      vertical: 12.h,
                    ),
                    child: Text(
                      'تفاصيل',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
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
