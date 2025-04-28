import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/customer_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/customer_state.dart';

class ProblemTypeDropdown extends StatelessWidget {
  final TextEditingController controller;
  final bool isDropdownVisible;
  final VoidCallback onToggleDropdown;

  const ProblemTypeDropdown({
    super.key,
    required this.controller,
    required this.isDropdownVisible,
    required this.onToggleDropdown,
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
                    controller.text.isEmpty ? 'نوع المشكلة' : controller.text,
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
                      const Text('فشل في جلب فئات المشكلة'),
                      TextButton(
                        onPressed: () {
                          context.read<CustomerCubit>().fetchProblemCategories();
                        },
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  );
                } else if (state.problemCategories.isNotEmpty) {
                  return ListView(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    children: state.problemCategories.map((category) {
                      return ListTile(
                        title: Text(category.name),
                        onTap: () {
                          controller.text = category.name;
                          onToggleDropdown();
                        },
                      );
                    }).toList(),
                  );
                } else {
                  return Column(
                    children: [
                      const Text('لا توجد فئات متاحة'),
                      TextButton(
                        onPressed: () {
                          context.read<CustomerCubit>().fetchProblemCategories();
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