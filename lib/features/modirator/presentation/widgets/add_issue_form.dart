// lib/features/home/presentation/screens/add_issue_form.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
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
  final _clientNameController = TextEditingController();
  final _problemTypeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _problemTitleController = TextEditingController();
  final _detailsController = TextEditingController();
  final _engineerController = TextEditingController();

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

  // متغيرات البحث المحلي
  String problemTypeSearchQuery = '';
  String engineerSearchQuery = '';

  // تاريخ المشكلة (الافتراضي: تاريخ اليوم)
  DateTime selectedDate = DateTime.now();

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
    _clientNameController.addListener(_onClientNameChanged);
    _problemTypeController.addListener(_onProblemTypeChanged);
    _engineerController.addListener(_onEngineerChanged);
  }

  void _onClientNameChanged() {
    final query = _clientNameController.text;
    if (query.isNotEmpty) {
      context.read<CustomerCubit>().searchCustomers(query);
      setState(() => isClientDropdownVisible = true);
    } else {
      setState(() {
        isClientDropdownVisible = false;
        selectedCustomer = null;
      });
    }
  }

  void _onProblemTypeChanged() {
    setState(() {
      problemTypeSearchQuery = _problemTypeController.text;
      if (problemTypeSearchQuery.isNotEmpty) {
        isTypeDropdownVisible = true;
      }
    });
  }

  void _onEngineerChanged() {
    setState(() {
      engineerSearchQuery = _engineerController.text;
      if (engineerSearchQuery.isNotEmpty) {
        isEngineerDropdownVisible = true;
      }
    });
  }

  @override
  void dispose() {
    _clientNameController.removeListener(_onClientNameChanged);
    _problemTypeController.removeListener(_onProblemTypeChanged);
    _engineerController.removeListener(_onEngineerChanged);
    _clientNameController.dispose();
    _problemTypeController.dispose();
    _phoneController.dispose();
    _problemTitleController.dispose();
    _detailsController.dispose();
    _engineerController.dispose();
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

  // دالة اختيار التاريخ
  Future<void> _pickDate() async {
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
              primary: primaryBtnColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryBtnColor,
              ),
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

  // تنسيق التاريخ للعرض
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final result = await showModalBottomSheet<dynamic>(
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
                color: Colors.grey[300],
                margin: const EdgeInsets.only(bottom: 20)),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: primaryBtnColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.camera_alt, color: primaryBtnColor),
              ),
              title: const Text('الكاميرا',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () async => Navigator.pop(
                  context, await picker.pickImage(source: ImageSource.camera)),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: primaryBtnColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.photo_library, color: primaryBtnColor),
              ),
              title: const Text('المعرض',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () async =>
                  Navigator.pop(context, await picker.pickMultiImage()),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() {
        if (result is List<XFile>) {
          images.addAll(result.map((f) => File(f.path)));
        } else if (result is XFile) {
          images.add(File(result.path));
        }
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
                child: Image.file(imageFile, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.black54, shape: BoxShape.circle),
                child: IconButton(
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context)),
              ),
            ),
            Positioned(
              top: 40,
              left: 20,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8), shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white, size: 30),
                  onPressed: () {
                    setState(() => images.removeAt(index));
                    Navigator.pop(context);
                    Fluttertoast.showToast(
                        msg: 'تم حذف الصورة',
                        backgroundColor: Colors.red,
                        textColor: Colors.white);
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
                    borderRadius: BorderRadius.circular(12)),
                child: Text('صورة ${index + 1} من ${images.length}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveProblem() {
    // ✅ التحقق من رقم الهاتف إذا كان موجوداً
    if (_phoneController.text.isNotEmpty &&
        !validatePhoneNumber(_phoneController.text)) {
      return;
    }

    if (selectedCustomer == null ||
        selectedCategory == null ||
        selectedEngineer == null ||
        _problemTitleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('يرجى ملء جميع الحقول المطلوبة'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final customerState = context.read<CustomerCubit>().state;
    final statusId = selectedStatus?.id ??
        customerState.problemStatusList
            .firstWhere((s) => s.name.toLowerCase().contains('جديد'),
                orElse: () => customerState.problemStatusList.first)
            .id;

    setState(() => isSaving = true);

    context.read<CustomerCubit>().createProblem(
          customerId: selectedCustomer!.id!,
          dateTime: DateTime.now(),
          problemStatusId: statusId,
          problemCategoryId: selectedCategory!.id,
          problemAddress: _problemTitleController.text.trim(),
          note: _detailsController.text.trim(),
          details: _detailsController.text.trim(),
          phone: _phoneController.text.isNotEmpty
              ? _phoneController.text.trim()
              : null,
          engineerId: selectedEngineer!.id,
          isUrgent: isUrgent,
          images: images.isNotEmpty ? images : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CustomerCubit, CustomerState>(
      listener: (context, state) {
        if (isSaving) {
          if (state.isProblemAdded) {
            setState(() => isSaving = false);
            Fluttertoast.showToast(
                msg: 'تم إضافة المشكلة بنجاح',
                backgroundColor: Colors.green,
                textColor: Colors.white);
            context.read<CustomerCubit>().resetProblemAddedFlag();
            widget.onSaved();
          } else if (state.status == CustomerStatus.failure) {
            setState(() => isSaving = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.errorMessage ?? 'حدث خطأ أثناء الإضافة'),
                  backgroundColor: Colors.red),
            );
          }
        }
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          children: [
            _buildLabelledRow(
                label: 'اسم العميل',
                child: _buildAutocompleteDropdown(
                  controller: _clientNameController,
                  hint: 'ابحث عن عميل',
                  isVisible: isClientDropdownVisible,
                  onTap: () => setState(
                      () => isClientDropdownVisible = !isClientDropdownVisible),
                  child: BlocBuilder<CustomerCubit, CustomerState>(
                      builder: (context, state) {
                    if (state.customers.isEmpty) {
                      return SizedBox(
                        height: 150.h,
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(primaryBtnColor),
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      primary: false,
                      physics: const BouncingScrollPhysics(),
                      itemCount: state.customers.length,
                      itemBuilder: (context, i) {
                        final c = state.customers[i];
                        return ListTile(
                          title: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: c.name ?? '',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                if (c.proudctName != null &&
                                    c.proudctName!.isNotEmpty)
                                  TextSpan(
                                    text: ' (${c.proudctName})',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  ),
                              ],
                            ),
                          ),
                          subtitle: Text(c.phone?.toString() ?? '',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                          onTap: () {
                            setState(() {
                              selectedCustomer = c;
                              _clientNameController.text = c.name ?? '';
                              _phoneController.text = c.phone?.toString() ?? '';
                              isClientDropdownVisible = false;
                            });
                          },
                        );
                      },
                    );
                  }),
                )),
            SizedBox(height: 16.h),

            // ====== رقم التواصل (محدود 11 رقم — أرقام فقط) ======
            _buildLabelledRow(
                label: 'رقم التواصل',
                child: _buildTextField(
                  _phoneController,
                  hint: 'رقم الهاتف',
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                )),
            SizedBox(height: 16.h),

            // ====== تاريخ المشكلة ======
            _buildLabelledRow(
              label: 'التاريخ',
              child: GestureDetector(
                onTap: _pickDate,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 50),
                  decoration: BoxDecoration(
                    color: fieldColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(selectedDate),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Icon(
                        Icons.calendar_today,
                        color: primaryBtnColor,
                        size: 24.sp,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            _buildLabelledRow(
                label: 'نوع المشكلة',
                child: _buildAutocompleteDropdown(
                  controller: _problemTypeController,
                  hint: 'اختر نوع المشكلة',
                  isVisible: isTypeDropdownVisible,
                  onTap: () => setState(
                      () => isTypeDropdownVisible = !isTypeDropdownVisible),
                  child: BlocBuilder<CustomerCubit, CustomerState>(
                      builder: (context, state) {
                    // فلترة نتائج البحث
                    final filteredCategories = problemTypeSearchQuery.isEmpty
                        ? state.problemCategories
                        : state.problemCategories
                            .where((cat) => cat.name
                                .toLowerCase()
                                .contains(problemTypeSearchQuery.toLowerCase()))
                            .toList();

                    if (filteredCategories.isEmpty) {
                      return SizedBox(
                        height: 150.h,
                        child: Center(
                          child: Text('لا توجد نتائج',
                              style: TextStyle(color: Colors.grey[600])),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      primary: false,
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredCategories.length,
                      itemBuilder: (context, i) {
                        final cat = filteredCategories[i];
                        return ListTile(
                          title: Text(cat.name,
                              style: const TextStyle(fontSize: 14)),
                          onTap: () {
                            setState(() {
                              selectedCategory = cat;
                              _problemTypeController.text = cat.name;
                              problemTypeSearchQuery = '';
                              isTypeDropdownVisible = false;
                            });
                          },
                        );
                      },
                    );
                  }),
                )),
            SizedBox(height: 16.h),
            _buildLabelledRow(
                label: 'عنوان المشكلة',
                child: _buildTextField(_problemTitleController,
                    hint: 'عنوان المشكلة')),
            SizedBox(height: 16.h),
            _buildLabelledRow(
                label: 'تفاصيل المشكلة',
                child: SizedBox(
                  height: 100.h,
                  child: _buildTextField(_detailsController,
                      hint: 'اكتب التفاصيل', maxLines: 5),
                )),
            SizedBox(height: 16.h),
            _buildLabelledRow(
                label: 'اسم المهندس',
                child: _buildAutocompleteDropdown(
                  controller: _engineerController,
                  hint: 'اختر مهندس',
                  isVisible: isEngineerDropdownVisible,
                  onTap: () => setState(() =>
                      isEngineerDropdownVisible = !isEngineerDropdownVisible),
                  child: BlocBuilder<EngineerCubit, EngineerState>(
                      builder: (context, state) {
                    // فلترة نتائج البحث
                    final filteredEngineers = engineerSearchQuery.isEmpty
                        ? state.engineers
                        : state.engineers
                            .where((eng) => eng.name
                                .toLowerCase()
                                .contains(engineerSearchQuery.toLowerCase()))
                            .toList();

                    if (filteredEngineers.isEmpty) {
                      return SizedBox(
                        height: 150.h,
                        child: Center(
                          child: Text('لا توجد نتائج',
                              style: TextStyle(color: Colors.grey[600])),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      primary: false,
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredEngineers.length,
                      itemBuilder: (context, i) {
                        final eng = filteredEngineers[i];
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
                                      fontWeight: FontWeight.bold))),
                          title: Text(eng.name,
                              style: const TextStyle(fontSize: 14)),
                          onTap: () {
                            setState(() {
                              selectedEngineer = eng;
                              _engineerController.text = eng.name;
                              engineerSearchQuery = '';
                              isEngineerDropdownVisible = false;
                            });
                          },
                        );
                      },
                    );
                  }),
                )),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Column(
                    children: [
                      Text('رفع صور',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14.sp)),
                      SizedBox(height: 4.h),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset('assets/images/pngs/upload_pic.png',
                              width: 50, height: 50),
                          if (images.isNotEmpty)
                            Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle),
                                    child: const Icon(Icons.check_circle,
                                        color: Colors.green, size: 14))),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text('URGENT',
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    Switch(
                        value: isUrgent,
                        activeTrackColor: Colors.red,
                        onChanged: (v) => setState(() => isUrgent = v)),
                  ],
                ),
              ],
            ),
            if (images.isNotEmpty) ...[
              SizedBox(height: 20.h),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: images
                    .asMap()
                    .entries
                    .map((e) => GestureDetector(
                          onTap: () => _showFullScreenImage(e.value, e.key),
                          child: Stack(
                            children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(e.value,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover)),
                              Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => images.removeAt(e.key)),
                                    child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle),
                                        child: const Icon(Icons.close,
                                            color: Colors.white, size: 16)),
                                  )),
                            ],
                          ),
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
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                      color: primaryBtnColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5))
                ],
              ),
              child: ElevatedButton(
                onPressed: isSaving ? null : _saveProblem,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30))),
                child: isSaving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 3))
                    : Text('حفظ',
                        style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
              ),
            ),
            SizedBox(height: 20.h),
          ],
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
            child: Text(label,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.black))),
        SizedBox(width: 12.w),
        Expanded(child: child),
      ],
    );
  }

  /// Updated helper: supports inputFormatters and keyboardType.
  Widget _buildTextField(TextEditingController controller,
      {String? hint,
      int maxLines = 1,
      TextInputType? keyboardType,
      List<TextInputFormatter>? inputFormatters}) {
    return Container(
      decoration: BoxDecoration(
          color: fieldColor, borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38),
            border: InputBorder.none,
            // لا نعرض عداد الطول حتى لا يشوش التصميم
            counterText: '',
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 12)),
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
                color: fieldColor, borderRadius: BorderRadius.circular(12)),
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
                        contentPadding: const EdgeInsets.only(right: 5)),
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
                      offset: const Offset(0, 3))
                ]),
            child: child,
          ),
      ],
    );
  }
}
