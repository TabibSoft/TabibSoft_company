import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:tabib_soft_company/core/utils/cache/cache_helper.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';
import 'package:tabib_soft_company/features/home/notifications/presentation/screens/notification_detail_screen_anyRole.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/screens/notes/notes_screen.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/widgets/home_widgets/filter_widget.dart';
import 'package:tabib_soft_company/features/home/notifications/data/model/notification_model.dart';
import 'package:tabib_soft_company/features/home/notifications/presentation/cubits/notification_cubit.dart';
import 'package:tabib_soft_company/features/home/notifications/presentation/cubits/notification_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _userRoles;
  late AnimationController _animationController;
  late AnimationController _shimmerController;
  // 1 = admin notes only, 2 = other notifications
  int _selectedFilter = 2;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _loadUserRoles();

    context.read<NotificationCubit>().clearUnreadNotificationBadge();
    context.read<NotificationCubit>().fetchNotifications();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _loadUserRoles() async {
    await CacheHelper.init();
    final rolesString =
        CacheHelper.sharedPreferences.getString('userRoles') ?? '';
    setState(() {
      _userRoles = rolesString;
    });
  }

  bool _hasSalesRole() {
    if (_userRoles == null || _userRoles!.isEmpty) return false;
    final roles = _userRoles!.split(',');
    return roles.contains('SALES') || roles.contains('SALSE');
  }

  String formatDate(DateTime date) {
    final localDate = date.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notificationDate =
        DateTime(localDate.year, localDate.month, localDate.day);

    if (notificationDate == today) {
      return 'اليوم ${DateFormat('hh:mm a', 'ar').format(localDate)}';
    } else if (notificationDate == yesterday) {
      return 'أمس ${DateFormat('hh:mm a', 'ar').format(localDate)}';
    }
    return DateFormat('dd MMM yyyy - hh:mm a', 'ar').format(localDate);
  }

  bool _isLeaveNotification(NotificationModel notification) {
    final type = notification.type?.toLowerCase() ?? '';
    final title = notification.title.toLowerCase();
    final body = notification.body.toLowerCase();

    return type.contains('leave') ||
        type.contains('vacation') ||
        type.contains('hrleave') ||
        title.contains('إجاز') ||
        title.contains('اجاز') ||
        title.contains('leave') ||
        body.contains('إجاز') ||
        body.contains('اجاز') ||
        body.contains('leave');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TechColors.surfaceLight,
      body: Stack(
        children: [
          Container(
            height: 280.h,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: TechColors.premiumGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -50,
                  right: -50,
                  child: Container(
                    width: 180.r,
                    height: 180.r,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 100,
                  left: -30,
                  child: Container(
                    width: 120.r,
                    height: 120.r,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Expanded(
                        child: Text(
                          'الإشعارات',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            context.read<NotificationCubit>().markAllAsRead(),
                        child: Text(
                          'قراءة الكل',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                Hero(
                  tag: 'app_logo',
                  child: Image.asset(
                    'assets/images/pngs/TS_Logo0.png',
                    width: 100.w,
                    height: 60.h,
                    color: Colors.white,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 20.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Container(
                    height: 56.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, 8),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 16.w),
                        Icon(Icons.search_rounded,
                            color: TechColors.primaryMid.withOpacity(0.6)),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: TechColors.primaryDark,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'البحث عن إشعار...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => const FilterBottomSheet(
                                  currentStatusId: null,
                                  currentProductId: null,
                                  currentFrom: null,
                                  currentTo: null,
                                  products: [],
                                  statuses: [],
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Image.asset(
                                'assets/images/pngs/filter.png',
                                width: 24.r,
                                height: 24.r,
                                color: TechColors.accentCyan,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 25.h),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: TechColors.surfaceLight,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(35),
                        topRight: Radius.circular(35),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, -5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Filter buttons
                        Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedFilter = 2;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    padding:
                                        EdgeInsets.symmetric(vertical: 10.h),
                                    decoration: BoxDecoration(
                                      color: _selectedFilter == 2
                                          ? TechColors.primaryMid
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: _selectedFilter == 2
                                            ? TechColors.primaryMid
                                            : Colors.grey.shade300,
                                      ),
                                      boxShadow: _selectedFilter == 2
                                          ? [
                                              BoxShadow(
                                                color: TechColors.primaryMid
                                                    .withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.notifications_rounded,
                                          size: 18.r,
                                          color: _selectedFilter == 2
                                              ? Colors.white
                                              : Colors.grey[600],
                                        ),
                                        SizedBox(width: 6.w),
                                        Text(
                                          'الإشعارات',
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w700,
                                            color: _selectedFilter == 2
                                                ? Colors.white
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedFilter = 1;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    padding:
                                        EdgeInsets.symmetric(vertical: 10.h),
                                    decoration: BoxDecoration(
                                      color: _selectedFilter == 1
                                          ? TechColors.accentCyan
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: _selectedFilter == 1
                                            ? TechColors.accentCyan
                                            : Colors.grey.shade300,
                                      ),
                                      boxShadow: _selectedFilter == 1
                                          ? [
                                              BoxShadow(
                                                color: TechColors.accentCyan
                                                    .withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.admin_panel_settings_rounded,
                                          size: 18.r,
                                          color: _selectedFilter == 1
                                              ? Colors.white
                                              : Colors.grey[600],
                                        ),
                                        SizedBox(width: 6.w),
                                        Text(
                                          'ملاحظات إدارية',
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w700,
                                            color: _selectedFilter == 1
                                                ? Colors.white
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        // Notification list
                        Expanded(
                          child:
                              BlocBuilder<NotificationCubit, NotificationState>(
                            builder: (context, state) {
                              if (state.status == NotificationStatus.loading) {
                                return _buildShimmerLoading();
                              } else if (state.status ==
                                  NotificationStatus.loaded) {
                                var notifications =
                                    state.notifications.toList();

                                // Apply admin note filter
                                bool isAdminNote(String title) {
                                  final t = title.toLowerCase();
                                  return t.contains('ملاحظة إدارية') ||
                                      t.contains('ملاحظة ادارية');
                                }

                                if (_selectedFilter == 1) {
                                  notifications = notifications
                                      .where((n) => isAdminNote(n.title ?? ''))
                                      .toList();
                                } else if (_selectedFilter == 2) {
                                  notifications = notifications
                                      .where((n) => !isAdminNote(n.title ?? ''))
                                      .toList();
                                }

                                // Apply search filter
                                final filtered = _searchQuery.isNotEmpty
                                    ? notifications
                                        .where((n) =>
                                            (n.title ?? '')
                                                .toString()
                                                .toLowerCase()
                                                .contains(_searchQuery
                                                    .toLowerCase()) ||
                                            (n.body ?? '')
                                                .toString()
                                                .toLowerCase()
                                                .contains(
                                                    _searchQuery.toLowerCase()))
                                        .toList()
                                    : notifications;

                                if (filtered.isEmpty) {
                                  return _buildEmptyState();
                                }

                                filtered.sort((a, b) {
                                  final aDate = a.date ?? DateTime(2000);
                                  final bDate = b.date ?? DateTime(2000);
                                  return bDate.compareTo(aDate);
                                });

                                return RefreshIndicator(
                                  color: TechColors.accentCyan,
                                  onRefresh: () async {
                                    await context
                                        .read<NotificationCubit>()
                                        .fetchNotifications();
                                  },
                                  child: ListView.builder(
                                    padding: EdgeInsets.fromLTRB(
                                        20.w, 12.h, 20.w, 40.h),
                                    itemCount: filtered.length,
                                    itemBuilder: (context, index) {
                                      final notification = filtered[index];
                                      final bool isRead = state
                                          .readNotificationIds
                                          .contains(notification.id);

                                      return Padding(
                                        padding: EdgeInsets.only(bottom: 16.h),
                                        child: _buildNotificationCard(
                                            notification, isRead),
                                      );
                                    },
                                  ),
                                );
                              } else if (state.status ==
                                  NotificationStatus.error) {
                                return _buildErrorState(
                                    state.failure?.errMessages ?? 'حدث خطأ');
                              }

                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, bool isRead) {
    final dateStr =
        notification.date != null ? formatDate(notification.date!) : '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 6),
            blurRadius: 12,
          ),
        ],
        border: isRead
            ? null
            : Border.all(
                color: TechColors.accentCyan.withOpacity(0.2), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () async {
            context.read<NotificationCubit>().markAsRead(notification.id);

            if (notification.referenceId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('لا يوجد معرف مرجعي لهذا الإشعار')),
              );
              return;
            }

            if (_hasSalesRole() && !_isLeaveNotification(notification)) {
              final bool isAdminNote =
                  (notification.title ?? '').contains('ملاحظة إدارية') ||
                      (notification.title ?? '').contains('ملاحظة ادارية');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => NotesScreen(
                    measurementId:
                        notification.measurementId ?? notification.referenceId!,
                    customerName: notification.title,
                    customerPhone: notification.body,
                    isFromNotification: true,
                    isAdminNote: isAdminNote,
                  ),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => NotificationDetailScreenAnyRole(
                    notification: notification,
                  ),
                ),
              );
            }
          },
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50.r,
                  height: 50.r,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isRead
                          ? [Colors.grey[200]!, Colors.grey[100]!]
                          : [TechColors.accentCyan, TechColors.primaryMid],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: isRead
                        ? []
                        : [
                            BoxShadow(
                              color: TechColors.accentCyan.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Icon(
                    isRead
                        ? Icons.notifications_none_rounded
                        : Icons.notifications_active_rounded,
                    color: isRead ? Colors.grey[600] : Colors.white,
                    size: 24.r,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title ?? '',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                                color: TechColors.primaryDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8.r,
                              height: 8.r,
                              decoration: const BoxDecoration(
                                color: TechColors.errorRed,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        notification.body ?? '',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[700],
                          height: 1.4,
                          fontWeight:
                              isRead ? FontWeight.normal : FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: 14.r, color: Colors.grey[500]),
                          SizedBox(width: 4.w),
                          Text(
                            dateStr,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
  }

  Widget _buildShimmerLoading() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          itemCount: 6,
          itemBuilder: (context, index) {
            final delay = index * 0.15;
            final animValue =
                ((_shimmerController.value - delay) % 1.0).clamp(0.0, 1.0);
            return Opacity(
              opacity: 0.6 + 0.4 * math.sin(animValue * math.pi),
              child: Container(
                margin: EdgeInsets.only(bottom: 16.h),
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar shimmer
                    Container(
                      width: 50.r,
                      height: 50.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment(-1.0 + 2.0 * animValue, 0),
                          end: Alignment(-1.0 + 2.0 * animValue + 1.0, 0),
                          colors: [
                            Colors.grey[200]!,
                            Colors.grey[100]!,
                            Colors.grey[200]!,
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title shimmer
                          Container(
                            height: 16.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: LinearGradient(
                                begin: Alignment(-1.0 + 2.0 * animValue, 0),
                                end: Alignment(-1.0 + 2.0 * animValue + 1.0, 0),
                                colors: [
                                  Colors.grey[200]!,
                                  Colors.grey[100]!,
                                  Colors.grey[200]!,
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          // Body shimmer
                          Container(
                            height: 12.h,
                            width: 200.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              gradient: LinearGradient(
                                begin: Alignment(-1.0 + 2.0 * animValue, 0),
                                end: Alignment(-1.0 + 2.0 * animValue + 1.0, 0),
                                colors: [
                                  Colors.grey[200]!,
                                  Colors.grey[100]!,
                                  Colors.grey[200]!,
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          // Date shimmer
                          Container(
                            height: 10.h,
                            width: 120.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              gradient: LinearGradient(
                                begin: Alignment(-1.0 + 2.0 * animValue, 0),
                                end: Alignment(-1.0 + 2.0 * animValue + 1.0, 0),
                                colors: [
                                  Colors.grey[300]!,
                                  Colors.grey[100]!,
                                  Colors.grey[300]!,
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_rounded,
              size: 80.r, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            'لا توجد إشعارات حالياً',
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.grey[400],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 60.r, color: TechColors.errorRed.withOpacity(0.5)),
            SizedBox(height: 16.h),
            Text(
              message,
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () =>
                  context.read<NotificationCubit>().fetchNotifications(),
              style: ElevatedButton.styleFrom(
                backgroundColor: TechColors.primaryMid,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text('إعادة المحاولة',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
