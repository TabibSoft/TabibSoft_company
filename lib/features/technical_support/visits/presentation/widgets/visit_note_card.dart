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

    final Color cardColor =
        isRead ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1);

    final Color borderColor = isRead ? Colors.green : Colors.red;

    final Color statusIconColor = isRead ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: statusIconColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isRead ? Icons.check_circle : Icons.circle_outlined,
                  color: statusIconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      noteText,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 5),
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
              const SizedBox(width: 10),
              if (!isRead && noteId.isNotEmpty)
                InkWell(
                  onTap: () => onMarkAsRead(noteId, index),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.visibility,
                      color: Colors.blue,
                      size: 22,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              if (noteId.isNotEmpty)
                InkWell(
                  onTap: () => onDelete(noteId, index),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 22,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusIconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isRead ? Icons.visibility : Icons.visibility_off,
                  size: 14,
                  color: statusIconColor,
                ),
                const SizedBox(width: 5),
                Text(
                  isRead ? 'تم القراءة' : 'غير مقروءة',
                  style: TextStyle(
                    fontSize: 12,
                    color: statusIconColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
