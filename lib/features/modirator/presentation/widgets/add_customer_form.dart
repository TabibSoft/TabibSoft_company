// lib/features/home/presentation/screens/add_customer_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  void _onSave() {
    if (_formKey.currentState!.validate()) {
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
              SizedBox(
                height: 200.h,
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
                      return const Text('خطأ في تحميل المهندسين');
                    }
                  },
                ),
              ),
            RowField(label: 'التخصص', child: _productDropdown()),
            if (_showProductDropdown)
              SizedBox(
                height: 200.h,
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
                      return const Text('خطأ في تحميل المنتجات');
                    }
                  },
                ),
              ),
            SizedBox(height: 16.h),
            saveButton(onPressed: _onSave),
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
        child: Center(
          child: Text(
            _engineer.text.isEmpty ? 'اختر المهندس' : _engineer.text,
            style: const TextStyle(color: Colors.white),
          ),
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
        child: Center(
          child: Text(
            _product.text.isEmpty ? 'اختر التخصص' : _product.text,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}