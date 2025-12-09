// lib/features/home/presentation/screens/add_customer_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tabib_soft_company/features/modirator/export.dart';

class AddCustomerForm extends StatefulWidget {
  const AddCustomerForm({super.key, required this.onSaved});
  final VoidCallback onSaved;

  @override
  State<AddCustomerForm> createState() => _AddCustomerFormState();
}

class _AddCustomerFormState extends State<AddCustomerForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _location = TextEditingController();
  final _engineer = TextEditingController();
  final _product = TextEditingController();
  bool _showEngineerDropdown = false;
  bool _showProductDropdown = false;
  String? _selectedEngineerId;
  String? _selectedProductId;

  @override
  void initState() {
    super.initState();
    context.read<EngineerCubit>().fetchEngineers();
    context.read<ProductCubit>().fetchProducts();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _location.dispose();
    _engineer.dispose();
    _product.dispose();
    super.dispose();
  }

  // ✅ دالة التحقق من صحة رقم الهاتف
  bool validatePhoneNumber(String phone) {
    // إزالة المسافات والأحرف غير الرقمية
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    
    // التحقق من أن الرقم يبدأ بـ 01 وطوله 11 رقم
    if (cleanPhone.length != 11) {
      Fluttertoast.showToast(
        msg: 'رقم الهاتف يجب أن يكون 11 رقم',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return false;
    }
    
    if (!cleanPhone.startsWith('01')) {
      Fluttertoast.showToast(
        msg: 'رقم الهاتف يجب أن يبدأ بـ 01',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return false;
    }
    
    return true;
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      // ✅ التحقق من رقم الهاتف قبل الحفظ
      if (!validatePhoneNumber(_phone.text)) {
        return;
      }

      final customer = AddCustomerModel(
        name: _name.text,
        telephone: _phone.text,
        engineerId: _selectedEngineerId ?? '',
        productId: _selectedProductId ?? '',
        location: _location.text.isNotEmpty ? _location.text : null,
      );
      context.read<AddCustomerCubit>().addCustomer(customer);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddCustomerCubit, AddCustomerState>(
      listener: (context, state) {
        if (state.status == AddCustomerStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إضافة العميل بنجاح')),
          );
          widget.onSaved();
        } else if (state.status == AddCustomerStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.errorMessage ?? 'حدث خطأ أثناء الإضافة')),
          );
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            RowField(label: 'اسم العميل', child: boxedText(_name)),
            RowField(
                label: 'رقم التواصل',
                child: boxedText(_phone, type: TextInputType.phone)),
            RowField(label: 'الموقع', child: boxedText(_location)),
            RowField(label: 'المهندس', child: _engineerDropdown()),
            if (_showEngineerDropdown)
              Container(
                height: 200.h,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: BlocBuilder<EngineerCubit, EngineerState>(
                  builder: (context, state) {
                    if (state.status == EngineerStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state.status == EngineerStatus.success) {
                      return ListView.builder(
                        itemCount: state.engineers.length,
                        itemBuilder: (context, index) {
                          final engineer = state.engineers[index];
                          return ListTile(
                            title: Text(engineer.name),
                            onTap: () {
                              setState(() {
                                _engineer.text = engineer.name;
                                _selectedEngineerId = engineer.id;
                                _showEngineerDropdown = false;
                              });
                            },
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: Text('خطأ في تحميل المهندسين'),
                      );
                    }
                  },
                ),
              ),
            RowField(label: 'التخصص', child: _productDropdown()),
            if (_showProductDropdown)
              Container(
                height: 200.h,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: BlocBuilder<ProductCubit, ProductState>(
                  builder: (context, state) {
                    if (state.status == ProductStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state.status == ProductStatus.success) {
                      return ListView.builder(
                        itemCount: state.products.length,
                        itemBuilder: (context, index) {
                          final product = state.products[index];
                          return ListTile(
                            title: Text(product.name),
                            onTap: () {
                              setState(() {
                                _product.text = product.name;
                                _selectedProductId = product.id;
                                _showProductDropdown = false;
                              });
                            },
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: Text('خطأ في تحميل المنتجات'),
                      );
                    }
                  },
                ),
              ),
            SizedBox(height: 16.h),
            BlocBuilder<AddCustomerCubit, AddCustomerState>(
              builder: (context, state) {
                final isLoading = state.status == AddCustomerStatus.loading;
                return saveButton(
                  onPressed: isLoading ? null : _onSave,
                  isLoading: isLoading,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _engineerDropdown() {
    return InkWell(
      onTap: () {
        setState(() {
          _showEngineerDropdown = !_showEngineerDropdown;
          _showProductDropdown = false;
        });
      },
      child: Container(
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
                _engineer.text.isEmpty ? 'اختر المهندس' : _engineer.text,
                style: TextStyle(
                  color: _engineer.text.isEmpty ? Colors.white70 : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.white, size: 30),
          ],
        ),
      ),
    );
  }

  Widget _productDropdown() {
    return InkWell(
      onTap: () {
        setState(() {
          _showProductDropdown = !_showProductDropdown;
          _showEngineerDropdown = false;
        });
      },
      child: Container(
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
                _product.text.isEmpty ? 'اختر التخصص' : _product.text,
                style: TextStyle(
                  color: _product.text.isEmpty ? Colors.white70 : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.white, size: 30),
          ],
        ),
      ),
    );
  }

  Widget saveButton({required VoidCallback? onPressed, bool isLoading = false}) {
    return Container(
      width: double.infinity,
      height: 54.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF28B5E1), Color(0xFF20AAC9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF28B5E1).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Text(
                'حفظ',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

// Widget helper للـ boxedText
Widget boxedText(TextEditingController controller, {TextInputType? type}) {
  return Container(
    height: 52,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: const Color(0xff104D9D),
      borderRadius: BorderRadius.circular(12),
    ),
    child: TextFormField(
      controller: controller,
      keyboardType: type,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(vertical: 15),
      ),
      validator: (value) =>
          (value == null || value.trim().isEmpty) ? 'مطلوب' : null,
    ),
  );
}

// Widget helper للـ RowField
class RowField extends StatelessWidget {
  final String label;
  final Widget child;

  const RowField({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: child),
          SizedBox(width: 12.w),
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
