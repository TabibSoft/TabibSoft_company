import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_app_bar_widget.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_nav_bar_widget.dart';
import 'package:tabib_soft_company/features/programmers/data/model/engineer_model.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/engineer_cubit.dart';

import 'dart:io';


import '../../../export.dart';

class AddProblemScreen extends StatefulWidget {
  const AddProblemScreen({super.key});

  @override
  State<AddProblemScreen> createState() => _AddProblemScreenState();
}

class _AddProblemScreenState extends State<AddProblemScreen> {
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _problemTypeController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _directionController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

  static const Color primaryColor = Color(0xFF56C7F1);

  CustomerModel? _selectedCustomer;
  List<File> _selectedImages = [];
  ProblemStatusModel? _selectedStatus;

  bool _isClientDropdownVisible = false;
  bool _isTypeDropdownVisible = false;
  bool _isDirectionDropdownVisible = false;
  bool _isStatusDropdownVisible = false;

  @override
  void initState() {
    super.initState();
    context.read<CustomerCubit>().fetchCustomers();
    context.read<CustomerCubit>().fetchProblemCategories();
    context.read<CustomerCubit>().fetchProblemStatus();
    context.read<EngineerCubit>().fetchEngineers();
    _clientNameController.addListener(_onClientNameChanged);
  }

  void _onClientNameChanged() {
    final query = _clientNameController.text;
    if (query.isNotEmpty) {
      context.read<CustomerCubit>().searchCustomers(query);
      setState(() => _isClientDropdownVisible = true);
    } else {
      setState(() {
        _isClientDropdownVisible = false;
        _selectedCustomer = null;
      });
    }
  }

  @override
  void dispose() {
    _clientNameController.removeListener(_onClientNameChanged);
    _clientNameController.dispose();
    _problemTypeController.dispose();
    _phoneNumberController.dispose();
    _directionController.dispose();
    _detailsController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  void _onCustomerSelected(CustomerModel customer) {
    setState(() {
      _selectedCustomer = customer;
      _clientNameController.text = customer.name ?? '';
      _phoneNumberController.text = customer.phone ?? '';
      _isClientDropdownVisible = false;
    });
  }

  void _onImagePicked(File image) {
    setState(() {
      _selectedImages.add(image);
    });
  }

  void _onImageRemoved(File image) {
    setState(() {
      _selectedImages.remove(image);
    });
  }

  void _onSave() {
    if (_selectedCustomer == null ||
        _problemTypeController.text.isEmpty ||
        _phoneNumberController.text.isEmpty ||
        _directionController.text.isEmpty ||
        _selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول المطلوبة')),
      );
      return;
    }

    bool hasValidImages = true;
    for (var image in _selectedImages) {
      if (!image.existsSync() || image.lengthSync() == 0) {
        hasValidImages = false;
        print('Invalid image: ${image.path}');
      }
    }
    if (!hasValidImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم اختيار صورة غير صالحة')),
      );
      return;
    }

    final customerState = context.read<CustomerCubit>().state;
    final engineerState = context.read<EngineerCubit>().state;

    final selectedCategory = customerState.problemCategories.firstWhere(
      (c) => c.name == _problemTypeController.text,
      orElse: () => ProblemCategoryModel(id: '', name: ''),
    );

