import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'package:tabib_soft_company/core/services/locator/get_it_locator.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_app_bar_widget.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_nav_bar_widget.dart';
import 'package:tabib_soft_company/features/programmers/data/model/customization_task_model.dart';
import 'package:tabib_soft_company/features/programmers/data/model/task_update_model.dart';
import 'package:tabib_soft_company/features/programmers/data/repo/report_repository.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/report_cubit.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/report_state.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/task_cubit.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/task_state.dart';

const statusToSectionId = {
  'مؤجل': '0cf06194-17b8-4245-9594-08dcd09a6b67', // TASKS
  'قيد العمل': '0d18c812-b508-4306-9595-08dcd09a6b67', // PROGRESS
  'تم': '006bab2f-2709-4bcd-9597-08dcd09a6b67', // FINISH
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
    final size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: CustomAppBar(
                title: 'المبرمجين',
                height: 332,
                leading: IconButton(
                  icon: Image.asset(
                    'assets/images/pngs/back.png',
                    width: 30,
                    height: 30,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            Positioned(
              top: size.height * 0.25,
              left: size.width * 0.05,
              right: size.width * 0.05,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  // color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF56C7F1), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: BlocBuilder<TaskCubit, TaskState>(
                  builder: (context, state) {
                    final customizations = state.tasks
                        .expand((task) => task.customization)
                        .toList();
                    return Skeletonizer(
                      enabled: state.status == TaskStatus.loading,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: state.status == TaskStatus.loading
                            ? 5
                            : customizations.length,
                        itemBuilder: (context, index) {
                          if (state.status == TaskStatus.loading) {
                            return _buildTaskCardSkeleton();
                          } else if (state.status == TaskStatus.success) {
                            final customization = customizations[index];
                            return _buildTaskCard(context, customization);
                          } else if (state.status == TaskStatus.failure) {
                            return Center(
                              child: Text('خطأ: ${state.errorMessage}'),
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
          ],
        ),
        bottomNavigationBar: const CustomNavBar(
          items: [],
          alignment: MainAxisAlignment.spaceBetween,
          padding: EdgeInsets.symmetric(horizontal: 32),
        ),
      ),
    );
  }

  Widget _buildTaskCardSkeleton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        height: 180,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 50,
                decoration: const BoxDecoration(
                  color: Color(0xff178CBB),
                  borderRadius:
                      BorderRadius.horizontal(left: Radius.circular(16)),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.only(left: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xff178CBB), width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'اسم المشروع: مشروع عينة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'غير محدد',
                      style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 40,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 100,
                          height: 40,
                          color: Colors.grey[300],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, Customization customization) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => _showDetailsPopup(context, customization.id),
        child: SizedBox(
          height: 180,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 50,
                  decoration: const BoxDecoration(
                    color: Color(0xff178CBB),
                    borderRadius:
                        BorderRadius.horizontal(left: Radius.circular(16)),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  margin: const EdgeInsets.only(left: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border:
                        Border.all(color: const Color(0xff178CBB), width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'اسم المشروع: ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff178CBB),
                              ),
                            ),
                            TextSpan(
                              text: customization.projectName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        customization.engName.isEmpty
                            ? 'غير محدد'
                            : customization.engName,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      // const Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailsPopup(BuildContext ctx, String taskId) {
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
                      child: _buildDetailsDialogSkeleton(),
                    ),
                  ),
                ),
              );
            } else if (state.status == TaskStatus.success &&
                state.selectedTask != null) {
              final task = state.selectedTask!;
              const statusOptions = ['مؤجل', 'قيد العمل', 'تم'];
              String? status = statusToSectionId.entries
                  .firstWhere(
                    (entry) => entry.value == task.sitiouationId,
                    orElse: () => const MapEntry(
                        'تم', '006bab2f-2709-4bcd-9597-08dcd09a6b67'),
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
                              'تفاصيل المشروع',
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
                                    onChanged: (v) =>
                                        setState(() => status = v),
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
                                    const Text(' الإنجاز:',
                                        style: TextStyle(fontSize: 16)),
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
                                    valueColor: const AlwaysStoppedAnimation(
                                        Color(0xff178CBB)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => _showAddReportDialog(
                                  context, setState, allReports, checked),
                              icon: const Icon(Icons.add),
                              label: const Text('إضافة تاسك'),
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
                                    color: const Color(0xff178CBB), width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: List.generate(allReports.length, (i) {
                                  return CheckboxListTile(
                                    value: checked[i],
                                    onChanged: (v) =>
                                        setState(() => checked[i] = v!),
                                    title: Text(
                                      allReports[i].name,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    subtitle: allReports[i].notes != null
                                        ? Text(
                                            allReports[i].notes!,
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
                                        content:
                                            Text('تم حفظ التغييرات بنجاح')),
                                  );
                                  Navigator.of(context).pop();
                                  context
                                      .read<TaskCubit>()
                                      .fetchTaskById(taskId);
                                } else if (reportState.status ==
                                    ReportStatus.failure) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'خطأ: ${reportState.errorMessage}')),
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
                                    model: "CustomizationForm",
                                  );
                                  context
                                      .read<ReportCubit>()
                                      .updateTask(updatedTask);
                                },
                                icon: const Icon(Icons.save, size: 20),
                                label: const Text('حفظ التغييرات',
                                    style: TextStyle(fontSize: 16)),
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
                    child: Center(child: Text('فشل في جلب التفاصيل')),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildDetailsDialogSkeleton() {
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
        Container(
          height: 50,
          color: Colors.grey[300],
        ),
        const SizedBox(height: 16),
        Container(
          height: 100,
          color: Colors.grey[300],
        ),
        const SizedBox(height: 16),
        Container(
          height: 30,
          color: Colors.grey[300],
        ),
        const SizedBox(height: 8),
        Container(
          height: 12,
          color: Colors.grey[300],
        ),
        const SizedBox(height: 16),
        Container(
          height: 40,
          color: Colors.grey[300],
        ),
        const SizedBox(height: 16),
        Container(
          height: 100,
          color: Colors.grey[300],
        ),
        const SizedBox(height: 24),
        Container(
          height: 40,
          color: Colors.grey[300],
        ),
      ],
    );
  }

  void _showAddReportDialog(BuildContext context, StateSetter dialogSetState,
      List<Report> allReports, List<bool> checked) {
    final nameCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'إضافة تاسك جديد',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'الاسم',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              decoration: InputDecoration(
                labelText: 'الملاحظات',
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
                        ? ' '
                        : 'الوقت: ${selectedTime!.format(context)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: selectedTime == null ? Colors.grey : Colors.black,
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child:
                      const Text('اختر الوقت', style: TextStyle(fontSize: 14)),
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
                  const SnackBar(content: Text('يرجى إدخال الاسم والوقت')),
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
