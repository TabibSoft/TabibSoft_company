// lib/features/modirator/presentation/screens/modirator_add_problem_screen.dart
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/engineer_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/support_customer_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/problem_status/problem_category_model.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/customer_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/customer_state.dart';

class ModiratorAddProblemScreen extends StatefulWidget {
  const ModiratorAddProblemScreen({super.key});

  @override
  State<ModiratorAddProblemScreen> createState() =>
      _ModiratorAddProblemScreenState();
}

class _ModiratorAddProblemScreenState extends State<ModiratorAddProblemScreen> {
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _problemTypeController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _directionController = TextEditingController();
  final TextEditingController _fromTimeController = TextEditingController();
  final TextEditingController _toTimeController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  static const Color primaryColor = Color(0xff104D9D);

  CustomerModel? _selectedCustomer;
  ProblemCategoryModel? _selectedProblemCategory;
  final List<File> _selectedImages = [];
  DateTime? _selectedDate;
  TimeOfDay? _fromTime;
  TimeOfDay? _toTime;

  bool _isClientDropdownVisible = false;
  bool _isTypeDropdownVisible = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    final nowTod = TimeOfDay.now();
    _fromTime = nowTod;
    _toTime = TimeOfDay(hour: (nowTod.hour + 1) % 24, minute: nowTod.minute);
    _updateDateText();
    _updateFromTimeText();
    _updateToTimeText();

    // fetch data from cubits
    context.read<CustomerCubit>().fetchCustomers();
    context.read<CustomerCubit>().fetchProblemCategories();
    context.read<CustomerCubit>().fetchProblemStatus();
    context.read<EngineerCubit>().fetchEngineers();

