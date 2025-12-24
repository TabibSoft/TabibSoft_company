import 'package:flutter/material.dart';
import 'package:tabib_soft_company/features/home/presentation/screens/nav_bar/settings.dart';

class HomeSettingsButton extends StatelessWidget {
  const HomeSettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12,
      left: 12,
      child: GestureDetector(
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Image.asset('assets/images/pngs/settings.png',
              width: 26, height: 26),
        ),
      ),
    );
  }
}
