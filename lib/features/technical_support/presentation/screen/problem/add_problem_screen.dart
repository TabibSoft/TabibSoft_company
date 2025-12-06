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
  final TextEditingController clientNameController = TextEditingController();
  final TextEditingController problemTypeController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController problemTitleController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  final TextEditingController engineerController = TextEditingController();

  static const Color headerColor = Color(0xFF0B4C99);
  static const Color fieldColor = Color(0xFF104084);
  static const Color primaryBtnColor = Color(0xFF28B5E1);
  static const Color backgroundColor = Color(0xFFF5F6FA);

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerCubit>().resetProblemAddedFlag();
      context.read<CustomerCubit>().fetchCustomers();
      context.read<CustomerCubit>().fetchProblemCategories();
      context.read<CustomerCubit>().fetchProblemStatus();
      context.read<EngineerCubit>().fetchEngineers();
    });

    clientNameController.addListener(onClientNameChanged);
  }

  void onClientNameChanged() {
    final query = clientNameController.text;
    if (query.isNotEmpty) {
      context.read<CustomerCubit>().searchCustomers(query);
      setState(() {
        isClientDropdownVisible = true;
      });
    } else {
      setState(() {
        isClientDropdownVisible = false;
        selectedCustomer = null;
      });
    }
  }

  @override
  void dispose() {
    clientNameController.removeListener(onClientNameChanged);
    clientNameController.dispose();
    problemTypeController.dispose();
    phoneController.dispose();
    problemTitleController.dispose();
    detailsController.dispose();
    engineerController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await showModalBottomSheet<XFile?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
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
              title: const Text(
                'الكاميرا',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () async {
                Navigator.pop(context,
                    await picker.pickImage(source: ImageSource.camera));
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
              title: const Text(
                'المعرض',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
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
      setState(() {
        images.add(File(pickedFile.path));
      });
    }
  }

  // دالة عرض الصورة بشكل كامل
  void _showFullScreenImage(File imageFile, int index) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            // الصورة بالحجم الكامل
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
            // زر الإغلاق
            Positioned(
              top: 40,
              right: 20,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            // زر الحذف
            Positioned(
              top: 40,
              left: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white, size: 30),
                  onPressed: () {
                    setState(() {
                      images.removeAt(index);
                    });
                    Navigator.pop(context);
                    Fluttertoast.showToast(
                      msg: 'تم حذف الصورة',
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                    );
                  },
                ),
              ),
            ),
            // معلومات الصورة
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'صورة ${index + 1} من ${images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void saveProblem() {
    if (selectedCustomer == null ||
        selectedCategory == null ||
        selectedEngineer == null ||
        problemTitleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('يرجى ملء جميع الحقول المطلوبة'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          dateTime: DateTime.now(),
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
            if (isSaving) {
              if (state.isProblemAdded) {
                setState(() {
                  isSaving = false;
                });
                Fluttertoast.showToast(
                  msg: 'تم إضافة المشكلة بنجاح',
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  fontSize: 16,
                );
                context.read<CustomerCubit>().resetProblemAddedFlag();
                Navigator.pop(context, true);
              } else if (state.status == CustomerStatus.failure) {
                setState(() {
                  isSaving = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text(state.errorMessage ?? 'حدث خطأ أثناء الإضافة'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
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
                            color: Colors.white, size: 22),
                        onPressed: () => Navigator.of(context).pop(),
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
                            onTap: showAddCustomerBottomSheet,
                            child: const Padding(
                              padding: EdgeInsets.all(12),
                              child: Icon(Icons.person_add_rounded,
                                  color: Colors.white, size: 24),
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
                        buildLabelledRow(
                          label: 'اسم العميل',
                          child: buildAutocompleteDropdown(
                            controller: clientNameController,
                            hint: 'ابحث عن عميل',
                            isVisible: isClientDropdownVisible,
                            onTap: () {
                              setState(() {
                                isClientDropdownVisible =
                                    !isClientDropdownVisible;
                              });
                            },
                            child: BlocBuilder<CustomerCubit, CustomerState>(
                              builder: (context, state) {
                                if (state.customers.isEmpty) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(8),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                return ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  itemCount: state.customers.length,
                                  itemBuilder: (context, index) {
                                    final customer = state.customers[index];
                                    return ListTile(
                                      title: Text(
                                        customer.name ?? '',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      subtitle: Text(
                                        customer.phone?.toString() ?? '',
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          selectedCustomer = customer;
                                          clientNameController.text =
                                              customer.name ?? '';
                                          phoneController.text =
                                              customer.phone?.toString() ?? '';
                                          isClientDropdownVisible = false;
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
                        buildLabelledRow(
                          label: 'رقم التواصل',
                          child: buildTextField(
                            controller: phoneController,
                            enabled: true,
                            hint: 'رقم الهاتف',
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        buildLabelledRow(
                          label: 'نوع المشكلة',
                          child: buildAutocompleteDropdown(
                            controller: problemTypeController,
                            hint: 'اختر نوع المشكلة',
                            isVisible: isTypeDropdownVisible,
                            onTap: () {
                              setState(() {
                                isTypeDropdownVisible = !isTypeDropdownVisible;
                              });
                            },
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
                                          selectedCategory = cat;
                                          problemTypeController.text = cat.name;
                                          isTypeDropdownVisible = false;
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
                        buildLabelledRow(
                          label: 'عنوان المشكلة',
                          child: buildTextField(
                            controller: problemTitleController,
                            hint: 'عنوان المشكلة',
                          ),
                        ),
                        SizedBox(height: 16.h),
                        buildLabelledRow(
                          label: 'تفاصيل المشكلة',
                          child: SizedBox(
                            height: 100.h,
                            child: buildTextField(
                              controller: detailsController,
                              hint: 'اكتب التفاصيل',
                              maxLines: 5,
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        buildLabelledRow(
                          label: 'اسم المهندس',
                          child: buildAutocompleteDropdown(
                            controller: engineerController,
                            hint: 'اختر مهندس',
                            isVisible: isEngineerDropdownVisible,
                            onTap: () {
                              setState(() {
                                isEngineerDropdownVisible =
                                    !isEngineerDropdownVisible;
                              });
                            },
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
                                          selectedEngineer = eng;
                                          engineerController.text = eng.name;
                                          isEngineerDropdownVisible = false;
                                        });
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(width: 13.w),
                            GestureDetector(
                              onTap: pickImage,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'رفع صور',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp,
                                    ),
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
                                      if (images.isNotEmpty)
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                              size: 14,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'URGENT',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Switch(
                                  value: isUrgent,
                                  activeThumbColor: Colors.red,
                                  onChanged: (v) {
                                    setState(() {
                                      isUrgent = v;
                                    });
                                  },
                                ),
                              ],
                            ),
                            SizedBox(width: 13.w),
                          ],
                        ),
                        SizedBox(height: 30.h),
                        if (images.isNotEmpty) ...[
                          SizedBox(height: 10.h),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: images
                                .asMap()
                                .entries
                                .map(
                                  (entry) => GestureDetector(
                                    onTap: () => _showFullScreenImage(
                                        entry.value, entry.key),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.file(
                                            entry.value,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                images.removeAt(entry.key);
                                              });
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
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
                            onPressed: isSaving ? null : saveProblem,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: isSaving
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

  Widget buildLabelledRow({required String label, required Widget child}) {
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

  Widget buildTextField({
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

  Widget buildAutocompleteDropdown({
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

// AddCustomerBottomSheet - نفس الكود السابق
class AddCustomerBottomSheet extends StatefulWidget {
  final VoidCallback onCustomerAdded;

  const AddCustomerBottomSheet({super.key, required this.onCustomerAdded});

  @override
  State<AddCustomerBottomSheet> createState() => _AddCustomerBottomSheetState();
}

class _AddCustomerBottomSheetState extends State<AddCustomerBottomSheet> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();
  final engineerController = TextEditingController();
  final productController = TextEditingController();
  bool showEngineerDropdown = false;
  bool showProductDropdown = false;
  String? selectedEngineerId;
  String? selectedProductId;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    locationController.dispose();
    engineerController.dispose();
    productController.dispose();
    super.dispose();
  }

  void onSave() {
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          Navigator.pop(context);
          widget.onCustomerAdded();
        }
      });
    }
  }

  Widget buildLabelledRow({required String label, required Widget child}) {
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
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
        validator: (value) =>
            (value == null || value.trim().isEmpty) ? 'مطلوب' : null,
      ),
    );
  }

  Widget engineerDropdown() {
    return InkWell(
      onTap: () {
        setState(() {
          showEngineerDropdown = !showEngineerDropdown;
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
                engineerController.text.isEmpty
                    ? 'اختر مهندس'
                    : engineerController.text,
                style: TextStyle(
                  color: engineerController.text.isEmpty
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

  Widget productDropdown() {
    return InkWell(
      onTap: () {
        setState(() {
          showProductDropdown = !showProductDropdown;
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
                productController.text.isEmpty
                    ? 'اختر منتج'
                    : productController.text,
                style: TextStyle(
                  color: productController.text.isEmpty
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

  Widget saveButton({required VoidCallback onPressed}) {
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
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 3),
              )
            : Text(
                'حفظ',
                style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
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
            key: formKey,
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
                buildLabelledRow(
                    label: 'الاسم', child: boxedText(nameController)),
                buildLabelledRow(
                    label: 'رقم التواصل',
                    child:
                        boxedText(phoneController, type: TextInputType.phone)),
                buildLabelledRow(
                    label: 'العنوان', child: boxedText(locationController)),
                buildLabelledRow(label: 'المهندس', child: engineerDropdown()),
                if (showEngineerDropdown)
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
                        return state.status == EngineerStatus.success
                            ? ListView.builder(
                                itemCount: state.engineers.length,
                                itemBuilder: (context, i) {
                                  return ListTile(
                                    title: Text(state.engineers[i].name),
                                    onTap: () {
                                      setState(() {
                                        engineerController.text =
                                            state.engineers[i].name;
                                        selectedEngineerId =
                                            state.engineers[i].id;
                                        showEngineerDropdown = false;
                                      });
                                    },
                                  );
                                },
                              )
                            : const Center(child: Text('لا يوجد مهندسون'));
                      },
                    ),
                  ),
                buildLabelledRow(label: 'المنتج', child: productDropdown()),
                if (showProductDropdown)
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
                        return state.problemCategories.isNotEmpty
                            ? ListView.builder(
                                itemCount: state.problemCategories.length,
                                itemBuilder: (context, i) {
                                  return ListTile(
                                    title:
                                        Text(state.problemCategories[i].name),
                                    onTap: () {
                                      setState(() {
                                        productController.text =
                                            state.problemCategories[i].name;
                                        selectedProductId =
                                            state.problemCategories[i].id;
                                        showProductDropdown = false;
                                      });
                                    },
                                  );
                                },
                              )
                            : const Center(child: Text('لا توجد منتجات'));
                      },
                    ),
                  ),
                SizedBox(height: 16.h),
                saveButton(onPressed: onSave),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
