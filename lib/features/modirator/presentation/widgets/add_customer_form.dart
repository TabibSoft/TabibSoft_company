// lib/features/home/presentation/screens/add_customer_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
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
  final _govController = TextEditingController();
  final _cityController = TextEditingController();
  final _engineer = TextEditingController();
  final _product = TextEditingController();
  bool _showEngineerDropdown = false;
  bool _showProductDropdown = false;
  bool _showGovDropdown = false;
  bool _showCityDropdown = false;

  String? _selectedEngineerId;
  String? _selectedProductId;
  String? _selectedGovId;
  String? _selectedCityId;

  @override
  void initState() {
    super.initState();
    context.read<EngineerCubit>().fetchEngineers();
    context.read<ProductCubit>().fetchProducts();
    context.read<AddCustomerCubit>().fetchGovernments();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _location.dispose();
    _govController.dispose();
    _cityController.dispose();
    _engineer.dispose();
    _product.dispose();
    super.dispose();
  }

  bool _isPhoneValid(String phone) {
    final normalized = phone.trim();
    final regex = RegExp(r'^01\d{9}$'); // 11 digits total
    return regex.hasMatch(normalized);
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final phoneText = _phone.text.trim();

      if (!_isPhoneValid(phoneText)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('رقم التواصل يجب أن يبدأ بـ 01 ويكون 11 رقمًا'),
          ),
        );
        return;
      }

      final customer = AddCustomerModel(
        name: _name.text,
        telephone: phoneText,
        engineerId: _selectedEngineerId ?? '',
        productId: _selectedProductId ?? '',
        location: _cityController.text.isNotEmpty
            ? "${_govController.text} - ${_cityController.text}"
            : _govController.text,
        governmentId: _selectedGovId,
        cityId: _selectedCityId,
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

            // ====================== رقم التواصل ======================
            RowField(
              label: 'رقم التواصل',
              child: TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                maxLength: 11,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // أرقام فقط
                  LengthLimitingTextInputFormatter(11), // يمنع أكثر من 11 رقم
                ],
                decoration: InputDecoration(
                  counterText: "",
                  filled: true,
                  fillColor: const Color(0xff104D9D),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: "رقم التواصل",
                  hintStyle: const TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال رقم التواصل';
                  }
                  if (!_isPhoneValid(value)) {
                    return 'يجب أن يبدأ بـ 01 ويكون 11 رقمًا';
                  }
                  return null;
                },
              ),
            ),

            // Government Dropdown
            RowField(
              label: 'المحافظة',
              child: InkWell(
                onTap: () {
                  setState(() {
                    _showGovDropdown = !_showGovDropdown;
                    _showCityDropdown = false;
                    _showEngineerDropdown = false;
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
                      _govController.text.isEmpty
                          ? 'اختر المحافظة'
                          : _govController.text,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            if (_showGovDropdown)
              SizedBox(
                height: 200.h,
                child: BlocBuilder<AddCustomerCubit, AddCustomerState>(
                  builder: (context, state) {
                    if (state.status == AddCustomerStatus.loadingGovernments) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ListView.builder(
                      itemCount: state.governments.length,
                      itemBuilder: (context, index) {
                        final gov = state.governments[index];
                        return ListTile(
                          title: Text(gov.name),
                          onTap: () {
                            setState(() {
                              _govController.text = gov.name;
                              _selectedGovId = gov.id;
                              _showGovDropdown = false;
                              _selectedCityId = null;
                              _cityController.clear();
                            });
                            context
                                .read<AddCustomerCubit>()
                                .fetchCities(gov.id);
                          },
                        );
                      },
                    );
                  },
                ),
              ),

            // City Dropdown
            RowField(
              label: 'المدينة',
              child: InkWell(
                onTap: () {
                  if (_selectedGovId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('يرجى اختيار المحافظة أولاً')),
                    );
                    return;
                  }
                  setState(() {
                    _showCityDropdown = !_showCityDropdown;
                    _showGovDropdown = false;
                    _showEngineerDropdown = false;
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
                      _cityController.text.isEmpty
                          ? 'اختر المدينة'
                          : _cityController.text,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            if (_showCityDropdown)
              SizedBox(
                height: 200.h,
                child: BlocBuilder<AddCustomerCubit, AddCustomerState>(
                  builder: (context, state) {
                    if (state.status == AddCustomerStatus.loadingCities) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.cities.isEmpty) {
                      return const Center(child: Text('لا توجد مدن'));
                    }
                    return ListView.builder(
                      itemCount: state.cities.length,
                      itemBuilder: (context, index) {
                        final city = state.cities[index];
                        return ListTile(
                          title: Text(city.name),
                          onTap: () {
                            setState(() {
                              _cityController.text = city.name;
                              _selectedCityId = city.id;
                              _showCityDropdown = false;
                            });
                          },
                        );
                      },
                    );
                  },
                ),
              ),
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
