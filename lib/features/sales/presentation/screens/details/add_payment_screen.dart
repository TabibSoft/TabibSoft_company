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
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _paidController = TextEditingController();
  final TextEditingController _remainingController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedPaymentMethod;
  List<PaymentMethodModel> _paymentMethods = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPaymentMethods();
    _remainingController.text = widget.totalAmount.toStringAsFixed(0);
    _amountController.addListener(_updatePaymentFields);
    _discountController.addListener(_updatePaymentFields);
    _paidController.addListener(_updatePaymentFields);
  }

  void _updatePaymentFields() {
    final total = widget.totalAmount;
    final discount = double.tryParse(_discountController.text) ?? 0;
    final paid = double.tryParse(_paidController.text) ?? 0;
    
    final remaining = total - discount - paid;
    _remainingController.text = remaining.toStringAsFixed(0);
    
    // Update the amount controller with the paid value
    if (_amountController.text != _paidController.text) {
      _amountController.text = _paidController.text;
    }
  }

  @override
  void dispose() {
    _amountController.removeListener(_updatePaymentFields);
    _discountController.removeListener(_updatePaymentFields);
    _paidController.removeListener(_updatePaymentFields);
    super.dispose();
  }

  Future<void> _fetchPaymentMethods() async {
    try {
      final response = await widget.apiService.getAllPaymentMethods();
      setState(() {
        _paymentMethods = response;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في جلب طرق الدفع')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitPayment() async {
    if (_amountController.text.isEmpty ||
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
        Value: double.parse(_amountController.text),
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
        backgroundColor: const Color.fromARGB(255, 255, 249, 249),
        content: SizedBox(
          width: width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ==== سطر الإجمالي ====
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      ':الإجمالي',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${widget.totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ==== حقل الخصم ====
              _buildPaymentField(
                controller: _discountController,
                label: 'الخصم',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),

              // ==== حقل المدفوع ====
              _buildPaymentField(
                controller: _paidController,
                label: 'المدفوع',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),

              // ==== حقل الباقي ====
              _buildPaymentField(
                controller: _remainingController,
                label: 'الباقي',
                keyboardType: TextInputType.number,
                isEnabled: false,
              ),
              const SizedBox(height: 16),

              // ==== طريقة الدفع ====
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  hintText: 'طريقة الدفع',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: const Color(0xFF56C7F1).withOpacity(0.5),
                        width: 1.5),
                  ),
                ),
                value: _selectedPaymentMethod,
                items: _paymentMethods.map((method) {
                  return DropdownMenuItem<String>(
                    value: method.id,
                    child: Text(method.name),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedPaymentMethod = value),
              ),
              const SizedBox(height: 16),

              // ==== تاريخ الدفع ====
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: _buildPaymentField(
                    controller: TextEditingController(
                      text: _selectedDate != null
                          ? _selectedDate!.toString().split(' ')[0]
                          : '',
                    ),
                    label: 'تاريخ الدفع',
                    suffixIcon: const Icon(
                      Icons.calendar_today,
                      color: Color(0xFF56C7F1),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ==== ملاحظات ====
              _buildPaymentField(
                controller: _noteController,
                label: 'ملاحظات',
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // ==== زر حفظ ====
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF56C7F1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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
    );
  }

  Widget _buildPaymentField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    int maxLines = 1,
    bool isEnabled = true,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: isEnabled,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 16),
        filled: true,
        fillColor: isEnabled ? Colors.white : Colors.grey[200],
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: const Color(0xFF56C7F1).withOpacity(0.5), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: const Color(0xFF56C7F1).withOpacity(0.5), width: 1.5),
        ),
      ),
    );
  }
}
