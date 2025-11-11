import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const double cardHeight = 180;
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: cardHeight,
        margin: const EdgeInsets.only(left: 30, right: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(33),
        ),
      ),
    );
  }
}
