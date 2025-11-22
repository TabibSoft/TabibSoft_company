// New File: lib/features/home/presentation/cubits/notifications/notification_state.dart
import 'package:tabib_soft_company/core/networking/api_error_handler.dart';
import 'package:tabib_soft_company/features/home/notifications/data/model/notification_model.dart';

enum NotificationStatus { initial, loading, loaded, error }

class NotificationState {
  final NotificationStatus status;
  final List<NotificationModel> notifications;
  final ServerFailure? failure;

  const NotificationState._({
    required this.status,
    this.notifications = const [],
    this.failure,
  });

  factory NotificationState.initial() => const NotificationState._(
    status: NotificationStatus.initial,
  );

  factory NotificationState.loading() => const NotificationState._(
    status: NotificationStatus.loading,
  );

  factory NotificationState.loaded(List<NotificationModel> notifications) => NotificationState._(
    status: NotificationStatus.loaded,
    notifications: notifications,
  );

  factory NotificationState.error(ServerFailure failure) => NotificationState._(
    status: NotificationStatus.error,
    failure: failure,
  );

  NotificationState copyWith({
    NotificationStatus? status,
    List<NotificationModel>? notifications,
    ServerFailure? failure,
  }) {
    return NotificationState._(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      failure: failure ?? this.failure,
    );
  }
}
