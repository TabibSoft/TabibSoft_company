import 'package:flutter/material.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';

class HomeHeader extends StatelessWidget {
  final String title;

  const HomeHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: size.height * 0.36,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEFF9FF), Color(0xFFDFF6FB)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: size.width * 0.05,
                  fontWeight: FontWeight.bold,
                  color: AppColor.primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Image.asset(
                'assets/images/pngs/TS Logo Final 1.png',
                width: size.width * 0.67,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
