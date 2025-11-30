// lib/features/home/notifications/presentation/screens/notification_detail_screen_anyRole.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tabib_soft_company/features/home/notifications/data/model/notification_model.dart';

class NotificationDetailScreenAnyRole extends StatelessWidget {
  final NotificationModel notification;

  const NotificationDetailScreenAnyRole({
    super.key,
    required this.notification,
  });

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(date);
  }

  @override
  Widget build(BuildContext context) {
    const bool isRead = false; // لأن المستخدم فتحها = مقروءة الآن
    final String formattedDate = _formatDate(notification.date);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
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
              const SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'assets/images/pngs/TS_Logo0.png',
                  width: 140,
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F5F6),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // كارت تفاصيل الإشعار
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'إشعار جديد',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff104D9D),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                notification.title ?? 'بدون عنوان',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                notification.body ?? 'لا يوجد محتوى',
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.6,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  formattedDate,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
