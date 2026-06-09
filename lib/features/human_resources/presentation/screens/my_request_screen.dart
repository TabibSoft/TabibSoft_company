import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tabib_soft_company/core/utils/constant/app_style.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/cubits/hr_leave_cubit.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/cubits/hr_leave_state.dart';
import 'package:tabib_soft_company/features/human_resources/data/models/hr_leave_request_model.dart';

class MyRequestsPage extends StatefulWidget {
  const MyRequestsPage({super.key});

  @override
  State<MyRequestsPage> createState() => _MyRequestsPageState();
}

class _MyRequestsPageState extends State<MyRequestsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'الكل';
  String _searchQuery = '';

  static const _filters = ['الكل', 'الإجازات', 'الاستئذان'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HrLeaveCubit>().fetchMyLeaves();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  DateTime _requestDateTime(HrLeaveRequestModel request) {
    return request.createdDate ??
        request.startDate ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  bool _matchesFilter(HrLeaveRequestModel request) {
    if (_selectedFilter == 'الكل') return true;
    if (_selectedFilter == 'الإجازات') return request.leaveType != 'LeaveHours';
    if (_selectedFilter == 'الاستئذان')
      return request.leaveType == 'LeaveHours';
    return true;
  }

  bool _matchesSearch(HrLeaveRequestModel request) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return true;

    final title = _leaveTypeLabel(request.leaveType).toLowerCase();
    final status = _statusLabel(request.status).toLowerCase();
    final number = request.id?.toString() ?? '';

    return title.contains(query) ||
        status.contains(query) ||
        number.contains(query);
  }

  List<HrLeaveRequestModel> _filteredRequests(
      List<HrLeaveRequestModel> requests) {
    final sorted = List<HrLeaveRequestModel>.from(requests)
      ..sort((a, b) => _requestDateTime(b).compareTo(_requestDateTime(a)));

    return sorted.where(_matchesFilter).where(_matchesSearch).toList();
  }

  Widget _buildFilterTab(String text, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = text;
          });
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00337C) : Colors.white,
            borderRadius: BorderRadius.circular(30.r),
            border: Border.all(
              color: isSelected ? Colors.transparent : const Color(0xFFE0E0E0),
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: AppStyle.font14_700Weight.copyWith(
                color: isSelected ? Colors.white : const Color(0xFF001233),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FE),
      body: Column(
        children: [
          // Header with curved gradient
          Container(
            height: 220.h,
            decoration: BoxDecoration(
              gradient: ProgrammerColors.headerGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(36.r),
                bottomRight: Radius.circular(36.r),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        // Circular menu button
                        Container(
                          width: 48.w,
                          height: 48.w,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white),
                            onPressed: () {},
                          ),
                        ),
                        const Spacer(),
                        // Title aligned right
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'طلباتي',
                              style: AppStyle.font24_700Weight.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            SizedBox(
                              width: 220.w,
                              child: Text(
                                'تتبع حالة طلباتك الإدارية والمالية بكل سهولة',
                                style: AppStyle.font14_400Weight.copyWith(
                                  color: Colors.white.withOpacity(0.95),
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Search box overlapping header
          Transform.translate(
            offset: Offset(0, -28.h),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'ابحث عن طلب معين...',
                    hintStyle: AppStyle.font14_400Weight
                        .copyWith(color: const Color(0xFF7D848D)),
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xFF7D848D)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                            child: const Icon(Icons.close,
                                color: Color(0xFF7D848D)),
                          )
                        : null,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // Filter tabs
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              children: _filters
                  .map((filter) =>
                      _buildFilterTab(filter, filter == _selectedFilter))
                  .toList(),
            ),
          ),

          SizedBox(height: 12.h),

          // Requests List with floating add button
          Expanded(
            child: Stack(
              children: [
                BlocBuilder<HrLeaveCubit, HrLeaveState>(
                  builder: (context, state) {
                    final requests = state.leaveRequests;
                    if (state.status == HrLeaveStatus.loadingRequests &&
                        requests.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final filteredRequests = _filteredRequests(requests);
                    final recentActivities = filteredRequests.take(2).toList();
                    final hasAnyRequests = requests.isNotEmpty;
                    final hasFilteredResults = filteredRequests.isNotEmpty;

                    return RefreshIndicator(
                      onRefresh: () =>
                          context.read<HrLeaveCubit>().fetchMyLeaves(),
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                        children: [
                          if (hasAnyRequests) ...[
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              child: Text(
                                'آخر الأنشطة',
                                style: AppStyle.font18_600Weight.copyWith(
                                  color: AppColor.titleColor,
                                ),
                              ),
                            ),
                            if (hasFilteredResults)
                              ...recentActivities.map((r) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 14.h),
                                  child: _buildRequestCard(
                                    status: _statusLabel(r.status),
                                    statusColor: _statusColor(r.status),
                                    title: _leaveTypeLabel(r.leaveType),
                                    date: _formatRequestDate(r),
                                    icon: _leaveIcon(r.leaveType),
                                    rejectionReason: r.rejectionReason,
                                  ),
                                );
                              })
                            else
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                child: Text(
                                  'لا توجد طلبات مطابقة للفلاتر أو البحث',
                                  style: AppStyle.font13_400Weight.copyWith(
                                    color: const Color(0xFF7D848D),
                                  ),
                                ),
                              ),
                            SizedBox(height: 16.h),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              child: Text(
                                'جميع الطلبات',
                                style: AppStyle.font18_600Weight.copyWith(
                                  color: AppColor.titleColor,
                                ),
                              ),
                            ),
                          ],
                          if (!hasAnyRequests)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              child: Text(
                                'لا توجد طلبات حالياً',
                                style: AppStyle.font13_400Weight.copyWith(
                                  color: const Color(0xFF7D848D),
                                ),
                              ),
                            ),
                          if (hasFilteredResults)
                            ...filteredRequests.map((r) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 14.h),
                                child: _buildRequestCard(
                                  status: _statusLabel(r.status),
                                  statusColor: _statusColor(r.status),
                                  title: _leaveTypeLabel(r.leaveType),
                                  date: _formatRequestDate(r),
                                  icon: _leaveIcon(r.leaveType),
                                  rejectionReason: r.rejectionReason,
                                ),
                              );
                            })
                          else if (hasAnyRequests)
                            const SizedBox.shrink(),
                          SizedBox(height: 24.h),

                          // Bottom CTA
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 8.w),
                            padding: EdgeInsets.symmetric(vertical: 28.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAE6FF),
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                            child: Center(
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF15A0C8),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 28.w, vertical: 12.h),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12.r)),
                                ),
                                child: Text(
                                  'تقديم طلب جديد',
                                  style: AppStyle.font16_700Weight
                                      .copyWith(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 40.h),
                        ],
                      ),
                    );
                  },
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard({
    required String status,
    required Color statusColor,
    required String title,
    required String date,
    required IconData icon,
    String? rejectionReason,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Colored vertical bar on the RIGHT
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 6.w,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r),
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main content (right-to-left)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Status badge
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              status,
                              style: AppStyle.font12_600Weight.copyWith(
                                color: statusColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Icon square on the right inside card
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        title,
                        style: AppStyle.font16_700Weight.copyWith(
                          color: const Color(0xFF001233),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 18, color: Color(0xFF7D848D)),
                          SizedBox(width: 6.w),
                          Text(
                            date,
                            style: AppStyle.font13_400Weight.copyWith(
                              color: const Color(0xFF7D848D),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      if (rejectionReason != null &&
                          rejectionReason.isNotEmpty) ...[
                        Text(
                          'سبب الرفض: $rejectionReason',
                          style: AppStyle.font13_400Weight.copyWith(
                            color: const Color(0xFFE53935),
                          ),
                        ),
                        SizedBox(height: 8.h),
                      ],
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: Text(
                          'التفاصيل',
                          style: AppStyle.font14_700Weight.copyWith(
                            color: const Color(0xFF19A7CE),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Icon square at the right edge of card content
                Container(
                  width: 56.w,
                  height: 56.w,
                  margin: EdgeInsets.only(left: 12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF6FF),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFE6F0FF)),
                  ),
                  child: Icon(icon, color: const Color(0xFF00337C), size: 26),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _leaveTypeLabel(String? value) {
    switch (value) {
      case 'RegularVacation':
        return 'طلب إجازة سنوية';
      case 'Casual':
        return 'طلب إجازة عارضة';
      case 'Sick':
        return 'طلب إجازة مرضية';
      case 'LeaveHours':
        return 'طلب استئذان (ساعات)';
      default:
        return 'طلب إجازة';
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
        return const Color(0xFF4CAF50);
      case 'Rejected':
        return const Color(0xFFE53935);
      default:
        return const Color(0xFFF4A800);
    }
  }

  IconData _leaveIcon(String? value) {
    switch (value) {
      case 'RegularVacation':
        return Icons.calendar_today;
      case 'Sick':
        return Icons.local_hospital;
      case 'LeaveHours':
        return Icons.access_time;
      case 'Casual':
      default:
        return Icons.pending_actions;
    }
  }

  String _formatRequestDate(HrLeaveRequestModel request) {
    final date = request.createdDate ?? request.startDate;
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
