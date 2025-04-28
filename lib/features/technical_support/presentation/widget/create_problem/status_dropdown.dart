import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/problem_status/problem_status_model.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/customer_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/customer_state.dart';

class StatusDropdown extends StatelessWidget {
  final TextEditingController controller;
  final bool isDropdownVisible;
  final VoidCallback onToggleDropdown;
  final Function(ProblemStatusModel) onStatusSelected;

  const StatusDropdown({
    super.key,
    required this.controller,
    required this.isDropdownVisible,
    required this.onToggleDropdown,
    required this.onStatusSelected,
  });

  static const Color primaryColor = Color(0xFF56C7F1);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onToggleDropdown,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                  color: primaryColor.withOpacity(0.5), width: 1.5),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    controller.text.isEmpty
                        ? 'حالة المشكلة'
                        : controller.text,
                    style: TextStyle(
                      color: controller.text.isEmpty
                          ? Colors.grey
                          : Colors.black,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Image.asset(
                  'assets/images/pngs/drop_down.png',
                  width: 24,
                  height: 24,
                ),
              ],
            ),
          ),
        ),
        if (isDropdownVisible)
          Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 300),
            padding: const EdgeInsets.only(right: 15.0, left: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: primaryColor, width: 1.5),
            ),
            child: BlocBuilder<CustomerCubit, CustomerState>(
              builder: (context, state) {
                if (state.status == CustomerStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state.status == CustomerStatus.failure) {
                  return Column(
                    children: [
                      const Text('فشل في جلب حالات المشكلة'),
                      TextButton(
                        onPressed: () {
                          context.read<CustomerCubit>().fetchProblemStatus();
                        },
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  );
                } else if (state.problemStatusList.isNotEmpty) {
                  return ListView(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    children: state.problemStatusList.map((status) {
                      return ListTile(
                        title: Text(status.name),
                        onTap: () {
                          controller.text = status.name;
                          onStatusSelected(status);
                          onToggleDropdown();
                        },
                      );
                    }).toList(),
                  );
                } else {
                  return Column(
                    children: [
                      const Text('لا توجد حالات متاحة'),
                      TextButton(
                        onPressed: () {
                          context.read<CustomerCubit>().fetchProblemStatus();
                        },
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
      ],
    );
  }
}