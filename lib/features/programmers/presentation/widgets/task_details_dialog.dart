import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'package:tabib_soft_company/core/services/locator/get_it_locator.dart';
import 'package:tabib_soft_company/features/programmers/data/model/customization_task_model.dart';
import 'package:tabib_soft_company/features/programmers/data/model/task_update_model.dart';
import 'package:tabib_soft_company/features/programmers/data/repo/report_repository.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/report_cubit.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/report_state.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/task_cubit.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/task_state.dart';

class TaskDetailsDialog extends StatefulWidget {
  final String taskId;
  final TaskCubit taskCubit;

  const TaskDetailsDialog({
    super.key,
    required this.taskId,
    required this.taskCubit,
  });

  @override
  State<TaskDetailsDialog> createState() => _TaskDetailsDialogState();
}

class _TaskDetailsDialogState extends State<TaskDetailsDialog> {
  @override
  void initState() {
    super.initState();
    widget.taskCubit.fetchTaskById(widget.taskId);
  }

  @override
  Widget build(BuildContext context) {
    const primaryDark = ProgrammerColors.primaryDark;
    const accentOrange = ProgrammerColors.accentOrange;
    const accentBlue = ProgrammerColors.accentBlue;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: widget.taskCubit),
        BlocProvider(
          create: (context) => ReportCubit(
            ReportRepository(ServicesLocator.locator<ApiService>()),
          ),
        ),
      ],
      child: BlocBuilder<TaskCubit, TaskState>(
        builder: (context, state) {
          if (state.status == TaskStatus.loading) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28.r)),
              insetPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: 400.w, maxWidth: 600.w),
                child: Padding(
                  padding: EdgeInsets.all(24.r),
                  child: Skeletonizer(
                    enabled: true,
                    child: _buildDetailsDialogSkeleton(),
                  ),
                ),
              ),
            );
          } else if (state.status == TaskStatus.success &&
              state.selectedTask != null) {
            final task = state.selectedTask!;
            final sections = state.sections;

            String? selectedSectionId = task.sitiouationId;

            if (!sections.any((s) => s.id == selectedSectionId) &&
                sections.isNotEmpty) {
              selectedSectionId = sections.first.id;
            }

            final TextEditingController detailsCtrl =
                TextEditingController(text: task.detailes);

            List<Report> allReports = List.from(task.reports);
            List<bool> checked =
                List.generate(allReports.length, (i) => allReports[i].finished);

            return StatefulBuilder(builder: (context, setState) {
              final progress = allReports.isEmpty
                  ? 0.0
                  : checked.where((c) => c).length / allReports.length;
              final isCompleted = progress == 1.0;

              return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                child: Container(
                  constraints: BoxConstraints(minWidth: 400.w, maxWidth: 600.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28.r),
                    boxShadow: [
                      BoxShadow(
                        color: primaryDark.withOpacity(0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Modern Header with Gradient
                      Container(
                        padding: EdgeInsets.all(20.r),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isCompleted
                                ? [
                                    ProgrammerColors.accentOrange,
                                    const Color(0xFFFFB74D)
                                  ]
                                : [
                                    ProgrammerColors.primaryDark,
                                    const Color(0xFF00409A)
                                  ],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(28.r),
                            topRight: Radius.circular(28.r),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12.r),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Icon(
                                isCompleted
                                    ? Icons.check_circle_rounded
                                    : Icons.code_rounded,
                                color: Colors.white,
                                size: 26.r,
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'تفاصيل المهمة',
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    isCompleted ? 'مكتملة' : 'قيد التنفيذ',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Navigator.pop(context),
                                borderRadius: BorderRadius.circular(12.r),
                                child: Container(
                                  padding: EdgeInsets.all(8.r),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Icon(
                                    Icons.close_rounded,
                                    color: Colors.white70,
                                    size: 22.r,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Content Area
                      Flexible(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.all(20.r),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Section Dropdown with Modern Style
                              Text(
                                'حالة القسم',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: primaryDark,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Container(
                                decoration: BoxDecoration(
                                  color: ProgrammerColors.backgroundLight,
                                  borderRadius: BorderRadius.circular(14.r),
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.15),
                                  ),
                                ),
                                child: DropdownButtonFormField<String>(
                                  initialValue: selectedSectionId,
                                  items: sections
                                      .map((section) => DropdownMenuItem(
                                            value: section.id,
                                            child: Text(section.name),
                                          ))
                                      .toList(),
                                  onChanged: (v) {
                                    setState(() {
                                      selectedSectionId = v;
                                    });
                                  },
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: primaryDark,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: accentBlue,
                                    size: 24,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 14.h,
                                    ),
                                  ),
                                  dropdownColor: Colors.white,
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                              ),
                              SizedBox(height: 24.h),

                              // Progress Section with Modern Design
                              Container(
                                padding: EdgeInsets.all(20.r),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isCompleted
                                        ? [
                                            accentOrange.withOpacity(0.08),
                                            accentOrange.withOpacity(0.03),
                                          ]
                                        : [
                                            accentBlue.withOpacity(0.08),
                                            accentBlue.withOpacity(0.03),
                                          ],
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomLeft,
                                  ),
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: (isCompleted
                                            ? accentOrange
                                            : accentBlue)
                                        .withOpacity(0.2),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(8.r),
                                              decoration: BoxDecoration(
                                                color: (isCompleted
                                                        ? accentOrange
                                                        : accentBlue)
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(10.r),
                                              ),
                                              child: Icon(
                                                Icons.analytics_rounded,
                                                color: isCompleted
                                                    ? accentOrange
                                                    : accentBlue,
                                                size: 20.r,
                                              ),
                                            ),
                                            SizedBox(width: 12.w),
                                            Text(
                                              'التقدم المنجز',
                                              style: TextStyle(
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.w600,
                                                color: primaryDark,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 14.w,
                                            vertical: 8.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isCompleted
                                                ? accentOrange
                                                : accentBlue,
                                            borderRadius:
                                                BorderRadius.circular(10.r),
                                          ),
                                          child: Text(
                                            '${(progress * 100).toStringAsFixed(0)}%',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16.h),
                                    Stack(
                                      children: [
                                        Container(
                                          height: 10.h,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius:
                                                BorderRadius.circular(5.r),
                                          ),
                                        ),
                                        FractionallySizedBox(
                                          widthFactor: progress,
                                          child: Container(
                                            height: 10.h,
                                            decoration: BoxDecoration(
                                              gradient: isCompleted
                                                  ? ProgrammerColors
                                                      .orangeGradient
                                                  : ProgrammerColors
                                                      .accentGradient,
                                              borderRadius:
                                                  BorderRadius.circular(5.r),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 24.h),

                              // Reports Header
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.list_alt_rounded,
                                        color: primaryDark,
                                        size: 22.r,
                                      ),
                                      SizedBox(width: 10.w),
                                      Text(
                                        'التقارير',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          color: primaryDark,
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                          vertical: 4.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: accentBlue.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                        ),
                                        child: Text(
                                          '${allReports.length}',
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.bold,
                                            color: accentBlue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => _showAddReportDialog(context,
                                          setState, allReports, checked),
                                      borderRadius: BorderRadius.circular(10.r),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 8.h,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient:
                                              ProgrammerColors.accentGradient,
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  accentBlue.withOpacity(0.3),
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.add_rounded,
                                              color: Colors.white,
                                              size: 18.r,
                                            ),
                                            SizedBox(width: 4.w),
                                            Text(
                                              'إضافة',
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 14.h),

                              // Reports List with Modern Cards
                              if (allReports.isEmpty)
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 40.h),
                                  decoration: BoxDecoration(
                                    color: ProgrammerColors.backgroundLight,
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(
                                      color: Colors.grey.withOpacity(0.1),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.inbox_rounded,
                                        size: 48.r,
                                        color: Colors.grey[400],
                                      ),
                                      SizedBox(height: 12.h),
                                      Text(
                                        'لا توجد تقارير',
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        'اضغط على "إضافة" لإنشاء تقرير جديد',
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Container(
                                  constraints: BoxConstraints(maxHeight: 220.h),
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: allReports.length,
                                    separatorBuilder: (_, __) =>
                                        SizedBox(height: 10.h),
                                    itemBuilder: (context, i) {
                                      return _buildReportItem(
                                        context,
                                        allReports[i],
                                        checked[i],
                                        (value) {
                                          setState(() {
                                            checked[i] = value ?? false;
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ),

                              SizedBox(height: 28.h),

                              // Save Button
                              BlocListener<ReportCubit, ReportState>(
                                listener: (context, reportState) {
                                  if (reportState.status ==
                                      ReportStatus.success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(Icons.check_circle,
                                                color: Colors.white),
                                            SizedBox(width: 8.w),
                                            const Text('تم الحفظ بنجاح'),
                                          ],
                                        ),
                                        backgroundColor:
                                            ProgrammerColors.successGreen,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    );
                                    Navigator.of(context).pop();
                                    widget.taskCubit.fetchTasks();
                                  } else if (reportState.status ==
                                      ReportStatus.failure) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text(reportState.errorMessage!),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.r),
                                    gradient: const LinearGradient(
                                      colors: [
                                        ProgrammerColors.primaryDark,
                                        Color(0xFF00409A)
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaryDark.withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      final updatedReports =
                                          allReports.asMap().entries.map((e) {
                                        final index = e.key;
                                        final report = e.value;
                                        return Report(
                                          id: report.id,
                                          name: report.name,
                                          notes: report.notes,
                                          finished: checked[index],
                                          time: report.time,
                                        );
                                      }).toList();

                                      final newSitiouationId =
                                          selectedSectionId ??
                                              task.sitiouationId;

                                      String? validCustomerId = task.customerId;
                                      if (validCustomerId.isEmpty) {
                                        validCustomerId = null;
                                      }

                                      final updatedTask = TaskUpdateModel(
                                        id: task.id,
                                        image: task.image,
                                        startDate: task.startDate,
                                        deadLine: task.deadLine,
                                        engRate: task.engRate,
                                        testing: task.testing,
                                        applaied: task.applaied,
                                        enginnerTesterId: task.enginnerTesterId,
                                        engineerIds: task.engineerIds,
                                        customerSupportId:
                                            task.customerSupportId,
                                        customerId: validCustomerId,
                                        detailes: detailsCtrl.text,
                                        reports: updatedReports,
                                        sitiouationStatusesId:
                                            task.sitiouationStatusesId,
                                        sitiouationId: newSitiouationId,
                                        file: task.file,
                                        model: 'CustomizationForm',
                                      );

                                      context
                                          .read<ReportCubit>()
                                          .updateTask(updatedTask);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      shadowColor: Colors.transparent,
                                      minimumSize: Size(double.infinity, 56.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.r),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.save_rounded, size: 22.r),
                                        SizedBox(width: 10.w),
                                        Text(
                                          'حفظ التغييرات',
                                          style: TextStyle(
                                            fontSize: 17.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
          } else {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: EdgeInsets.all(32.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        color: Colors.red,
                        size: 48.r,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'حدث خطأ',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: primaryDark,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'تعذر تحميل بيانات المهمة',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 24.h),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: accentBlue,
                      ),
                      child: const Text('إغلاق'),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildReportItem(
    BuildContext context,
    Report report,
    bool isChecked,
    ValueChanged<bool?> onChanged,
  ) {
    const primaryDark = ProgrammerColors.primaryDark;
    const accentOrange = ProgrammerColors.accentOrange;

    return Container(
      decoration: BoxDecoration(
        color: isChecked ? accentOrange.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isChecked
              ? accentOrange.withOpacity(0.3)
              : Colors.grey.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(!isChecked),
          borderRadius: BorderRadius.circular(14.r),
          child: Padding(
            padding: EdgeInsets.all(14.r),
            child: Row(
              children: [
                // Custom Checkbox
                Container(
                  width: 24.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: isChecked ? accentOrange : Colors.transparent,
                    borderRadius: BorderRadius.circular(7.r),
                    border: Border.all(
                      color: isChecked ? accentOrange : Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  child: isChecked
                      ? Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 16.r,
                        )
                      : null,
                ),
                SizedBox(width: 14.w),
                // Report Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.name,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight:
                              isChecked ? FontWeight.w600 : FontWeight.w500,
                          color: isChecked
                              ? ProgrammerColors.successGreen
                              : primaryDark,
                          decoration:
                              isChecked ? TextDecoration.lineThrough : null,
                          decorationColor: ProgrammerColors.successGreen,
                        ),
                      ),
                      if (report.notes.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          report.notes,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                // Status Icon
                if (isChecked)
                  Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: BoxDecoration(
                      color: ProgrammerColors.successGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.done_all_rounded,
                      color: ProgrammerColors.successGreen,
                      size: 16.r,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsDialogSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header Skeleton
        Row(
          children: [
            Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      height: 20.h, width: 120.w, color: Colors.grey[200]),
                  SizedBox(height: 8.h),
                  Container(height: 14.h, width: 80.w, color: Colors.grey[200]),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 28.h),
        // Progress Section Skeleton
        Container(
          height: 100.h,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
        SizedBox(height: 24.h),
        // Reports Skeleton
        Container(height: 20.h, width: 100.w, color: Colors.grey[200]),
        SizedBox(height: 14.h),
        Column(
          children: List.generate(
            3,
            (index) => Container(
              height: 60.h,
              margin: EdgeInsets.only(bottom: 10.h),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
          ),
        ),
        SizedBox(height: 24.h),
        // Button Skeleton
        Container(
          height: 56.h,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ],
    );
  }

  void _showAddReportDialog(
    BuildContext context,
    StateSetter dialogSetState,
    List<Report> allReports,
    List<bool> checked,
  ) {
    const primaryDark = ProgrammerColors.primaryDark;
    const accentOrange = ProgrammerColors.accentOrange;
    const accentBlue = ProgrammerColors.accentBlue;
    final nameCtrl = TextEditingController();
    final focusNode = FocusNode();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Add Report Dialog',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return ScaleTransition(
          scale: curvedAnimation,
          child: FadeTransition(
            opacity: animation,
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28.r),
                  ),
                  contentPadding: EdgeInsets.zero,
                  content: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28.r),
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header with gradient
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 20.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: ProgrammerColors.headerGradient,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(28.r),
                              topRight: Radius.circular(28.r),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10.r),
                                decoration: BoxDecoration(
                                  color: accentOrange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  Icons.add_task_rounded,
                                  color: accentOrange,
                                  size: 24.r,
                                ),
                              ),
                              SizedBox(width: 14.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'إضافة تقرير جديد',
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      'أضف وصفاً للمهمة أو التقرير',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => Navigator.pop(context),
                                  borderRadius: BorderRadius.circular(10.r),
                                  child: Container(
                                    padding: EdgeInsets.all(6.r),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: Icon(
                                      Icons.close_rounded,
                                      color: Colors.white70,
                                      size: 20.r,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Content
                        Padding(
                          padding: EdgeInsets.all(24.r),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Text field with modern design
                              Container(
                                decoration: BoxDecoration(
                                  color: ProgrammerColors.backgroundLight,
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.15),
                                  ),
                                ),
                                child: TextField(
                                  controller: nameCtrl,
                                  focusNode: focusNode,
                                  maxLines: 5,
                                  minLines: 4,
                                  textAlignVertical: TextAlignVertical.top,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    height: 1.5,
                                    color: primaryDark,
                                  ),
                                  decoration: InputDecoration(
                                    hintText:
                                        'اكتب وصف التقرير أو المهمة هنا...',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 14.sp,
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    filled: true,
                                    fillColor: Colors.transparent,
                                    contentPadding: EdgeInsets.all(16.r),
                                  ),
                                ),
                              ),

                              SizedBox(height: 24.h),

                              // Action buttons
                              Row(
                                children: [
                                  // Cancel button
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 14.h),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                          side: BorderSide(
                                              color: Colors.grey[300]!),
                                        ),
                                      ),
                                      child: Text(
                                        'إلغاء',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  // Add button
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                        gradient:
                                            ProgrammerColors.accentGradient,
                                        boxShadow: [
                                          BoxShadow(
                                            color: accentBlue.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          final name = nameCtrl.text.trim();

                                          if (name.isEmpty) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Row(
                                                  children: [
                                                    const Icon(
                                                        Icons
                                                            .warning_amber_rounded,
                                                        color: Colors.white),
                                                    SizedBox(width: 8.w),
                                                    const Text(
                                                        'يرجى إدخال وصف التقرير'),
                                                  ],
                                                ),
                                                backgroundColor:
                                                    Colors.orange[700],
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                            );
                                            return;
                                          }

                                          final newReport = Report(
                                            id: null,
                                            name: name,
                                            notes: '',
                                            finished: false,
                                            time: 0,
                                          );

                                          allReports.add(newReport);
                                          checked.add(false);

                                          Navigator.pop(context);
                                          dialogSetState(() {});

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                children: [
                                                  const Icon(Icons.check_circle,
                                                      color: Colors.white),
                                                  SizedBox(width: 8.w),
                                                  const Text(
                                                      'تم إضافة التقرير بنجاح'),
                                                ],
                                              ),
                                              backgroundColor:
                                                  ProgrammerColors.successGreen,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          );
                                        },
                                        icon:
                                            Icon(Icons.add_rounded, size: 20.r),
                                        label: Text(
                                          'إضافة التقرير',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15.sp,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          foregroundColor: Colors.white,
                                          shadowColor: Colors.transparent,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 14.h),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.r),
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
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
