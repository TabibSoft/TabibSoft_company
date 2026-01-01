import 'package:flutter/material.dart';

class AppColor {
  static const Color backGroundColor = Color(0xFFFFFFFF);
  static const Color primaryColor = Color(0xFF00337C);
  static const Color secondaryColor = Color(0xFFF4A800);
  static const Color titleColor = Color(0xFF001233);
  static const Color subTitleColor = Color(0xFF7D848D);
  static const Color whiteColor = Color(0xFFEFEFEF);
  static const Color whiteBlueColor = Color(0xFFD6F8FF);

  static const Color borderColor = Color(0xFFFFC10D);
  static const Color hintColor = Color(0xFFAEAEAE);
  static const Color containerColor = Color(0xFFF8F8F8);
  static const Color borderContainerColor = Color(0xFFF5F5F5);
  static const Color accentColor = Color(0xFF19A7CE);
  static const Color lightBg = Color(0xFFF4F9FC);
}

class SalesColors {
  // الألوان الأساسية
  static const Color primaryOrange = Color(0xFFFF6D00);
  static const Color primaryBlue = Color(0xFF1976D2);
  static const Color secondaryBlue = Color(0xFF2196F3);
  static const Color accentBlue = Color(0xFF64B5F6);
  static const Color deepBlue = Color(0xFF0D47A1);

  // ألوان الخلفية
  static const Color cardBackground = Color(0xFFF8FAFF);
  static const Color surfaceLight = Color(0xFFF0F5FF);

  // ألوان النص
  static const Color textPrimary = Color(0xFF1A2332);
  static const Color textSecondary = Color(0xFF546E7A);
  static const Color textMuted = Color(0xFF90A4AE);

  // ألوان الحدود والظلال
  static const Color borderLight = Color(0xFFE3F2FD);
  static const Color borderMedium = Color(0xFFBBDEFB);
  static const Color successGreen = Color(0xFF4CAF50);

  // تدرجات
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, secondaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [secondaryBlue, accentBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [deepBlue, primaryBlue, secondaryBlue],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

class TechColors {
  // Premium Blue Palette
  static const Color primaryDark = Color(0xFF0A2647);
  static const Color primaryMid = Color(0xFF144272);
  static const Color accentCyan = Color(0xFF2C7DA0);
  static const Color accentLight = Color(0xFF89C2D9);

  // Surfaces & Backgrounds
  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color cardBg = Color(0xFFFFFFFF);

  // Semantic Colors
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);

  // Gradients
  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryDark,
      primaryMid,
      accentCyan,
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [accentCyan, primaryMid],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
