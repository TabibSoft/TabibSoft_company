import 'package:flutter/material.dart';
import 'package:tabib_soft_company/core/utils/cache/cache_helper.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_app_bar_widget.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_nav_bar_widget.dart';
import 'package:tabib_soft_company/features/programmers/presentation/screens/programmers_screen.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/screen/support_home/technical_support_screen.dart';
import 'package:tabib_soft_company/features/auth/presentation/screens/login/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static const Color primaryColor = Color(0xFF56C7F1);
  static const Color secondaryColor = Color(0xFF75D6A9);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const navBarHeight = 60.0;
    // جلب اسم المستخدم من SharedPreferences (في حالة تم تخزينه)
    final userName = CacheHelper.getString(key: 'userName');

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            // AppBar مع عرض اسم المستخدم
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: CustomAppBar(
                logoAsset: 'assets/images/pngs/tabibLogo.png',
                title:
                    'شوف شغلك يا ${userName.isNotEmpty ? userName : 'المستخدم'}',
                height: 480,
              ),
            ),
            // المحتوى الرئيسي مع البطاقات
            Positioned.fill(
              top: 0,
              child: Stack(
                children: [
                  // خلفية رمادية
                  Positioned(
                    top: size.height * 0.35,
                    left: size.width * 0.05,
                    right: size.width * 0.05,
                    bottom: navBarHeight + 20,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 95, 93, 93)
                            .withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: primaryColor,
                          width: 3.0,
                        ),
                      ),
                    ),
                  ),
                  // أربع أزرار رئيسية
                  Positioned(
                    top: size.height * 0.4,
                    left: size.width * 0.1,
                    right: size.width * 0.1,
                    bottom: navBarHeight + 40,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildHomeButton(
                          context,
                          'assets/images/pngs/manager.png',
                          'الإدارة',
                          () {},
                        ),
                        _buildHomeButton(
                          context,
                          'assets/images/pngs/developers.png',
                          'المبرمجين',
                          () {
                              Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ProgrammersScreen(),
                              ),
                            );
                          },
                        ),
                        _buildHomeButton(
                          context,
                          'assets/images/pngs/technical_support.png',
                          'الدعم الفني',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TechnicalSupportScreen(),
                              ),
                            );
                          },
                        ),
                        _buildHomeButton(
                          context,
                          'assets/images/pngs/sales.png',
                          'مبيعات',
                          () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // شريط تنقل سفلي
        bottomNavigationBar: CustomNavBar(
          items: [
            GestureDetector(
              onTap: () {},
              child: Image.asset(
                'assets/images/pngs/list.png',
                width: 33,
                height: 33,
              ),
            ),
            const Spacer(), // Add spacer to push items apart
            GestureDetector(
              onTap: () {},
              child: Image.asset(
                'assets/images/pngs/settings.png',
                width: 33,
                height: 33,
              ),
            ),
          ],
          alignment: MainAxisAlignment.spaceBetween,
          padding: const EdgeInsets.symmetric(horizontal: 32),
        ),
      ),
    );
  }

  Widget _buildHomeButton(
    BuildContext context,
    String iconPath,
    String label,
    VoidCallback onTap,
  ) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.08,
      width: MediaQuery.of(context).size.width * 0.60,
      child: HomeButton(
        iconPath: iconPath,
        label: label,
        onTap: onTap,
      ),
    );
  }
}

class HomeButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const HomeButton({
    super.key,
    required this.iconPath,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  static const Color primaryColor = HomeScreen.primaryColor;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        decoration: BoxDecoration(
          color: active ? primaryColor.withOpacity(0.2) : Colors.white,
          border: Border.all(color: primaryColor, width: 1),
          borderRadius: BorderRadius.circular(30),
        ),
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: size.width * 0.1,
              height: size.width * 0.1,
            ),
            SizedBox(width: size.width * 0.04),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: active ? primaryColor : Colors.grey[800],
                  fontSize: size.width * 0.06,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
