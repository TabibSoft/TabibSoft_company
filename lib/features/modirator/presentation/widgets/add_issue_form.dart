// lib/features/home/presentation/screens/add_issue_form.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tabib_soft_company/features/modirator/export.dart';

class AddIssueForm extends StatefulWidget {
  const AddIssueForm({
    super.key,
    required this.onSaved,
    this.onClientTap,
  });
  final VoidCallback onSaved;
  final VoidCallback? onClientTap;

  @override
  State<AddIssueForm> createState() => _AddIssueFormState();
}

class _AddIssueFormState extends State<AddIssueForm> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _problemTypeController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _directionController = TextEditingController();
  final _detailsController = TextEditingController();
  final _statusController = TextEditingController();
  static const Color primaryColor = Color(0xff104D9D);
  CustomerModel? _selectedCustomer;
  final List<File> _selectedImages = [];
  ProblemStatusModel? _selectedStatus;
  ProblemCategoryModel? _selectedCategory;
  EngineerModel? _selectedEngineer;
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
    return BlocListener<CustomerCubit, CustomerState>(
      listener: (context, state) {
        if (state.status == CustomerStatus.success && state.isProblemAdded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إضافة المشكلة بنجاح')),
          );
          widget.onSaved();
        } else if (state.status == CustomerStatus.failure) {
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
            RowField(
              label: 'اسم العميل',
              child: ClientNameField(
                controller: _clientNameController,
                isDropdownVisible: _isClientDropdownVisible,
                onToggleDropdown: () {
                  setState(() {
                    _isClientDropdownVisible = !_isClientDropdownVisible;
                    if (_isClientDropdownVisible) {
                      context.read<CustomerCubit>().fetchCustomers();
                    }
                  });
                },
                onCustomerSelected: _onCustomerSelected,
              ),
            ),
            RowField(
              label: 'رقم التواصل',
              child:
                  boxedText(_phoneNumberController, type: TextInputType.phone),
            ),
            RowField(
              label: 'نوع المشكلة',
              child: ProblemTypeDropdown(
                controller: _problemTypeController,
                isDropdownVisible: _isTypeDropdownVisible,
                onToggleDropdown: () {
                  setState(() {
                    _isTypeDropdownVisible = !_isTypeDropdownVisible;
                  });
                },
              ),
            ),
            RowField(
              label: 'توجيه إلى',
              child: DirectionDropdown(
                controller: _directionController,
                isDropdownVisible: _isDirectionDropdownVisible,
                onToggleDropdown: () {
                  setState(() {
                    _isDirectionDropdownVisible = !_isDirectionDropdownVisible;
                  });
                },
              ),
            ),
            RowField(
              label: 'حالة المشكلة',
              child: StatusDropdown(
                controller: _statusController,
                isDropdownVisible: _isStatusDropdownVisible,
                onToggleDropdown: () {
                  setState(() {
                    _isStatusDropdownVisible = !_isStatusDropdownVisible;
                  });
                },
                onStatusSelected: (status) {
                  setState(() {
                    _selectedStatus = status;
                  });
                },
              ),
            ),
            RowField(
              label: 'التفاصيل',
              child: boxedMultiline(_detailsController),
            ),
            RowField(
              label: 'الصور',
              child: ImagePickerWidget(
                onImagePicked: _onImagePicked,
              ),
            ),
            if (_selectedImages.isNotEmpty)
              SizedBox(
                height: 100.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    final image = _selectedImages[index];
                    return Padding(
                      padding: EdgeInsets.all(8.w),
                      child: Stack(
                        children: [
                          Image.file(
                            image,
                            width: 80.w,
                            height: 80.h,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _onImageRemoved(image),
                              child: const Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
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
}

// ... (ClientNameField, ProblemTypeDropdown, DirectionDropdown, StatusDropdown, ImagePickerWidget, ImagePickerBottomSheet كما هي في الكود الأصلي، لكن نقلها إلى هذا الملف أو shared إذا كانت مشتركة. هنا نفترض نقلها إلى shared_widgets.dart للاختصار، لكن إذا كانت خاصة، ابقها هنا)