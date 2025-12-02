// New File: lib/features/home/presentation/cubits/notifications/notification_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/core/utils/cache/cache_helper.dart';
import 'package:tabib_soft_company/features/home/notifications/data/repo/notification_repo.dart';
import 'package:tabib_soft_company/features/home/notifications/presentation/cubits/notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _repository;

  NotificationCubit(this._repository) : super(NotificationState.initial()) {
    _loadUnreadStatus(); // تحميل حالة النقطة الحمراء عند بدء التطبيق
  }

  // تحميل حالة النقطة الحمراء من الكاش
  Future<void> _loadUnreadStatus() async {
    await CacheHelper.init();
    final hasUnread = CacheHelper.sharedPreferences.getBool('has_unread_notifications') ?? false;
    emit(state.copyWith(hasUnreadNotifications: hasUnread));
  }

  // جلب الإشعارات من API
  Future<void> fetchNotifications() async {
    emit(NotificationState.loading());
    final result = await _repository.getNotifications();
    
    await CacheHelper.init();
    final hasUnread = CacheHelper.sharedPreferences.getBool('has_unread_notifications') ?? false;
    
    result.fold(
      (failure) => emit(NotificationState.error(failure)),
      (notifications) => emit(NotificationState.loaded(notifications, hasUnread: hasUnread)),
    );
  }

  // تعيين النقطة الحمراء عند وصول إشعار جديد (من Push Notification)
  Future<void> markAsHasNewNotification() async {
    await CacheHelper.init();
    await CacheHelper.sharedPreferences.setBool('has_unread_notifications', true);
    emit(state.copyWith(hasUnreadNotifications: true));
  }

  // إخفاء النقطة الحمراء عند دخول صفحة الإشعارات
  Future<void> clearUnreadNotificationBadge() async {
    await CacheHelper.init();
    await CacheHelper.sharedPreferences.setBool('has_unread_notifications', false);
    emit(state.copyWith(hasUnreadNotifications: false));
  }
}
