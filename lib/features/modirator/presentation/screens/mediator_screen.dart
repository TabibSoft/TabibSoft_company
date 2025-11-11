// lib/features/home/presentation/screens/mediator_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tabib_soft_company/core/networking/api_result.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/engineer_cubit.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/engineer_state.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/addCustomer/add_customer_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/addCustomer/product_model.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/add_customer/add_cusomer_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/add_customer/add_customer_state.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/add_customer/product_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/add_customer/product_state.dart';

class ModiratorScreen extends StatelessWidget {
  const ModiratorScreen({super.key});

  static const Color topDark = Color(0xFF104D9D);
  static const Color topLight = Color(0xFF20AAC9);
  static const Color buttonBorder = Color(0xFF1386B0);
  static const double _cardTopFactor = 0.36;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 19, 99, 209),
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                height: size.height,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [topDark, topLight],
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: 0.12,
                  child: Image.asset(
                    'assets/images/pngs/TS_Logo1.png',
                    width: size.width * 0.9,
                    height: size.width * 0.45,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: size.height * _cardTopFactor,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F8FA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(36.r),
                      topRight: Radius.circular(36.r),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 30.h),
                      _bigPillButton(
                        context,
                        label: 'عميل جديد',
                        onTap: () => _openNewClientDialog(context),
                        borderColor: buttonBorder,
                      ),
                      SizedBox(height: 39.h),
                      _bigPillButton(
                        context,
                        label: 'إضافة مشكلة',
                        onTap: () => _openAddIssueDialog(context),
                        borderColor: buttonBorder,
                      ),
                      SizedBox(height: 39.h),
                      _bigPillButton(
                        context,
                        label: 'إضافة اشتراك',
                        onTap: () => _openAddSubscriptionDialog(context),
                        borderColor: buttonBorder,
                      ),
                      const Spacer(),
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

  Widget _bigPillButton(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
    required Color borderColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 78.h,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          elevation: 6,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(48.r),
            side: BorderSide(color: borderColor, width: 2),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: const Color(0xFF0F5FA8),
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // POP-UP dialogs
  Future<void> _openNewClientDialog(BuildContext context) async {
    await _openBlockingDialog(
      context,
      title: 'عميل جديد',
      child: _NewClientForm(onSaved: () => Navigator.of(context).pop()),
    );
  } // يستخدم showDialog مع barrierDismissible:false بحسب التوثيق.

  Future<void> _openAddIssueDialog(BuildContext context) async {
    await _openBlockingDialog(
      context,
      title: 'إضافة مشكلة',
      child: _AddIssueForm(
        onSaved: () => Navigator.of(context).pop(),
        onClientTap: () => _openNewClientDialog(context),
      ),
    );
  } // التحكم بزر الرجوع عبر WillPopScope مسموح.

  Future<void> _openAddSubscriptionDialog(BuildContext context) async {
    await _openBlockingDialog(
      context,
      title: 'إضافة اشتراك',
      child: _AddSubscriptionForm(
        onSaved: () => Navigator.of(context).pop(),
        onClientTap: () => _openAddIssueDialog(context),
      ),
    );
  } // زر X داخل الـ Dialog مخصص أعلى اليمين.

  Future<void> _openBlockingDialog(
    BuildContext context, {
    required String title,
    required Widget child,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return WillPopScope(
          onWillPop: () async => true,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Dialog(
              insetPadding:
                  EdgeInsets.symmetric(horizontal: 18.w, vertical: 24.h),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 720.w),
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 16.h),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _dialogGrabberAndTitle(title),
                            SizedBox(height: 8.h),
                            child,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        tooltip: 'إغلاق',
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close,
                            color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  } // showDialog وDialog يحققان السلوك المطلوب.
}

// ============ النماذج ============

class _NewClientForm extends StatefulWidget {
  const _NewClientForm({required this.onSaved});
  final VoidCallback onSaved;

  @override
  State<_NewClientForm> createState() => _NewClientFormState();
}

class _NewClientFormState extends State<_NewClientForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _location = TextEditingController();
  final _engineer = TextEditingController();
  final _product = TextEditingController();

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
    _name.dispose();
    _phone.dispose();
    _location.dispose();
    _engineer.dispose();
    _product.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final customer = AddCustomerModel(
        name: _name.text,
        telephone: _phone.text,
        engineerId: _selectedEngineerId ?? '',
        productId: _selectedProductId ?? '',
        location: _location.text.isNotEmpty ? _location.text : null,
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
            RowField(label: 'اسم العميل', child: _boxedText(_name)),
            RowField(
                label: 'رقم التواصل',
                child: _boxedText(_phone, type: TextInputType.phone)),
            RowField(label: 'الموقع', child: _boxedText(_location)),
            RowField(label: 'المهندس', child: _engineerDropdown()),
            if (_showEngineerDropdown)
              SizedBox(
                height: 200.h, // ارتفاع ثابت للتمرير الداخلي
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
                height: 200.h, // ارتفاع ثابت للتمرير الداخلي
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
            _saveButton(onPressed: _onSave),
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

class _AddIssueForm extends StatefulWidget {
  const _AddIssueForm({
    required this.onSaved,
    this.onClientTap,
  });
  final VoidCallback onSaved;
  final VoidCallback? onClientTap;

  @override
  State<_AddIssueForm> createState() => _AddIssueFormState();
}

class _AddIssueFormState extends State<_AddIssueForm> {
  final _formKey = GlobalKey<FormState>();
  final _client = TextEditingController();
  final _specialty = TextEditingController();
  final _problem = TextEditingController();
  DateTime? _expectedDate;
  TimeOfDay? _from;
  TimeOfDay? _to;
  final List<String> _imagePaths = [];

  @override
  void initState() {
    super.initState();
    _expectedDate = DateTime.now();
    final nowTime = TimeOfDay.now();
    _from = nowTime;
    _to = nowTime.replacing(hour: (nowTime.hour + 1) % 24);
  }

  @override
  void dispose() {
    _client.dispose();
    _specialty.dispose();
    _problem.dispose();
    super.dispose();
  }

  Future<void> _pickExpectedDate() async {
    final now = DateTime.now();
    final picked = await showDialog<DateTime>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DatePickerDialog(
        initialDate: _expectedDate ?? now,
        onConfirm: (d) => Navigator.of(context).pop(d),
      ),
    );
    if (picked != null) setState(() => _expectedDate = picked);
  } // اختيار التاريخ عبر حوار مخصص ضمن showDialog.

  Future<void> _pickTime({required bool isFrom}) async {
    final t = await showTimePicker(
      context: context,
      initialTime: (isFrom ? _from : _to) ?? TimeOfDay.now(),
      builder: (ctx, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
    );
    if (t != null) setState(() => isFrom ? _from = t : _to = t);
  } // showTimePicker قياسي لاختيار الوقت.

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('معرض الصور'),
                onTap: () async {
                  Navigator.pop(bc);
                  final XFile? image =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      _imagePaths.add(image.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('الكاميرا'),
                onTap: () async {
                  Navigator.pop(bc);
                  final XFile? image =
                      await picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    setState(() {
                      _imagePaths.add(image.path);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _timeBox({required bool isFrom}) {
    final time = isFrom ? _from : _to;
    final label = isFrom ? 'من' : 'إلى';
    String displayText;
    if (time == null) {
      displayText = 'اختر $label';
    } else {
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      displayText = '$label $hour:$minute';
    }
    final onTapCallback =
        isFrom ? () => _pickTime(isFrom: true) : () => _pickTime(isFrom: false);
    return Expanded(
      child: InkWell(
        onTap: onTapCallback,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xff104D9D),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  displayText,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _clientDropdown() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xff104D9D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: TextFormField(
          controller: _client,
          readOnly: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'اختر',
            hintStyle: const TextStyle(color: Colors.white70),
            isCollapsed: true,
            suffixIcon: Padding(
              padding: const EdgeInsetsDirectional.only(end: 6),
              child: ColorFiltered(
                colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                child: Image.asset(
                  'assets/images/pngs/dropdown.png',
                  width: 10,
                  height: 14,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          validator: (v) => (v == null || v.trim().isEmpty) ? ' مطلوب' : null,
          onTap: widget.onClientTap,
        ),
      ),
    );
  }

  Widget _imagesUploadSection() {
    return Column(
      children: [
        Text(
          'رفع الملفات',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 10.h),
        GestureDetector(
          onTap: _pickImage,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/images/pngs/Ellipse_3.png',
                width: 90.w,
                height: 90.h,
                fit: BoxFit.contain,
              ),
              if (_imagePaths.isNotEmpty)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _imagePaths.length.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ),
              const Text(
                '+',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        if (_imagePaths.isNotEmpty)
          SizedBox(
            height: 100.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _imagePaths.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Image.file(
                    File(_imagePaths[index]),
                    width: 80.w,
                    height: 80.h,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          RowField(label: 'اسم العميل', child: _clientDropdown()),
          RowField(label: 'التخصص', child: _boxedText(_specialty)),
          RowField(label: 'المشكلة', child: _boxedMultiline(_problem)),
          RowField(
            label: 'تاريخ المتوقع',
            child: _dateBox(
              value: _expectedDate == null
                  ? 'اختر التاريخ'
                  : '${_expectedDate!.year}/${_expectedDate!.month.toString().padLeft(2, '0')}/${_expectedDate!.day.toString().padLeft(2, '0')}',
              onTap: _pickExpectedDate,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                _timeBox(isFrom: true),
                SizedBox(width: 8.w),
                _timeBox(isFrom: false),
              ],
            ),
          ),
          _imagesUploadSection(),
          SizedBox(height: 16.h),
          _saveButton(onPressed: () {
            if (_formKey.currentState?.validate() ?? false) widget.onSaved();
          }),
        ],
      ),
    );
  }
}

class _AddSubscriptionForm extends StatefulWidget {
  const _AddSubscriptionForm({
    required this.onSaved,
    this.onClientTap,
  });
  final VoidCallback onSaved;
  final VoidCallback? onClientTap;

  @override
  State<_AddSubscriptionForm> createState() => _AddSubscriptionFormState();
}

class _AddSubscriptionFormState extends State<_AddSubscriptionForm> {
  final _formKey = GlobalKey<FormState>();
  final _client = TextEditingController();
  final _specialty = TextEditingController();
  final _paymentMethod = TextEditingController();
  final _amount = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _date;
  final List<String> _imagePaths = [];

  @override
  void initState() {
    super.initState();
    _date = DateTime.now();
    _startDate = DateTime.now();
    _endDate = DateTime.now();
  }

  @override
  void dispose() {
    _client.dispose();
    _specialty.dispose();
    _paymentMethod.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _pickDate(
      ValueSetter<DateTime> setValue, DateTime? current) async {
    final now = DateTime.now();
    final picked = await showDialog<DateTime>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DatePickerDialog(
        initialDate: current ?? now,
        onConfirm: (d) => Navigator.of(context).pop(d),
      ),
    );
    if (picked != null) {
      setValue(picked);
      setState(() {});
    }
  } // showDialog يمنع الإغلاق الخارجي أثناء اختيار التاريخ.

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('معرض الصور'),
                onTap: () async {
                  Navigator.pop(bc);
                  final XFile? image =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      _imagePaths.add(image.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('الكاميرا'),
                onTap: () async {
                  Navigator.pop(bc);
                  final XFile? image =
                      await picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    setState(() {
                      _imagePaths.add(image.path);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _clientDropdown() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.orange, // تغيير اللون إلى برتقالي
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: TextFormField(
          controller: _client,
          readOnly: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'اختر',
            hintStyle: const TextStyle(color: Colors.white70),
            isCollapsed: true,
            suffixIcon: Padding(
              padding: const EdgeInsetsDirectional.only(end: 6),
              child: ColorFiltered(
                colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                child: Image.asset(
                  'assets/images/pngs/dropdown.png',
                  width: 10,
                  height: 14,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          validator: (v) => (v == null || v.trim().isEmpty) ? ' مطلوب' : null,
          onTap: widget.onClientTap,
        ),
      ),
    );
  }

  Widget _imagesUploadSection() {
    return Column(
      children: [
        Text(
          'رفع الملفات',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 10.h),
        GestureDetector(
          onTap: _pickImage,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/images/pngs/Ellipse_3.png',
                width: 90.w,
                height: 90.h,
                fit: BoxFit.contain,
              ),
              if (_imagePaths.isNotEmpty)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _imagePaths.length.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ),
              const Text(
                '+',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        if (_imagePaths.isNotEmpty)
          SizedBox(
            height: 100.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _imagePaths.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Image.file(
                    File(_imagePaths[index]),
                    width: 80.w,
                    height: 80.h,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          RowField(label: 'العميل', child: _clientDropdown()),
          RowField(
            label: 'التاريخ',
            child: _dateBox(
              value: _date == null
                  ? 'اختر التاريخ'
                  : '${_date!.year}/${_date!.month.toString().padLeft(2, '0')}/${_date!.day.toString().padLeft(2, '0')}',
              onTap: () => _pickDate((d) => _date = d, _date),
            ),
          ),
          RowField(label: 'التخصص', child: _boxedText(_specialty)),
          RowField(
            label: 'بداية الاشتراك',
            child: _dateBox(
              value: _startDate == null
                  ? 'اختر التاريخ'
                  : '${_startDate!.year}/${_startDate!.month.toString().padLeft(2, '0')}/${_startDate!.day.toString().padLeft(2, '0')}',
              onTap: () => _pickDate((d) => _startDate = d, _startDate),
            ),
          ),
          RowField(
            label: 'نهاية الاشتراك',
            child: _dateBox(
              value: _endDate == null
                  ? 'اختر التاريخ'
                  : '${_endDate!.year}/${_endDate!.month.toString().padLeft(2, '0')}/${_endDate!.day.toString().padLeft(2, '0')}',
              onTap: () => _pickDate((d) => _endDate = d, _endDate),
            ),
          ),
          RowField(label: 'طريقة الدفع', child: _dropdownBox(_paymentMethod)),
          RowField(
              label: 'المبلغ',
              child: _boxedText(_amount, type: TextInputType.number)),
          _imagesUploadSection(),
          SizedBox(height: 16.h),
          _saveButton(onPressed: () {
            if (_formKey.currentState?.validate() ?? false) widget.onSaved();
          }),
        ],
      ),
    );
  }
}

// ============ عناصر واجهة مشتركة (صف تسمية + حقل) ============

class RowField extends StatelessWidget {
  const RowField({
    super.key,
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 110, // عرض ثابت للنص مثل الصور
            child: Text(label,
                style: const TextStyle(fontSize: 14, color: Color(0xFF2D2D2D))),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
} // استخدام تخطيط صف لمحاذاة التسمية بجوار الحقل كما توصي أدلة التخطيط.

Widget _boxedText(TextEditingController c,
    {TextInputType type = TextInputType.text}) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xff104D9D),
      borderRadius: BorderRadius.circular(12),
    ),
    child: TextFormField(
      controller: c,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: TextStyle(color: Colors.white70),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? ' مطلوب' : null,
    ),
  );
} // حقل نصي مطابق مع خامة ولون.

Widget _boxedMultiline(TextEditingController c) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xff104D9D),
      borderRadius: BorderRadius.circular(12),
    ),
    child: TextFormField(
      controller: c,
      maxLines: 4,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: TextStyle(color: Colors.white70),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? ' مطلوب' : null,
    ),
  );
} // متعدد الأسطر بنفس النمط.

Widget _dropdownBox(TextEditingController c) {
  return Container(
    height: 52,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: Colors.orange, // تغيير اللون إلى برتقالي
      borderRadius: BorderRadius.circular(12),
    ),
    child: Center(
      child: TextFormField(
        controller: c,
        readOnly: true,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'اختر',
          hintStyle: const TextStyle(color: Colors.white70),
          isCollapsed: true,
          suffixIcon: Padding(
            padding: const EdgeInsetsDirectional.only(end: 6),
            child: ColorFiltered(
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              child: Image.asset(
                'assets/images/pngs/dropdown.png',
                width: 10,
                height: 14,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        validator: (v) => (v == null || v.trim().isEmpty) ? ' مطلوب' : null,
        onTap: () {
          // TODO: فتح قائمة اختيار
        },
      ),
    ),
  );
} // suffixIcon مخصص وفق InputDecoration API.

Widget _dateBox({
  required String value,
  required VoidCallback onTap,
  IconData icon = Icons.calendar_month,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xff104D9D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
              child: Text(value, style: const TextStyle(color: Colors.white))),
        ],
      ),
    ),
  );
} // عنصر تاريخ/وقت بنفس مظهر الحقول في صف واحد.

Widget _dialogGrabberAndTitle(String title) {
  return Column(
    children: [
      Container(
        width: 50,
        height: 5,
        margin: const EdgeInsets.only(top: 6, bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      Text(
        title,
        style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F5FA8)),
      ),
    ],
  );
} // عنوان الحوار.

Widget _saveButton({required VoidCallback onPressed}) {
  return SizedBox(
    width: double.infinity,
    height: 48,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF20AAC9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text('حفظ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    ),
  );
} // زر الحفظ يغلق عبر onSaved.

// ===== Dialog لاختيار التاريخ مع تأكيد/إلغاء =====
class _DatePickerDialog extends StatefulWidget {
  const _DatePickerDialog({required this.initialDate, required this.onConfirm});
  final DateTime initialDate;
  final ValueChanged<DateTime> onConfirm;

  @override
  State<_DatePickerDialog> createState() => _DatePickerDialogState();
}

class _DatePickerDialogState extends State<_DatePickerDialog> {
  late DateTime _temp = widget.initialDate;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: const Color(0xFF104D9D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: SizedBox(
          width: 360,
          child: Theme(
            data: ThemeData.dark(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                const Text('اختر التاريخ',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 18)),
                const Divider(height: 20, color: Colors.white70),
                Theme(
                  data: ThemeData.dark(),
                  child: CalendarDatePicker(
                    initialDate: _temp,
                    firstDate: DateTime(_temp.year - 5),
                    lastDate: DateTime(_temp.year + 5),
                    onDateChanged: (d) => setState(() => _temp = d),
                  ),
                ),
                const Divider(height: 20, color: Colors.white70),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('إلغاء'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF20AAC9),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => widget.onConfirm(_temp),
                          child: const Text('تأكيد'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} // حوار تاريخ مخصص يعمل ضمن showDialog.
