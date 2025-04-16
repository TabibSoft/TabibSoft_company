import 'package:flutter/material.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_app_bar_widget.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_nav_bar_widget.dart';

class programmersDetails extends StatelessWidget {
  final String programType;

  const programmersDetails({super.key, required this.programType});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: CustomAppBar(
                title: programType,
                height: 332,
                leading: IconButton(
                  icon: Image.asset(
                    'assets/images/pngs/back.png',
                    width: 30,
                    height: 30,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),

            Positioned(
              top: size.height * 0.23,
              left: size.width * 0.05,
              right: size.width * 0.05,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 95, 93, 93).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF56C7F1), width: 3),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: const CustomNavBar(
          items: [],
          alignment: MainAxisAlignment.spaceBetween,
          padding: EdgeInsets.symmetric(horizontal: 32),
        ),
      ),
    );
  }
}
