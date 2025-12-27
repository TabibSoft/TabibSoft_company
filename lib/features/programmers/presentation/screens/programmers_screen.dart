import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tabib_soft_company/features/programmers/data/model/customization_task_model.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/task_cubit.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/task_state.dart';
import 'package:tabib_soft_company/features/programmers/presentation/widgets/task_card.dart';
import 'package:tabib_soft_company/features/programmers/presentation/widgets/task_details_dialog.dart';

class ProgrammersScreen extends StatefulWidget {
  const ProgrammersScreen({super.key});

  @override
  State<ProgrammersScreen> createState() => _ProgrammersScreenState();
}

class _ProgrammersScreenState extends State<ProgrammersScreen>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounceTimer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    context.read<TaskCubit>().fetchTasks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _searchQuery = value.trim().toLowerCase();
        });
      }
    });
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

  List<Customization> _processCustomizations(
      List<CustomizationTaskModel> tasks) {
    var customizations = tasks.expand((task) => task.customization).toList();

    // Sort by deadLine descending (newest first)
    customizations.sort((a, b) {
      final dateA = DateTime.tryParse(a.deadLine ?? '') ?? DateTime(1970);
      final dateB = DateTime.tryParse(b.deadLine ?? '') ?? DateTime(1970);
      return dateB.compareTo(dateA);
    });

    // Filter by search query (doctor name or task/report name)
    if (_searchQuery.isNotEmpty) {
      customizations = customizations.where((c) {
        final customerName = c.customerName.toLowerCase();
        final projectName = c.projectName.toLowerCase();
        final hasMatchingReport = c.reports.any(
          (report) => report.name.toLowerCase().contains(_searchQuery),
        );
        return customerName.contains(_searchQuery) ||
            projectName.contains(_searchQuery) ||
            hasMatchingReport;
      }).toList();
    }

    return customizations;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                  cacheWidth: 220, // Cache for performance
                  cacheHeight: 220,
                ),
              ),
              const SizedBox(height: 16),
              // Search Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'ابحث باسم الطبيب أو اسم التاسك...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon:
                          const Icon(Icons.search, color: mainBlueColor),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear,
                                  color: Colors.grey.shade400),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
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
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: BlocBuilder<TaskCubit, TaskState>(
                      buildWhen: (previous, current) =>
                          previous.status != current.status ||
                          previous.tasks != current.tasks,
                      builder: (context, state) {
                        if (state.status == TaskStatus.loading) {
                          return Skeletonizer(
                            enabled: true,
                            child: ListView.builder(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 20.h,
                              ),
                              itemCount: 6,
                              itemBuilder: (context, index) =>
                                  const TaskCardSkeleton(),
                            ),
                          );
                        }

                        final customizations =
                            _processCustomizations(state.tasks);

                        if (customizations.isEmpty &&
                            state.status == TaskStatus.success) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _searchQuery.isNotEmpty
                                      ? Icons.search_off
                                      : Icons.assignment_outlined,
                                  size: 60,
                                  color: Colors.grey.shade300,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'لا توجد نتائج للبحث'
                                      : 'لا توجد مهام متاحة',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        if (state.status == TaskStatus.failure) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 60,
                                  color: Colors.red.shade300,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  state.errorMessage ?? 'حدث خطأ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.red.shade400,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      context.read<TaskCubit>().fetchTasks(),
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('إعادة المحاولة'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: mainBlueColor,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: () async {
                            await context.read<TaskCubit>().fetchTasks();
                          },
                          color: mainBlueColor,
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            cacheExtent:
                                500, // Cache more items for smoother scrolling
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 20.h,
                            ),
                            itemCount: customizations.length,
                            itemBuilder: (context, index) {
                              final customization = customizations[index];
                              return TaskCard(
                                key: ValueKey(customization.id),
                                customization: customization,
                                onDetailsTap: () => _showDetailsPopup(
                                    context, customization.id),
                              );
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
