import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';

class HomeButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final Color primaryColor;

  const HomeButton({
    super.key,
    required this.iconPath,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.primaryColor = AppColor.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return InkWell(
      onTap: enabled ? onTap : () => _showToast(context),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding:
            EdgeInsets.symmetric(vertical: size.width * 0.04, horizontal: 12),
        decoration: BoxDecoration(
          color:
              enabled ? primaryColor.withOpacity(0.12) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                enabled ? primaryColor.withOpacity(0.18) : Colors.grey.shade300,
            width: 1.6,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: enabled
                    ? primaryColor.withOpacity(0.14)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                iconPath,
                width: size.width * 0.12,
                height: size.width * 0.12,
                color: enabled ? null : Colors.grey,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: size.height * 0.015),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: enabled ? primaryColor.darken(0.1) : Colors.grey,
                fontSize: size.width * 0.048,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showToast(BuildContext context) {
    final responses = [
      'إنت بتعمل إيه هنا؟',
      'لو ضغطت تاني هنبلغ الإدارة',
      'ده مش ليك يا نجم',
      'حاول في مكان تاني يا بطل',
      'بس يا بــابــا'
    ];
    final random = Random().nextInt(responses.length);
    Fluttertoast.showToast(
      msg: responses[random],
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}

extension ColorBrightness on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    return Color.fromARGB(
      alpha,
      (red * (1 - amount)).round(),
      (green * (1 - amount)).round(),
      (blue * (1 - amount)).round(),
    );
  }
}