    if (selectedCategory.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فئة المشكلة غير صالحة')),
      );
      return;
    }

    final selectedEngineer = engineerState.engineers.firstWhere(
      (e) => e.name == _directionController.text,
      orElse: () => EngineerModel(id: '', name: '', address: '', telephone: ''),
    );

    if (_selectedCustomer!.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('معرف العميل غير متاح')),
      );
      return;
    }

    if (!RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')
        .hasMatch(_selectedCustomer!.id!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('معرف العميل غير صالح')),
      );
      return;
    }
    if (!RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')
        .hasMatch(selectedCategory.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('معرف فئة المشكلة غير صالح')),
      );
      return;
    }
    if (selectedEngineer.id.isNotEmpty &&
        !RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')
            .hasMatch(selectedEngineer.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('معرف المهندس غير صالح')),
      );
      return;
    }

    context.read<CustomerCubit>().createProblem(
          customerId: _selectedCustomer!.id!,
          dateTime: DateTime.now(),
          problemStatusId: _selectedStatus!.id,
          problemCategoryId: selectedCategory.id,
          note: _detailsController.text.isNotEmpty
              ? _detailsController.text
              : null,
          engineerId:
              selectedEngineer.id.isNotEmpty ? selectedEngineer.id : null,
          details: _detailsController.text.isNotEmpty
              ? _detailsController.text
              : null,
          phone: _phoneNumberController.text,
          images: _selectedImages.isNotEmpty ? _selectedImages : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: BlocListener<CustomerCubit, CustomerState>(
          listenWhen: (previous, current) =>
              current.isProblemAdded != previous.isProblemAdded ||
              current.status == CustomerStatus.failure,
          listener: (context, state) {
            if (state.isProblemAdded) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تمت إضافة المشكلة بنجاح')),
              );
              _detailsController.clear();
              _clientNameController.clear();
              _problemTypeController.clear();
              _phoneNumberController.clear();
              _directionController.clear();
              _statusController.clear();
              setState(() {
                _selectedCustomer = null;
                _selectedStatus = null;
                _isClientDropdownVisible = false;
                _isTypeDropdownVisible = false;
                _isDirectionDropdownVisible = false;
                _isStatusDropdownVisible = false;
                _selectedImages.clear();
              });
              Navigator.of(context).pop();
            } else if (state.status == CustomerStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.errorMessage ??
                        'فشل في إضافة المشكلة. يرجى التحقق من البيانات وحاول مجددًا.',
                  ),
                ),
              );
            }
          },
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: CustomAppBar(
                  title: 'إضافة مشكلة',
                  height: 343,
                  leading: IconButton(
                    icon: Image.asset('assets/images/pngs/back.png',
                        width: 30, height: 30),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  actions: [
                    IconButton(
                      icon: Image.asset('assets/images/pngs/add_customer.png',
                          width: 38, height: 38),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AddCustomerScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Positioned(
                top: size.height * 0.25,
                left: size.width * 0.05,
                right: size.width * 0.05,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        const Color.fromARGB(100, 95, 93, 93).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: primaryColor, width: 3),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: size.height * 0.7),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClientNameField(
                              controller: _clientNameController,
                              isDropdownVisible: _isClientDropdownVisible,
                              onToggleDropdown: () {
                                setState(() {
                                  _isClientDropdownVisible =
                                      !_isClientDropdownVisible;
                                  if (_isClientDropdownVisible) {
                                    context
                                        .read<CustomerCubit>()
                                        .fetchCustomers();
                                  }
                                });
                              },
                              onCustomerSelected: _onCustomerSelected,
                            ),
                            const SizedBox(height: 16),
                            ProblemTypeDropdown(
                              controller: _problemTypeController,
                              isDropdownVisible: _isTypeDropdownVisible,
                              onToggleDropdown: () {
                                setState(() {
                                  _isTypeDropdownVisible =
                                      !_isTypeDropdownVisible;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            PhoneNumberField(
                              controller: _phoneNumberController,
                            ),
                            const SizedBox(height: 16),
                            DirectionDropdown(
                              controller: _directionController,
                              isDropdownVisible: _isDirectionDropdownVisible,
                              onToggleDropdown: () {
                                setState(() {
                                  _isDirectionDropdownVisible =
                                      !_isDirectionDropdownVisible;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            StatusDropdown(
                              controller: _statusController,
                              isDropdownVisible: _isStatusDropdownVisible,
                              onToggleDropdown: () {
                                setState(() {
                                  _isStatusDropdownVisible =
                                      !_isStatusDropdownVisible;
                                });
                              },
                              onStatusSelected: (status) {
                                setState(() {
                                  _selectedStatus = status;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            DetailsField(
                              controller: _detailsController,
                            ),
                            SelectedImagesDisplay(
                              images: _selectedImages,
                              onImageRemoved: _onImageRemoved,
                            ),
                            const SizedBox(height: 16),
                            ImagePickerWidget(
                              onImagePicked: _onImagePicked,
                            ),
                            const SizedBox(height: 24),
                            SaveButton(
                              onPressed: _onSave,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const CustomNavBar(
          items: [],
          alignment: MainAxisAlignment.spaceBetween,
          padding: EdgeInsets.symmetric(horizontal: 32),
        ),
      ),
    );
  }
}
