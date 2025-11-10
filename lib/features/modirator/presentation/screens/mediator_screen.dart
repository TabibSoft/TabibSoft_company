// lib/features/home/presentation/screens/mediator_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MediatorScreen extends StatelessWidget {
  const MediatorScreen({super.key});

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
                        onTap: () => _openNewClientSheet(context),
                        borderColor: buttonBorder,
                      ),
                      SizedBox(height: 39.h),
                      _bigPillButton(
                        context,
                        label: 'إضافة مشكلة',
                        onTap: () => _openAddIssueSheet(context),
                        borderColor: buttonBorder,
                      ),
                      SizedBox(height: 39.h),
                      _bigPillButton(
                        context,
                        label: 'إضافة اشتراك',
                        onTap: () => _openAddSubscriptionSheet(context),
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

  // 1) عميل جديد
  Future<void> _openNewClientSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.85,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (c, scroll) {
                return SingleChildScrollView(
                  controller: scroll,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                    child: _NewClientForm(),
                  ),
                );
              },
            ),
          ),
        );
      },
    ); // حواف دائرية وScrollable موصى بها في التوثيق [web:4][web:2]
  }

  // 2) إضافة مشكلة
  Future<void> _openAddIssueSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.9,
              minChildSize: 0.6,
              maxChildSize: 0.98,
              builder: (c, scroll) {
                return SingleChildScrollView(
                  controller: scroll,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                    child: _AddIssueForm(),
                  ),
                );
              },
            ),
          ),
        );
      },
    ); // استخدام isScrollControlled للوصول لطول شبه كامل حسب توصيات المجتمع [web:10][web:6]
  }

  // 3) إضافة اشتراك
  Future<void> _openAddSubscriptionSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.9,
              minChildSize: 0.6,
              maxChildSize: 0.98,
              builder: (c, scroll) {
                return SingleChildScrollView(
                  controller: scroll,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                    child: _AddSubscriptionForm(),
                  ),
                );
              },
            ),
          ),
        );
      },
    ); // DraggableScrollableSheet يمنح ارتفاعاً مرناً داخل الـ BottomSheet [web:8][web:4]
  }
}

// فورم: عميل جديد (مطابق لفكرة التصميم في صورة "عميل جديد")
class _NewClientForm extends StatefulWidget {
  @override
  State<_NewClientForm> createState() => _NewClientFormState();
}

class _NewClientFormState extends State<_NewClientForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _governorate = TextEditingController();
  final _address = TextEditingController();
  final _specialty = TextEditingController();
  final _engineer = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _governorate.dispose();
    _address.dispose();
    _specialty.dispose();
    _engineer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _sheetHeader('عميل جديد'),
        SizedBox(height: 12.h),
        Form(
          key: _formKey,
          child: Column(
            children: [
              _filledField(label: 'اسم العميل', controller: _name),
              _filledField(
                  label: 'رقم التواصل',
                  controller: _phone,
                  keyboardType: TextInputType.phone),
              _filledField(label: 'المحافظة', controller: _governorate),
              _filledField(label: 'العنوان', controller: _address),
              _filledField(label: 'التخصص', controller: _specialty),
              _filledField(label: 'المهندس', controller: _engineer),
              SizedBox(height: 16.h),
              _saveButton(onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  Navigator.pop(context);
                }
              }),
            ],
          ),
        ),
      ],
    );
  }
}

// فورم: إضافة مشكلة (مطابق للفكرة في صورة "إضافة مشكلة")
class _AddIssueForm extends StatefulWidget {
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

  @override
  void dispose() {
    _client.dispose();
    _specialty.dispose();
    _problem.dispose();
    super.dispose();
  }

  Future<void> _pickExpectedDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      initialDate: _expectedDate ?? now,
      builder: (ctx, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
    );
    if (picked != null) setState(() => _expectedDate = picked);
  } // استخدام showDatePicker الرسمي لاختيار التاريخ [web:15][web:4]

  Future<void> _pickFrom() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _from ?? TimeOfDay.now(),
      builder: (ctx, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
    );
    if (t != null) setState(() => _from = t);
  }

  Future<void> _pickTo() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _to ?? TimeOfDay.now(),
      builder: (ctx, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
    );
    if (t != null) setState(() => _to = t);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _sheetHeader('إضافة مشكلة'),
        SizedBox(height: 12.h),
        Form(
          key: _formKey,
          child: Column(
            children: [
              _dropdownLikeField(label: 'اسم العميل', controller: _client),
              _filledField(label: 'التخصص', controller: _specialty),
              _multilineField(label: 'المشكلة', controller: _problem),
              _datePickerField(
                label: 'تاريخ المتوقع',
                valueText: _expectedDate == null
                    ? 'اختر التاريخ'
                    : '${_expectedDate!.year}/${_expectedDate!.month.toString().padLeft(2, '0')}/${_expectedDate!.day.toString().padLeft(2, '0')}',
                onTap: _pickExpectedDate,
              ),
              Row(
                children: [
                  Expanded(
                    child: _datePickerField(
                      label: 'من',
                      valueText:
                          _from == null ? 'اختر' : _from!.format(context),
                      onTap: _pickFrom,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _datePickerField(
                      label: 'إلى',
                      valueText: _to == null ? 'اختر' : _to!.format(context),
                      onTap: _pickTo,
                    ),
                  ),
                ],
              ),
              _filesUploadStub(),
              SizedBox(height: 16.h),
              _saveButton(onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  Navigator.pop(context);
                }
              }),
            ],
          ),
        ),
      ],
    );
  }
}

