import 'package:flutter/material.dart';

class ProblemDetailsWidget extends StatelessWidget {
  final String? savedField1;
  final String? savedField2;
  final List<String> savedImageUrls;
  final Color primaryColor;

  const ProblemDetailsWidget({
    super.key,
    required this.savedField1,
    required this.savedField2,
    required this.savedImageUrls,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    if (savedField1 == null && savedField2 == null && savedImageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryColor,
          width: 2.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (savedField1 != null && savedField1!.isNotEmpty)
            Text(
              'تفاصيل المشكلة: $savedField1',
              style: TextStyle(
                color: primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (savedField2 != null && savedField2!.isNotEmpty)
            Text(
              'تفاصيل الحل: $savedField2',
              style: TextStyle(
                color: primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (savedImageUrls.isNotEmpty)
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children: savedImageUrls.map((url) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    url,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}