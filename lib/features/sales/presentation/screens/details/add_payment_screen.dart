import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'package:tabib_soft_company/features/sales/data/model/details/payment_method_model.dart';

class AddPaymentPopup extends StatefulWidget {
  final String measurementId;
  final double totalAmount;
  final ApiService apiService;

  const AddPaymentPopup({
    super.key,
    required this.measurementId,
    required this.totalAmount,
    required this.apiService,
  });

  @override
  State<AddPaymentPopup> createState() => _AddPaymentPopupState();
}

class _AddPaymentPopupState extends State<AddPaymentPopup> {
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _paidController = TextEditingController();
  final TextEditingController _remainingController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedPaymentMethod;
  List<PaymentMethodModel> _paymentMethods = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _remainingController.text = widget.totalAmount.toStringAsFixed(0);
    _discountController.addListener(_updateRemaining);
    _paidController.addListener(_updateRemaining);
    _fetchPaymentMethods();
  }

  Future<void> _fetchPaymentMethods() async {
    try {
      final methods = await widget.apiService.getAllPaymentMethods();
      setState(() {
        _paymentMethods = methods;
      });
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في جلب طرق الدفع')),
      );
    }
  }

  void _updateRemaining() {
    final total = widget.totalAmount;
    final discount = double.tryParse(_discountController.text) ?? 0;
    final paid = double.tryParse(_paidController.text) ?? 0;
    _remainingController.text = (total - discount - paid).toStringAsFixed(0);
  }

  @override
  void dispose() {
    _discountController
      ..removeListener(_updateRemaining)
      ..dispose();
    _paidController
      ..removeListener(_updateRemaining)
      ..dispose();
    _remainingController.dispose();
    _noteController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = picked.toIso8601String().split('T').first;
      });
    }
  }

  Future<void> _submitPayment() async {
    if (_paidController.text.isEmpty ||
        _selectedDate == null ||
        _selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await widget.apiService.addPayment(
        PaymentDate: _selectedDate!.toIso8601String(),
        PaymentNote: _noteController.text,
        Value: double.parse(_paidController.text),
        MeasurementId: widget.measurementId,
        payMethodId: _selectedPaymentMethod!,
      );
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إضافة الدفع بنجاح')),
      );
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في إضافة الدفع: ${e.message}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.9;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF56C7F1), width: 3),
        ),
        backgroundColor: const Color(0xFFFFF9F9),
        content: SingleChildScrollView(
          child: SizedBox(
            width: width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // الإجمالي
                Text(
                  'الإجمالي: ${widget.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                // الخصم
                _buildRowField('الخصم:', _discountController),
                const SizedBox(height: 8),
                // المدفوع
                _buildRowField('المدفوع:', _paidController),
                const SizedBox(height: 8),
                // الباقي
                _buildRowField('الباقي:', _remainingController, enabled: false),
                const SizedBox(height: 16),
                // طريقة الدفع
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    hintText: 'طريقة الدفع',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide:
                          const BorderSide(color: Color(0xFF56C7F1), width: 2),
                    ),
                  ),
                  value: _selectedPaymentMethod,
                  items: _paymentMethods.map((method) {
                    return DropdownMenuItem(
                      value: method.id,
                      child: Text(method.name),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedPaymentMethod = v),
                ),
                const SizedBox(height: 16),
                // تاريخ الدفع
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _dateController,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        labelText: 'تاريخ الدفع',
                        labelStyle:
                            const TextStyle(color: Colors.grey, fontSize: 16),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 20),
                        suffixIcon: const Icon(
                          Icons.calendar_today,
                          color: Color(0xFF56C7F1),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                              color: Color(0xFF56C7F1), width: 2),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // ملاحظات
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    labelText: 'ملاحظات',
                    labelStyle:
                        const TextStyle(color: Colors.grey, fontSize: 16),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide:
                          const BorderSide(color: Color(0xFF56C7F1), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // زر حفظ
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF56C7F1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text(
                            'حفظ',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRowField(String label, TextEditingController controller,
      {bool enabled = true}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            enabled: enabled,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              filled: true,
              fillColor: enabled ? Colors.white : Colors.grey[200],
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide:
                    const BorderSide(color: Color(0xFF56C7F1), width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide:
                    const BorderSide(color: Color(0xFF56C7F1), width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