// فورم: إضافة اشتراك (مطابق لفكرة الصورة "إضافة اشتراك")
class _AddSubscriptionForm extends StatefulWidget {
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
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      initialDate: current ?? now,
      builder: (ctx, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
    );
    if (picked != null) setValue(picked);
    setState(() {});
  } // اختيار التاريخ عبر واجهة Material الرسمية [web:15][web:4]

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _sheetHeader('إضافة اشتراك'),
        SizedBox(height: 12.h),
        Form(
          key: _formKey,
          child: Column(
            children: [
              _dropdownLikeField(label: 'العميل', controller: _client),
              _datePickerField(
                label: 'التاريخ',
                valueText: _date == null
                    ? 'اختر التاريخ'
                    : '${_date!.year}/${_date!.month.toString().padLeft(2, '0')}/${_date!.day.toString().padLeft(2, '0')}',
                onTap: () => _pickDate((d) => _date = d, _date),
              ),
              _filledField(label: 'التخصص', controller: _specialty),
              _datePickerField(
                label: 'بداية الاشتراك',
                valueText: _startDate == null
                    ? 'اختر التاريخ'
                    : '${_startDate!.year}/${_startDate!.month.toString().padLeft(2, '0')}/${_startDate!.day.toString().padLeft(2, '0')}',
                onTap: () => _pickDate((d) => _startDate = d, _startDate),
              ),
              _datePickerField(
                label: 'نهاية الاشتراك',
                valueText: _endDate == null
                    ? 'اختر التاريخ'
                    : '${_endDate!.year}/${_endDate!.month.toString().padLeft(2, '0')}/${_endDate!.day.toString().padLeft(2, '0')}',
                onTap: () => _pickDate((d) => _endDate = d, _endDate),
              ),
              _filledField(label: 'طريقة الدفع', controller: _paymentMethod),
              _filledField(
                  label: 'المبلغ',
                  controller: _amount,
                  keyboardType: TextInputType.number),
              _filesUploadStub(),
              SizedBox(height: 16.h),
              _saveButton(onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  Navigator.pop(context);
                }
              }),
            ],
          ),
        ),
      ],
    );
  }
}

// عناصر واجهة مشتركة

Widget _sheetHeader(String title) {
  return Column(
    children: [
      Container(
        width: 50,
        height: 5,
        margin: const EdgeInsets.only(top: 10, bottom: 12),
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
          color: Color(0xFF0F5FA8),
        ),
      ),
    ],
  );
}

Widget _filledField({
  required String label,
  required TextEditingController controller,
  TextInputType keyboardType = TextInputType.text,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF2D2D2D))),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE8F1F8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'حقل مطلوب' : null,
          ),
        ),
      ],
    ),
  );
}

Widget _multilineField({
  required String label,
  required TextEditingController controller,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF2D2D2D))),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE8F1F8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'حقل مطلوب' : null,
          ),
        ),
      ],
    ),
  );
}

Widget _dropdownLikeField({
  required String label,
  required TextEditingController controller,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF2D2D2D))),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () {
            // TODO: افتح اختيار عميل/قائمة
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? 'اختر' : controller.text,
                    style: TextStyle(
                      color: controller.text.isEmpty
                          ? Colors.grey
                          : Colors.black87,
                    ),
                  ),
                ),
                const Icon(Icons.check_circle, color: Color(0xFF0F5FA8)),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _datePickerField({
  required String label,
  required String valueText,
  required VoidCallback onTap,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF2D2D2D))),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: Color(0xFF0F5FA8)),
                const SizedBox(width: 8),
                Expanded(child: Text(valueText)),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _filesUploadStub() {
  return const Padding(
    padding: EdgeInsets.only(top: 8, bottom: 8),
    child: Column(
      children: [
        SizedBox(height: 8),
        Icon(Icons.file_upload_outlined, size: 36, color: Color(0xFF0F5FA8)),
        SizedBox(height: 4),
        Text('رفع ملفات', style: TextStyle(color: Colors.black54)),
      ],
    ),
  );
}

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
}
