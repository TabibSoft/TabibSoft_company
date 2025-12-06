import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/features/technical_support/visits/data/models/visit_model.dart';
import 'package:tabib_soft_company/features/technical_support/visits/presentation/screens/visit_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tabib_soft_company/core/services/locator/get_it_locator.dart';
import 'package:tabib_soft_company/features/technical_support/visits/presentation/cubits/visit_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/visits/presentation/cubits/visit_state.dart';

class VisitsAndInstallsScreen extends StatelessWidget {
  const VisitsAndInstallsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                        if (state.status == VisitStatus.loading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (state.status == VisitStatus.error) {
                          return Center(
                            child: Text(
                              state.errorMessage ?? "حدث خطأ",
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }

                        if (state.visits.isEmpty) {
                          return const Center(
                              child: Text("لا توجد زيارات حالياً"));
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.only(
                              top: 30, left: 16, right: 16, bottom: 40),
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

class _VisitCard extends StatelessWidget {
  final VisitModel visit;

  const _VisitCard({required this.visit});

  Future<void> _makePhoneCall(String? phone) async {
    if (phone == null || phone.trim().isEmpty) return;

    final uri = Uri(scheme: 'tel', path: phone.trim());
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

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

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكن فتح الخرائط')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String displayVisitType =
        (visit.visitType == null || visit.visitType!.trim().isEmpty)
            ? '****'
            : visit.visitType!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: SizedBox(
        height: 500,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // الظل الأزرق
            Positioned(
              left: 0,
              top: 13,
              child: Container(
                width: MediaQuery.of(context).size.width - 40,
                height: 350,
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

            // الكارت الأبيض
            Padding(
              padding: const EdgeInsets.only(top: 23, left: 20),
              child: Container(
                height: 330,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xff20AAC9), width: 4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // الصف العلوي: اسم العميل + نوع الزيارة
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Image.asset("assets/images/pngs/new_person.png",
                                  width: 38, height: 38),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  visit.customerName,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: visit.visitType == "*****"
                                ? Colors.orange.shade100
                                : Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            displayVisitType,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: visit.visitType == "****"
                                  ? Colors.orange.shade800
                                  : Colors.blue.shade800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),

                    // الملاحظة
                    if (visit.note != null && visit.note!.trim().isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          "الملاحظة: ${visit.note}",
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black87, height: 1.4),
                        ),
                      ),

                    const SizedBox(height: 5),

                    // التاريخ
                    _buildInfoRow(
                      imagePath: "assets/images/pngs/new_calender.png",
                      text: visit.visitDate.toString().substring(0, 10),
                    ),
                    const SizedBox(height: 12),

                    // رقم الهاتف - قابل للتحديد والنسخ + قابل للضغط للاتصال
                    GestureDetector(
                      onTap: () => _makePhoneCall(visit.customerPhone),
                      child: Row(
                        children: [
                          const Icon(Icons.phone,
                              color: Colors.green, size: 24),
                          const SizedBox(width: 4),
                          Expanded(
                            child: SelectableText(
                              visit.customerPhone ?? "غير متوفر",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.green,
                              ),
                              textDirection: TextDirection.rtl,
                              onTap: () => _makePhoneCall(visit.customerPhone),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 6),

                    // المنتج
                    _buildInfoRow(
                      imagePath: "assets/images/pngs/specialization.png",
                      text: visit.proudctName,
                    ),
                    const SizedBox(height: 5),

                    // العنوان
                    _buildInfoRow(
                      imagePath: "assets/images/pngs/location.png",
                      text: visit.adress ?? 'غير محدد',
                    ),
                    const SizedBox(height: 5),

                    // الموقع على الخريطة
                    _buildInfoRow(
                      imagePath: "assets/images/pngs/earth.png",
                      text: visit.location,
                      onTap: () => _openInMaps(context, visit.location),
                    ),
                  ],
                ),
              ),
            ),

            // زر إضافة إجراء أو تم التركيب
            Positioned(
              left: 115,
              bottom: 130,
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
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  decoration: BoxDecoration(
                    color: visit.isInstallDone
                        ? Colors.green
                        : const Color(0xFF00C0C8),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    visit.isInstallDone ? "تم التركيب" : "إضافة إجراء",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String imagePath,
    required String text,
    VoidCallback? onTap,
  }) {
    final row = Row(
      children: [
        Image.asset(imagePath, width: 30, height: 30),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    return onTap != null
        ? InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: row,
          )
        : row;
  }
}
