// lib/features/technical_support/presentation/widget/customer_list_widget.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/problem/problem_model.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/add_customer_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/add_customer_state.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/widget/problem_status_dialog.dart';

class CustomerListWidget extends StatefulWidget {
  final String searchQuery;

  const CustomerListWidget({super.key, required this.searchQuery});

  static const Color primaryColor = Color(0xFF56C7F1);

  @override
  _CustomerListWidgetState createState() => _CustomerListWidgetState();
}

class _CustomerListWidgetState extends State<CustomerListWidget> {
  void _showProblemDialog(BuildContext context, ProblemModel issue) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProblemStatusDialog(issue: issue),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocBuilder<CustomerCubit, CustomerState>(
        builder: (context, state) {
          if (state.status == CustomerStatus.loading) {
            return Skeletonizer(
              enabled: true,
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return FractionallySizedBox(
                    widthFactor: 0.95,
                    child: Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const SizedBox(height: 100),
                    ),
                  );
                },
              ),
            );
          } else if (state.status == CustomerStatus.success) {
            final filtered = state.techSupportIssues.where((issue) {
              final name = issue.customerName?.toLowerCase() ?? '';
              final addr = issue.problemAddress?.toLowerCase() ?? '';
              final q = widget.searchQuery.toLowerCase();
              return name.contains(q) || addr.contains(q);
            }).toList();

            if (filtered.isEmpty) {
              return const Center(child: Text('لا توجد نتائج مطابقة'));
            }

            return ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final issue = filtered[index];
                return GestureDetector(
                  onTap: () => _showProblemDialog(context, issue),
                  child: FractionallySizedBox(
                    widthFactor: 0.95,
                    child: _buildIssueCard(issue),
                  ),
                );
              },
            );
          } else if (state.status == CustomerStatus.failure) {
            return Center(child: Text(state.errorMessage ?? 'حدث خطأ'));
          } else {
            return const Center(child: Text('لا توجد بيانات'));
          }
        },
      ),
    );
  }

  Widget _buildIssueCard(ProblemModel issue) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _richText(
                    'اسم العميل: ', issue.customerName, 18, FontWeight.bold),
                const SizedBox(height: 8),
                _richText(
                    'المشكلة: ', issue.problemAddress, 16, FontWeight.bold),
                const SizedBox(height: 8),
                _richText('التاريخ: ', issue.problemDate, 16, FontWeight.bold),
                const SizedBox(height: 8),
                _richText('الحالة: ', issue.problemtype, 16, FontWeight.bold),
                if (issue.image != null && issue.image!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Image.file(
                    File(issue.image!),
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ],
              ],
            ),
          ),
          if (issue.problemtype == 'تم الحل')
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
        ],
      ),
    );
  }

  RichText _richText(
      String label, String? value, double labelSize, FontWeight labelWeight) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: TextStyle(
              color: const Color(0xff178CBB),
              fontSize: labelSize,
              fontWeight: labelWeight,
            ),
          ),
          TextSpan(
            text: value ?? 'غير متوفر',
            style: TextStyle(
              color: Colors.black,
              fontSize: labelSize,
              fontWeight: labelSize == 18 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
