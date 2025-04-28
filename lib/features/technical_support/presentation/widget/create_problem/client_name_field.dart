import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/support_customer_model.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/customer_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/customer_state.dart';

class ClientNameField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDropdownVisible;
  final VoidCallback onToggleDropdown;
  final Function(CustomerModel) onCustomerSelected;

  const ClientNameField({
    super.key,
    required this.controller,
    required this.isDropdownVisible,
    required this.onToggleDropdown,
    required this.onCustomerSelected,
  });

  static const Color primaryColor = Color(0xFF56C7F1);

  InputDecoration _buildDropdownDecoration({
    required String hint,
    required VoidCallback onIconTap,
    required String iconAsset,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
      suffixIcon: GestureDetector(
        onTap: onIconTap,
        child: Padding(
          padding: const EdgeInsets.only(right: 15.0, left: 19),
          child: Image.asset(iconAsset, width: 24, height: 24),
        ),
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide:
            BorderSide(color: primaryColor.withOpacity(0.5), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide:
            BorderSide(color: primaryColor.withOpacity(0.5), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerCubit, CustomerState>(
      builder: (context, state) {
        final filteredCustomers = state.customers;
        return Column(
          children: [
            TextField(
              controller: controller,
              textAlign: TextAlign.center,
              decoration: _buildDropdownDecoration(
                hint: 'اسم العميل',
                iconAsset: 'assets/images/pngs/drop_down.png',
                onIconTap: onToggleDropdown,
              ),
            ),
            if (isDropdownVisible && filteredCustomers.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                constraints: const BoxConstraints(maxHeight: 300),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: primaryColor, width: 1.5),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: filteredCustomers.length,
                  itemBuilder: (ctx, idx) {
                    final customer = filteredCustomers[idx];
                    return ListTile(
                      title: Text(customer.name ?? ''),
                      onTap: () => onCustomerSelected(customer),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}