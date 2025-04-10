// lib/features/technical_support/presentation/widget/filter_status_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/add_customer_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/problem/problem_model.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/add_customer_state.dart';

class FilterStatusWidget extends StatelessWidget {
  final ValueChanged<String?> onStatusSelected;
  final String? selectedStatus;

  const FilterStatusWidget({
    Key? key,
    required this.onStatusSelected,
    this.selectedStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerCubit, CustomerState>(
      builder: (context, state) {
        final statuses = <String?>[null, ...state.problemStatusList.map((status) => status.name)];
        // null يمثل "جميع الحالات"
        return DropdownButtonFormField<String?>(
          value: selectedStatus,
          decoration: const InputDecoration(
            labelText: 'فلتر حسب الحالة',
            border: OutlineInputBorder(),
          ),
          items: statuses.map((status) {
            final label = status ?? 'جميع الحالات';
            return DropdownMenuItem<String?>(
              value: status,
              child: Text(label),
            );
          }).toList(),
          onChanged: onStatusSelected,
        );
      },
    );
  }
}
