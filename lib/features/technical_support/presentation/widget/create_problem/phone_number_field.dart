import 'package:flutter/material.dart';

class PhoneNumberField extends StatelessWidget {
  final TextEditingController controller;

  const PhoneNumberField({
    super.key,
    required this.controller,
  });

  static const Color primaryColor = Color(0xFF56C7F1);

  InputDecoration _buildPhoneDecoration() {
    return InputDecoration(
      hintText: 'رقم التواصل',
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
      suffixIcon: Padding(
        padding: const EdgeInsets.only(right: 15.0, left: 19),
        child:
            Image.asset('assets/images/pngs/phone.png', width: 24, height: 24),
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide:
            BorderSide(color: primaryColor.withOpacity(0.5), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide:
            BorderSide(color: primaryColor.withOpacity(0.5), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.phone,
      decoration: _buildPhoneDecoration(),
    );
  }
}