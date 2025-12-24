import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/core/export.dart';
import 'package:tabib_soft_company/features/home/notifications/presentation/cubits/notification_cubit.dart';
import 'package:tabib_soft_company/features/home/notifications/presentation/cubits/notification_state.dart';
import 'package:tabib_soft_company/features/home/notifications/presentation/screens/notification_screen.dart';

class HomeNotificationButton extends StatelessWidget {
  const HomeNotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12,
      right: 12,
      child: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          final bool hasUnread = state.hasUnreadNotifications;

          return GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen())),
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: const Icon(Icons.notifications,
                      color: Color.fromARGB(221, 64, 144, 197), size: 26),
                ),
                // النقطة الحمراء
                if (hasUnread)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
