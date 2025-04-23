import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/problem/problem_model.dart';

class ProblemDetailsDialog extends StatelessWidget {
  final ProblemModel issue;

  const ProblemDetailsDialog({super.key, required this.issue});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تفاصيل المشكلة',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xff178CBB),
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('اسم العميل:', issue.customerName ?? 'غير متوفر'),
            _buildDetailRow('المشكلة:', issue.problemDetails ?? 'غير متوفر'),
            _buildDetailRow('الحالة:', issue.problemtype ?? 'غير متوفر'),
            _buildDetailRow(
                'تاريخ المشكلة:',
                issue.problemDate != null
                    ? DateFormat('dd/MM/yyyy')
                        .format(DateTime.parse(issue.problemDate!))
                    : 'غير متوفر'),
            _buildDetailRow('تفاصيل إضافية:',
                issue.problemDetails ?? 'لا توجد تفاصيل إضافية'),
            if (issue.image != null && issue.image!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Image.file(
                File(issue.image!),
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ],
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF56C7F1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'إغلاق',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(
                color: Color(0xff178CBB),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
