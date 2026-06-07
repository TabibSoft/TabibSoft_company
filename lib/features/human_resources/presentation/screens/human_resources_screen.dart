import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';
import 'package:tabib_soft_company/core/utils/constant/app_style.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/cubits/hr_leave_cubit.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/cubits/hr_leave_state.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/cubits/hr_profile_cubit.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/cubits/hr_profile_state.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/screens/my_request_screen.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/screens/salary_advance_screen.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/screens/vacation_request_screen.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/screens/work_fromhome_screen.dart';

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
              const _HeaderSection(),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _welcomeCard(context),
                    SizedBox(height: 24.h),
                    Text(
                      "إحصائيات الإجازات",
                      style: AppStyle.font18_600Weight.copyWith(
                        color: AppColor.titleColor,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    BlocBuilder<HrProfileCubit, HrProfileState>(
                      builder: (context, state) {
                        if (state.status == HrProfileStatus.loading ||
                            state.status == HrProfileStatus.initial) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (state.status == HrProfileStatus.error) {
                          return Center(
                            child: Text(
                              state.failure?.errMessages ?? 'حدث خطأ',
                              style: AppStyle.font14_400Weight,
                            ),
                          );
                        }
                        final profile = state.profile!;
                        final vacationBalance = profile.vacationBalance ?? 0;
                        final sickBalance = profile.sickLeaveBalance ?? 0;
                        final casualBalance = profile.casualLeaveBalance ?? 0;

                        // حدود الإجازات حسب سياسات الموارد البشرية الحالية.
                        const vacationMax = 9;
                        const sickMax = 10;
                        const casualMax = 7;

                        final vacationMonthlyMax =
                            profile.vacationMonthlyMax ?? 0;
                        final earlyPermissionMonthlyHours =
                            profile.maxLeaveHoursPerMonth ?? 0;
                        final earlyPermissionDailyHours =
                            profile.maxLeaveHoursPerDay ?? 0;

                        final vacationPercent = vacationMax > 0
                            ? (vacationBalance / vacationMax).clamp(0.0, 1.0)
                            : 0.0;
                        final sickPercent = sickMax > 0
                            ? (sickBalance / sickMax).clamp(0.0, 1.0)
                            : 0.0;
                        final casualPercent = casualMax > 0
                            ? (casualBalance / casualMax).clamp(0.0, 1.0)
                            : 0.0;

                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _StatCard(
                                    title: "إجازة اعتيادية",
                                    value: "$vacationBalance/$vacationMax",
                                    percent: vacationPercent,
                                    color: AppColor.accentColor,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: _StatCard(
                                    title: "إجازة مرضية",
                                    value: "$sickBalance/$sickMax",
                                    percent: sickPercent,
                                    color: AppColor.secondaryColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            _StatCard(
                              title: "إجازة عارضة",
                              value: "$casualBalance/$casualMax",
                              percent: casualPercent,
                              color: const Color(0xffD6A100),
                            ),
                            SizedBox(height: 12.h),
                            SizedBox(height: 10.h),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(14.w),
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
                                  Text(
                                    "الحدود الشهرية",
                                    style: AppStyle.font14_700Weight.copyWith(
                                      color: AppColor.titleColor,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    "طلب الإجازة الاعتيادية: $vacationMonthlyMax يوم / شهر",
                                    style: AppStyle.font13_400Weight.copyWith(
                                      color: AppColor.subTitleColor,
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    "الاستئذان المبكر: $earlyPermissionMonthlyHours ساعة / شهر (بحد أقصى $earlyPermissionDailyHours ساعة يومياً)",
                                    style: AppStyle.font13_400Weight.copyWith(
                                      color: AppColor.subTitleColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 30.h),
                    Text(
                      "الخدمات",
                      style: AppStyle.font18_600Weight.copyWith(
                        color: AppColor.titleColor,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(
                      height: 200.h,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _ServiceSection(
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
                          // SizedBox(width: 12.w),
                          // _ServiceSection(
                          //   title: "طلب استئذان مبكر",
                          //   icon: Icons.access_time_rounded,
                          //   bgColor: const Color(0xffE7FAF4),
                          //   iconColor: const Color(0xff34B299),
                          //   onTap: () {
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //           builder: (context) =>
                          //               const EarlyPermissionScreen()),
                          //     );
                          //   },
                          // ),
                          SizedBox(width: 20.w),
                          _ServiceSection(
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
                          _ServiceSection(
                            title: "سلفة راتب",
                            icon: Icons.payments_rounded,
                            bgColor: const Color(0xffEAF7E8),
                            iconColor: Colors.green,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SalaryAdvanceScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "آخر الأنشطة",
                          style: AppStyle.font18_600Weight.copyWith(
                            color: AppColor.titleColor,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            "عرض الكل",
                            style: AppStyle.font14_700Weight.copyWith(
                              color: AppColor.accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    BlocBuilder<HrLeaveCubit, HrLeaveState>(
                      builder: (context, state) {
                        final requests = state.leaveRequests;

                        if (state.status == HrLeaveStatus.loadingRequests &&
                            requests.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (requests.isEmpty) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            child: Text(
                              'لا توجد أنشطة حالياً',
                              style: AppStyle.font13_400Weight.copyWith(
                                color: AppColor.subTitleColor,
                              ),
                            ),
                          );
                        }

                        final recent = requests.take(3).toList();
                        return Column(
                          children: List.generate(recent.length, (i) {
                            final r = recent[i];
                            return Column(
                              children: [
                                _ActivityCard(
                                  title: _leaveTypeLabel(r.leaveType),
                                  time: _timeAgo(r.createdDate),
                                  status: _statusLabel(r.status),
                                  icon: _leaveIcon(r.leaveType),
                                  color: _statusColor(r.status),
                                ),
                                if (i < recent.length - 1)
                                  SizedBox(height: 14.h),
                              ],
                            );
                          }),
                        );
                      },
                    ),
                    SizedBox(height: 25.h),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionButton(
                            title: "تقاريري",
                            icon: Icons.analytics_rounded,
                            color: AppColor.primaryColor,
                            onTap: () {},
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _QuickActionButton(
                            title: "طلباتي",
                            icon: Icons.description_rounded,
                            color: AppColor.accentColor,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MyRequestsPage(),
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

  Widget _welcomeCard(BuildContext context) {
    return BlocBuilder<HrProfileCubit, HrProfileState>(
      builder: (context, state) {
        final name = state.profile?.employeeName ?? '';
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColor.accentColor,
                AppColor.primaryColor,
              ],
            ),
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: AppColor.primaryColor.withOpacity(.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.pending_actions_rounded,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isNotEmpty
                          ? "أهلاً بك، $name 👋"
                          : "لديك طلبات قيد المراجعة",
                      style: AppStyle.font16_700Weight.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "يمكنك متابعة حالة جميع الطلبات",
                      style: AppStyle.font13_400Weight.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240.h,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColor.primaryColor,
            AppColor.accentColor,
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40.r),
          bottomRight: Radius.circular(40.r),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white30,
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: 32,
                    backgroundImage: AssetImage(
                      "assets/images/pngs/developers.png",
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "أهلاً بك 👋",
                        style: AppStyle.font14_400Weight.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        "قسم الموارد البشرية",
                        style: AppStyle.font24_700Weight.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final double percent;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 100.w,
            width: 100.w,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 10,
                  color: color,
                  backgroundColor: color.withOpacity(.15),
                ),
                Center(
                  child: Text(
                    value,
                    style: AppStyle.font16_700Weight.copyWith(color: color),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppStyle.font15_500Weight,
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String title;
  final String time;
  final String status;
  final IconData icon;
  final Color color;

  const _ActivityCard({
    required this.title,
    required this.time,
    required this.status,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 46.w,
              height: 46.w,
              decoration: BoxDecoration(
                color: color.withOpacity(.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24.sp,
              ),
            ),
            Container(
              width: 2.w,
              height: 70.h,
              color: Colors.grey.shade300,
            ),
          ],
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusBadge(
                  text: status,
                  color: color,
                ),
                SizedBox(height: 10.h),
                Text(
                  title,
                  style: AppStyle.font15_500Weight.copyWith(
                    color: AppColor.titleColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 16.sp,
                      color: AppColor.subTitleColor,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      time,
                      style: AppStyle.font13_400Weight.copyWith(
                        color: AppColor.subTitleColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusBadge({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 6.h,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(50.r),
      ),
      child: Text(
        text,
        style: AppStyle.font12_600Weight.copyWith(
          color: color,
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 14.w,
          vertical: 12.h,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(.08),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: color.withOpacity(.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18.sp,
              color: color,
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: AppStyle.font14_700Weight.copyWith(
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _ServiceSection({
    required this.title,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22.r),
      onTap: onTap,
      child: Container(
        width: 95.w,
        height: 320.h,
        padding: EdgeInsets.symmetric(
          horizontal: 8.w,
          vertical: 14.h,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(22.r),

          // ظل ثلاثي الأبعاد جميل وعميق
          boxShadow: [
            // الظل الرئيسي (الأقرب)
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
            // الظل المتوسط (لعمق أكبر)
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            // الظل الخارجي الناعم (لإحساس 3D فاخر)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 35,
              offset: const Offset(0, 18),
            ),
            // ظل خفيف من الأعلى لإضاءة طبيعية (Highlight)
            BoxShadow(
              color: Colors.white.withOpacity(0.7),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withOpacity(0.15),
                // ظل خفيف داخل الدائرة لتعزيز الـ 3D
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 28.sp,
              ),
            ),
            SizedBox(height: 38.h),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppStyle.font14_700Weight.copyWith(
                color: AppColor.titleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
