import 'dart:io'; // فقط إذا أردت استخدام الصورة المرفوعة بالمسار /mnt/data/...
import 'package:flutter/material.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/screen/support_home/technical_support_screen.dart';
import 'package:tabib_soft_company/features/technical_support/visits/presentation/screens/visits_and_installs_screen.dart';

class TechnicalSupportChoiseScreen extends StatelessWidget {
  const TechnicalSupportChoiseScreen({super.key});

  // --- Helper button builder to keep code clean
  Widget _buildChoiceButton({
    required BuildContext context,
    required String text,
    required VoidCallback onTap,
  }) {
    final width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width * 0.82,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(48),
          border: Border.all(color: const Color(0xFF1E8CB0), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              offset: const Offset(0, 6),
              blurRadius: 10,
            ),
            // subtle inner shadow effect imitation
          ],
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0E5E8A),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      // اجبار اتجاه RTL
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // الخلفية العلوية بالتدرج
            Container(
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color.fromARGB(255, 9, 57, 121), Color(0xFF20AAC9)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/pngs/TS_Logo0.png',
                          width: 140,
                          height: 140,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 10),
                        Image.asset(
                          'assets/images/pngs/TabibSoft CRM.png',
                          width: 220,
                          height: 48,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.5,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF4F8FB),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(36),
                        topRight: Radius.circular(36),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildChoiceButton(
                          context: context,
                          text: 'دعم فني اونلاين',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TechnicalSupportScreen(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // زر ٢
                        _buildChoiceButton(
                          context: context,
                          text: 'زيارات و تسطيبات',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const VisitsAndInstallsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
