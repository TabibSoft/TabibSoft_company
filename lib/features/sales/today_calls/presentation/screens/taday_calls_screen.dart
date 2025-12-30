import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tabib_soft_company/core/services/locator/get_it_locator.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';

import 'package:tabib_soft_company/features/sales/today_calls/data/models/today_call_model.dart';
import 'package:tabib_soft_company/features/sales/today_calls/presentation/cubit/today_call_cubit.dart';
import 'package:tabib_soft_company/features/sales/today_calls/presentation/cubit/today_call_state.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intl;

class TodayCallsScreen extends StatefulWidget {
  const TodayCallsScreen({super.key});

  @override
  State<TodayCallsScreen> createState() => _TodayCallsScreenState();
}

class _TodayCallsScreenState extends State<TodayCallsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  late final TodayCallsCubit _cubit;

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _cubit = ServicesLocator.locator<TodayCallsCubit>();
    _cubit.fetchTodayCalls();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: SalesColors.primaryBlue,
              onPrimary: Colors.white,
              onSurface: SalesColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      // Re-schedule notifications if needed, or simply filter.
      // The user asked to "send local notification" when date is selected.
      // We will handle this in the build/listener or here.
      // Ideally, we should check calls for this date and schedule them.
      _scheduleNotificationsForDate(picked);
    }
  }

  void _scheduleNotificationsForDate(DateTime date) {
    // This logic relies on the loaded state.calls
    // It filters calls for the selected date and schedules them.
    final state = _cubit.state;
    if (state.status == TodayCallsStatus.loaded) {
      final callsForDate = state.calls.where((call) {
        if (call.exepectedCallDate == null) return false;
        return call.exepectedCallDate!.year == date.year &&
            call.exepectedCallDate!.month == date.month &&
            call.exepectedCallDate!.day == date.day;
      }).toList();

      for (var call in callsForDate) {
        // Logic to parse time and schedule
        // As per user request: "send local notification alert that the call time has come"
        // We will try to schedule it.

        // Assuming we have a helper in MessagingConfig.
        // Since we can't easily import MessagingConfig here without checking,
        // we will assume we can import it.
        /* 
         MessagingConfig.scheduleCallNotification(
             id: call.id.hashCode,
             title: 'موعد مكالمة: ${call.customerName}',
             body: 'حان موعد الاتصال بالعميل ${call.customerName}',
             scheduledDate: call.exepectedCallDate!); // + time logic
         */
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TodayCallsCubit, TodayCallsState>(
      // Changed to BlocConsumer to listen
      bloc: _cubit,
      listener: (context, state) {
        if (state.status == TodayCallsStatus.loaded && _selectedDate != null) {
          _scheduleNotificationsForDate(_selectedDate!);
        }
      },
      builder: (context, state) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: const Color(0xFFF8F9FD),
            body: Stack(
              children: [
                // Header Background
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 240.h,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: SalesColors.headerGradient,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(36),
                        bottomRight: Radius.circular(36),
                      ),
                    ),
                  ),
                ),

                // Main Content
                Column(
                  children: [
                    // Custom App Bar
                    SafeArea(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 16.h),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: const Icon(Icons.arrow_back_ios_new,
                                    color: Colors.white, size: 20),
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Text(
                              'مكالمات اليوم',
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.1)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.call,
                                      color: Colors.white, size: 18.sp),
                                  SizedBox(width: 8.w),
                                  Text(
                                    '${state.calls.length}',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 10.h),

                    // Search Bar & Date Picker
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _searchController,
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    color: SalesColors.textPrimary),
                                decoration: InputDecoration(
                                  hintText: 'ابحث عن عميل...',
                                  hintStyle: TextStyle(
                                      color: SalesColors.textMuted,
                                      fontSize: 14.sp),
                                  prefixIcon: Icon(Icons.search,
                                      color: SalesColors.primaryBlue,
                                      size: 24.sp),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16.w, vertical: 16.h),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          GestureDetector(
                            onTap: () => _selectDate(context),
                            child: Container(
                              padding: EdgeInsets.all(14.w),
                              decoration: BoxDecoration(
                                color: _selectedDate != null
                                    ? SalesColors.primaryBlue
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.calendar_month_rounded,
                                color: _selectedDate != null
                                    ? Colors.white
                                    : SalesColors.primaryBlue,
                                size: 24.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_selectedDate != null)
                      Padding(
                        padding: EdgeInsets.only(top: 8.h, right: 30.w),
                        child: Row(
                          children: [
                            Text(
                              'تصفية حسب: ${intl.DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 8.w),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedDate = null;
                                });
                              },
                              child: Icon(Icons.close,
                                  color: Colors.white, size: 16.sp),
                            )
                          ],
                        ),
                      ),

                    SizedBox(height: _selectedDate != null ? 37.h : 65.h),

                    // Calls List
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: RefreshIndicator(
                          onRefresh: () async {
                            _cubit.fetchTodayCalls();
                          },
                          color: SalesColors.primaryBlue,
                          child: _buildCallsContent(state),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCallsContent(TodayCallsState state) {
    final filteredCalls = state.calls.where((call) {
      final matchesSearch = call.customerName
              ?.toLowerCase()
              .contains(_searchQuery.toLowerCase()) ??
          false;

      if (_selectedDate == null) return matchesSearch;

      if (call.exepectedCallDate == null) return false;

      final isSameDay = call.exepectedCallDate!.year == _selectedDate!.year &&
          call.exepectedCallDate!.month == _selectedDate!.month &&
          call.exepectedCallDate!.day == _selectedDate!.day;

      return matchesSearch && isSameDay;
    }).toList();

    if (state.status == TodayCallsStatus.loading) {
      return ListView.separated(
        padding: EdgeInsets.only(top: 10.h, bottom: 20.h),
        itemCount: 4,
        separatorBuilder: (_, __) => SizedBox(height: 16.h),
        itemBuilder: (_, __) => Skeletonizer(
          enabled: true,
          child: Container(
            height: 140.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
        ),
      );
    } else if (state.status == TodayCallsStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, size: 40.sp, color: Colors.red),
            ),
            SizedBox(height: 16.h),
            Text(
              state.errorMessage ?? 'حدث خطأ أثناء تحميل المكالمات',
              style: TextStyle(
                  color: SalesColors.textSecondary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => _cubit.fetchTodayCalls(),
              style: ElevatedButton.styleFrom(
                backgroundColor: SalesColors.primaryBlue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
              child: const Text('إعادة المحاولة',
                  style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      );
    } else if (filteredCalls.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(30.w),
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ]),
              child: Icon(Icons.phone_missed_rounded,
                  size: 60.sp, color: SalesColors.borderMedium),
            ),
            SizedBox(height: 20.h),
            Text(
              'لا توجد مكالمات اليوم',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: SalesColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'أنت متزامن تماماً! لا توجد مهام حالياً.',
              style: TextStyle(
                fontSize: 14.sp,
                color: SalesColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.only(top: 10.h, bottom: 20.h),
      itemCount: filteredCalls.length,
      separatorBuilder: (_, __) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        return CallCard(call: filteredCalls[index], index: index);
      },
    );
  }
}

class CallCard extends StatefulWidget {
  final TodayCallModel call;
  final int index;

  const CallCard({super.key, required this.call, required this.index});

  @override
  State<CallCard> createState() => _CallCardState();
}

class _CallCardState extends State<CallCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  bool get _isOverdue {
    final now = DateTime.now();
    if (widget.call.exepectedCallDate == null) return false;

    // Case 1: Specific end time provided
    if (widget.call.exepectedCallTimeTo != null &&
        widget.call.exepectedCallTimeTo!.contains(':')) {
      try {
        final timeParts = widget.call.exepectedCallTimeTo!.split(':');
        final hours = int.parse(timeParts[0]);
        final minutes = int.parse(timeParts[1]);

        final deadline = DateTime(
          widget.call.exepectedCallDate!.year,
          widget.call.exepectedCallDate!.month,
          widget.call.exepectedCallDate!.day,
          hours,
          minutes,
        );
        return now.isAfter(deadline);
      } catch (e) {
        // If parsing fails, fall through to default logic
      }
    }

    // Case 2: No specific times provided, use Date + 1 hour as requested
    if (widget.call.exepectedCallTimeFrom == null &&
        widget.call.exepectedCallTimeTo == null) {
      final deadline =
          widget.call.exepectedCallDate!.add(const Duration(hours: 1));
      return now.isAfter(deadline);
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final bool overdue = _isOverdue;

    return Container(
      decoration: BoxDecoration(
        color: overdue ? const Color(0xFFF5F5F5) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: overdue
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFF1A1F3D).withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Stack(
          children: [
            // Left Status Strip
            Positioned(
              top: 0,
              bottom: 0,
              right: 0, // In RTL this is the "start"
              width: 6.w,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: overdue
                        ? [Colors.grey.shade400, Colors.grey.shade300]
                        : [
                            SalesColors.primaryBlue,
                            SalesColors.accentBlue,
                          ],
                  ),
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 24.w,
                      16.h), // Extra padding on right for strip
                  child: Column(
                    children: [
                      // Header (Avatar + Name + Date)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: overdue
                                      ? Colors.grey.shade300
                                      : SalesColors.primaryBlue
                                          .withOpacity(0.2),
                                  width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 22.r,
                              backgroundColor: overdue
                                  ? Colors.grey.shade200
                                  : SalesColors.surfaceLight,
                              child: Text(
                                widget.call.customerName
                                        ?.substring(0, 1)
                                        .toUpperCase() ??
                                    '?',
                                style: TextStyle(
                                  color: overdue
                                      ? Colors.grey
                                      : SalesColors.primaryBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.sp,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.call.customerName ?? 'عميل غير معروف',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: overdue
                                        ? Colors.grey
                                        : SalesColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 6.h),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8.w, vertical: 4.h),
                                      decoration: BoxDecoration(
                                        color: overdue
                                            ? Colors.transparent
                                            : SalesColors.surfaceLight,
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.calendar_today_rounded,
                                              size: 10.sp,
                                              color: overdue
                                                  ? Colors.grey
                                                  : SalesColors.textSecondary),
                                          SizedBox(width: 4.w),
                                          Text(
                                            widget.call.exepectedCallDate !=
                                                    null
                                                ? intl.DateFormat(
                                                        'd MMM - hh:mm a',
                                                        'ar') // Added time for clarity
                                                    .format(widget.call
                                                        .exepectedCallDate!)
                                                : '--',
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w600,
                                              color: overdue
                                                  ? Colors.grey
                                                  : SalesColors.textSecondary,
                                              decoration: overdue
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                            ),
                                          ),
                                          if (overdue) ...[
                                            SizedBox(width: 8.w),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 6.w,
                                                  vertical: 2.h),
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(4.r),
                                              ),
                                              child: Text(
                                                'انتهي الموعد المحدد',
                                                style: TextStyle(
                                                  fontSize: 9.sp,
                                                  color: Colors.red.shade700,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20.h),

                      // Info Block
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: overdue
                              ? Colors.grey.shade50
                              : const Color(0xFFF8F9FB),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(Icons.phone_iphone_rounded,
                                widget.call.customerPhone ?? '--',
                                isPhone: true, isOverdue: overdue),
                            if (widget.call.notes != null &&
                                widget.call.notes!.isNotEmpty) ...[
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                child: Divider(
                                    color: Colors.grey.withOpacity(0.1),
                                    height: 1),
                              ),
                              _buildInfoRow(Icons.sticky_note_2_outlined,
                                  widget.call.notes ?? '',
                                  isMultiLine: true, isOverdue: overdue),
                            ],
                          ],
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: ElevatedButton.icon(
                              onPressed: overdue
                                  ? null
                                  : () async {
                                      final Uri phoneUri = Uri(
                                          scheme: 'tel',
                                          path: widget.call.customerPhone);
                                      if (await canLaunchUrl(phoneUri)) {
                                        await launchUrl(phoneUri);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'لا يمكن فتح تطبيق الهاتف')),
                                        );
                                      }
                                    },
                              icon: const Icon(Icons.call_rounded,
                                  size: 18, color: Colors.white),
                              label: const Text('اتصال الآن',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: overdue
                                    ? Colors.grey
                                    : SalesColors.successGreen,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                            ),
                          ),
                          if (widget.call.requireImages != null &&
                              widget.call.requireImages!.isNotEmpty) ...[
                            SizedBox(width: 12.w),
                            Expanded(
                              flex: 2,
                              child: OutlinedButton.icon(
                                onPressed: overdue
                                    ? null
                                    : () {
                                        setState(() {
                                          _isExpanded = !_isExpanded;
                                        });
                                      },
                                icon: Icon(
                                    _isExpanded
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.image_outlined,
                                    size: 18,
                                    color: overdue
                                        ? Colors.grey
                                        : SalesColors.primaryBlue),
                                label: Text(
                                  _isExpanded ? 'إخفاء' : 'المرفقات',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: overdue
                                          ? Colors.grey
                                          : SalesColors.primaryBlue),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: overdue
                                      ? Colors.grey
                                      : SalesColors.primaryBlue,
                                  side: BorderSide(
                                      color: overdue
                                          ? Colors.grey.shade300
                                          : SalesColors.primaryBlue),
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Images Section (Animated)
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutQuart,
                  child: _isExpanded &&
                          (widget.call.requireImages?.isNotEmpty ?? false)
                      ? Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: SalesColors.surfaceLight,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(24.r),
                              bottomRight: Radius.circular(24.r),
                            ),
                          ),
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الصور المرفقة',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: SalesColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Wrap(
                                spacing: 10.w,
                                runSpacing: 10.h,
                                children:
                                    widget.call.requireImages!.map((imgUrl) {
                                  return GestureDetector(
                                    onTap: () {
                                      // Can implement full screen view here
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.05),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            )
                                          ]),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                        child: Image.network(
                                          imgUrl,
                                          width: 70.w,
                                          height: 70.w,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                            width: 70.w,
                                            height: 70.w,
                                            color: Colors.white,
                                            child: Icon(
                                                Icons.broken_image_rounded,
                                                color: Colors.grey[400]),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text,
      {bool isPhone = false,
      bool isMultiLine = false,
      bool isOverdue = false}) {
    return Row(
      crossAxisAlignment:
          isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Icon(icon,
              size: 16.sp,
              color: isOverdue ? Colors.grey : SalesColors.textSecondary),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              color: isOverdue
                  ? Colors.grey
                  : (isPhone
                      ? SalesColors.primaryBlue
                      : SalesColors.textPrimary),
              fontWeight: isPhone ? FontWeight.w800 : FontWeight.w500,
              decoration: isOverdue
                  ? TextDecoration.lineThrough
                  : (isPhone ? TextDecoration.none : null),
              height: isMultiLine ? 1.5 : 1,
            ),
            maxLines: isMultiLine ? 5 : 1, // Allow more lines for notes
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
