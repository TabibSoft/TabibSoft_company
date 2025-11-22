// New File: lib/features/home/presentation/cubits/notifications/notification_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/features/home/notifications/data/repo/notification_repo.dart';
import 'package:tabib_soft_company/features/home/notifications/presentation/cubits/notification_state.dart';
class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _repository;

  NotificationCubit(this._repository) : super( NotificationState.initial());

  Future<void> fetchNotifications() async {
    emit( NotificationState.loading());
    final result = await _repository.getNotifications();
    result.fold(
      (failure) => emit(NotificationState.error(failure)),
      (notifications) => emit(NotificationState.loaded(notifications)),
    );
  }
}
