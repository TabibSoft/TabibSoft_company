import 'package:flutter/material.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';
import 'package:tabib_soft_company/features/home/presentation/widgets/home_button.dart';
import 'package:tabib_soft_company/features/management/presentation/screens/management_screen.dart';
import 'package:tabib_soft_company/features/modirator/presentation/screens/mediator_screen.dart';
import 'package:tabib_soft_company/features/programmers/presentation/screens/programmers_screen.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/screens/sales_home_screen.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/screen/support_home/technical_support_choise_screen.dart'
    show TechnicalSupportChoiseScreen;

class HomeFeaturesGrid extends StatelessWidget {
  final List<String> userRoles;

  const HomeFeaturesGrid({super.key, required this.userRoles});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isAdmin = userRoles.contains('ADMIN');
    final bool isModerator = userRoles.contains('MODERATOR');
    final bool isTracker = userRoles.contains('TRACKER');

    return Positioned(
      top: size.height * 0.32, // Adjusted for new header height
      left: 20,
      right: 20,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(36),
            topRight: Radius.circular(36),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 30,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: GridView.count(
          physics: const BouncingScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 18,
          crossAxisSpacing: 18,
          childAspectRatio: 1.05,
          children: [
            // الإدارة
            HomeButton(
              index: 0,
              iconPath: 'assets/images/pngs/manager.png',
              label: 'الإدارة',
              enabled: isAdmin || userRoles.contains('MANAGEMENT'),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ManagementScreen())),
              primaryColor: TechColors.primaryDark,
            ),

            // المبيعات
            HomeButton(
              index: 1,
              iconPath: 'assets/images/pngs/sales.png',
              label: 'المبيعات',
              enabled: isAdmin || userRoles.contains('SALSE'),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SalesHomeScreen())),
              primaryColor: TechColors.accentCyan,
            ),

            // المبرمجين
            HomeButton(
              index: 2,
              iconPath: 'assets/images/pngs/developers.png',
              label: 'المبرمجين',
              enabled: isAdmin || userRoles.contains('PROGRAMMER'),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProgrammersScreen())),
              primaryColor: TechColors.primaryMid,
            ),

            // الدعم الفني
            HomeButton(
              index: 3,
              iconPath: 'assets/images/pngs/technical_support.png',
              label: 'الدعم الفني',
              enabled: isAdmin || userRoles.contains('SUPPORT'),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const TechnicalSupportChoiseScreen())),
              primaryColor: TechColors.accentCyan,
            ),

            // الوسيط
            HomeButton(
              index: 4,
              iconPath: 'assets/images/pngs/icons8-find-user-40 1.png',
              label: 'الوسيط',
              enabled: isAdmin || isModerator,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ModeratorScreen())),
              primaryColor: TechColors.primaryDark,
            ),

            // المتابعة
            HomeButton(
              index: 5,
              iconPath: 'assets/images/pngs/icons8-scroll-up-40 1.png',
              label: 'المتابعة',
              enabled: isAdmin || isTracker,
              onTap: () {
                if (isAdmin || isTracker) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('شاشة المتابعة قيد التطوير')),
                  );
                }
              },
              primaryColor: TechColors.primaryMid,
            ),
            const SizedBox(height: 80), // Padding for bottom
          ],
        ),
      ),
    );
  }
}
