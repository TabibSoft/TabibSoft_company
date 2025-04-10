import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/problem/problem_model.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/add_customer_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/add_customer_state.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/widget/problem_status_dialog.dart';

class CustomerListWidget extends StatelessWidget {
  final String searchQuery;
  final String? selectedStatus;

  const CustomerListWidget({
    super.key,
    required this.searchQuery,
    this.selectedStatus,
  });

  static const Color primaryColor = Color(0xFF56C7F1);

  void _showProblemDialog(BuildContext context, ProblemModel issue) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ProblemStatusDialog(issue: issue),
    );
  }

  String? _getStatusIcon(String? status) {
    if (status == null) return null;

    // طباعة القيمة الفعلية للتحقق منها
    debugPrint('Problem Status: $status');

    final normalized = status.replaceAll(' ', '').toLowerCase();
    debugPrint('Normalized Status: $normalized');

    if (normalized.contains('تمالحل') || normalized.contains('تمالحل')) {
      return 'assets/images/pngs/good_pincode.png';
    } else if (normalized.contains('جديد')) {
      return 'assets/images/pngs/new.png';
    } else if (normalized.contains('جاريمتابعة') ||
        normalized.contains('جارىالمتابعه') ||
        normalized.contains('جاريمتابعه') ||
        normalized.contains('جارىمتابعه') ||
        normalized.contains('جارى المتابعة') ||
        normalized.contains('جارى المتابعه')) {
      return 'assets/images/pngs/move_up_row.png';
    } else if (normalized.contains('مؤجل') || normalized.contains('مؤجله')) {
      return 'assets/images/pngs/event_declined.png';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerCubit, CustomerState>(
      builder: (context, state) {
        if (state.status == CustomerStatus.loading) {
          return Skeletonizer(
            enabled: true,
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (_, __) => FractionallySizedBox(
                widthFactor: 0.95,
                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const SizedBox(height: 100),
                ),
              ),
            ),
          );
        } else if (state.status == CustomerStatus.success) {
          var issues = state.techSupportIssues;

          if (searchQuery.isNotEmpty) {
            final q = searchQuery.toLowerCase();
            issues = issues.where((i) {
              return (i.customerName?.toLowerCase().contains(q) ?? false) ||
                  (i.problemAddress?.toLowerCase().contains(q) ?? false);
            }).toList();
          }

          if (selectedStatus != null) {
            final statusFilter = selectedStatus!.trim().toLowerCase();
            issues = issues
                .where(
                    (i) => i.problemtype?.trim().toLowerCase() == statusFilter)
                .toList();
          }

          if (issues.isEmpty) {
            return const Center(child: Text('لا توجد نتائج مطابقة'));
          }

          return ListView.builder(
            itemCount: issues.length,
            itemBuilder: (_, idx) {
              final issue = issues[idx];
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
    );
  }

  Widget _buildIssueCard(ProblemModel issue) {
    final iconPath = _getStatusIcon(issue.problemtype);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'اسم العميل: ',
                        style: TextStyle(
                          color: Color(0xff178CBB),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: issue.customerName ?? 'غير متوفر',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'المشكلة: ',
                        style: TextStyle(
                          color: Color(0xff178CBB),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: issue.problemAddress ?? 'غير متوفر',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'التاريخ: ',
                        style: TextStyle(
                          color: Color(0xff178CBB),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: issue.problemDate != null
                            ? DateFormat('dd/MM/yyyy')
                                .format(DateTime.parse(issue.problemDate!))
                            : 'غير متوفر',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'الحالة: ',
                        style: TextStyle(
                          color: Color(0xff178CBB),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: issue.problemtype ?? 'غير متوفر',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
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
          if (iconPath != null)
            Positioned(
              top: -8,
              left: -8,
              child: Image.asset(
                iconPath,
                height: 48,
                width: 48,
              ),
            ),
        ],
      ),
    );
  }
}
