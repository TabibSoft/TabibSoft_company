// New File: lib/features/home/presentation/cubits/notifications/notification_state.dart

import 'package:tabib_soft_company/core/networking/api_error_handler.dart';
import 'package:tabib_soft_company/features/home/notifications/data/model/notification_model.dart';

enum NotificationStatus { initial, loading, loaded, error }

class NotificationState {
  final NotificationStatus status;
  final List<NotificationModel> notifications;
  final List<String> readNotificationIds; // إضافة قائمة المعرفات المقروءة
  final ServerFailure? failure;
  final bool hasUnreadNotifications;

  const NotificationState._({
    required this.status,
    this.notifications = const [],
    this.readNotificationIds = const [],
    this.failure,
    this.hasUnreadNotifications = false,
  });

  factory NotificationState.initial() => const NotificationState._(
        status: NotificationStatus.initial,
        hasUnreadNotifications: false,
        readNotificationIds: [],
      );

  factory NotificationState.loading() => const NotificationState._(
        status: NotificationStatus.loading,
      );

  factory NotificationState.loaded(
    List<NotificationModel> notifications, {
    bool hasUnread = false,
    List<String> readIds = const [],
  }) =>
      NotificationState._(
        status: NotificationStatus.loaded,
        notifications: notifications,
        readNotificationIds: readIds,
        hasUnreadNotifications: hasUnread,
      );

  factory NotificationState.error(ServerFailure failure) => NotificationState._(
        status: NotificationStatus.error,
        failure: failure,
      );

  NotificationState copyWith({
    NotificationStatus? status,
    List<NotificationModel>? notifications,
    List<String>? readNotificationIds,
    ServerFailure? failure,
    bool? hasUnreadNotifications,
  }) {
    return NotificationState._(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      readNotificationIds: readNotificationIds ?? this.readNotificationIds,
      failure: failure ?? this.failure,
      hasUnreadNotifications:
          hasUnreadNotifications ?? this.hasUnreadNotifications,
    );
  }
}
