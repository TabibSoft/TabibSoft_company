import 'package:flutter/material.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';
import 'package:tabib_soft_company/core/utils/constant/constants.dart';
import 'package:tabib_soft_company/features/home/presentation/widgets/home_button.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/screens/human_resources_screen.dart';
import 'package:tabib_soft_company/features/management/presentation/screens/management_screen.dart';
import 'package:tabib_soft_company/features/modirator/presentation/screens/mediator_screen.dart';
import 'package:tabib_soft_company/features/programmers/presentation/screens/programmers_screen.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/screens/sales_home_screen.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/screen/support_home/technical_support_choise_screen.dart'
    show TechnicalSupportChoiseScreen;

class HomeFeaturesGrid extends StatelessWidget {
  final List<String> userRoles;

  const HomeFeaturesGrid({super.key, required this.userRoles});

  void _handleSalesNavigation(BuildContext context, List<String> roles) {
    final hasSales = roles.contains('SALSE');
    final hasSalesAdmin = roles.contains('SALESADMIN');

    // إذا كان لديه كلا الدورين، اعرض دايلوج للاختيار
    if (hasSales && hasSalesAdmin) {
      _showRoleSelectionDialog(context);
    } else if (hasSalesAdmin) {
      // الانتقال إلى صفحة SalesAdmin
      Navigator.pushNamed(context, salesAdminRequirementsScreen);
    } else {
      // الانتقال إلى صفحة Sales العادية
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SalesHomeScreen()),
      );
    }
  }

  void _showRoleSelectionDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation1, animation2) {
        return const SizedBox();
      },
      transitionBuilder: (context, a1, a2, widget) {
        final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
          child: Opacity(
            opacity: a1.value,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                backgroundColor: Colors.white,
                elevation: 10,
                contentPadding: const EdgeInsets.all(20),
                title: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFF104D9D).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_user_outlined,
                        size: 40,
                        color: Color(0xFF104D9D),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'اختيار الصلاحيات ',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ' هتبيع ولا هتراقبهم ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildRoleOption(
                      context,
                      title: 'المبيعات',
                      subtitle: 'الدخول لصلاحيات السيلز ',
                      icon: Icons.person_outline_rounded,
                      color: const Color(0xFF20AAC9),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SalesHomeScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildRoleOption(
                      context,
                      title: 'إدارة المبيعات',
                      subtitle: 'الدخول لصلاحيات المدير',
                      icon: Icons.admin_panel_settings_outlined,
                      color: const Color(0xFF104D9D),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                            context, salesAdminRequirementsScreen);
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: color.withOpacity(0.1),
        highlightColor: color.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.15), width: 1.5),
            borderRadius: BorderRadius.circular(20),
            color: color.withOpacity(0.03),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.withOpacity(0.1),
                ),
                padding: const EdgeInsets.all(6),
                child: Icon(Icons.arrow_forward_ios_rounded,
                    color: color, size: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isAdmin = userRoles.contains('ADMIN');
    final bool isModerator = userRoles.contains('MODERATOR');
    final bool isTracker = userRoles.contains('TRACKER');
    const bool canAccessHr = true;

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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final buttonWidth = (constraints.maxWidth - 18) / 2;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Wrap(
                    spacing: 18,
                    runSpacing: 18,
                    children: [
                      SizedBox(
                        width: buttonWidth,
                        child: HomeButton(
                          index: 0,
                          iconPath: 'assets/images/pngs/manager.png',
                          label: 'الإدارة',
                          enabled: isAdmin || userRoles.contains('MANAGEMENT'),
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ManagementScreen())),
                          primaryColor: TechColors.primaryDark,
                        ),
                      ),
                      SizedBox(
                        width: buttonWidth,
                        child: HomeButton(
                          index: 1,
                          iconPath: 'assets/images/pngs/sales.png',
                          label: 'المبيعات',
                          enabled: isAdmin ||
                              userRoles.contains('SALSE') ||
                              userRoles.contains('SALESADMIN'),
                          onTap: () =>
                              _handleSalesNavigation(context, userRoles),
                          primaryColor: TechColors.accentCyan,
                        ),
                      ),
                      SizedBox(
                        width: buttonWidth,
                        child: HomeButton(
                          index: 2,
                          iconPath: 'assets/images/pngs/developers.png',
                          label: 'المبرمجين',
                          enabled: isAdmin || userRoles.contains('PROGRAMMER'),
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ProgrammersScreen())),
                          primaryColor: TechColors.primaryMid,
                        ),
                      ),
                      SizedBox(
                        width: buttonWidth,
                        child: HomeButton(
                          index: 3,
                          iconPath: 'assets/images/pngs/technical_support.png',
                          label: 'الدعم الفني',
                          enabled: isAdmin || userRoles.contains('SUPPORT'),
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const TechnicalSupportChoiseScreen())),
                          primaryColor: TechColors.accentCyan,
                        ),
                      ),
                      SizedBox(
                        width: buttonWidth,
                        child: HomeButton(
                          index: 4,
                          iconPath:
                              'assets/images/pngs/icons8-find-user-40 1.png',
                          label: 'الوسيط',
                          enabled: isAdmin || isModerator,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ModeratorScreen())),
                          primaryColor: TechColors.primaryDark,
                        ),
                      ),
                      SizedBox(
                        width: buttonWidth,
                        child: HomeButton(
                          index: 5,
                          iconPath:
                              'assets/images/pngs/icons8-scroll-up-40 1.png',
                          label: 'المتابعة',
                          enabled: isAdmin || isTracker,
                          onTap: () {
                            if (isAdmin || isTracker) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('شاشة المتابعة قيد التطوير')),
                              );
                            }
                          },
                          primaryColor: TechColors.primaryMid,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: HomeButton(
                      index: 6,
                      iconPath: 'assets/images/pngs/manager.png',
                      label: 'HR',
                      enabled: canAccessHr,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HumanResourcesScreen(),
                        ),
                      ),
                      primaryColor: TechColors.primaryMid,
                      isWide: true,
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
