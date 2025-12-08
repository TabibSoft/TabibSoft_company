import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          );
                        }

                        return Skeletonizer(
                          enabled: state.status == TaskStatus.loading,
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 20),
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
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color.fromARGB(255, 185, 185, 185), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 150, 153, 156).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 50,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 143, 144, 145),
                  borderRadius:
                      BorderRadius.horizontal(left: Radius.circular(16)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16).copyWith(left: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 20, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Container(height: 16, width: 200, color: Colors.grey[300]),
                  const SizedBox(height: 8),
                  Container(height: 16, width: 150, color: Colors.grey[300]),
                  const SizedBox(height: 8),
                  Container(height: 16, width: 180, color: Colors.grey[300]),
                  const Spacer(),
                  Container(width: 120, height: 30, color: Colors.grey[300]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTaskCard(BuildContext context, Customization customization) {
    // تنسيق التاريخ
    String formattedDeadline = '';
    if (customization.deadLine != null &&
        customization.deadLine!.isNotEmpty) {
      try {
        final date = DateTime.parse(customization.deadLine!);
        formattedDeadline = '${date.day}/${date.month}/${date.year}';
      } catch (e) {
        formattedDeadline = customization.deadLine!;
      }
    }

    // تحديد اللون من situationStatus
    Color statusColor = const Color(0xff178CBB);
    if (customization.situationStatus != null &&
        customization.situationStatus!.color.isNotEmpty) {
      try {
        statusColor = Color(
          int.parse(
            '0xff${customization.situationStatus!.color.replaceAll('#', '')}',
          ),
        );
      } catch (e) {
        statusColor = const Color(0xff178CBB);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => showDetailsPopup(context, customization.id),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF20AAC9), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF104D9D).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // الشريط الجانبي الأزرق
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 50,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(16),
                    ),
                  ),
                ),
              ),

              // المحتوى
              Padding(
                padding: const EdgeInsets.all(16).copyWith(left: 65),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اسم المشروع
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'اسم المشروع: ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff178CBB),
                            ),
                          ),
                          TextSpan(
                            text: customization.projectName.isEmpty
                                ? 'غير محدد'
                                : customization.projectName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // اسم العميل
                    if (customization.customerName.isNotEmpty)
                      _buildInfoRow(
                        icon: Icons.person,
                        label: 'العميل',
                        value: customization.customerName,
                      ),

                    if (customization.customerName.isNotEmpty)
                      const SizedBox(height: 6),

                    // اسم المهندس
                    if (customization.engName.isNotEmpty)
                      _buildInfoRow(
                        icon: Icons.engineering,
                        label: 'المهندس',
                        value: customization.engName,
                      ),

                    if (customization.engName.isNotEmpty)
                      const SizedBox(height: 6),

                    // اسم مهندس الاختبار
                    if (customization.testEngName.isNotEmpty)
                      _buildInfoRow(
                        icon: Icons.science,
                        label: 'مهندس الاختبار',
                        value: customization.testEngName,
                      ),

                    if (customization.testEngName.isNotEmpty)
                      const SizedBox(height: 6),

                    // الموعد النهائي
                    if (formattedDeadline.isNotEmpty)
                      _buildInfoRow(
                        icon: Icons.calendar_today,
                        label: 'الموعد النهائي',
                        value: formattedDeadline,
                        color: Colors.red,
                      ),

                    const SizedBox(height: 12),

                    // حالة المشروع
                    if (customization.situationStatus != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: statusColor,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 10,
                              color: statusColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              customization.situationStatus!.name,
                              style: TextStyle(
                                fontSize: 13,
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
            ],
          ),
        ),
      ),
    );
  }

  // دالة مساعدة لعرض صف معلومة
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color ?? const Color(0xff178CBB),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color ?? const Color(0xff178CBB),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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

              const statusOptions = [
                'جارى العمل',
                'قيد الاختبار',
                'منتهى',
              ];

              String? status = statusToSectionId.entries
                  .firstWhere(
                    (entry) => entry.value == task.sitiouationId,
                    orElse: () => const MapEntry(
                        'جارى العمل', '006bab2f-2709-4bcd-9597-08dcd09a6b67'),
                  )
                  .key;

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
                            Row(
                              children: [
                                const Text('الحالة:',
                                    style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: status,
                                    items: statusOptions
                                        .map((s) => DropdownMenuItem(
                                              value: s,
                                              child: Text(s),
                                            ))
                                        .toList(),
                                    onChanged: (v) {
                                      setState(() {
                                        status = v;
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
                            TextField(
                              controller: detailsCtrl,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: 'أدخل التفاصيل...',
                                hintStyle: const TextStyle(color: Colors.grey),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
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
                                children: List.generate(allReports.length, (i) {
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
                                  context
                                      .read<TaskCubit>()
                                      .fetchTaskById(taskId);
                                } else if (reportState.status ==
                                    ReportStatus.failure) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(reportState.errorMessage!)),
                                  );
                                }
                              },
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  final updatedReports = allReports
                                      .asMap()
                                      .entries
                                      .map((e) {
                                        final index = e.key;
                                        final report = e.value;
                                        return Report(
                                          id: report.id,
                                          name: report.name,
                                          notes: report.notes,
                                          finished: checked[index],
                                          time: report.time,
                                        );
                                      })
                                      .toList();

                                  final newSitiouationId =
                                      statusToSectionId[status!] ??
                                          task.sitiouationId;

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
                                    customerId: task.customerId,
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
      builder: (ctx) => AlertDialog(
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
                      dialogSetState(() {
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
    );
  }
}
