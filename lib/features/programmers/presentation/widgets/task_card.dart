import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';
import 'package:tabib_soft_company/features/programmers/data/model/customization_task_model.dart';

class TaskCardSkeleton extends StatelessWidget {
  const TaskCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        height: 18.h, width: 180.w, color: Colors.grey[200]),
                    SizedBox(height: 8.h),
                    Container(
                        height: 14.h, width: 120.w, color: Colors.grey[200]),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
              height: 8.h,
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4.r))),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  width: 80.w,
                  height: 28.h,
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.r))),
              Container(
                  width: 100.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10.r))),
            ],
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

  // Use centralized ProgrammerColors palette
  static const _primaryDark = ProgrammerColors.primaryDark;
  static const _accentOrange = ProgrammerColors.accentOrange;
  static const _accentBlue = ProgrammerColors.accentBlue;

  @override
  Widget build(BuildContext context) {
    // تنسيق التاريخ
    String formattedDeadline = '';
    bool isOverdue = false;
    if (customization.deadLine != null && customization.deadLine!.isNotEmpty) {
      try {
        final date = DateTime.parse(customization.deadLine!);
        formattedDeadline = '${date.day}/${date.month}/${date.year}';
        isOverdue = date.isBefore(DateTime.now());
      } catch (e) {
        formattedDeadline = customization.deadLine!;
      }
    }

    // تحديد اللون من situationStatus
    Color statusColor = _accentBlue;
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
          statusColor = _accentBlue;
        }
      }
    }

    // حساب عدد المهام المنجزة
    final totalReports = customization.reports.length;
    final finishedReports =
        customization.reports.where((r) => r.finished).length;
    final progress = totalReports > 0 ? finishedReports / totalReports : 0.0;
    final isCompleted = progress == 1.0;

    // عنوان المهمة (أول تقرير أو رسالة افتراضية)
    String taskTitle = 'مهمة برمجية';
    if (customization.reports.isNotEmpty) {
      taskTitle = customization.reports.first.name;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20.r),
        child: InkWell(
          onTap: onDetailsTap,
          borderRadius: BorderRadius.circular(20.r),
          child: Container(
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Task Icon Container
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isCompleted
                              ? [
                                  ProgrammerColors.accentOrange,
                                  const Color(0xFFFFB74D)
                                ]
                              : [
                                  ProgrammerColors.accentBlue,
                                  const Color(0xFF19B2E6)
                                ],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow: [
                          BoxShadow(
                            color: (isCompleted ? _accentOrange : _accentBlue)
                                .withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        isCompleted
                            ? Icons.check_circle_rounded
                            : Icons.code_rounded,
                        color: Colors.white,
                        size: 24.r,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    // Title & Project Name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            taskTitle,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: _primaryDark,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              Icon(
                                Icons.folder_outlined,
                                size: 14.r,
                                color: Colors.grey[500],
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  customization.projectName,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Status Badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: statusColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        statusName,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 18.h),

                // Progress Bar Section
                if (totalReports > 0) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'التقدم',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: (isCompleted ? _accentOrange : _accentBlue)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          '$finishedReports / $totalReports',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: isCompleted ? _accentOrange : _accentBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Stack(
                    children: [
                      // Background
                      Container(
                        height: 6.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                      ),
                      // Progress
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          height: 6.h,
                          decoration: BoxDecoration(
                            gradient: isCompleted
                                ? ProgrammerColors.orangeGradient
                                : ProgrammerColors.accentGradient,
                            borderRadius: BorderRadius.circular(3.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                ],

                // Bottom Info Row
                Row(
                  children: [
                    // Engineer Info
                    if (customization.engName.isNotEmpty) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: ProgrammerColors.backgroundLight,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              size: 16.r,
                              color: _primaryDark,
                            ),
                            SizedBox(width: 6.w),
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 100.w),
                              child: Text(
                                customization.engName,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: _primaryDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ],

                    // Deadline
                    if (formattedDeadline.isNotEmpty) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: isOverdue
                              ? ProgrammerColors.overdueRed.withOpacity(0.1)
                              : ProgrammerColors.backgroundLight,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 14.r,
                              color: isOverdue
                                  ? ProgrammerColors.overdueRed
                                  : Colors.grey[600],
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              formattedDeadline,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: isOverdue
                                    ? ProgrammerColors.overdueRed
                                    : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const Spacer(),

                    // Details Button
                    Container(
                      decoration: BoxDecoration(
                        gradient: ProgrammerColors.accentGradient,
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: [
                          BoxShadow(
                            color: _accentBlue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onDetailsTap,
                          borderRadius: BorderRadius.circular(10.r),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 10.h,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'التفاصيل',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.white,
                                  size: 12.r,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
