import 'package:flutter/material.dart';

class VisitNoteCard extends StatelessWidget {
  final dynamic note;
  final int index;
  final Function(String, int) onMarkAsRead;
  final Function(String, int) onDelete;
  final String Function(String) formatDate;

  const VisitNoteCard({
    super.key,
    required this.note,
    required this.index,
    required this.onMarkAsRead,
    required this.onDelete,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    if (note is! Map) {
      return const SizedBox.shrink();
    }

    final String noteId = note['id']?.toString() ?? '';
    final String noteText = note['note']?.toString() ?? '';
    final bool isRead = note['isRead'] == true;
    final String createdDate =
        note['createdDate']?.toString() ?? note['date']?.toString() ?? '';

    // Clean Styling
    final Color borderColor =
        isRead ? Colors.grey.withOpacity(0.3) : const Color(0xFFFFB74D);
    final Color statusColor = isRead ? Colors.green : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: isRead ? 1 : 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isRead
                      ? Icons.done_all_rounded
                      : Icons.mark_chat_unread_rounded,
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      noteText,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF2D3436),
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          formatDate(createdDate),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (noteId.isNotEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),

          // Actions Row
          if (noteId.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isRead)
                  InkWell(
                    onTap: () => onMarkAsRead(noteId, index),
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.visibility_outlined,
                              size: 18, color: Color(0xFF1565C0)),
                          SizedBox(width: 6),
                          Text(
                            "تحديد كمقروء",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF1565C0),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const Spacer(),
                InkWell(
                  onTap: () => onDelete(noteId, index),
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.delete_outline_rounded,
                            size: 18, color: Color(0xFFC62828)),
                        SizedBox(width: 6),
                        Text(
                          "حذف",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFC62828),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
