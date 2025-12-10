import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
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

  void _showFullScreenImage(File imageFile, int index) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
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
    // ✅ التحقق من رقم الهاتف إذا كان موجوداً
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

                        // ====== رقم التواصل (محدود 11 رقم — أرقام فقط) ======
                        buildLabelledRow(
                          label: 'رقم التواصل',
                          child: buildTextField(
                            controller: phoneController,
                            enabled: true,
                            hint: '01XXXXXXXXX',
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                            maxLength: 11,
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
                                  activeTrackColor: Colors.red,
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

  /// Updated helper: supports inputFormatters and maxLength
  Widget buildTextField({
    required TextEditingController controller,
    bool enabled = true,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
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
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          counterText: '', // hide built-in counter to keep UI clean
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

// AddCustomerBottomSheet

class AddCustomerBottomSheet extends StatefulWidget {
  final VoidCallback onCustomerAdded;

  const AddCustomerBottomSheet({super.key, required this.onCustomerAdded});

  @override
  State<AddCustomerBottomSheet> createState() => _AddCustomerBottomSheetState();
}

class _AddCustomerBottomSheetState extends State<AddCustomerBottomSheet> {
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

  @override
  void initState() {
    super.initState();
    context.read<EngineerCubit>().fetchEngineers();
    context.read<ProductCubit>().fetchProducts();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _engineerController.dispose();
    _productController.dispose();
    super.dispose();
  }

  // ✅ دالة التحقق من صحة رقم الهاتف
  bool validatePhoneNumber(String phone) {
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');

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
      if (!validatePhoneNumber(_phoneController.text)) {
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

  /// تم تعديل boxedText ليأخذ inputFormatters و maxLength اختياريًا
  Widget boxedText(
    TextEditingController controller, {
    TextInputType? type,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    String? hint,
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
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          counterText: '', // لإخفاء عداد الطول
        ),
        validator: (value) =>
            (value == null || value.trim().isEmpty) ? 'مطلوب' : null,
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
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
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
    return BlocListener<AddCustomerCubit, AddCustomerState>(
      listener: (context, state) {
        if (state.status == AddCustomerStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إضافة العميل بنجاح')),
          );
          Navigator.pop(context);
          widget.onCustomerAdded();
        } else if (state.status == AddCustomerStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'حدث خطأ أثناء الإضافة'),
            ),
          );
        }
      },
      child: Container(
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

                  buildLabelledRow(
                    label: 'اسم العميل',
                    child: boxedText(_nameController),
                  ),

                  // here: phone field limited to digits only and max 11
                  buildLabelledRow(
                    label: 'رقم التواصل',
                    child: boxedText(
                      _phoneController,
                      type: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                      maxLength: 11,
                      hint: '01XXXXXXXXX',
                    ),
                  ),

                  buildLabelledRow(
                    label: 'الموقع',
                    child: boxedText(_locationController),
                  ),

                  buildLabelledRow(
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

                  buildLabelledRow(
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
                      child: BlocBuilder<ProductCubit, ProductState>(
                        builder: (context, state) {
                          if (state.status == ProductStatus.loading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (state.status == ProductStatus.success) {
                            return ListView.builder(
                              itemCount: state.products.length,
                              itemBuilder: (context, index) {
                                final product = state.products[index];
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
                                child: Text('خطأ في تحميل التخصصات'));
                          }
                        },
                      ),
                    ),

                  SizedBox(height: 16.h),

                  BlocBuilder<AddCustomerCubit, AddCustomerState>(
                    builder: (context, state) {
                      final isLoading =
                          state.status == AddCustomerStatus.loading;

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
                          onPressed: isLoading ? null : _onSave,
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
                    },
                  ),

                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
