import 'package:flutter/material.dart';
import 'package:tabib_soft_company/features/technical_support/visits/presentation/widgets/full_screen_image_dialog.dart';

class VisitImagesBottomSheet extends StatelessWidget {
  final List<String> images;

  const VisitImagesBottomSheet({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'صور الزيارة',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF16669E),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16669E),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${images.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Grid of images
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                return _NetworkImageThumbnail(
                  imageUrl: images[index],
                  index: index,
                  allImages: images,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NetworkImageThumbnail extends StatelessWidget {
  final String imageUrl;
  final int index;
  final List<String> allImages;

  const _NetworkImageThumbnail({
    required this.imageUrl,
    required this.index,
    required this.allImages,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierColor: Colors.black87,
          builder: (context) => FullScreenImageDialog(
            imageUrl: imageUrl,
            currentIndex: index,
            totalCount: allImages.length,
            tag: 'network_image_$index',
          ),
        );
      },
      child: Hero(
        tag: 'network_image_$index',
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    strokeWidth: 2,
                    color: const Color(0xFF16669E),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.broken_image,
                    color: Colors.grey,
                    size: 40,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
