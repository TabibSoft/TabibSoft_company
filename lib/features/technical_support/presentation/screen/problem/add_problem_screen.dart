import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';
import 'package:tabib_soft_company/features/programmers/data/model/engineer_model.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/engineer_cubit.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/engineer_state.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/addCustomer/add_customer_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/support_customer_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/problem_status/problem_category_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/problem_status/problem_status_model.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/add_customer/add_cusomer_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/add_customer/add_customer_state.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/add_customer/product_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/add_customer/product_state.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/customer_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/customer_state.dart';

class AddProblemScreen extends StatefulWidget {
  const AddProblemScreen({super.key});

  @override
  State<AddProblemScreen> createState() => _AddProblemScreenState();
}

class _AddProblemScreenState extends State<AddProblemScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController clientNameController = TextEditingController();
  final TextEditingController problemTypeController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController problemTitleController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  final TextEditingController engineerController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  CustomerModel? selectedCustomer;
  ProblemCategoryModel? selectedCategory;
  ProblemStatusModel? selectedStatus;
  EngineerModel? selectedEngineer;

  final List<File> images = [];
  bool isUrgent = false;
  bool isClientDropdownVisible = false;
  bool isTypeDropdownVisible = false;
  bool isEngineerDropdownVisible = false;
  bool isSaving = false;

  String problemTypeSearchQuery = '';
  String engineerSearchQuery = '';

  // Local lists for client-side filtering
  List<CustomerModel> _allCustomers = [];
  List<CustomerModel> _filteredCustomers = [];
  bool _isCustomersLoaded = false;

  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _animationController, curve: Curves.easeOutCubic));
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerCubit>().resetProblemAddedFlag();
      context.read<CustomerCubit>().fetchCustomers();
      context.read<CustomerCubit>().fetchProblemCategories();
      context.read<CustomerCubit>().fetchProblemStatus();
      context.read<EngineerCubit>().fetchEngineers();
    });
  }

  @override
  void dispose() {
    clientNameController.dispose();
    problemTypeController.dispose();
    phoneController.dispose();
    problemTitleController.dispose();
    detailsController.dispose();
    engineerController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  bool validatePhoneNumber(String phone) {
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.length != 11) {
      Fluttertoast.showToast(
          msg: 'رقم الهاتف يجب أن يكون 11 رقم',
          backgroundColor: TechColors.errorRed);
      return false;
    }
    if (!cleanPhone.startsWith('01')) {
      Fluttertoast.showToast(
          msg: 'رقم الهاتف يجب أن يبدأ بـ 01',
          backgroundColor: TechColors.errorRed);
      return false;
    }
    return true;
  }

  Future<void> pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('ar'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: TechColors.accentCyan,
              onPrimary: Colors.white,
              onSurface: TechColors.primaryDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await showModalBottomSheet<XFile?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildImagePickerBottomSheet(picker),
    );

    if (pickedFile != null) {
      setState(() {
        images.add(File(pickedFile.path));
      });
    }
  }

  Widget _buildImagePickerBottomSheet(ImagePicker picker) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: TechColors.surfaceLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'اختر المصدر',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: TechColors.primaryDark,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPickerOption(
                icon: Icons.camera_alt_rounded,
                label: 'الكاميرا',
                color: TechColors.accentCyan,
                onTap: () async => Navigator.pop(context,
                    await picker.pickImage(source: ImageSource.camera)),
              ),
              _buildPickerOption(
                icon: Icons.photo_library_rounded,
                label: 'المعرض',
                color: TechColors.primaryMid,
                onTap: () async => Navigator.pop(context,
                    await picker.pickImage(source: ImageSource.gallery)),
              ),
            ],
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(File imageFile, int index) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.95),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.file(
                  imageFile,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 40.h,
              right: 20.w,
              child: _buildCircleBtn(
                icon: Icons.close,
                color: Colors.white.withOpacity(0.2),
                onTap: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              bottom: 40.h,
              left: 0,
              right: 0,
              child: Center(
                child: _buildCircleBtn(
                  icon: Icons.delete_outline_rounded,
                  color: TechColors.errorRed.withOpacity(0.8),
                  size: 60.r,
                  onTap: () {
                    setState(() {
                      images.removeAt(index);
                    });
                    Navigator.pop(context);
                    Fluttertoast.showToast(
                        msg: 'تم حذف الصورة',
                        backgroundColor: TechColors.errorRed);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    double? size,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size ?? 45.r,
        height: size ?? 45.r,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: (size ?? 45.r) * 0.5),
      ),
    );
  }

  void saveProblem() {
    if (phoneController.text.isNotEmpty &&
        !validatePhoneNumber(phoneController.text)) {
      return;
    }

    if (selectedCustomer == null ||
        selectedCategory == null ||
        selectedEngineer == null ||
        problemTitleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('يرجى ملء جميع الحقول المطلوبة'),
          backgroundColor: TechColors.errorRed,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final customerState = context.read<CustomerCubit>().state;
    final statusId = selectedStatus?.id ??
        customerState.problemStatusList
            .firstWhere(
              (s) => s.name.toLowerCase().contains('جديد'),
              orElse: () => customerState.problemStatusList.first,
            )
            .id;

    setState(() {
      isSaving = true;
    });

    context.read<CustomerCubit>().createProblem(
          customerId: selectedCustomer!.id!,
          dateTime: selectedDate,
          problemStatusId: statusId,
          problemCategoryId: selectedCategory!.id,
          problemAddress: problemTitleController.text.trim(),
          note: detailsController.text.trim(),
          details: detailsController.text.trim(),
          phone: phoneController.text.isNotEmpty
              ? phoneController.text.trim()
              : null,
          engineerId: selectedEngineer!.id,
          isUrgent: isUrgent,
          images: images.isNotEmpty ? images : null,
        );
  }

  void showAddCustomerBottomSheet() {
    setState(() {
      isClientDropdownVisible = false;
      isTypeDropdownVisible = false;
      isEngineerDropdownVisible = false;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddCustomerBottomSheet(
        onCustomerAdded: () {
          context.read<CustomerCubit>().fetchCustomers();
          Fluttertoast.showToast(
            msg: 'تم إضافة العميل بنجاح',
            backgroundColor: TechColors.successGreen,
            textColor: Colors.white,
            fontSize: 16,
          );
        },
      ),
    );
  }

  void _filterCustomers(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredCustomers = List.from(_allCustomers);
      });
    } else {
      setState(() {
        _filteredCustomers = _allCustomers
            .where((customer) =>
                (customer.name?.toLowerCase() ?? '')
                    .contains(query.toLowerCase()) ||
                (customer.phone?.toLowerCase() ?? '')
                    .contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: TechColors.surfaceLight,
        body: MultiBlocListener(
          listeners: [
            BlocListener<CustomerCubit, CustomerState>(
              listener: (context, state) {
                if (state.status == CustomerStatus.success &&
                    state.customers.isNotEmpty &&
                    !_isCustomersLoaded) {
                  setState(() {
                    _allCustomers = List.from(state.customers);
                    _filteredCustomers = List.from(state.customers);
                    _isCustomersLoaded = true;
                  });
                }

                if (isSaving) {
                  if (state.isProblemAdded) {
                    setState(() => isSaving = false);
                    Fluttertoast.showToast(
                        msg: 'تم إضافة المشكلة بنجاح',
                        backgroundColor: TechColors.successGreen);
                    context.read<CustomerCubit>().resetProblemAddedFlag();
                    Navigator.pop(context, true);
                  } else if (state.status == CustomerStatus.failure) {
                    setState(() => isSaving = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(state.errorMessage ?? 'حدث خطأ'),
                          backgroundColor: TechColors.errorRed),
                    );
                  }
                }
              },
            ),
          ],
          child: Stack(
            children: [
              // Premium Header Background
              Container(
                height: 200.h,
                decoration: const BoxDecoration(
                  gradient: TechColors.premiumGradient,
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    // AppBar
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCircleBtn(
                            icon: Icons.arrow_back_ios_rounded,
                            color: Colors.white.withOpacity(0.2),
                            onTap: () => Navigator.of(context).pop(),
                          ),
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              'إضافة مشكلة',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildAddCustomerButton(),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),

                    // Body
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: TechColors.surfaceLight,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30.r),
                            topRight: Radius.circular(30.r),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: TechColors.primaryDark.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, -5),
                            )
                          ],
                        ),
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(24.r),
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildClientSection(),
                                SizedBox(height: 16.h),
                                _buildInfoField(
                                  label: 'رقم التواصل',
                                  controller: phoneController,
                                  icon: Icons.phone_rounded,
                                  isNumeric: true,
                                ),
                                SizedBox(height: 16.h),
                                _buildDateSection(),
                                SizedBox(height: 16.h),
                                _buildProblemTypeSection(),
                                SizedBox(height: 16.h),
                                _buildInfoField(
                                  label: 'عنوان المشكلة',
                                  controller: problemTitleController,
                                  icon: Icons.title_rounded,
                                ),
                                SizedBox(height: 16.h),
                                _buildInfoField(
                                  label: 'التفاصيل',
                                  controller: detailsController,
                                  icon: Icons.description_outlined,
                                  maxLines: 4,
                                ),
                                SizedBox(height: 16.h),
                                _buildEngineerSection(),
                                SizedBox(height: 24.h),
                                _buildAttachmentsSection(),
                                SizedBox(height: 32.h),
                                _buildSaveButton(),
                                SizedBox(height: 32.h),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddCustomerButton() {
    return GestureDetector(
      onTap: showAddCustomerBottomSheet,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.person_add_rounded, color: Colors.white, size: 16.sp),
            SizedBox(width: 6.w),
            Text('عميل جديد',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    bool isNumeric = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
                color: TechColors.primaryDark)),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)
            ],
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: isNumeric ? TextInputType.phone : TextInputType.text,
            inputFormatters: isNumeric
                ? [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ]
                : [],
            style: TextStyle(fontSize: 14.sp, color: TechColors.primaryDark),
            decoration: InputDecoration(
              hintText: 'أدخل $label...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13.sp),
              prefixIcon: Icon(icon, color: TechColors.accentCyan),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClientSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('اسم العميل',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
                color: TechColors.primaryDark)),
        SizedBox(height: 8.h),
        buildAutocompleteDropdown(
          controller: clientNameController,
          hint: 'ابحث عن عميل...',
          isVisible: isClientDropdownVisible,
          onTap: () {
            setState(() {
              isClientDropdownVisible = !isClientDropdownVisible;
            });
          },
          onChanged: (val) {
            _filterCustomers(val);
            setState(() => isClientDropdownVisible = true);
          },
          child: _filteredCustomers.isEmpty
              ? Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Center(
                      child: Text("لا توجد نتائج",
                          style: TextStyle(color: Colors.grey[600]))),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: _filteredCustomers.length,
                  padding: EdgeInsets.zero,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final customer = _filteredCustomers[index];
                    return ListTile(
                      dense: true,
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(customer.name ?? '',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp)),
                          ),
                          if (customer.proudctName != null &&
                              customer.proudctName!.isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: TechColors.accentCyan.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                customer.proudctName!,
                                style: TextStyle(
                                    fontSize: 11.sp,
                                    color: TechColors.accentCyan,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Text(customer.phone ?? '',
                          style: TextStyle(color: Colors.grey[600])),
                      onTap: () {
                        setState(() {
                          selectedCustomer = customer;
                          clientNameController.text = customer.name ?? '';
                          phoneController.text = customer.phone ?? '';
                          isClientDropdownVisible = false;
                        });
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('التاريخ',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
                color: TechColors.primaryDark)),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: pickDate,
          child: Container(
            height: 52.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatDate(selectedDate),
                  style: TextStyle(
                    color: TechColors.primaryDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
                Icon(Icons.calendar_today_rounded,
                    color: TechColors.accentCyan, size: 20.sp),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProblemTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('نوع المشكلة',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
                color: TechColors.primaryDark)),
        SizedBox(height: 8.h),
        buildAutocompleteDropdown(
          controller: problemTypeController,
          hint: 'اختر نوع المشكلة',
          isVisible: isTypeDropdownVisible,
          onTap: () {
            setState(() {
              isTypeDropdownVisible = !isTypeDropdownVisible;
            });
          },
          onChanged: (val) {
            setState(() {
              problemTypeSearchQuery = val;
              isTypeDropdownVisible = true;
            });
          },
          child: BlocBuilder<CustomerCubit, CustomerState>(
            builder: (context, state) {
              final filtered = problemTypeSearchQuery.isEmpty
                  ? state.problemCategories
                  : state.problemCategories
                      .where((e) => e.name
                          .toLowerCase()
                          .contains(problemTypeSearchQuery.toLowerCase()))
                      .toList();

              if (filtered.isEmpty) {
                return const Center(
                    child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text("لا توجد نتائج")));
              }
              return ListView.separated(
                shrinkWrap: true,
                itemCount: filtered.length,
                padding: EdgeInsets.zero,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final cat = filtered[index];
                  return ListTile(
                    dense: true,
                    title: Text(cat.name, style: TextStyle(fontSize: 14.sp)),
                    onTap: () {
                      setState(() {
                        selectedCategory = cat;
                        problemTypeController.text = cat.name;
                        problemTypeSearchQuery = '';
                        isTypeDropdownVisible = false;
                      });
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEngineerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('تعيين مهندس',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
                color: TechColors.primaryDark)),
        SizedBox(height: 8.h),
        buildAutocompleteDropdown(
          controller: engineerController,
          hint: 'اختر المهندس',
          isVisible: isEngineerDropdownVisible,
          onTap: () {
            setState(() {
              isEngineerDropdownVisible = !isEngineerDropdownVisible;
              if (isEngineerDropdownVisible) {
                context.read<EngineerCubit>().fetchEngineers();
              }
            });
          },
          onChanged: (val) {
            setState(() {
              engineerSearchQuery = val;
              isEngineerDropdownVisible = true;
            });
          },
          child: BlocBuilder<EngineerCubit, EngineerState>(
            builder: (context, state) {
              if (state.status == EngineerStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              final filtered = engineerSearchQuery.isEmpty
                  ? state.engineers
                  : state.engineers
                      .where((e) => e.name
                          .toLowerCase()
                          .contains(engineerSearchQuery.toLowerCase()))
                      .toList();

              if (filtered.isEmpty) {
                return const Center(
                    child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text("لا توجد نتائج")));
              }

              return ListView.separated(
                shrinkWrap: true,
                itemCount: filtered.length,
                padding: EdgeInsets.zero,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final eng = filtered[index];
                  return ListTile(
                    dense: true,
                    title: Text(eng.name, style: TextStyle(fontSize: 14.sp)),
                    leading: CircleAvatar(
                      radius: 16.r,
                      backgroundColor: TechColors.accentCyan,
                      child: Text(
                          eng.name.isNotEmpty ? eng.name[0].toUpperCase() : '',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold)),
                    ),
                    onTap: () {
                      setState(() {
                        selectedEngineer = eng;
                        engineerController.text = eng.name;
                        engineerSearchQuery = '';
                        isEngineerDropdownVisible = false;
                      });
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentsSection() {
    return Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: pickImage,
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                            color: TechColors.surfaceLight,
                            borderRadius: BorderRadius.circular(10.r)),
                        child: Icon(Icons.cloud_upload_rounded,
                            color: TechColors.accentCyan, size: 24.sp),
                      ),
                      SizedBox(width: 8.w),
                      Text('المرفقات (${images.length})',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13.sp)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text('عاجل',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                            color: isUrgent
                                ? TechColors.errorRed
                                : Colors.grey[600])),
                    Switch(
                      value: isUrgent,
                      activeThumbColor: TechColors.errorRed,
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey[200],
                      onChanged: (v) => setState(() => isUrgent = v),
                    ),
                  ],
                ),
              ],
            ),
            if (images.isNotEmpty) ...[
              SizedBox(height: 16.h),
              SizedBox(
                height: 70.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  separatorBuilder: (_, __) => SizedBox(width: 8.w),
                  itemBuilder: (ctx, idx) => GestureDetector(
                    onTap: () => _showFullScreenImage(images[idx], idx),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.file(images[idx],
                          width: 70.h, height: 70.h, fit: BoxFit.cover),
                    ),
                  ),
                ),
              )
            ]
          ],
        ));
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 54.h,
      decoration: BoxDecoration(
        gradient: TechColors.premiumGradient,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: TechColors.accentCyan.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isSaving ? null : saveProblem,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        ),
        child: isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.save_rounded, color: Colors.white),
                  SizedBox(width: 8.w),
                  Text('حفظ المشكلة',
                      style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ],
              ),
      ),
    );
  }

  Widget buildAutocompleteDropdown({
    required TextEditingController controller,
    required String hint,
    required bool isVisible,
    required VoidCallback onTap,
    Function(String)? onChanged,
    required Widget child,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            height: 52.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                  color:
                      isVisible ? TechColors.accentCyan : Colors.grey.shade300),
              boxShadow: isVisible
                  ? [
                      BoxShadow(
                          color: TechColors.accentCyan.withOpacity(0.1),
                          blurRadius: 8)
                    ]
                  : [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.02), blurRadius: 5)
                    ],
            ),
            child: Row(children: [
              Expanded(
                  child: TextField(
                controller: controller,
                onTap: onTap,
                onChanged: onChanged,
                style:
                    TextStyle(fontSize: 14.sp, color: TechColors.primaryDark),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle:
                      TextStyle(color: Colors.grey[400], fontSize: 13.sp),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                ),
              )),
              IconButton(
                icon: Icon(
                    isVisible
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 24.sp),
                onPressed: onTap,
                color: TechColors.accentCyan,
              )
            ])),
        if (isVisible)
          Container(
            height: 200.h,
            margin: EdgeInsets.only(top: 8.h),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1), blurRadius: 10)
                ],
                border: Border.all(color: Colors.grey.shade200)),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r), child: child),
          )
      ],
    );
  }
}

