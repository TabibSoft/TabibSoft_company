import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/task_cubit.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/task_state.dart';
import 'package:tabib_soft_company/features/programmers/presentation/widgets/task_card.dart';
import 'package:tabib_soft_company/features/programmers/presentation/widgets/task_details_dialog.dart';

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

  void _showDetailsPopup(BuildContext context, String taskId) {
    showDialog(
      context: context,
      builder: (_) => TaskDetailsDialog(
        taskId: taskId,
        taskCubit: context.read<TaskCubit>(),
      ),
    );
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
                                return const TaskCardSkeleton();
                              }

                              if (state.status == TaskStatus.success) {
                                final customization = customizations[index];
                                return TaskCard(
                                  customization: customization,
                                  onDetailsTap: () => _showDetailsPopup(
                                      context, customization.id),
                                );
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
}
