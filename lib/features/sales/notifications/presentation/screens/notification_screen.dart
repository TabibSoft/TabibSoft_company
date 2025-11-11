import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tabib_soft_company/core/utils/cache/cache_helper.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/screens/notes/notes_screen.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/widgets/home_widgets/filter_widget.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/widgets/home_widgets/home_skeltonizer_widget.dart';
import 'package:tabib_soft_company/features/sales/notifications/data/model/notification_model.dart';
import 'package:tabib_soft_company/features/sales/notifications/presentation/cubits/notification_cubit.dart';
import 'package:tabib_soft_company/features/sales/notifications/presentation/cubits/notification_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  static const double horizontalPadding = 16.0;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<String> _readNotificationIds = [];

  @override
  void initState() {
    super.initState();
    _loadReadNotifications();
    context.read<NotificationCubit>().fetchNotifications();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadReadNotifications() async {
    await CacheHelper.init();
    final readIds =
        CacheHelper.sharedPreferences.getStringList('read_notification_ids') ??
            [];
    setState(() {
      _readNotificationIds = readIds;
    });
  }

  Future<void> _saveReadNotifications() async {
    await CacheHelper.sharedPreferences
        .setStringList('read_notification_ids', _readNotificationIds);
  }

  void _markAsRead(String notificationId) {
    if (!_readNotificationIds.contains(notificationId)) {
      setState(() {
        _readNotificationIds.add(notificationId);
      });
      _saveReadNotifications();
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const SizedBox.shrink(),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.topRight,
            colors: [
              Color(0xff104D9D),
              Color(0xFF20AAC9),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Center(
                child: Image.asset(
                  'assets/images/pngs/TS_Logo0.png',
                  width: 140,
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: NotificationsScreen.horizontalPadding),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        offset: const Offset(0, 6),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
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
                        child: Image.asset(
                          'assets/images/pngs/filter.png',
                          width: 28,
                          height: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'البحث...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F5F6),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: BlocBuilder<NotificationCubit, NotificationState>(
                    builder: (context, state) {
                      if (state.status == NotificationStatus.loading) {
                        return Skeletonizer(
                          enabled: true,
                          child: ListView.builder(
                            itemCount: 5,
                            padding: const EdgeInsets.symmetric(
                                horizontal:
                                    NotificationsScreen.horizontalPadding),
                            itemBuilder: (_, __) => SkeletonCard(),
                          ),
                        );
                      } else if (state.status == NotificationStatus.loaded) {
                        final notifications = state.notifications;
                        final filtered = _searchQuery.isNotEmpty
                            ? notifications
                                .where((n) =>
                                    (n.title ?? '')
                                        .toString()
                                        .contains(_searchQuery) ||
                                    (n.body ?? '')
                                        .toString()
                                        .contains(_searchQuery))
                                .toList()
                            : notifications.toList();

                        if (filtered.isEmpty) {
                          return Center(
                            child: Text(
                              'لا توجد إشعارات',
                              style: TextStyle(
                                  color: Colors.grey[700], fontSize: 16),
                            ),
                          );
                        }

                        filtered.sort((a, b) => b.date.compareTo(a.date));

                        return RefreshIndicator(
                          onRefresh: () async {
                            await context
                                .read<NotificationCubit>()
                                .fetchNotifications();
                          },
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                                horizontal:
                                    NotificationsScreen.horizontalPadding,
                                vertical: 12),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final notification = filtered[index];
                              final bool isRead = _readNotificationIds
                                  .contains(notification.id);

                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  if (notification.referenceId != null) {
                                    _markAsRead(notification.id);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (ctx) => NotesScreen(
                                          measurementId:
                                              notification.referenceId!,
                                          customerName: notification.title,
                                          customerPhone: notification.body,
                                          isFromNotification: true,
                                        ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'لا يوجد  ReferenceId لهذا الإشعار'),
                                      ),
                                    );
                                  }
                                },
                                child: _buildNotificationCard(
                                    notification, isRead),
                              );
                            },
                          ),
                        );
                      } else if (state.status == NotificationStatus.error) {
                        return Center(
                          child: Text(state.failure?.errMessages ?? 'حدث خطأ'),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, bool isRead) {
    final dateStr = formatDate(notification.date);
    return Container(
      decoration: BoxDecoration(
        color: isRead ? Colors.white : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6, left: 12),
            decoration: BoxDecoration(
              color: isRead ? Colors.transparent : Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title ?? '',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  notification.body ?? '',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    dateStr,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
