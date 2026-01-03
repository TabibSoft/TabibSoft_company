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
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isRead
            ? Colors.white
            : const Color(0xFFFFFDE7), // Light yellow for unread
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: isRead
            ? Border.all(color: Colors.grey.shade100)
            : Border.all(color: const Color(0xFFFFF59D)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon State
          GestureDetector(
            onTap: onMarkAsRead,
            child: Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color:
                    isRead ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                isRead
                    ? Icons.check_circle_outline_rounded
                    : Icons.mark_chat_unread_outlined,
                color: isRead ? Colors.green[600] : Colors.orange[800],
                size: 22.r,
              ),
            ),
          ),

          SizedBox(width: 14.w),

          // Note Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note['note'] ?? '',
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.5,
                    color: const Color(0xFF455A64),
                    fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                  ),
                ),
                if (!isRead)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      "ملاحظة جديدة",
                      style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.orange[800],
                          fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(width: 10.w),

          // Delete Button
          if (id.isNotEmpty && onDelete != null)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: EdgeInsets.all(6.r),
                  child: Icon(Icons.close_rounded,
                      color: Colors.grey[400], size: 20.r),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
