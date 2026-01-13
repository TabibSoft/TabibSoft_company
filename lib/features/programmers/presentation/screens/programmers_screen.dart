import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';
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
    const primaryColor = ProgrammerColors.primaryDark;
    const accentColor = ProgrammerColors.accentOrange;
    const secondaryAccent = ProgrammerColors.accentBlue;
    const backgroundColor = ProgrammerColors.backgroundLight;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: primaryColor,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Modern Header Section
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  children: [
                    // Top Row with Logo and Title
                    Row(
                      children: [
                        // Logo with Glow Effect
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                accentColor.withOpacity(0.2),
                                secondaryAccent.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: accentColor.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Image.asset(
                            'assets/images/pngs/TS_Logo0.png',
                            width: 40.w,
                            height: 40.h,
                            fit: BoxFit.contain,
                            color: Colors.white,
                            cacheWidth: 80,
                            cacheHeight: 80,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        // Title Section
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'قسم المبرمجين',
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 4.h),
                            ],
                          ),
                        ),
                        // Stats Badge
                        BlocBuilder<TaskCubit, TaskState>(
                          builder: (context, state) {
                            final totalTasks = state.tasks.fold<int>(
                              0,
                              (sum, task) => sum + task.customization.length,
                            );
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                gradient: ProgrammerColors.accentGradient,
                                borderRadius: BorderRadius.circular(20.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: secondaryAccent.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.code_rounded,
                                    color: Colors.white,
                                    size: 16.r,
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    '$totalTasks',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    // Modern Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        textInputAction: TextInputAction.search,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                        ),
                        decoration: InputDecoration(
                          hintText: 'ابحث عن مهمة، مشروع، أو مطور...',
                          hintStyle: TextStyle(
                            color: Colors.white38,
                            fontSize: 14.sp,
                          ),
                          prefixIcon: Container(
                            padding: EdgeInsets.all(12.r),
                            child: Icon(
                              Icons.search_rounded,
                              color: accentColor,
                              size: 22.r,
                            ),
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Container(
                                    padding: EdgeInsets.all(4.r),
                                    decoration: BoxDecoration(
                                      color: Colors.white10,
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Icon(
                                      Icons.close_rounded,
                                      color: Colors.white60,
                                      size: 18.r,
                                    ),
                                  ),
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
                            vertical: 16.h,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              // Main Content Area
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32.r),
                      topRight: Radius.circular(32.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32.r),
                      topRight: Radius.circular(32.r),
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
                              padding: EdgeInsets.only(
                                left: 16.w,
                                right: 16.w,
                                top: 24.h,
                                bottom: 100.h,
                              ),
                              itemCount: 5,
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
                                Container(
                                  padding: EdgeInsets.all(24.r),
                                  decoration: BoxDecoration(
                                    color: ProgrammerColors.accentBlue
                                        .withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _searchQuery.isNotEmpty
                                        ? Icons.search_off_rounded
                                        : Icons.code_off_rounded,
                                    size: 56.r,
                                    color: ProgrammerColors.accentBlue,
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'لا توجد نتائج للبحث'
                                      : 'لا توجد مهام متاحة',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                    color: ProgrammerColors.primaryDark,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'جرب البحث بكلمات مختلفة'
                                      : 'ستظهر المهام الجديدة هنا',
                                  style: TextStyle(
                                    fontSize: 14.sp,
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
                                Container(
                                  padding: EdgeInsets.all(24.r),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.error_outline_rounded,
                                    size: 56.r,
                                    color: Colors.red.shade400,
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                Text(
                                  'حدث خطأ',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                    color: ProgrammerColors.primaryDark,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 40.w),
                                  child: Text(
                                    state.errorMessage ?? 'تعذر تحميل البيانات',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: ProgrammerColors.accentGradient,
                                    borderRadius: BorderRadius.circular(12.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: ProgrammerColors.accentBlue
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        context.read<TaskCubit>().fetchTasks(),
                                    icon: const Icon(Icons.refresh_rounded,
                                        size: 20),
                                    label: Text(
                                      'إعادة المحاولة',
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      shadowColor: Colors.transparent,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 24.w,
                                        vertical: 12.h,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                      ),
                                    ),
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
                          color: ProgrammerColors.accentOrange,
                          backgroundColor: Colors.white,
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            cacheExtent: 500,
                            padding: EdgeInsets.only(
                              left: 16.w,
                              right: 16.w,
                              top: 24.h,
                              bottom: 100.h,
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
