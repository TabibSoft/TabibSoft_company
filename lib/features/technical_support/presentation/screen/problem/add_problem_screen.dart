import 'package:flutter/material.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_app_bar_widget.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_nav_bar_widget.dart';

class AddProblemScreen extends StatelessWidget {
  const AddProblemScreen({super.key});

  static const Color primaryColor = Color(0xFF56C7F1);
  static const Color secondaryColor = Color(0xFF75D6A9);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const navBarHeight = 60.0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: CustomAppBar(
                title: 'الدعم الفني',
                height: 480,
              ),
            ),
            Positioned.fill(
              top: 0,
              child: Stack(
                children: [
                  Positioned(
                    top: size.height * 0.33,
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
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio: 1.0,
                          children: const [
                            // _buildSupportButton(
                            //   context,
                            //   'assets/images/pngs/sales.png',
                            //   'جاري المتابعة',
                            //   () {},
                            // ),
                            // _buildSupportButton(
                            //   context,
                            //   'assets/images/pngs/sales.png',
                            //   'زياراتي',
                            //   () {},
                            // ),
                            // _buildSupportButton(
                            //   context,
                            //   'assets/images/pngs/sales.png',
                            //   'تم الحل',
                            //   () {},
                            // ),
                            // _buildSupportButton(
                            //   context,
                            //   'assets/images/pngs/sales.png',
                            //   'مؤجله',
                            //   () {},
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: size.height * 0.25,
                    left: size.width * 0.20,
                    right: size.width * 0.20,
                    child: InkWell(
                      onTap: () {
                        print('زر إضافة مشكلة تم الضغط عليه');
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: primaryColor,
                            width: 2.0,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/pngs/sales.png',
                              width: size.width * 0.08,
                              height: size.width * 0.08,
                            ),
                            const SizedBox(width: 25),
                            const Text(
                              'اضافة مشكلة',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: CustomNavBar(
          items: [
            GestureDetector(
              onTap: () {},
              child: Image.asset(
                'assets/images/pngs/sales.png',
                width: 28,
                height: 28,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Image.asset(
                'assets/images/pngs/sales.png',
                width: 28,
                height: 28,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Image.asset(
                'assets/images/pngs/sales.png',
                width: 28,
                height: 28,
              ),
            ),
          ],
          alignment: MainAxisAlignment.spaceAround,
          padding: const EdgeInsets.symmetric(horizontal: 32),
        ),
      ),
    );
  }

  Widget _buildSupportButton(
    BuildContext context,
    String iconPath,
    String label,
    VoidCallback onTap,
  ) {
    final size = MediaQuery.of(context).size;
    final buttonSize = size.width * 0.25;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: primaryColor,
            width: 2.0,
          ),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: buttonSize * 0.5,
              height: buttonSize * 0.5,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: primaryColor,
                fontSize: buttonSize * 0.12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
