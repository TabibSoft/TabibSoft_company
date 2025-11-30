import 'package:flutter/material.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_app_bar_widget.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_nav_bar_widget.dart';

/// شاشة الإدارة - واجهة مُعدّلة لتطابق التصميم المحفوظ (الألوان، الكروت، الصور، التنسيقات)
class ManagementScreen extends StatefulWidget {
  const ManagementScreen({super.key});

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  @override
  // كمثال احتفظت بالتعليق الخاص بالـ logic الذي كان موجودًا مسبقًا
  // void initState() {
  //   super.initState();
  //   context.read<EngineerCubit>().fetchEngineers();
  // }

  // ملاحظة: هنا لم أغيّر أي منطق موجود — عدّلت فقط واجهة المستخدم لتطابق المرجع المحفوظ.

  @override
  Widget build(BuildContext context) {
    // ألوان التصميم (مطابقة للمرجع المحفوظ)
    const mainBlueColor = Color(0xFF16669E);
    const sheetColor = Color(0xFFF5F7FA);
    const borderCardColor = Color(0xFF20AAC9);
    const shadowBlue = Color(0xff104D9D);

    final size = MediaQuery.of(context).size;

    // مثال بيانات عرضية للـ UI فقط (يمكن استبدالها بالبيانات الحقيقية من الـ logic)
    final sampleItems = List.generate(6, (i) {
      return {
        'customerName': 'العميل ${i + 1}',
        'visitDate': DateTime.now().subtract(Duration(days: i)),
        'productName': 'منتج ${i + 1}',
        'address': 'شارع المثال ${i + 1}، القاهرة',
        'location': 'عنوان GPS ${i + 1}',
        'isInstallDone': i % 3 == 0,
      };
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: mainBlueColor,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 20),

              // الشعار في الأعلى (مطابق للمرجع — شبه شفاف بالأبيض)
              Center(
                child: Image.asset(
                  'assets/images/pngs/TS_Logo0.png',
                  width: 110,
                  height: 110,
                  fit: BoxFit.contain,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
              const SizedBox(height: 20),

              // المساحة السفلية البيضاء التي تحتوي على القائمة
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: sheetColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(
                        top: 30,
                        left: 16,
                        right: 16,
                        bottom: 40,
                      ),
                      itemCount: sampleItems.length,
                      itemBuilder: (context, index) {
                        final item = sampleItems[index];
                        return _ManagementCard(
                          customerName: item['customerName'] as String,
                          visitDate: (item['visitDate'] as DateTime)
                              .toString()
                              .substring(0, 10),
                          productName: item['productName'] as String,
                          address: item['address'] as String,
                          location: item['location'] as String,
                          isInstallDone: item['isInstallDone'] as bool,
                          maxWidth: size.width - 40,
                          shadowBlue: shadowBlue,
                          borderCardColor: borderCardColor,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// كارد مُعاد تصميمه ليتطابق مع مرجع VisitsAndInstallsScreen
class _ManagementCard extends StatelessWidget {
  final String customerName;
  final String visitDate;
  final String productName;
  final String address;
  final String location;
  final bool isInstallDone;
  final double maxWidth;
  final Color shadowBlue;
  final Color borderCardColor;

  const _ManagementCard({
    required this.customerName,
    required this.visitDate,
    required this.productName,
    required this.address,
    required this.location,
    required this.isInstallDone,
    required this.maxWidth,
    required this.shadowBlue,
    required this.borderCardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: SizedBox(
        height: 280,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // الظل الأزرق خلف الكارت (مطابق للمرجع)
            Positioned(
              left: 0,
              top: 13,
              child: Container(
                width: maxWidth,
                height: 275,
                decoration: BoxDecoration(
                  color: shadowBlue,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      offset: const Offset(4, 6),
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),
            ),

            // الكارت الأبيض مع حدود ملونة
            Padding(
              padding: const EdgeInsets.only(top: 23, left: 20),
              child: Container(
                height: 290,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: borderCardColor,
                    width: 4,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اسم العميل (سطر عنوان)
                    _buildInfoRow(
                      imagePath: "assets/images/pngs/new_person.png",
                      text: customerName,
                      isTitle: true,
                    ),
                    const SizedBox(height: 10),

                    // التاريخ
                    _buildInfoRow(
                      imagePath: "assets/images/pngs/new_calender.png",
                      text: visitDate,
                    ),
                    const SizedBox(height: 10),

                    // المنتج
                    _buildInfoRow(
                      imagePath: "assets/images/pngs/specialization.png",
                      text: productName,
                    ),
                    const SizedBox(height: 8),

                    // العنوان الأول
                    _buildInfoRow(
                      imagePath: "assets/images/pngs/location.png",
                      text: address,
                    ),
                    const SizedBox(height: 12),

                    // العنوان الثاني (earth) — تصميمي هنا يحافظ على الشكل فقط (بدون منطق فتح خرائط)
                    _buildInfoRow(
                      imagePath: "assets/images/pngs/earth.png",
                      text: location,
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            // زر (إضافة إجراء / تم التركيب) موضوع بنفس الموقع والتصميم كما في المرجع
            Positioned(
              left: 115,
              bottom: 0,
              child: GestureDetector(
                onTap: () {
                  // احتفظت بالـ logic خفيف — هنا مجرد إخطار للمستخدم فقط (يمكن استبداله بتنقل/منطق حقيقي)
                  final snack = SnackBar(
                    content: Text(
                        isInstallDone ? 'تم التركيب مسبقاً' : 'إضافة إجراء'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snack);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                  decoration: BoxDecoration(
                    color:
                        isInstallDone ? Colors.green : const Color(0xFF00C0C8),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 5,
                          offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Text(
                    isInstallDone ? "تم التركيب" : "إضافة إجراء",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء صف المعلومات باستخدام صور الأيقونات (مطابق للمرجع)
  Widget _buildInfoRow({
    required String imagePath,
    required String text,
    bool isTitle = false,
  }) {
    return Row(
      children: [
        Image.asset(
          imagePath,
          width: isTitle ? 35 : 30,
          height: isTitle ? 35 : 30,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: isTitle ? 22 : 16,
              fontWeight: isTitle ? FontWeight.w900 : FontWeight.w600,
              color: isTitle ? Colors.black87 : Colors.grey[800],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
