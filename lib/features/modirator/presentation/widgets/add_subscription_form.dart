// lib/features/home/presentation/screens/add_subscription_form.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tabib_soft_company/features/modirator/export.dart';

class AddSubscriptionForm extends StatefulWidget {
  final VoidCallback onSaved;
  final VoidCallback? onClientTap;
  const AddSubscriptionForm(
      {super.key, required this.onSaved, this.onClientTap});

  @override
  State<AddSubscriptionForm> createState() => _AddSubscriptionFormState();
}

class _AddSubscriptionFormState extends State<AddSubscriptionForm> {
  final _formKey = GlobalKey<FormState>();
  final _clientController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _paymentMethodController = TextEditingController();
  DateTime? _contractDate;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedCustomerId;
  String? _selectedPaymentMethodId;
  final List<String> _imagePaths = [];
  final ImagePicker _picker = ImagePicker();
  late AddSubscriptionCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<AddSubscriptionCubit>();
    _contractDate = DateTime.now();
    _startDate = DateTime.now();
    _endDate = DateTime.now().add(const Duration(days: 365));
  }

  Future<void> _pickDate(
      ValueSetter<DateTime> setter, DateTime? current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF20AAC9)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setter(picked);
      setState(() {});
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('معرض الصور'),
              onTap: () async {
                Navigator.pop(context);
                final files = await _picker.pickMultiImage();
                if (files.isNotEmpty) {
                  setState(() => _imagePaths.addAll(files.map((f) => f.path)));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('الكاميرا'),
              onTap: () async {
                Navigator.pop(context);
                final file =
                    await _picker.pickImage(source: ImageSource.camera);
                if (file != null) {
                  setState(() => _imagePaths.add(file.path));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<List<MultipartFile>?> _prepareImages() async {
    if (_imagePaths.isEmpty) return null;
    return Future.wait(_imagePaths.map((path) => MultipartFile.fromFile(path)));
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار العميل')),
      );
      return;
    }
    final images = await _prepareImages();
    final model = AddSubscriptionModel(
      customerId: _selectedCustomerId!,
      contractDate: _contractDate!,
      startDate: _startDate!,
      endDate: _endDate!,
      cost: double.tryParse(_amountController.text) ?? 0.0,
      payment: double.tryParse(_amountController.text) ?? 0.0,
      payMethodId: _selectedPaymentMethodId ?? '',
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      file: images,
    );
    _cubit.addSubscription(model);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddSubscriptionCubit, AddSubscriptionState>(
      listener: (context, state) {
        if (state.status == AddSubscriptionStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إضافة الاشتراك بنجاح')),
          );
          widget.onSaved();
        } else if (state.status == AddSubscriptionStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.errorMessage ?? 'فشل في إضافة الاشتراك')),
          );
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            RowField(
              label: 'العميل',
              child: ClientSearchField(
                onCustomerSelected: (customer) {
                  _selectedCustomerId = customer.id;
                  _clientController.text = customer.name ?? '';
                },
              ),
            ),
            RowField(
              label: 'تاريخ العقد',
              child: dateBox(
                value: _contractDate == null
                    ? 'اختر التاريخ'
                    : '${_contractDate!.year}/${_contractDate!.month.toString().padLeft(2, '0')}/${_contractDate!.day.toString().padLeft(2, '0')}',
                onTap: () => _pickDate((d) => _contractDate = d, _contractDate),
              ),
            ),
            RowField(
              label: 'بداية الاشتراك',
              child: dateBox(
                value: _startDate == null
                    ? 'اختر التاريخ'
                    : '${_startDate!.year}/${_startDate!.month.toString().padLeft(2, '0')}/${_startDate!.day.toString().padLeft(2, '0')}',
                onTap: () => _pickDate((d) => _startDate = d, _startDate),
              ),
            ),
            RowField(
              label: 'نهاية الاشتراك',
              child: dateBox(
                value: _endDate == null
                    ? 'اختر التاريخ'
                    : '${_endDate!.year}/${_endDate!.month.toString().padLeft(2, '0')}/${_endDate!.day.toString().padLeft(2, '0')}',
                onTap: () => _pickDate((d) => _endDate = d, _endDate),
              ),
            ),
            RowField(
              label: 'المبلغ',
              child: boxedText(_amountController, type: TextInputType.number),
            ),
            RowField(
              label: 'طريقة الدفع',
              child: PaymentMethodDropdown(
                controller: _paymentMethodController,
                onMethodSelected: (method) {
                  setState(() {
                    _selectedPaymentMethodId = method.id;
                    _paymentMethodController.text = method.name;
                  });
                },
              ),
            ),
            RowField(
              label: 'ملاحظات',
              child: boxedMultiline(_notesController),
            ),
            RowField(
              label: 'الملفات',
              child: _imagesUploadSection(),
            ),
            SizedBox(height: 20.h),
            BlocBuilder<AddSubscriptionCubit, AddSubscriptionState>(
              builder: (context, state) {
                return saveButton(
                  onPressed: state.status == AddSubscriptionStatus.loading
                      ? null
                      : _submit,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagesUploadSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset('assets/images/pngs/pictures_folder.png',
                  width: 90.w, height: 90.h),
              if (_imagePaths.isNotEmpty)
                Positioned(
                  top: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.red,
                    child: Text(_imagePaths.length.toString(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
              const Text('+',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        if (_imagePaths.isNotEmpty)
          SizedBox(
            height: 100.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _imagePaths.length,
              itemBuilder: (_, i) => Padding(
                padding: EdgeInsets.all(8.w),
                child: Stack(
                  children: [
                    Image.file(File(_imagePaths[i]),
                        width: 80.w, height: 80.h, fit: BoxFit.cover),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => setState(() => _imagePaths.removeAt(i)),
                        child:
                            const Icon(Icons.remove_circle, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ... (ClientSearchField, PaymentMethodDropdown كما هي في الكود الأصلي، نقلها إلى هذا الملف أو shared)
