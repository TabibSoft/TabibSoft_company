import 'package:flutter/material.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';
import 'package:tabib_soft_company/features/home/presentation/screens/nav_bar/settings.dart';

class HomeSettingsButton extends StatelessWidget {
  const HomeSettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 45,
      left: 16,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 1000),
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const SettingsScreen())),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Center(
              child: Image.asset(
                'assets/images/pngs/settings.png',
                width: 24,
                height: 24,
                color: TechColors.primaryDark,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
