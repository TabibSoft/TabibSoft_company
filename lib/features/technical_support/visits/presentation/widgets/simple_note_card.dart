import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SimpleNoteCard extends StatelessWidget {
  final dynamic note;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;

  const SimpleNoteCard({
    super.key,
    required this.note,
    this.onMarkAsRead,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRead = note['isRead'] == true;
    final String id = note['id']?.toString() ?? '';

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isRead ? Colors.grey[50] : Colors.blue[50],
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isRead ? Colors.grey[300]! : Colors.blue[400]!,
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // أيقونة الحالة + الضغط لتغييرها
          GestureDetector(
            onTap: onMarkAsRead,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: isRead
                    ? Colors.green.withOpacity(0.15)
                    : Colors.orange.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isRead ? Colors.green : Colors.orange,
                  width: 2,
                ),
              ),
              child: Icon(
                isRead ? Icons.mark_email_read : Icons.mark_email_unread,
                color: isRead ? Colors.green[700] : Colors.orange[700],
                size: 26.r,
              ),
            ),
          ),

          SizedBox(width: 14.w),

          // نص الملاحظة
          Expanded(
            child: Text(
              note['note'] ?? '',
              style: TextStyle(
                fontSize: 15.5.sp,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ),

          SizedBox(width: 10.w),

          // زر الحذف
          if (id.isNotEmpty && onDelete != null)
            GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.delete_outline,
                    color: Colors.red[600], size: 22.r),
              ),
            ),
        ],
      ),
    );
  }
}
