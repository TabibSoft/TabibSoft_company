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

const statusToSectionId = {
  'جارى العمل': '0cf06194-17b8-4245-9594-08dcd09a6b67',
  'قيد الاختبار': '0d18c812-b508-4306-9595-08dcd09a6b67',
  'منتهى': '006bab2f-2709-4bcd-9597-08dcd09a6b67',
};

class ProgrammersScreen extends StatefulWidget {
  const ProgrammersScreen({super.key});

  @override
  State<ProgrammersScreen> createState() => _ProgrammersScreenState();
}

class _ProgrammersScreenState extends State<ProgrammersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TaskCubit>().fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    const mainBlueColor = Color(0xFF16669E);
    const sheetColor = Color(0xFFF5F7FA);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: mainBlueColor,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'assets/images/pngs/TS_Logo0.png',
                  width: 110,
                  height: 110,
                  fit: BoxFit.contain,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: sheetColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: BlocBuilder<TaskCubit, TaskState>(
                      builder: (context, state) {
                        final customizations = state.tasks
                            .expand((task) => task.customization)
                            .toList();

                        if (customizations.isEmpty &&
                            state.status == TaskStatus.success) {
                          return const Center(
                            child: Text(
                              'لا توجد مهام متاحة',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          );
                        }

                        return Skeletonizer(
                          enabled: state.status == TaskStatus.loading,
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 20.h),
                            itemCount: state.status == TaskStatus.loading
                                ? 6
                                : customizations.length,
                            itemBuilder: (context, index) {
                              if (state.status == TaskStatus.loading) {
                                return buildTaskCardSkeleton();
                              }

                              if (state.status == TaskStatus.success) {
                                final customization = customizations[index];
                                return buildTaskCard(context, customization);
                              }

                              if (state.status == TaskStatus.failure) {
                                return Center(
                                  child: Text(
                                    state.errorMessage!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                );
                              }

                              return const SizedBox.shrink();
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTaskCardSkeleton() {
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

  Widget buildTaskCard(BuildContext context, Customization customization) {
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
                  onTap: () => showDetailsPopup(context, customization.id),
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

  void showDetailsPopup(BuildContext ctx, String taskId) {
    context.read<TaskCubit>().fetchTaskById(taskId);

    showDialog(
      context: ctx,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<TaskCubit>()),
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
                insetPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(minWidth: 400, maxWidth: 600),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Skeletonizer(
                      enabled: true,
                      child: buildDetailsDialogSkeleton(),
                    ),
                  ),
                ),
              );
            } else if (state.status == TaskStatus.success &&
                state.selectedTask != null) {
              final task = state.selectedTask!;
              final sections = state.sections; // جلب الـ sections من الـ state

              // البحث عن الـ section الحالي
              String? selectedSectionId = task.sitiouationId;

              // التأكد من وجود الـ section في القائمة
              if (!sections.any((s) => s.id == selectedSectionId) &&
                  sections.isNotEmpty) {
                selectedSectionId = sections.first.id;
              }

              final TextEditingController detailsCtrl =
                  TextEditingController(text: task.detailes);

              List<Report> allReports = List.from(task.reports);
              List<bool> checked = List.generate(
                  allReports.length, (i) => allReports[i].finished);

              return StatefulBuilder(builder: (context, setState) {
                final progress = allReports.isEmpty
                    ? 0.0
                    : checked.where((c) => c).length / allReports.length;

                return Dialog(
                  insetPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(minWidth: 400, maxWidth: 600),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'تفاصيل المهمة',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(color: const Color(0xff178CBB)),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),

                            // Dropdown للحالات الديناميكية
                            Row(
                              children: [
                                const Text('القسم:',
                                    style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 16),
                                Expanded(
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
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            const SizedBox(height: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'التقدم:',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      '${(progress * 100).toStringAsFixed(0)}%',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 12,
                                    backgroundColor: Colors.grey[300],
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            Color(0xff178CBB)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => showAddReportDialog(
                                  context, setState, allReports, checked),
                              icon: const Icon(Icons.add),
                              label: const Text('إضافة تقرير'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff178CBB),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (allReports.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xff178CBB),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children:
                                      List.generate(allReports.length, (i) {
                                    return CheckboxListTile(
                                      value: checked[i],
                                      onChanged: (v) {
                                        setState(() {
                                          checked[i] = v!;
                                        });
                                      },
                                      title: Text(
                                        allReports[i].name,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      subtitle: allReports[i].notes.isNotEmpty
                                          ? Text(
                                              allReports[i].notes,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            )
                                          : null,
                                      controlAffinity:
                                          ListTileControlAffinity.trailing,
                                      contentPadding: EdgeInsets.zero,
                                    );
                                  }),
                                ),
                              ),
                            const SizedBox(height: 24),
                            BlocListener<ReportCubit, ReportState>(
                              listener: (context, reportState) {
                                if (reportState.status ==
                                    ReportStatus.success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('تم الحفظ بنجاح')),
                                  );
                                  Navigator.of(context).pop();
                                  context.read<TaskCubit>().fetchTasks();
                                } else if (reportState.status ==
                                    ReportStatus.failure) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text(reportState.errorMessage!)),
                                  );
                                }
                              },
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

                                  // استخدام الـ section المحدد
                                  final newSitiouationId =
                                      selectedSectionId ?? task.sitiouationId;

                                  // إصلاح customerId
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
                                icon: const Icon(Icons.save, size: 20),
                                label: const Text(
                                  'حفظ التغييرات',
                                  style: TextStyle(fontSize: 16),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff178CBB),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
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
                insetPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(minWidth: 400, maxWidth: 600),
                  child: const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('حدث خطأ')),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget buildDetailsDialogSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'تفاصيل المهمة',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[400],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(height: 50, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Container(height: 100, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Container(height: 30, color: Colors.grey[300]),
        const SizedBox(height: 8),
        Container(height: 12, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Container(height: 40, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Container(height: 100, color: Colors.grey[300]),
        const SizedBox(height: 24),
        Container(height: 40, color: Colors.grey[300]),
      ],
    );
  }

  void showAddReportDialog(
    BuildContext context,
    StateSetter dialogSetState,
    List<Report> allReports,
    List<bool> checked,
  ) {
    final nameCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text(
            'إضافة تقرير جديد',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'اسم التقرير',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                decoration: InputDecoration(
                  labelText: 'ملاحظات',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedTime == null
                          ? 'اختر الوقت'
                          : selectedTime!.format(context),
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            selectedTime == null ? Colors.grey : Colors.black,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        builder: (context, child) {
                          return MediaQuery(
                            data: MediaQuery.of(context)
                                .copyWith(alwaysUse24HourFormat: false),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setDialogState(() {
                          selectedTime = picked;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff178CBB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    child: const Text(
                      'اختر',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                final note = noteCtrl.text.trim();

                if (name.isEmpty || selectedTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('يرجى إكمال جميع الحقول')),
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
                backgroundColor: const Color(0xff178CBB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }
}
