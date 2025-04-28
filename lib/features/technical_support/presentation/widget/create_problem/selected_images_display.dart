import 'package:flutter/material.dart';
import 'dart:io';

class SelectedImagesDisplay extends StatelessWidget {
  final List<File> images;
  final Function(File) onImageRemoved;

  const SelectedImagesDisplay({
    super.key,
    required this.images,
    required this.onImageRemoved,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: images.map((image) {
            return Stack(
              children: [
                Image.file(
                  image,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => onImageRemoved(image),
                    child: const Icon(
                      Icons.remove_circle,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}