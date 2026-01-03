import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/core/utils/cache/cache_helper.dart';
import 'package:tabib_soft_company/features/home/notifications/data/repo/notification_repo.dart';
import 'package:tabib_soft_company/features/home/notifications/presentation/cubits/notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _repository;

  NotificationCubit(this._repository) : super(NotificationState.initial()) {
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    await CacheHelper.init();
    final readIds =
        CacheHelper.sharedPreferences.getStringList('read_notification_ids') ??
            [];
    final hasUnread =
        CacheHelper.sharedPreferences.getBool('has_unread_notifications') ??
            false;
    emit(state.copyWith(
      hasUnreadNotifications: hasUnread,
      readNotificationIds: readIds,
    ));
  }

  Future<void> fetchNotifications() async {
    emit(state.copyWith(status: NotificationStatus.loading));
    final result = await _repository.getNotifications();

    await CacheHelper.init();
    final readIds =
        CacheHelper.sharedPreferences.getStringList('read_notification_ids') ??
            [];

    result.fold(
      (failure) => emit(
          state.copyWith(status: NotificationStatus.error, failure: failure)),
      (notifications) {
        final bool hasNewUnread =
            notifications.any((n) => !readIds.contains(n.id));

        if (hasNewUnread) {
          CacheHelper.sharedPreferences
              .setBool('has_unread_notifications', true);
        }

        emit(state.copyWith(
          status: NotificationStatus.loaded,
          notifications: notifications,
          readNotificationIds: readIds,
          hasUnreadNotifications: hasNewUnread,
        ));
      },
    );
  }

  Future<void> markAsRead(String id) async {
    await CacheHelper.init();
    final readIds = List<String>.from(state.readNotificationIds);
    if (!readIds.contains(id)) {
      readIds.add(id);
      await CacheHelper.sharedPreferences
          .setStringList('read_notification_ids', readIds);

      final hasUnread = state.notifications.any((n) => !readIds.contains(n.id));
      await CacheHelper.sharedPreferences
          .setBool('has_unread_notifications', hasUnread);

      emit(state.copyWith(
        hasUnreadNotifications: hasUnread,
        readNotificationIds: readIds,
      ));
    }
  }

  Future<void> markAllAsRead() async {
    await CacheHelper.init();
    final allIds = state.notifications.map((n) => n.id).toList();
    await CacheHelper.sharedPreferences
        .setStringList('read_notification_ids', allIds);
    await CacheHelper.sharedPreferences
        .setBool('has_unread_notifications', false);

    emit(state.copyWith(
      hasUnreadNotifications: false,
      readNotificationIds: allIds,
    ));
  }

  Future<void> clearUnreadNotificationBadge() async {
    await CacheHelper.init();
    await CacheHelper.sharedPreferences
        .setBool('has_unread_notifications', false);
    emit(state.copyWith(hasUnreadNotifications: false));
  }
}
