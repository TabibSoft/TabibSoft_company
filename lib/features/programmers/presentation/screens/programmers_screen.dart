import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_app_bar_widget.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_nav_bar_widget.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/engineer_cubit.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/engineer_state.dart';
import 'package:tabib_soft_company/features/programmers/presentation/widgets/programmers_details_screen.dart';

// الصفحة الرئيسية
class ProgrammersScreen extends StatefulWidget {
  const ProgrammersScreen({super.key});

  @override
  State<ProgrammersScreen> createState() => _ProgrammersScreenState();
}

class _ProgrammersScreenState extends State<ProgrammersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<EngineerCubit>().fetchEngineers();
  }

  // بيانات اختبارية مؤقتة
  final List<Map<String, String>> testData = [
    {"programType": "عيادة أطفال", "modification": "إضافة صور للمرضى"},
    {"programType": "عيادة باطنة", "modification": "تحديث بيانات المرضى"},
    {"programType": "عيادة أسنان", "modification": "إضافة مواعيد الحجز"},
    {"programType": "عيادة عيون", "modification": "تحسين واجهة المستخدم"},
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            /// الـ AppBar في أعلى الصفحة
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: CustomAppBar(
                title: 'المبرمجين',
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

            /// المربع الشفاف المُتواجد مسبقًا
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

            /// الحاوية الجديدة مع ListView.builder لتكرار الكروت
            Positioned(
              top: size.height * 0.23 + 16,
              left: size.width * 0.05 + 16,
              right: size.width * 0.05 + 16,
              bottom: 16,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: testData.length,
                itemBuilder: (context, index) {
                  final item = testData[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => programmersDetails(
                              programType: item["programType"]!,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 334,
                        height: 146,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: const Color(0xFF178CBB),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'نوع البرنامج: ',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff178CBB),
                                      ),
                                    ),
                                    TextSpan(
                                      text: item["programType"],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'التعديل: ',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff178CBB),
                                      ),
                                    ),
                                    TextSpan(
                                      text: item["modification"],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
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

// صفحة التفاصيل