    // when typing in client name, show dropdown and search
    _clientNameController.addListener(_onClientNameChanged);
  }

  void _onClientNameChanged() {
    final query = _clientNameController.text.trim();
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

  void _updateDateText() {
    if (_selectedDate != null) {
      _directionController.text =
          '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';
    }
  }

  void _updateFromTimeText() {
    if (_fromTime != null) {
      _fromTimeController.text =
          '${_fromTime!.hour.toString().padLeft(2, '0')}:${_fromTime!.minute.toString().padLeft(2, '0')}';
    }
  }

  void _updateToTimeText() {
    if (_toTime != null) {
      _toTimeController.text =
          '${_toTime!.hour.toString().padLeft(2, '0')}:${_toTime!.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _updateDateText();
      });
    }
  }

  Future<void> _selectFromTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _fromTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _fromTime) {
      setState(() {
        _fromTime = picked;
        _updateFromTimeText();
      });
    }
  }

  Future<void> _selectToTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _toTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _toTime) {
      setState(() {
        _toTime = picked;
        _updateToTimeText();
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
    _fromTimeController.dispose();
    _toTimeController.dispose();
    _detailsController.dispose();
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

  void _onProblemCategorySelected(ProblemCategoryModel category) {
    setState(() {
      _selectedProblemCategory = category;
      _problemTypeController.text = category.name ?? '';
      _isTypeDropdownVisible = false;
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
        _selectedProblemCategory == null ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول الإلزامية')),
      );
      return;
    }

    final now = DateTime.now();
    final dateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _fromTime?.hour ?? now.hour,
      _fromTime?.minute ?? now.minute,
    );

    context.read<CustomerCubit>().createProblem(
          customerId: _selectedCustomer!.id!,
          dateTime: dateTime,
          problemStatusId: 1,
          problemCategoryId: _selectedProblemCategory!.id.toString(),
          note: _detailsController.text,
          engineerId: null,
          details: _detailsController.text,
          phone: _phoneNumberController.text,
          images: _selectedImages,
        );

    Navigator.pop(context);
  }

  void _onClose() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final dialogWidth = math.min(420.0, media.size.width * 0.92);
    final dialogHeight = math.min(media.size.height * 0.78, 620.0);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
          // keep scaffold transparent so background shows
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // dimmed background (like barrierColor)
              GestureDetector(
                onTap: () {
                  // keep as no-op to prevent accidental close;
                  // if you want tapping outside to close, call: _onClose();
                },
                child: Container(
                  color: Colors.black.withOpacity(0.35),
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),

              // Centered card
              Center(
                child: SizedBox(
                  width: dialogWidth,
                  height: dialogHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: primaryColor, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Material(
                            color: Colors.white,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // header row with title and close
                                  Row(
                                    children: [
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'إضافة مشكلة',
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: _onClose,
                                        icon: const Icon(Icons.close,
                                            color: primaryColor),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  // 1 - اسم العميل (label on right, field left)
                                  RowField(
                                    label: 'اسم العميل',
                                    child: ClientNameField(
                                      controller: _clientNameController,
                                      isDropdownVisible:
                                          _isClientDropdownVisible,
                                      onToggleDropdown: () {
                                        setState(() {
                                          _isClientDropdownVisible =
                                              !_isClientDropdownVisible;
                                          if (_isClientDropdownVisible)
                                            _isTypeDropdownVisible = false;
                                        });
                                      },
                                      onCustomerSelected: _onCustomerSelected,
                                      primaryColor: primaryColor,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // 2 - نوع المشكلة
                                  RowField(
                                    label: 'نوع المشكلة',
                                    child: ProblemTypeDropdown(
                                      controller: _problemTypeController,
                                      isDropdownVisible: _isTypeDropdownVisible,
                                      onToggleDropdown: () {
                                        setState(() {
                                          _isTypeDropdownVisible =
                                              !_isTypeDropdownVisible;
                                          if (_isTypeDropdownVisible)
                                            _isClientDropdownVisible = false;
                                        });
                                      },
                                      onCategorySelected:
                                          _onProblemCategorySelected,
                                      primaryColor: primaryColor,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // 3 - المشكلة (details) - أكبر مربع
                                  RowField(
                                    label: 'المشكلة',
                                    child: DetailsField(
                                      controller: _detailsController,
                                      primaryColor: primaryColor,
                                      // DetailsField used without internal hint
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // 4 - رقم التواصل
                                  RowField(
                                    label: 'رقم التواصل',
                                    child: PhoneNumberField(
                                      controller: _phoneNumberController,
                                      primaryColor: primaryColor,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // 5 - التاريخ
                                  RowField(
                                    label: 'التاريخ',
                                    child: DateField(
                                      controller: _directionController,
                                      onTap: _selectDate,
                                      primaryColor: primaryColor,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // 6 - مربعان من - إلى (كل مربع مع تسميته على اليمين)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            const SizedBox(
                                              width: 100,
                                              child: Text(
                                                'من',
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xFF2D2D2D),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: TimeField(
                                                controller: _fromTimeController,
                                                label: '',
                                                onTap: _selectFromTime,
                                                primaryColor: primaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            const SizedBox(
                                              width: 100,
                                              child: Text(
                                                'إلى',
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xFF2D2D2D),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: TimeField(
                                                controller: _toTimeController,
                                                label: '',
                                                onTap: _selectToTime,
                                                primaryColor: primaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 14),

                                  // رفع ملفات و الصور المختارة
                                  SelectedImagesDisplay(
                                    images: _selectedImages,
                                    onImageRemoved: _onImageRemoved,
                                  ),

                                  const SizedBox(height: 8),

                                  // رفع الملفات زر
                                  Row(
                                    children: [
                                      const SizedBox(
                                          width: 110), // label space empty
                                      Expanded(
                                        child: ImagePickerWidget(
                                          onImagePicked: _onImagePicked,
                                          primaryColor: primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 14),

                                  // زر حفظ
                                  Row(
                                    children: [
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: SaveButton(
                                          onPressed: _onSave,
                                          primaryColor: primaryColor,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                  ),

                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // (optional) floating plus button overlapping bottom-right removed
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- Widgets (مضبوطة لتدعم الحقل القابل للكتابة) ----------------

class ClientNameField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDropdownVisible;
  final VoidCallback onToggleDropdown;
  final Function(CustomerModel) onCustomerSelected;
  final Color primaryColor;

  const ClientNameField({
    super.key,
    required this.controller,
    required this.isDropdownVisible,
    required this.onToggleDropdown,
    required this.onCustomerSelected,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerCubit, CustomerState>(
      builder: (context, state) {
        final filteredCustomers = state.customers;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor, width: 2),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      textAlign: TextAlign.center,
                      readOnly: false, // الحقل قابل للكتابة
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onToggleDropdown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Image.asset(
                        'assets/images/pngs/drop_down.png',
                        width: 26,
                        height: 26,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isDropdownVisible)
              Container(
                margin: const EdgeInsets.only(top: 8),
                constraints: const BoxConstraints(maxHeight: 180),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryColor, width: 1.5),
                ),
                child: Builder(builder: (ctx) {
                  if (state.status == CustomerStatus.loading) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (filteredCustomers.isNotEmpty) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: filteredCustomers.length,
                      itemBuilder: (c, idx) {
                        final customer = filteredCustomers[idx];
                        return ListTile(
                          title: Text(customer.name ?? ''),
                          subtitle: (customer.phone != null &&
                                  customer.phone!.isNotEmpty)
                              ? Text(customer.phone!)
                              : null,
                          onTap: () => onCustomerSelected(customer),
                        );
                      },
                    );
                  } else {
                    return const Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Text('لا توجد نتائج'),
                        ],
                      ),
                    );
                  }
                }),
              ),
          ],
        );
      },
    );
  }
}

class ProblemTypeDropdown extends StatelessWidget {
  final TextEditingController controller;
  final bool isDropdownVisible;
  final VoidCallback onToggleDropdown;
  final Function(ProblemCategoryModel) onCategorySelected;
  final Color primaryColor;

  const ProblemTypeDropdown({
    super.key,
    required this.controller,
    required this.isDropdownVisible,
    required this.onToggleDropdown,
    required this.onCategorySelected,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: onToggleDropdown,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryColor, width: 2),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? '' : controller.text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: controller.text.isEmpty
                            ? Colors.grey[600]
                            : Colors.black),
                  ),
                ),
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.check, size: 18, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Image.asset('assets/images/pngs/email.png',
                    width: 22, height: 22),
              ],
            ),
          ),
        ),
        if (isDropdownVisible)
          Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 180),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryColor, width: 1.5),
            ),
            child: BlocBuilder<CustomerCubit, CustomerState>(
              builder: (context, state) {
                if (state.status == CustomerStatus.loading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (state.problemCategories.isNotEmpty) {
                  return ListView(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    children: state.problemCategories.map((category) {
                      return ListTile(
                        title: Text(category.name),
                        onTap: () {
                          onCategorySelected(category);
                        },
                      );
                    }).toList(),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const Text('لا توجد فئات متاحة'),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            context
                                .read<CustomerCubit>()
                                .fetchProblemCategories();
                          },
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
      ],
    );
  }
}

class DateField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onTap;
  final Color primaryColor;

  const DateField({
    super.key,
    required this.controller,
    required this.onTap,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryColor, width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: AbsorbPointer(
                child: TextFormField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  readOnly: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Image.asset('assets/images/pngs/calendar.png',
                  width: 24, height: 24),
            ),
          ],
        ),
      ),
    );
  }
}

class TimeField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final VoidCallback onTap;
  final Color primaryColor;

  const TimeField({
    super.key,
    required this.controller,
    required this.label,
    required this.onTap,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: primaryColor, width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: AbsorbPointer(
                child: TextFormField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  readOnly: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: Image.asset('assets/images/pngs/email.png',
                  width: 18, height: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class PhoneNumberField extends StatelessWidget {
  final TextEditingController controller;
  final Color primaryColor;

  const PhoneNumberField({
    super.key,
    required this.controller,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor, width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Image.asset('assets/images/pngs/phone.png',
                width: 22, height: 22),
          ),
        ],
      ),
    );
  }
}

class DetailsField extends StatelessWidget {
  final TextEditingController controller;
  final Color primaryColor;

  const DetailsField({
    super.key,
    required this.controller,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // make the details box a little taller
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor, width: 2),
      ),
      child: TextFormField(
        controller: controller,
        textAlign: TextAlign.center,
        maxLines: 4,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        ),
      ),
    );
  }
}

class ImagePickerWidget extends StatelessWidget {
  final Function(File) onImagePicked;
  final Color primaryColor;

  const ImagePickerWidget({
    super.key,
    required this.onImagePicked,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (_) => ImagePickerBottomSheet(
            onImagePicked: onImagePicked,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryColor, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/pngs/pictures_folder.png',
                width: 22, height: 22),
            const SizedBox(width: 8),
            Text('رفع ملفات',
                style: TextStyle(
                    color: primaryColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class SelectedImagesDisplay extends StatelessWidget {
  final List<File> images;
  final Function(File) onImageRemoved;

  const SelectedImagesDisplay({
    super.key,
    required this.images,
    required this.onImageRemoved,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('الصور المختارة:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: images.map((image) {
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(image,
                      width: 100, height: 100, fit: BoxFit.cover),
                ),
                Positioned(
                  top: -6,
                  right: -6,
                  child: GestureDetector(
                    onTap: () => onImageRemoved(image),
                    child: const CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.red,
                      child: Icon(Icons.close, color: Colors.white, size: 14),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

class SaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color primaryColor;

  const SaveButton({
    super.key,
    required this.onPressed,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        child: const Center(
            child: Text('حفظ',
                style: TextStyle(fontSize: 17, color: Colors.white))),
      ),
    );
  }
}

class ImagePickerBottomSheet extends StatelessWidget {
  final Function(File) onImagePicked;

  const ImagePickerBottomSheet({
    super.key,
    required this.onImagePicked,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('الكاميرا'),
            onTap: () async {
              final picker = ImagePicker();
              final pickedFile =
                  await picker.pickImage(source: ImageSource.camera);
              if (pickedFile != null && pickedFile.path.isNotEmpty) {
                onImagePicked(File(pickedFile.path));
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('فشل في اختيار الصورة')));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text('المعرض'),
            onTap: () async {
              final picker = ImagePicker();
              final pickedFile =
                  await picker.pickImage(source: ImageSource.gallery);
              if (pickedFile != null && pickedFile.path.isNotEmpty) {
                onImagePicked(File(pickedFile.path));
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('فشل في اختيار الصورة')));
              }
            },
          ),
        ],
      ),
    );
  }
}

// Helper row widget that places label on the right and child field expanded on the left
class RowField extends StatelessWidget {
  final String label;
  final Widget child;
  const RowField({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 14, color: Color(0xFF2D2D2D))),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
