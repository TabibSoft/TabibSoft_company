// lib/features/home/presentation/screens/home_screen.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tabib_soft_company/core/utils/cache/cache_helper.dart';
import 'package:tabib_soft_company/features/management/presentation/screens/management_screen.dart';
import 'package:tabib_soft_company/features/modirator/presentation/screens/mediator_screen.dart';
import 'package:tabib_soft_company/features/programmers/presentation/screens/programmers_screen.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/screens/sales_home_screen.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/screen/support_home/technical_support_screen.dart';
import 'package:tabib_soft_company/features/home/presentation/screens/nav_bar/settings.dart';

class HomeScreen  extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color primaryColor =
      Color(0xFF0F5FA8); // لون أزرق عميق يشبه الصورة
  static const Color accentColor = Color(0xFF19A7CE); // أزرق فاتح / سماوي
  static const Color lightBg = Color(0xFFF4F9FC); // خلفية خفيفة

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final userName = CacheHelper.getString(key: 'userName');
    final rawRoles = CacheHelper.getString(key: 'userRoles');
    final userRoles = (rawRoles.isNotEmpty) ? rawRoles.split(',') : <String>[];

    // Title logic (مبسط)
    String title;
    if (userRoles.contains('ADMIN') || userRoles.contains('MANAGEMENT')) {
      title = ' أهلا بالإدارة  ${userName.isNotEmpty ? userName : 'المستخدم'}';
    } else if (userRoles.contains('SALSE')) {
      title = 'أهلاً السيلز اللعيب ${userName.isNotEmpty ? userName : ''}';
    } else if (userRoles.contains('PROGRAMMERS')) {
      title = 'ملك الكودينج ${userName.isNotEmpty ? userName : ''}';
    } else if (userRoles.contains('SUPPORT')) {
      title = 'وحش الدعم  ${userName.isNotEmpty ? userName : ''}';
    } else {
      title = 'أهلاً ${userName.isNotEmpty ? userName : 'المستخدم'}';
    }

    // final jokes = [
    //   "اجمد كدا مفيش مهندس بيعيط 😎",
    //   'الtester لما بيغرق بيقول Bug Bug Bug 🐛',
    //   'ليه المبرمج مش بيخاف؟ لأنه متعود على الكراش 💥',
    //   'الدعم الفني دايمًا بيحلها... حتى لو بالكلام بس 😎',
    // ];
    // final randomJoke = (jokes..shuffle()).first;

    // إظهار فقاعة نكتة عائمة بعد البناء
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _showFloatingJoke(context, randomJoke);
    // });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: lightBg,
        // لا AppBar ولا BottomNavigationBar كما طلبت
        body: SafeArea(
          child: Stack(
            children: [
              // الخلفية العلوية المنحنية (مثل التصميم)
              Positioned(
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
                    // يمكن إضافة شكل منحني باستخدام borderRadius
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        // Greeting text
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: size.width * 0.05,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Logo
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
              ),

              // زر الإعدادات في أعلى اليسار (كما طلبت)
              Positioned(
                top: 12,
                left: 12,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/pngs/settings.png',
                      width: 26,
                      height: 26,
                    ),
                  ),
                ),
              ),

              // المحتوى الرئيسي: شبكه الأزرار
              Positioned(
                top: size.height * 0.30,
                left: 16,
                right: 16,
                bottom: 20,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      // شبكة 2x3
                      Expanded(
                        child: GridView.count(
                          physics: const BouncingScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 1.03,
                          children: [
                            _buildFeatureTile(
                              context: context,
                              iconPath: 'assets/images/pngs/manager.png',
                              label: 'الإدارة',
                              enabled: userRoles.contains('MANAGEMENT') ||
                                  userRoles.contains('ADMIN'),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ManagementScreen(),
                                ),
                              ),
                              primaryColor: accentColor,
                            ),
                            _buildFeatureTile(
                              context: context,
                              iconPath: 'assets/images/pngs/sales.png',
                              label: 'المبيعات',
                              enabled: userRoles.contains('SALSE') ||
                                  userRoles.contains('ADMIN'),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SalesHomeScreen(),
                                ),
                              ),
                              primaryColor: primaryColor,
                            ),
                            _buildFeatureTile(
                              context: context,
                              iconPath: 'assets/images/pngs/developers.png',
                              label: 'المبرمجين',
                              enabled: userRoles.contains('PROGRAMMERS') ||
                                  userRoles.contains('ADMIN'),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ProgrammersScreen(),
                                ),
                              ),
                              primaryColor: primaryColor,
                            ),
                            _buildFeatureTile(
                              context: context,
                              iconPath:
                                  'assets/images/pngs/technical_support.png',
                              label: 'الدعم الفني',
                              enabled: userRoles.contains('SUPPORT') ||
                                  userRoles.contains('ADMIN'),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const TechnicalSupportScreen(),
                                ),
                              ),
                              primaryColor: accentColor,
                            ),
                            _buildFeatureTile(
                              context: context,
                              iconPath:
                                  'assets/images/pngs/icons8-find-user-40 1.png',
                              label: 'الوسيط',
                              enabled: true,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const MediatorScreen()),
                              ),
                              primaryColor: accentColor,
                            ),
                            _buildFeatureTile(
                              context: context,
                              iconPath:
                                  'assets/images/pngs/icons8-scroll-up-40 1.png',
                              label: 'المتابعة',
                              enabled: true,
                              onTap: () {
                                // action for follow up
                              },
                              primaryColor: primaryColor,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // optional small hint / copyright
                      // Text(
                      //   'TabibSoft',
                      //   style: TextStyle(
                      //     color: Colors.grey[500],
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // ),
                      // const SizedBox(height: 6),
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

  // Tile builder helper
  Widget _buildFeatureTile({
    required BuildContext context,
    required String iconPath,
    required String label,
    required VoidCallback onTap,
    required bool enabled,
    required Color primaryColor,
  }) {
    final size = MediaQuery.of(context).size;
    return HomeButton(
      iconPath: iconPath,
      label: label,
      onTap: onTap,
      enabled: enabled,
      primaryColor: primaryColor,
    );
  }
}

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
    this.primaryColor = HomeScreen.primaryColor,
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
            // أيقونة
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
                // <-- show original colors when enabled; gray tint when disabled
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
      'إنت بتعمل إيه هنا؟ 😅',
      'لو ضغطت تاني هنبلغ الإدارة 😂',
      'ده مش ليك يا نجم 🤭',
      'حاول في مكان تاني يا بطل 🕵️‍♂️',
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

// Extension to darken a color slightly
extension ColorBrightness on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final h = this;
    return Color.fromARGB(
      h.alpha,
      (h.red * (1 - amount)).round(),
      (h.green * (1 - amount)).round(),
      (h.blue * (1 - amount)).round(),
    );
  }
}
