import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
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
  EngineerModel? _selectedEngineer;

  final List<File> _images = [];

  bool _isClientDropdownVisible = false;
  bool _isTypeDropdownVisible = false;
  bool _isEngineerDropdownVisible = false;
  bool _isSaving = false; // متغير لتتبع عملية الحفظ

  @override
  void initState() {
    super.initState();
    // إعادة تعيين حالة isProblemAdded عند فتح الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerCubit>().resetProblemAddedFlag();
    });

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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryBtnColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.camera_alt, color: primaryBtnColor),
              ),
              title: const Text('الكاميرا',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () async {
                Navigator.pop(
                    context, await picker.pickImage(source: ImageSource.camera));
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryBtnColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.photo_library, color: primaryBtnColor),
              ),
              title: const Text('المعرض',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () async {
                Navigator.pop(context,
                    await picker.pickImage(source: ImageSource.gallery));
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );

    if (pickedFile != null) {
      setState(() => _images.add(File(pickedFile.path)));
    }
  }

  void _saveProblem() {
    if (_selectedCustomer == null ||
        _selectedCategory == null ||
        _selectedEngineer == null ||
        _detailsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('يرجى ملء جميع الحقول واختيار المهندس'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
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
          SnackBar(
            content: const Text('لا توجد حالات مشاكل متاحة'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }
    }

    String finalCategoryId = _selectedCategory!.id;

    // تعيين حالة الحفظ
    setState(() => _isSaving = true);

    context.read<CustomerCubit>().createProblem(
          customerId: _selectedCustomer!.id!,
          dateTime: DateTime.now(),
          problemStatusId: finalStatusId ?? 0,
          problemCategoryId: finalCategoryId,
          details: _detailsController.text,
          phone: _phoneController.text,
          images: _images.isNotEmpty ? _images : null,
          note: _detailsController.text,
          engineerId: _selectedEngineer!.id,
        );
  }

  void _showAddCustomerBottomSheet() {
    setState(() {
      _isClientDropdownVisible = false;
      _isTypeDropdownVisible = false;
      _isEngineerDropdownVisible = false;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddCustomerBottomSheet(
        onCustomerAdded: () {
          context.read<CustomerCubit>().fetchCustomers();
          Fluttertoast.showToast(
            msg: 'تم إضافة العميل بنجاح ✓',
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        },
      ),
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
            // الاستماع فقط عندما نكون في حالة حفظ
            if (_isSaving) {
              if (state.isProblemAdded) {
                setState(() => _isSaving = false);
                
                Fluttertoast.showToast(
                  msg: 'تمت إضافة المشكلة بنجاح ✓',
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  fontSize: 16,
                );
                
                // إعادة تعيين الحالة قبل الرجوع
                context.read<CustomerCubit>().resetProblemAddedFlag();
                Navigator.pop(context, true); // إرجاع true للإشارة إلى نجاح الإضافة
              } else if (state.status == CustomerStatus.failure) {
                setState(() => _isSaving = false);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage ?? 'فشل الحفظ'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            }
          },
          child: Column(
            children: [
              // Header مع أيقونة إضافة عميل
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
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios,
                              color: Colors.white, size: 22),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40.h,
                      left: 10.w,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF28B5E1), Color(0xFF20AAC9)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: primaryBtnColor.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: _showAddCustomerBottomSheet,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.person_add_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'عميل جديد',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
                        _buildLabelledRow(
                          label: "عنوان المشكلة:",
                          child: _buildTextField(
                            controller: _addressController,
                            hint: "",
                          ),
                        ),
                        SizedBox(height: 16.h),
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
                                      leading: CircleAvatar(
                                        backgroundColor: primaryBtnColor,
                                        radius: 18,
                                        child: Text(
                                          eng.name.isNotEmpty
                                              ? eng.name[0].toUpperCase()
                                              : '',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      title: Text(eng.name,
                                          style: const TextStyle(fontSize: 14)),
                                      onTap: () {
                                        setState(() {
                                          _selectedEngineer = eng;
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
                        Container(
                          width: 160.w,
                          height: 50.h,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF28B5E1), Color(0xFF20AAC9)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: primaryBtnColor.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveProblem,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : Text(
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

// نموذج إضافة العميل (بدون تغيير - نفس الكود السابق)
class _AddCustomerBottomSheet extends StatefulWidget {
  final VoidCallback onCustomerAdded;

  const _AddCustomerBottomSheet({required this.onCustomerAdded});

  @override
  State<_AddCustomerBottomSheet> createState() =>
      _AddCustomerBottomSheetState();
}

class _AddCustomerBottomSheetState extends State<_AddCustomerBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _engineerController = TextEditingController();
  final _productController = TextEditingController();

  bool _showEngineerDropdown = false;
  bool _showProductDropdown = false;
  String? _selectedEngineerId;
  String? _selectedProductId;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _engineerController.dispose();
    _productController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.pop(context);
          widget.onCustomerAdded();
        }
      });
    }
  }

  Widget _buildLabelledRow({required String label, required Widget child}) {
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

  Widget _boxedText(
    TextEditingController controller, {
    TextInputType? type,
  }) {
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
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'هذا الحقل مطلوب';
          }
          return null;
        },
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
                _engineerController.text.isEmpty
                    ? 'اختر المهندس'
                    : _engineerController.text,
                style: TextStyle(
                  color: _engineerController.text.isEmpty
                      ? Colors.white70
                      : Colors.white,
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
                _productController.text.isEmpty
                    ? 'اختر التخصص'
                    : _productController.text,
                style: TextStyle(
                  color: _productController.text.isEmpty
                      ? Colors.white70
                      : Colors.white,
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

  Widget _saveButton({required VoidCallback onPressed}) {
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
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'إضافة عميل جديد',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF104084),
                  ),
                ),
                SizedBox(height: 24.h),
                _buildLabelledRow(
                  label: 'اسم العميل',
                  child: _boxedText(_nameController),
                ),
                _buildLabelledRow(
                  label: 'رقم التواصل',
                  child: _boxedText(_phoneController, type: TextInputType.phone),
                ),
                _buildLabelledRow(
                  label: 'الموقع',
                  child: _boxedText(_locationController),
                ),
                _buildLabelledRow(
                  label: 'المهندس',
                  child: _engineerDropdown(),
                ),
                if (_showEngineerDropdown)
                  Container(
                    height: 200.h,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: BlocBuilder<EngineerCubit, EngineerState>(
                      builder: (context, state) {
                        if (state.status == EngineerStatus.loading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (state.status == EngineerStatus.success) {
                          return ListView.builder(
                            itemCount: state.engineers.length,
                            itemBuilder: (context, index) {
                              final engineer = state.engineers[index];
                              return ListTile(
                                title: Text(engineer.name),
                                onTap: () {
                                  setState(() {
                                    _engineerController.text = engineer.name;
                                    _selectedEngineerId = engineer.id;
                                    _showEngineerDropdown = false;
                                  });
                                },
                              );
                            },
                          );
                        } else {
                          return const Center(
                              child: Text('خطأ في تحميل المهندسين'));
                        }
                      },
                    ),
                  ),
                _buildLabelledRow(
                  label: 'التخصص',
                  child: _productDropdown(),
                ),
                if (_showProductDropdown)
                  Container(
                    height: 200.h,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: BlocBuilder<CustomerCubit, CustomerState>(
                      builder: (context, state) {
                        if (state.status == CustomerStatus.loading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (state.problemCategories.isNotEmpty) {
                          return ListView.builder(
                            itemCount: state.problemCategories.length,
                            itemBuilder: (context, index) {
                              final product = state.problemCategories[index];
                              return ListTile(
                                title: Text(product.name),
                                onTap: () {
                                  setState(() {
                                    _productController.text = product.name;
                                    _selectedProductId = product.id;
                                    _showProductDropdown = false;
                                  });
                                },
                              );
                            },
                          );
                        } else {
                          return const Center(
                              child: Text('خطأ في تحميل المنتجات'));
                        }
                      },
                    ),
                  ),
                SizedBox(height: 16.h),
                _saveButton(onPressed: _onSave),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
