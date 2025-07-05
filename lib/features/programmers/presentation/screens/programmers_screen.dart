import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

// خريطة لربط الحالات بمعرفات الأقسام
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
              top: 250 - 40,
              right: size.width * 0.3,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: تنفيذ إضافة مشكلة جديدة
                },
                icon: const Icon(Icons.add, size: 20),
                label: const Text('إضافة مشكلة',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  backgroundColor: const Color(0xff178CBB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            Positioned(
              top: size.height * 0.33,
              left: size.width * 0.05,
              right: size.width * 0.05,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF56C7F1), width: 3),
                ),
              ),
            ),
            Positioned(
              top: size.height * 0.35 + 16,
              left: size.width * 0.05 + 16,
              right: size.width * 0.05 + 16,
              bottom: 16,
              child: BlocBuilder<TaskCubit, TaskState>(
                builder: (context, state) {
                  if (state.status == TaskStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state.status == TaskStatus.success) {
                    final customizations = state.tasks
                        .expand((task) => task.customization)
                        .toList();
                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: customizations.length,
                      itemBuilder: (context, index) {
                        final customization = customizations[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GestureDetector(
                            onTap: () =>
                                _showDetailsPopup(context, customization.id),
                            child: SizedBox(
                              height: 220,
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
                                        borderRadius: BorderRadius.horizontal(
                                            left: Radius.circular(20)),
                                      ),
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 12),
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            color: const Color(0xff178CBB),
                                            width: 2),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                  text:
                                                      customization.projectName,
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
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey),
                                          ),
                                          const SizedBox(height: 16),
                                          const Spacer(),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  // TODO: تنفيذ زر العميل
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xff178CBB),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                  minimumSize:
                                                      const Size(100, 48),
                                                  textStyle: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                child: const Text('عميل',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ),
                                              const SizedBox(width: 16),
                                              ElevatedButton(
                                                onPressed: () {
                                                  // TODO: تنفيذ زر التعديل
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xff178CBB),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                  minimumSize:
                                                      const Size(100, 48),
                                                  textStyle: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                child: const Text('تعديل',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else if (state.status == TaskStatus.failure) {
                    return Center(child: Text('خطأ: ${state.errorMessage}'));
                  }
                  return const SizedBox.shrink();
                },
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
              return const Center(child: CircularProgressIndicator());
            } else if (state.status == TaskStatus.success &&
                state.selectedTask != null) {
              final task = state.selectedTask!;
              const statusOptions = ['مؤجل', 'قيد العمل', 'تم'];
              String? status =
                  statusOptions.contains(task.sitiouationStatusesId)
                      ? task.sitiouationStatusesId
                      : 'تم';
              final TextEditingController detailsCtrl =
                  TextEditingController(text: task.detailes);
              final reports = task.reports;
              final checked = List<bool>.filled(reports.length, false);
              for (int i = 0; i < reports.length; i++) {
                checked[i] = reports[i].finished;
              }
              int currentTab = 0;

              return StatefulBuilder(builder: (context, setState) {
                final progress = reports.isEmpty
                    ? 0.0
                    : checked.where((c) => c).length / reports.length;
                return Dialog(
                  insetPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(minWidth: 600, maxWidth: 650),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
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
                                            value: s, child: Text(s)))
                                        .toList(),
                                    onChanged: (v) =>
                                        setState(() => status = v),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: detailsCtrl,
                              maxLines: 5,
                              decoration: InputDecoration(
                                hintText: 'أدخل التفاصيل...',
                                hintStyle: const TextStyle(color: Colors.grey),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('حالة الإنجاز:',
                                        style: TextStyle(fontSize: 16)),
                                    Text(
                                      '${(progress * 100).toStringAsFixed(0)}%',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
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
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color(0xff178CBB), width: 2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: List.generate(reports.length, (i) {
                                  return CheckboxListTile(
                                    value: checked[i],
                                    onChanged: (v) =>
                                        setState(() => checked[i] = v!),
                                    title: Text(reports[i].name,
                                        style: const TextStyle(fontSize: 16)),
                                    subtitle: reports[i].notes != null
                                        ? Text(reports[i].notes!,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey))
                                        : null,
                                    controlAffinity:
                                        ListTileControlAffinity.trailing,
                                    contentPadding: EdgeInsets.zero,
                                  );
                                }),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.grey.shade300))),
                              // Removed the tab row as requested.
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
                                      .fetchTaskById(taskId); // تحديث المهمة
                                } else if (reportState.status ==
                                    ReportStatus.failure) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'خطأ: ${reportState.errorMessage}')),
                                  );
                                }
                              },
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        final updatedReports = task.reports
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
                                          enginnerTesterId:
                                              task.enginnerTesterId,
                                          engineerIds: task.engineerIds,
                                          customerSupportId:
                                              task.customerSupportId,
                                          customerId: task.customerId,
                                          detailes: detailsCtrl.text,
                                          reports: updatedReports,
                                          sitiouationStatusesId: task
                                              .sitiouationStatusesId, // الاحتفاظ بالقيمة الأصلية
                                          sitiouationId: newSitiouationId,
                                          file: task.file,
                                        );
                                        context
                                            .read<ReportCubit>()
                                            .updateTask(updatedTask);
                                      },
                                      icon: const Icon(Icons.save, size: 20),
                                      label: const Text('حفظ التغييرات',
                                          style: TextStyle(fontSize: 16)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xff178CBB),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                      ),
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
                );
              });
            } else {
              return const Center(child: Text('فشل في جلب التفاصيل'));
            }
          },
        ),
      ),
    );
  }
}
