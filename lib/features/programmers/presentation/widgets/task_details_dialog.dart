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
    const primaryBlue = Color(0xff16669E);
    const accentCyan = Color(0xff20AAC9);

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
                  borderRadius: BorderRadius.circular(24.r)),
              insetPadding:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
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

              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28.r)),
                insetPadding:
                    EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: 400.w, maxWidth: 600.w),
                  child: Padding(
                    padding: EdgeInsets.all(24.r),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10.r),
                                decoration: BoxDecoration(
                                  color: primaryBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(Icons.assignment_rounded,
                                    color: primaryBlue, size: 26.r),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Text(
                                  'تفاصيل المهمة',
                                  style: TextStyle(
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xff2C3E50),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close),
                                color: Colors.grey,
                              ),
                            ],
                          ),
                          const Divider(height: 32),

                          // Section Dropdown
                          Text(
                            'حالة القسم',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 8.h),
                          DropdownButtonFormField<String>(
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
                                fontSize: 16.sp, color: Colors.black87),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.r),
                                borderSide:
                                    BorderSide(color: Colors.grey[200]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.r),
                                borderSide:
                                    BorderSide(color: Colors.grey[200]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.r),
                                borderSide: const BorderSide(
                                    color: accentCyan, width: 1.5),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 12.h),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Progress Section
                          Container(
                            padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(
                              color: accentCyan.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                  color: accentCyan.withOpacity(0.2)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'التقدم المنجز',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: accentCyan,
                                      ),
                                    ),
                                    Text(
                                      '${(progress * 100).toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w900,
                                        color: accentCyan,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 14.h,
                                    backgroundColor:
                                        accentCyan.withOpacity(0.1),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            accentCyan),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Reports Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'التقارير (${allReports.length})',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xff2C3E50),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => _showAddReportDialog(
                                    context, setState, allReports, checked),
                                icon: const Icon(Icons.add_circle_outline,
                                    size: 20),
                                label: const Text('إضافة تقرير'),
                                style: TextButton.styleFrom(
                                  foregroundColor: accentCyan,
                                  textStyle: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Reports List
                          if (allReports.isEmpty)
                            Container(
                              padding: EdgeInsets.all(32.r),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                    color: Colors.grey[200]!, width: 1.5),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.notes_rounded,
                                      size: 40.r, color: Colors.grey[300]),
                                  SizedBox(height: 12.h),
                                  const Text('لا توجد تقارير لهذا النشاط',
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            )
                          else
                            Container(
                              constraints: BoxConstraints(maxHeight: 250.h),
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                itemCount: allReports.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(height: 10.h),
                                itemBuilder: (context, i) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: checked[i]
                                          ? Colors.green.withOpacity(0.05)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(15.r),
                                      border: Border.all(
                                        color: checked[i]
                                            ? Colors.green.withOpacity(0.2)
                                            : Colors.grey[200]!,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: CheckboxListTile(
                                      value: checked[i],
                                      onChanged: (v) {
                                        setState(() {
                                          checked[i] = v!;
                                        });
                                      },
                                      activeColor: Colors.green,
                                      checkColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.r)),
                                      title: Text(
                                        allReports[i].name,
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: checked[i]
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          color: checked[i]
                                              ? Colors.green[800]
                                              : Colors.black87,
                                        ),
                                      ),
                                      subtitle: allReports[i].notes.isNotEmpty
                                          ? Text(
                                              allReports[i].notes,
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                color: Colors.grey[600],
                                              ),
                                            )
                                          : null,
                                      controlAffinity:
                                          ListTileControlAffinity.trailing,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16.w, vertical: 4.h),
                                    ),
                                  );
                                },
                              ),
                            ),

                          const SizedBox(height: 32),

                          // Save Button
                          BlocListener<ReportCubit, ReportState>(
                            listener: (context, reportState) {
                              if (reportState.status == ReportStatus.success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('تم الحفظ بنجاح')),
                                );
                                Navigator.of(context).pop();
                                widget.taskCubit.fetchTasks();
                              } else if (reportState.status ==
                                  ReportStatus.failure) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(reportState.errorMessage!)),
                                );
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryBlue.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
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
                                      selectedSectionId ?? task.sitiouationId;

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
                                    customerSupportId: task.customerSupportId,
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
                                icon: const Icon(Icons.check_circle_outline,
                                    size: 22),
                                label: Text(
                                  'حفظ التغييرات النهائية',
                                  style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryBlue,
                                  foregroundColor: Colors.white,
                                  minimumSize: Size(double.infinity, 56.h),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.r),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            });
          } else {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r)),
              child: Padding(
                padding: EdgeInsets.all(24.r),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: Colors.red, size: 50),
                      SizedBox(height: 16.h),
                      const Text('حدث خطأ أثناء تحميل البيانات'),
                      SizedBox(height: 16.h),
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('إغلاق')),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildDetailsDialogSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Container(
            height: 30.h,
            width: 150.w,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Container(
          height: 120.h,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          height: 50.h,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(15.r),
          ),
        ),
        const SizedBox(height: 24),
        Column(
          children: List.generate(
              3,
              (index) => Container(
                    height: 60.h,
                    margin: EdgeInsets.only(bottom: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                  )),
        ),
        const SizedBox(height: 24),
        Container(
          height: 55.h,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(18.r),
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
    const primaryBlue = Color(0xff16669E);
    final nameCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: EdgeInsets.all(20.r),
            decoration: const BoxDecoration(
              color: primaryBlue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.add_task_rounded, color: Colors.white),
                SizedBox(width: 12.w),
                const Text(
                  'إضافة تقرير جديد',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'اسم التقرير',
                  prefixIcon: const Icon(Icons.title_rounded, size: 22),
                  hintText: 'مثلاً: تحسين واجهة المستخدم',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'الملاحظات',
                  prefixIcon: const Icon(Icons.note_alt_rounded, size: 22),
                  hintText: 'تفاصيل إضافية حول التقرير...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: primaryBlue,
                          ),
                        ),
                        child: MediaQuery(
                          data: MediaQuery.of(context)
                              .copyWith(alwaysUse24HourFormat: false),
                          child: child!,
                        ),
                      );
                    },
                  );
                  if (picked != null) {
                    setDialogState(() {
                      selectedTime = picked;
                    });
                  }
                },
                borderRadius: BorderRadius.circular(15.r),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(15.r),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_filled_rounded,
                          color: primaryBlue),
                      SizedBox(width: 12.w),
                      Text(
                        selectedTime == null
                            ? 'تحديد الوقت المناسب'
                            : selectedTime!.format(context),
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              selectedTime == null ? Colors.grey : Colors.black,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء',
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                final note = noteCtrl.text.trim();

                if (name.isEmpty || selectedTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('يرجى إكمال جميع الحقول الضرورية')),
                  );
                  return;
                }

                final timeInMinutes =
                    selectedTime!.hour * 60 + selectedTime!.minute;

                final newReport = Report(
                  id: null,
                  name: name,
                  notes: note,
                  finished: false,
                  time: timeInMinutes,
                );

                allReports.add(newReport);
                checked.add(false);

                Navigator.of(ctx).pop();
                dialogSetState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
              child: const Text('إضافة التقرير',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
