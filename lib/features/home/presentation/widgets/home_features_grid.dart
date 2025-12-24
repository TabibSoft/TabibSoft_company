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
      top: size.height * 0.30,
      left: 16,
      right: 16,
      bottom: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 6))
          ],
        ),
        child: GridView.count(
          physics: const BouncingScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.03,
          children: [
            // الإدارة
            _buildFeatureTile(
              context: context,
              iconPath: 'assets/images/pngs/manager.png',
              label: 'الإدارة',
              enabled: isAdmin || userRoles.contains('MANAGEMENT'),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ManagementScreen())),
              primaryColor: AppColor.accentColor,
            ),

            // المبيعات
            _buildFeatureTile(
              context: context,
              iconPath: 'assets/images/pngs/sales.png',
              label: 'المبيعات',
              enabled: isAdmin || userRoles.contains('SALSE'),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SalesHomeScreen())),
              primaryColor: AppColor.primaryColor,
            ),

            // المبرمجين
            _buildFeatureTile(
              context: context,
              iconPath: 'assets/images/pngs/developers.png',
              label: 'المبرمجين',
              enabled: isAdmin || userRoles.contains('PROGRAMMER'),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProgrammersScreen())),
              primaryColor: AppColor.primaryColor,
            ),

            // الدعم الفني
            _buildFeatureTile(
              context: context,
              iconPath: 'assets/images/pngs/technical_support.png',
              label: 'الدعم الفني',
              enabled: isAdmin || userRoles.contains('SUPPORT'),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const TechnicalSupportChoiseScreen())),
              primaryColor: AppColor.accentColor,
            ),

            // الوسيط
            _buildFeatureTile(
              context: context,
              iconPath: 'assets/images/pngs/icons8-find-user-40 1.png',
              label: 'الوسيط',
              enabled: isAdmin || isModerator,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ModeratorScreen())),
              primaryColor: AppColor.accentColor,
            ),

            // المتابعة
            _buildFeatureTile(
              context: context,
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
              primaryColor: AppColor.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required BuildContext context,
    required String iconPath,
    required String label,
    required VoidCallback onTap,
    required bool enabled,
    required Color primaryColor,
  }) {
    return HomeButton(
      iconPath: iconPath,
      label: label,
      onTap: onTap,
      enabled: enabled,
      primaryColor: primaryColor,
    );
  }
}
