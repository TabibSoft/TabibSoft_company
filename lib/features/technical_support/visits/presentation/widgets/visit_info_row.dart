import 'package:flutter/material.dart';

class VisitInfoRow extends StatelessWidget {
  final String imagePath;
  final String text;
  final VoidCallback? onTap;

  const VisitInfoRow({
    super.key,
    required this.imagePath,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        Image.asset(imagePath, width: 30, height: 30),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    return onTap != null
        ? InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: content,
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: content,
          );
  }
}
