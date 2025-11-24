import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_app_bar_widget.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_nav_bar_widget.dart';
import 'package:tabib_soft_company/features/programmers/data/model/engineer_model.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/engineer_cubit.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/engineer_state.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/support_customer_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/problem_status/problem_category_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/problem_status/problem_status_model.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/customer_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/customer_state.dart';

class AddProblemScreen extends StatefulWidget {
  const AddProblemScreen({super.key});

  @override
  State<AddProblemScreen> createState() => _AddProblemScreenState();
}

class _AddProblemScreenState extends State<AddProblemScreen> {
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _problemTypeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _engineerController = TextEditingController();

  static const Color headerColor = Color(0xFF0B4C99);
  static const Color fieldColor = Color(0xFF104084);
  static const Color primaryBtnColor = Color(0xFF28B5E1);
  static const Color backgroundColor = Color(0xFFF5F6FA);

  CustomerModel? _selectedCustomer;
  ProblemCategoryModel? _selectedCategory;
  ProblemStatusModel? _selectedStatus;
  EngineerModel? _selectedEngineer; // متغير لتخزين المهندس

  final List<File> _images = [];

  // bool _isUrgent = false;

  bool _isClientDropdownVisible = false;
  bool _isTypeDropdownVisible = false;
  bool _isEngineerDropdownVisible = false;

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
    _phoneController.dispose();
    _addressController.dispose();
    _detailsController.dispose();
    _engineerController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('الكاميرا'),
            onTap: () async {
              Navigator.pop(
                  context, await picker.pickImage(source: ImageSource.camera));
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('المعرض'),
            onTap: () async {
              Navigator.pop(
                  context, await picker.pickImage(source: ImageSource.gallery));
            },
          ),
        ],
      ),
    );

    if (pickedFile != null) {
      setState(() => _images.add(File(pickedFile.path)));
    }
  }

  void _saveProblem() {
    // 1. التحقق من جميع الحقول بما في ذلك المهندس
    if (_selectedCustomer == null ||
        _selectedCategory == null ||
        _selectedEngineer == null || // <-- تحقق إجباري من اختيار المهندس
        _detailsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول واختيار المهندس')),
      );
      return;
    }

    int? finalStatusId;
    final customerState = context.read<CustomerCubit>().state;

    if (_selectedStatus != null) {
      finalStatusId = _selectedStatus!.id;
    } else {
      if (customerState.problemStatusList.isNotEmpty) {
        finalStatusId = customerState.problemStatusList.first.id;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا توجد حالات مشاكل متاحة')),
        );
        return;
      }
    }

    String finalCategoryId = _selectedCategory!.id;

    context.read<CustomerCubit>().createProblem(
          customerId: _selectedCustomer!.id!,
          dateTime: DateTime.now(),
          problemStatusId: finalStatusId ?? 0,
          problemCategoryId: finalCategoryId,
          details: _detailsController.text,
          phone: _phoneController.text,
          images: _images.isNotEmpty ? _images : null,
          note: _detailsController.text,
          engineerId:
              _selectedEngineer!.id, // <-- لن يكون null أبداً بسبب التحقق أعلاه
        );
  }

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = 20.w;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: headerColor,
        body: BlocListener<CustomerCubit, CustomerState>(
          listener: (context, state) {
            if (state.isProblemAdded) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تمت إضافة المشكلة بنجاح')),
              );
              Navigator.pop(context);
            } else if (state.status == CustomerStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? 'فشل الحفظ')),
              );
            }
          },
          child: Column(
            children: [
              // Header
              SizedBox(
                height: 200.h,
                child: Stack(
                  children: [
                    Positioned(
                      top: 80.h,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Image.asset(
                          'assets/images/pngs/TS_Logo0.png',
                          height: 70.h,
                          color: Colors.white.withOpacity(0.3),
                          colorBlendMode: BlendMode.modulate,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40.h,
                      right: 10.w,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),

              // Body
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding, vertical: 30.h),
                    child: Column(
                      children: [
                        // -- اسم العميل --
                        _buildLabelledRow(
                          label: "اسم العميل:",
                          child: _buildAutocompleteDropdown(
                            controller: _clientNameController,
                            hint: "",
                            isVisible: _isClientDropdownVisible,
                            onTap: () => setState(() =>
                                _isClientDropdownVisible =
                                    !_isClientDropdownVisible),
                            child: BlocBuilder<CustomerCubit, CustomerState>(
                              builder: (context, state) {
                                if (state.customers.isEmpty) {
                                  return const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Text("لا يوجد عملاء"));
                                }
                                return ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  itemCount: state.customers.length,
                                  itemBuilder: (context, index) {
                                    final customer = state.customers[index];
                                    return ListTile(
                                      title: Text(customer.name ?? '',
                                          style: const TextStyle(fontSize: 14)),
                                      subtitle: Text(
                                          customer.phone?.toString() ?? '',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey)),
                                      onTap: () {
                                        setState(() {
                                          _selectedCustomer = customer;
                                          _clientNameController.text =
                                              customer.name ?? '';
                                          _phoneController.text =
                                              customer.phone?.toString() ?? '';
                                          _isClientDropdownVisible = false;
                                        });
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // -- رقم العميل --
                        _buildLabelledRow(
                          label: "رقم العميل:",
                          child: _buildTextField(
                            controller: _phoneController,
                            enabled: true,
                            hint: "",
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // -- نوع المشكلة --
                        _buildLabelledRow(
                          label: "نوع المشكلة:",
                          child: _buildAutocompleteDropdown(
                            controller: _problemTypeController,
                            hint: "",
                            isVisible: _isTypeDropdownVisible,
                            onTap: () => setState(() => _isTypeDropdownVisible =
                                !_isTypeDropdownVisible),
                            child: BlocBuilder<CustomerCubit, CustomerState>(
                              builder: (context, state) {
                                return ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  itemCount: state.problemCategories.length,
                                  itemBuilder: (context, index) {
                                    final cat = state.problemCategories[index];
                                    return ListTile(
                                      title: Text(cat.name,
                                          style: const TextStyle(fontSize: 14)),
                                      onTap: () {
                                        setState(() {
                                          _selectedCategory = cat;
                                          _problemTypeController.text =
                                              cat.name;
                                          _isTypeDropdownVisible = false;
                                        });
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // -- عنوان المشكلة --
                        _buildLabelledRow(
                          label: "عنوان المشكلة:",
                          child: _buildTextField(
                            controller: _addressController,
                            hint: "",
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // -- تفاصيل المشكلة --
                        _buildLabelledRow(
                          label: "تفاصيل المشكلة:",
                          child: SizedBox(
                            height: 100.h,
                            child: _buildTextField(
                              controller: _detailsController,
                              hint: "",
                              maxLines: 5,
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // -- تحويل الي --
                        _buildLabelledRow(
                          label: "تحويل الي:",
                          child: _buildAutocompleteDropdown(
                            controller: _engineerController,
                            hint: "",
                            isVisible: _isEngineerDropdownVisible,
                            onTap: () => setState(() =>
                                _isEngineerDropdownVisible =
                                    !_isEngineerDropdownVisible),
                            child: BlocBuilder<EngineerCubit, EngineerState>(
                              builder: (context, state) {
                                return ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  itemCount: state.engineers.length,
                                  itemBuilder: (context, index) {
                                    final eng = state.engineers[index];
                                    return ListTile(
                                      title: Text(eng.name,
                                          style: const TextStyle(fontSize: 14)),
                                      onTap: () {
                                        setState(() {
                                          _selectedEngineer =
                                              eng; // تخزين المهندس
                                          _engineerController.text = eng.name;
                                          _isEngineerDropdownVisible = false;
                                        });
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 30.h),

                        // -- الفوتر --
                        Center(
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "رفع ملفات",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp),
                                ),
                                SizedBox(height: 4.h),
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/pngs/upload_pic.png',
                                      width: 50,
                                      height: 50,
                                    ),
                                    if (_images.isNotEmpty)
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle),
                                          child: const Icon(Icons.check_circle,
                                              color: Colors.green, size: 14),
                                        ),
                                      )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (_images.isNotEmpty) ...[
                          SizedBox(height: 10.h),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _images
                                .map((img) => Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.file(img,
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: GestureDetector(
                                            onTap: () => setState(
                                                () => _images.remove(img)),
                                            child: const Icon(Icons.cancel,
                                                color: Colors.red, size: 20),
                                          ),
                                        ),
                                      ],
                                    ))
                                .toList(),
                          ),
                        ],

                        SizedBox(height: 40.h),

                        SizedBox(
                          width: 160.w,
                          height: 50.h,
                          child: ElevatedButton(
                            onPressed: _saveProblem,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBtnColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              "حفظ",
                              style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabelledRow({required String label, required Widget child}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100.w,
          child: Text(
            label,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(child: child),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    bool enabled = true,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildAutocompleteDropdown({
    required TextEditingController controller,
    required String hint,
    required bool isVisible,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 50),
            decoration: BoxDecoration(
              color: fieldColor,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    enabled: true,
                    onTap: onTap,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: const TextStyle(color: Colors.white38),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.only(right: 5),
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down,
                    color: primaryBtnColor, size: 35.sp),
              ],
            ),
          ),
        ),
        if (isVisible)
          Container(
            margin: const EdgeInsets.only(top: 5),
            height: 150.h,
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
            child: child,
          ),
      ],
    );
  }
}