// =======================
// ADD CUSTOMER BOTTOM SHEET
// =======================
class AddCustomerBottomSheet extends StatefulWidget {
  final VoidCallback onCustomerAdded;
  const AddCustomerBottomSheet({super.key, required this.onCustomerAdded});

  @override
  State<AddCustomerBottomSheet> createState() => _AddCustomerBottomSheetState();
}

class _AddCustomerBottomSheetState extends State<AddCustomerBottomSheet>
    with SingleTickerProviderStateMixin {
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

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();

    context.read<EngineerCubit>().fetchEngineers();
    context.read<ProductCubit>().fetchProducts();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _engineerController.dispose();
    _productController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      if (_phoneController.text.length != 11 ||
          !_phoneController.text.startsWith('01')) {
        Fluttertoast.showToast(
            msg: 'رقم الهاتف غير صحيح', backgroundColor: TechColors.errorRed);
        return;
      }

      final customer = AddCustomerModel(
        name: _nameController.text.trim(),
        telephone: _phoneController.text.trim(),
        engineerId: _selectedEngineerId ?? '',
        productId: _selectedProductId ?? '',
        location: _locationController.text.isNotEmpty
            ? _locationController.text.trim()
            : null,
        createdDate: DateTime.now(),
      );
      context.read<AddCustomerCubit>().addCustomer(customer);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddCustomerCubit, AddCustomerState>(
      listener: (context, state) {
        if (state.status == AddCustomerStatus.success) {
          Navigator.pop(context);
          widget.onCustomerAdded();
        } else if (state.status == AddCustomerStatus.failure) {
          Fluttertoast.showToast(
              msg: state.errorMessage ?? 'error',
              backgroundColor: TechColors.errorRed);
        }
      },
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          boxShadow: [
            BoxShadow(
              color: TechColors.primaryDark.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 45.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            // Header
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 16.h),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              TechColors.accentCyan,
                              TechColors.primaryMid
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: TechColors.accentCyan.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.person_add_rounded,
                          color: Colors.white,
                          size: 26.r,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إضافة عميل جديد',
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w800,
                                color: TechColors.primaryDark,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'أدخل بيانات العميل الجديد',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          padding: EdgeInsets.all(8.r),
                        ),
                        icon: Icon(
                          Icons.close_rounded,
                          color: Colors.grey[600],
                          size: 22.r,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Divider(height: 1, color: Colors.grey[200]),
            // Form content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
                  left: 24.w,
                  right: 24.w,
                  top: 20.h,
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name Field
                          _buildSectionLabel('معلومات العميل'),
                          SizedBox(height: 12.h),
                          _buildModernField(
                            label: 'اسم العميل',
                            controller: _nameController,
                            icon: Icons.person_rounded,
                            hint: 'أدخل اسم العميل',
                          ),
                          SizedBox(height: 16.h),
                          _buildModernField(
                            label: 'رقم الهاتف',
                            controller: _phoneController,
                            icon: Icons.phone_rounded,
                            hint: '01xxxxxxxxx',
                            isPhone: true,
                          ),
                          SizedBox(height: 16.h),
                          _buildModernField(
                            label: 'العنوان',
                            controller: _locationController,
                            icon: Icons.location_on_rounded,
                            hint: 'أدخل العنوان',
                            isOptional: true,
                          ),
                          SizedBox(height: 24.h),

                          // Assignment Section
                          _buildSectionLabel('التعيينات'),
                          SizedBox(height: 12.h),

                          // Engineer Dropdown
                          _buildModernDropdown(
                            label: 'المهندس المسؤول',
                            controller: _engineerController,
                            icon: Icons.engineering_rounded,
                            isVisible: _showEngineerDropdown,
                            onTap: () => setState(() {
                              _showEngineerDropdown = !_showEngineerDropdown;
                              _showProductDropdown = false;
                            }),
                            child: BlocBuilder<EngineerCubit, EngineerState>(
                              builder: (context, state) {
                                if (state.engineers.isEmpty) {
                                  return Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20.r),
                                      child: Text(
                                        'لا يوجد مهندسين',
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                  itemCount: state.engineers.length,
                                  itemBuilder: (context, index) {
                                    final eng = state.engineers[index];
                                    final isSelected =
                                        _selectedEngineerId == eng.id;
                                    return _buildDropdownItem(
                                      title: eng.name,
                                      subtitle: eng.telephone,
                                      icon: Icons.engineering_rounded,
                                      isSelected: isSelected,
                                      onTap: () {
                                        setState(() {
                                          _selectedEngineerId = eng.id;
                                          _engineerController.text = eng.name;
                                          _showEngineerDropdown = false;
                                        });
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 16.h),

                          // Product Dropdown
                          _buildModernDropdown(
                            label: 'التخصص',
                            controller: _productController,
                            icon: Icons.inventory_2_rounded,
                            isVisible: _showProductDropdown,
                            onTap: () => setState(() {
                              _showProductDropdown = !_showProductDropdown;
                              _showEngineerDropdown = false;
                            }),
                            child: BlocBuilder<ProductCubit, ProductState>(
                              builder: (context, state) {
                                if (state.products.isEmpty) {
                                  return Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20.r),
                                      child: Text(
                                        'لا يوجد منتجات',
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                  itemCount: state.products.length,
                                  itemBuilder: (context, index) {
                                    final prod = state.products[index];
                                    final isSelected = _selectedProductId ==
                                        prod.id.toString();
                                    return _buildDropdownItem(
                                      title: prod.name,
                                      icon: Icons.inventory_2_rounded,
                                      isSelected: isSelected,
                                      onTap: () {
                                        setState(() {
                                          _selectedProductId =
                                              prod.id.toString();
                                          _productController.text = prod.name;
                                          _showProductDropdown = false;
                                        });
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 32.h),

                          // Save Button
                          BlocBuilder<AddCustomerCubit, AddCustomerState>(
                            builder: (context, state) {
                              final isLoading =
                                  state.status == AddCustomerStatus.loading;
                              return Container(
                                width: double.infinity,
                                height: 56.h,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      TechColors.accentCyan,
                                      TechColors.primaryMid
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: TechColors.accentCyan
                                          .withOpacity(0.4),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16.r),
                                    onTap: isLoading ? null : _onSave,
                                    child: Center(
                                      child: isLoading
                                          ? SizedBox(
                                              width: 24.r,
                                              height: 24.r,
                                              child:
                                                  const CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                valueColor:
                                                    AlwaysStoppedAnimation(
                                                        Colors.white),
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.check_circle_rounded,
                                                  color: Colors.white,
                                                  size: 22.r,
                                                ),
                                                SizedBox(width: 10.w),
                                                Text(
                                                  'حفظ العميل',
                                                  style: TextStyle(
                                                    fontSize: 17.sp,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 16.h),
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
    );
  }

  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 20.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [TechColors.accentCyan, TechColors.primaryMid],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 10.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: TechColors.primaryDark,
          ),
        ),
      ],
    );
  }

  Widget _buildModernField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isPhone = false,
    bool isOptional = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: TechColors.surfaceLight,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        inputFormatters: isPhone
            ? [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11)
              ]
            : null,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: TechColors.primaryDark,
        ),
        validator: (v) => v!.isEmpty && !isOptional ? 'هذا الحقل مطلوب' : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey[400],
          ),
          prefixIcon: Container(
            margin: EdgeInsets.all(12.r),
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: TechColors.accentCyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: TechColors.accentCyan, size: 20.r),
          ),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          errorStyle: TextStyle(fontSize: 11.sp),
        ),
      ),
    );
  }

  Widget _buildModernDropdown({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isVisible,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: TechColors.surfaceLight,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isVisible ? TechColors.accentCyan : Colors.grey.shade200,
                width: isVisible ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: TechColors.accentCyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, color: TechColors.accentCyan, size: 20.r),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        controller.text.isEmpty ? 'اختر...' : controller.text,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: controller.text.isEmpty
                              ? Colors.grey[400]
                              : TechColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: isVisible ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: isVisible
                          ? TechColors.accentCyan.withOpacity(0.1)
                          : Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color:
                          isVisible ? TechColors.accentCyan : Colors.grey[500],
                      size: 20.r,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: isVisible
              ? Container(
                  height: 180.h,
                  margin: EdgeInsets.only(top: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: TechColors.primaryDark.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: child,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildDropdownItem({
    required String title,
    String? subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected
          ? TechColors.accentCyan.withOpacity(0.08)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: isSelected
                      ? TechColors.accentCyan.withOpacity(0.15)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? TechColors.accentCyan : Colors.grey[500],
                  size: 18.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected
                            ? TechColors.accentCyan
                            : TechColors.primaryDark,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: const BoxDecoration(
                    color: TechColors.accentCyan,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 14.r,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
