import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';
import 'package:tabib_soft_company/core/utils/constant/app_style.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/cubits/hr_leave_cubit.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/cubits/hr_leave_state.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/cubits/hr_profile_cubit.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/cubits/hr_profile_state.dart';
import 'package:tabib_soft_company/features/human_resources/data/models/hr_leave_request_model.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/screens/my_request_screen.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/screens/my_reports_sceen.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/screens/early_permission_screen.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/screens/vacation_request_screen.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/screens/work_fromhome_screen.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/screens/work_laws_screen.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/widgets/human_resources_widgets.dart';

class HumanResourcesScreen extends StatefulWidget {
  const HumanResourcesScreen({super.key});

  @override
  State<HumanResourcesScreen> createState() => _HumanResourcesScreenState();
}

class _HumanResourcesScreenState extends State<HumanResourcesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HrProfileCubit>().fetchHrProfile();
      context.read<HrLeaveCubit>().fetchMyLeaves();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffF5F7FA),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const HrHeaderSection(),
              BlocBuilder<HrProfileCubit, HrProfileState>(
                builder: (context, profileState) {
                  return BlocBuilder<HrLeaveCubit, HrLeaveState>(
                    builder: (context, leaveState) {
                      final isProfileLoading =
                          profileState.status == HrProfileStatus.loading ||
                              profileState.status == HrProfileStatus.initial;
                      final isLeaveLoading =
                          leaveState.status == HrLeaveStatus.loadingRequests &&
                              leaveState.leaveRequests.isEmpty;

                      if (isProfileLoading || isLeaveLoading) {
                        return const HrHumanResourcesSkeleton();
                      }

                      final profile = profileState.profile!;
                      final vacationBalance = profile.vacationBalance ?? 0;
                      final sickBalance = profile.sickLeaveBalance ?? 0;
                      final casualBalance = profile.casualLeaveBalance ?? 0;

                      final vacationMax = profile.totalVacationBalance ??
                          profile.vacationBalance ??
                          0;
                      final sickMax = profile.totalSickLeaveBalance ??
                          profile.sickLeaveBalance ??
                          0;
                      final casualMax = profile.totalCasualLeaveBalance ??
                          profile.casualLeaveBalance ??
                          0;

                      final vacationPercent = vacationMax > 0
                          ? (vacationBalance / vacationMax).clamp(0.0, 1.0)
                          : 0.0;
                      final sickPercent = sickMax > 0
                          ? (sickBalance / sickMax).clamp(0.0, 1.0)
                          : 0.0;
                      final casualPercent = casualMax > 0
                          ? (casualBalance / casualMax).clamp(0.0, 1.0)
                          : 0.0;

                      final requests = leaveState.leaveRequests;
                      final recentActivities = List<HrLeaveRequestModel>.from(
                          requests)
                        ..sort((a, b) =>
                            _requestDateTime(b).compareTo(_requestDateTime(a)));
                      final latestActivities =
                          recentActivities.take(1).toList();

                      return Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // _welcomeCard(context),
                            // SizedBox(height: 10.h),
                            Text(
                              "إحصائيات الإجازات",
                              style: AppStyle.font18_600Weight.copyWith(
                                color: AppColor.titleColor,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            SizedBox(
                              height: 150.h,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                children: [
                                  SizedBox(width: 16.w),
                                  SizedBox(
                                    width: 120.w,
                                    child: HrStatCard(
                                      title: "إجازة اعتيادية",
                                      value: "$vacationBalance/$vacationMax",
                                      percent: vacationPercent,
                                      color: AppColor.accentColor,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  SizedBox(
                                    width: 120.w,
                                    child: HrStatCard(
                                      title: "إجازة مرضية",
                                      value: "$sickBalance/$sickMax",
                                      percent: sickPercent,
                                      color: AppColor.secondaryColor,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  SizedBox(
                                    width: 120.w,
                                    child: HrStatCard(
                                      title: "إجازة عارضة",
                                      value: "$casualBalance/$casualMax",
                                      percent: casualPercent,
                                      color: const Color(0xffD6A100),
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                ],
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color:
                                      AppColor.secondaryColor.withOpacity(.2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "آخر الأنشطة",
                                        style:
                                            AppStyle.font18_600Weight.copyWith(
                                          color: AppColor.titleColor,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const MyRequestsPage(),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          "عرض الكل",
                                          style: AppStyle.font14_700Weight
                                              .copyWith(
                                            color: AppColor.accentColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  if (latestActivities.isEmpty)
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16.h),
                                      child: Text(
                                        'لا توجد أنشطة حالياً',
                                        style:
                                            AppStyle.font13_400Weight.copyWith(
                                          color: AppColor.subTitleColor,
                                        ),
                                      ),
                                    )
                                  else
                                    Column(
                                      children: List.generate(
                                          latestActivities.length, (i) {
                                        final r = latestActivities[i];
                                        return Column(
                                          children: [
                                            HrActivityCard(
                                              title:
                                                  _leaveTypeLabel(r.leaveType),
                                              time: _timeAgo(r.createdDate),
                                              status: _statusLabel(r.status),
                                              icon: _leaveIcon(r.leaveType),
                                              color: _statusColor(r.status),
                                            ),
                                            if (i < latestActivities.length - 1)
                                              SizedBox(height: 4.h),
                                          ],
                                        );
                                      }),
                                    ),
                                  // SizedBox(height: 10.h),
                                ],
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Row(
                              children: [
                                Text(
                                  "الخدمات",
                                  style: AppStyle.font18_600Weight.copyWith(
                                    color: AppColor.titleColor,
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  child: Text(
                                    "لائحة العمل",
                                    style: AppStyle.font14_700Weight.copyWith(
                                      color: AppColor.accentColor,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const WorkLawsPage(),
                                      ),
                                    );
                                  },
                                )
                              ],
                            ),
                            SizedBox(height: 14.h),
                            SizedBox(
                              height: 170.h,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                children: [
                                  HrServiceSection(
                                    title: "طلب إجازة",
                                    icon: Icons.add_rounded,
                                    bgColor: const Color(0xffEEF1FF),
                                    iconColor: const Color(0xff4C5FD5),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const VacationRequestScreen()),
                                      );
                                    },
                                  ),
                                  SizedBox(width: 12.w),
                                  HrServiceSection(
                                    title: "طلب استئذان مبكر",
                                    icon: Icons.access_time_rounded,
                                    bgColor: const Color(0xffE7FAF4),
                                    iconColor: const Color(0xff34B299),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const EarlyPermissionScreen()),
                                      );
                                    },
                                  ),
                                  SizedBox(width: 20.w),
                                  HrServiceSection(
                                    title: "طلب عمل\nمن البيت",
                                    icon: Icons.home_rounded,
                                    bgColor: const Color(0xffFFF7D9),
                                    iconColor: const Color(0xffD6A100),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const WorkFromHomeScreen()),
                                      );
                                    },
                                  ),
                                  SizedBox(width: 20.w),
                                  // _ServiceSection(
                                  //   title: "سلفة راتب",
                                  //   icon: Icons.payments_rounded,
                                  //   bgColor: const Color(0xffEAF7E8),
                                  //   iconColor: Colors.green,
                                  //   onTap: () {
                                  //     Navigator.push(
                                  //       context,
                                  //       MaterialPageRoute(
                                  //         builder: (context) =>
                                  //             const SalaryAdvanceScreen(),
                                  //       ),
                                  //     );
                                  //   },
                                  // ),
                                ],
                              ),
                            ),
                            SizedBox(height: 30.h),
                            Row(
                              children: [
                                Expanded(
                                  child: HrQuickActionButton(
                                    title: "تقاريري",
                                    icon: Icons.analytics_rounded,
                                    color: AppColor.primaryColor,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const MyReportsPage(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: HrQuickActionButton(
                                    title: "طلباتي",
                                    icon: Icons.description_rounded,
                                    color: AppColor.accentColor,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const MyRequestsPage(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 30.h),
                            SizedBox(height: 10.h),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _leaveTypeLabel(String? value) {
    switch (value) {
      case 'RegularVacation':
        return 'إجازة اعتيادية';
      case 'Casual':
        return 'إجازة عارضة';
      case 'Sick':
        return 'إجازة مرضية';
      case 'LeaveHours':
        return 'استئذان (ساعات)';
      default:
        return value ?? 'طلب إجازة';
    }
  }

  String _statusLabel(String? value) {
    switch (value) {
      case 'Approved':
        return 'تمت الموافقة';
      case 'Rejected':
        return 'مرفوض';
      case 'PendingLevel1':
      case 'PendingLevel2':
        return 'قيد المراجعة';
      default:
        return value ?? 'قيد المراجعة';
    }
  }

  Color _statusColor(String? value) {
    switch (value) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _leaveIcon(String? value) {
    switch (value) {
      case 'RegularVacation':
        return Icons.beach_access_rounded;
      case 'Sick':
        return Icons.local_hospital_rounded;
      case 'LeaveHours':
        return Icons.access_time_rounded;
      case 'Casual':
      default:
        return Icons.pending_actions_rounded;
    }
  }

  String _timeAgo(DateTime? date) {
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays == 1) return 'أمس';
    return 'منذ ${diff.inDays} أيام';
  }

  DateTime _requestDateTime(HrLeaveRequestModel request) {
    return request.createdDate ??
        request.startDate ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  // Widget _welcomeCard(BuildContext context) {
  //   return BlocBuilder<HrProfileCubit, HrProfileState>(
  //     builder: (context, state) {
  //       final name = state.profile?.employeeName ?? '';
  //       return Container(
  //         width: double.infinity,
  //         padding: EdgeInsets.all(18.w),
  //         decoration: BoxDecoration(
  //           gradient: const LinearGradient(
  //             colors: [
  //               AppColor.accentColor,
  //               AppColor.primaryColor,
  //             ],
  //           ),
  //           borderRadius: BorderRadius.circular(24.r),
  //           boxShadow: [
  //             BoxShadow(
  //               color: AppColor.primaryColor.withOpacity(.15),
  //               blurRadius: 20,
  //               offset: const Offset(0, 8),
  //             )
  //           ],
  //         ),
  //         child: Row(
  //           children: [
  //             Container(
  //               padding: EdgeInsets.all(12.w),
  //               decoration: BoxDecoration(
  //                 color: Colors.white.withOpacity(.2),
  //                 shape: BoxShape.circle,
  //               ),
  //               child: const Icon(
  //                 Icons.pending_actions_rounded,
  //                 color: Colors.white,
  //               ),
  //             ),
  //             SizedBox(width: 14.w),
  //             // Expanded(
  //             //   child: Column(
  //             //     crossAxisAlignment: CrossAxisAlignment.start,
  //             //     children: [
  //             //       Text(
  //             //         name.isNotEmpty
  //             //             ? "أهلاً بك، $name 👋"
  //             //             : "لديك طلبات قيد المراجعة",
  //             //         style: AppStyle.font16_700Weight.copyWith(
  //             //           color: Colors.white,
  //             //         ),
  //             //       ),
  //             //       SizedBox(height: 4.h),
  //             //       Text(
  //             //         "يمكنك متابعة حالة جميع الطلبات",
  //             //         style: AppStyle.font13_400Weight.copyWith(
  //             //           color: Colors.white70,
  //             //         ),
  //             //       ),
  //             //     ],
  //             //   ),
  //             // ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
}
