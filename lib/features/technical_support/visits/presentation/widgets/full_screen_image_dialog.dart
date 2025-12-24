import 'dart:io';
import 'package:flutter/material.dart';

class FullScreenImageDialog extends StatelessWidget {
  final String imageUrl;
  final int currentIndex;
  final int totalCount;
  final String tag;
  final bool isLocal;

  const FullScreenImageDialog({
    super.key,
    required this.imageUrl,
    required this.currentIndex,
    required this.totalCount,
    required this.tag,
    this.isLocal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          // الصورة
          Center(
            child: Hero(
              tag: tag,
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: isLocal
                    ? Image.file(
                        File(imageUrl),
                        fit: BoxFit.contain,
                      )
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: Colors.white,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline,
                                    color: Colors.white, size: 60),
                                SizedBox(height: 10),
                                Text(
                                  'فشل تحميل الصورة',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),

          // زر الإغلاق
          Positioned(
            top: 40,
            right: 20,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // عداد الصور
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'صورة ${currentIndex + 1} من $totalCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
