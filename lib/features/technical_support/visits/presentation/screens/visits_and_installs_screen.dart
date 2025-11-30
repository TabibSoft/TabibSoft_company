import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/features/technical_support/visits/presentation/screens/visit_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tabib_soft_company/core/services/locator/get_it_locator.dart';
import 'package:tabib_soft_company/features/technical_support/visits/presentation/cubits/visit_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/visits/presentation/cubits/visit_state.dart';

class VisitsAndInstallsScreen extends StatelessWidget {
  const VisitsAndInstallsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // الألوان الأساسية للشاشة
    const mainBlueColor = Color(0xFF16669E);
    const sheetColor = Color(0xFFF5F7FA);

    return Directionality(
      textDirection: TextDirection.rtl, 
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        
        backgroundColor: mainBlueColor,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 1. الهيدر العلوي (الشعار/الأيقونة)
              const SizedBox(height: 20),
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

              // 2. المحتوى الأبيض السفلي
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
                  child: BlocProvider(
                    create: (_) => ServicesLocator.visitCubit..loadVisits(),
                    child: BlocBuilder<VisitCubit, VisitState>(
                      builder: (context, state) {
                        // حالة التحميل
                        if (state.status == VisitStatus.loading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        // حالة الخطأ
                        if (state.status == VisitStatus.error) {
                          return Center(
                            child: Text(
                              state.errorMessage ?? "حدث خطأ",
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }

                        // حالة لا توجد بيانات
                        if (state.visits.isEmpty) {
                          return const Center(
                              child: Text("لا توجد زيارات حالياً"));
                        }

                        // قائمة الزيارات
                        return ListView.builder(
                          padding: const EdgeInsets.only(
                            top: 30,
                            left: 16,
                            right: 16,
                            bottom: 40,
                          ),
                          itemCount: state.visits.length,
                          itemBuilder: (context, index) {
                            final visit = state.visits[index];
                            return _VisitCard(visit: visit);
                          },
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

// ---------------------------------------------------------
// ويدجت الكارت المنفصلة (التصميم الجديد)
// ---------------------------------------------------------
class _VisitCard extends StatelessWidget {
  final dynamic visit;

  const _VisitCard({
    required this.visit,
  });

  /// يفتح العنوان في خرائط جوجل (رابط ويب)
  Future<void> _openInMaps(BuildContext context, String? address) async {
    final addr = (address ?? '').trim();
    if (addr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('العنوان غير متوفر')),
      );
      return;
    }

    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(addr)}',
    );

    try {
      // حاول الفتح مباشرة في تطبيق خارجي (browser / maps)
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        // فشل الفتح — أعطِ رسالة للمستخدم
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا يمكن فتح الخرائط على هذا الجهاز')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء محاولة فتح الخرائط')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: SizedBox(
        height: 280,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            /// الظل الأزرق
            Positioned(
              left: 0,
              top: 13,
              child: Container(
                width: MediaQuery.of(context).size.width - 40,
                height: 275,
                decoration: BoxDecoration(
                  color: const Color(0xff104D9D),
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

            /// الكارت الأبيض
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
                    color: const Color(0xff20AAC9),
                    width: 4,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// الاسم
                    _buildInfoRow(
                      imagePath: "assets/images/pngs/new_person.png",
                      text: visit.customerName,
                      isTitle: true,
                    ),
                    const SizedBox(height: 10),

                    /// التاريخ
                    _buildInfoRow(
                      imagePath: "assets/images/pngs/new_calender.png",
                      text: visit.visitDate.toString().substring(0, 10),
                    ),
                    const SizedBox(height: 10),

                    /// المنتج
                    _buildInfoRow(
                      imagePath: "assets/images/pngs/specialization.png",
                      text: visit.proudctName,
                    ),

                    /// العنوان الأول
                    _buildInfoRow(
                      imagePath: "assets/images/pngs/location.png",
                      text: visit.adress ?? 'العنوان غير محدد',
                    ),
                    const SizedBox(height: 12),

                    /// العنوان الثاني (باستخدام earth.png) - عند الضغط يفتح خرائط جوجل
                    _buildInfoRow(
                      imagePath: "assets/images/pngs/earth.png",
                      text: visit.location ?? 'العنوان غير محدد',
                      onTap: () =>
                          _openInMaps(context, visit.location ?? visit.adress),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            /// زر إتمام الزيارة
            Positioned(
              left: 115,
              bottom: 0,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VisitDetailScreen(visit: visit),
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                  decoration: BoxDecoration(
                    color: visit.isInstallDone
                        ? Colors.green
                        : const Color(0xFF00C0C8),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 5,
                          offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Text(
                    visit.isInstallDone ? "تم التركيب" : "إضافة إجراء",
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

  /// الدالة بعد التعديل لقبول الصور بدلاً من الأيقونات
  Widget _buildInfoRow({
    required String imagePath,
    required String text,
    bool isTitle = false,
    VoidCallback? onTap,
  }) {
    final row = Row(
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

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        child: row,
      );
    }

    return row;
  }
}
