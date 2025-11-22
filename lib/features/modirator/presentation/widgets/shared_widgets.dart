// lib/features/home/presentation/screens/shared_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tabib_soft_company/features/modirator/export.dart';

class BigPillButton extends StatelessWidget {
  final BuildContext context;
  final String label;
  final VoidCallback onTap;
  final Color borderColor;

  const BigPillButton(
    this.context, {
    super.key,
    required this.label,
    required this.onTap,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 78.h,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          elevation: 6,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(48.r),
            side: BorderSide(color: borderColor, width: 2),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: const Color(0xFF0F5FA8),
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RowField extends StatelessWidget {
  const RowField({
    super.key,
    required this.label,
    required this.child,
  });
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(fontSize: 14, color: Color(0xFF2D2D2D))),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

Widget boxedText(TextEditingController c,
    {TextInputType type = TextInputType.text}) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xff104D9D),
      borderRadius: BorderRadius.circular(12),
    ),
    child: TextFormField(
      controller: c,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: TextStyle(color: Colors.white70),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? ' مطلوب' : null,
    ),
  );
}

Widget boxedMultiline(TextEditingController c) {
  return Container(
    height: 100.h,
    decoration: BoxDecoration(
      color: const Color(0xff104D9D),
      borderRadius: BorderRadius.circular(12),
    ),
    child: TextFormField(
      controller: c,
      maxLines: null,
      expands: true,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: TextStyle(color: Colors.white70),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? ' مطلوب' : null,
    ),
  );
}

Widget dateBox({
  required String value,
  required VoidCallback onTap,
  IconData icon = Icons.calendar_month,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xff104D9D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
              child: Text(value, style: const TextStyle(color: Colors.white))),
        ],
      ),
    ),
  );
}

Widget DialogGrabberAndTitle(String title) {
  return Column(
    children: [
      Container(
        width: 50,
        height: 5,
        margin: const EdgeInsets.only(top: 6, bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      Text(
        title,
        style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F5FA8)),
      ),
    ],
  );
}

Widget saveButton({VoidCallback? onPressed}) {
  return SizedBox(
    width: double.infinity,
    height: 48,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            onPressed != null ? const Color(0xFF20AAC9) : Colors.grey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text('حفظ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    ),
  );
}

// نقل الويدجيتات الخاصة مثل ClientNameField, ProblemTypeDropdown, إلخ إلى هنا إذا كانت مشتركة، أو ابقها في ملفاتها الخاصة.

// مثال على ClientSearchField (مشتركة بين add_issue و add_subscription)
class ClientSearchField extends StatelessWidget {
  final Function(CustomerModel) onCustomerSelected;
  const ClientSearchField({super.key, required this.onCustomerSelected});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    bool showDropdown = false;
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            TextField(
              controller: controller,
              onChanged: (q) {
                if (q.isNotEmpty) {
                  context.read<CustomerCubit>().searchCustomers(q);
                  setState(() => showDropdown = true);
                } else {
                  setState(() => showDropdown = false);
                }
              },
              decoration: InputDecoration(
                hintText: 'ابحث عن العميل',
                filled: true,
                fillColor: const Color(0xFF104D9D),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                suffixIcon: const Icon(Icons.search, color: Colors.white),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            if (showDropdown)
              Container(
                margin: const EdgeInsets.only(top: 8),
                constraints: const BoxConstraints(maxHeight: 300),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: BlocBuilder<CustomerCubit, CustomerState>(
                  builder: (context, state) {
                    if (state.customers.isEmpty)
                      return const Text('لا يوجد عملاء');
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.customers.length,
                      itemBuilder: (_, i) {
                        final c = state.customers[i];
                        return ListTile(
                          title: Text(c.name ?? ''),
                          subtitle: Text(c.phone ?? ''),
                          onTap: () {
                            onCustomerSelected(c);
                            controller.text = c.name ?? '';
                            setState(() => showDropdown = false);
                          },
                        );
                      },
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

// أضف باقي الويدجيتات المشتركة هنا مثل PaymentMethodDropdown, ImagePickerWidget, etc.
class PaymentMethodDropdown extends StatelessWidget {
  final TextEditingController controller;
  final Function(PaymentMethodModel) onMethodSelected;
  const PaymentMethodDropdown({
    super.key,
    required this.controller,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<PaymentMethodCubit>().fetchPaymentMethods();
      },
      child: BlocBuilder<PaymentMethodCubit, PaymentMethodState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xff104D9D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        controller.text.isEmpty
                            ? 'اختر طريقة الدفع'
                            : controller.text,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.white),
                  ],
                ),
              ),
              if (state.status == PaymentMethodStatus.loading)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  ),
                ),
              if (state.status == PaymentMethodStatus.success &&
                  state.paymentMethods.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  constraints: const BoxConstraints(maxHeight: 250),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: const Color(0xff104D9D), width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3))
                    ],
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: state.paymentMethods.length,
                    itemBuilder: (ctx, index) {
                      final method = state.paymentMethods[index];
                      return ListTile(
                        dense: true,
                        title: Text(method.name),
                        onTap: () {
                          onMethodSelected(method);
                        },
                      );
                    },
                  ),
                ),
              if (state.status == PaymentMethodStatus.failure)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'فشل في جلب طرق الدفع',
                    style: TextStyle(color: Colors.red[300], fontSize: 13),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// أضف ClientNameField, ProblemTypeDropdown, DirectionDropdown, StatusDropdown, ImagePickerWidget, ImagePickerBottomSheet هنا إذا كانت مشتركة، أو في ملفاتها الخاصة.