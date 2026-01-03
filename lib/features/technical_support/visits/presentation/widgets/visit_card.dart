import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';
import 'package:tabib_soft_company/features/technical_support/visits/data/models/visit_model.dart';
import 'package:tabib_soft_company/features/technical_support/visits/presentation/cubits/visit_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/visits/presentation/screens/visit_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class VisitCard extends StatefulWidget {
  final VisitModel visit;

  const VisitCard({super.key, required this.visit});

  @override
  State<VisitCard> createState() => _VisitCardState();
}

class _VisitCardState extends State<VisitCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _depthAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _depthAnimation = Tween<double>(begin: 24.0, end: 8.0).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDone = widget.visit.isInstallDone;
    final Color mainColor = isDone
        ? TechColors.successGreen
        : (widget.visit.visitType == "*****"
            ? TechColors.warningOrange
            : TechColors.accentCyan);

    // لون خلفية الصفحة (مهم جداً لتأثير الحواف الخارجية الـ 3D)
    const Color backgroundColor =
        TechColors.surfaceLight; // يفضل أن يكون فاتح جداً مثل #F5F7FA

    return AnimatedBuilder(
      animation: _pressController,
      builder: (context, child) {
        final double depth = _depthAnimation.value;

        // حواف خارجية بارزة (Outer Border 3D Effect)
        // طبقة داخلية غامقة قليلاً + طبقة خارجية فاتحة لتعطي إحساس بالسمك والارتفاع
        final List<BoxShadow> outerShadows = [
          // الظل الداكن الخارجي (يحاكي الحافة السفلية واليمنى)
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            offset: Offset(depth / 3, depth / 3),
            blurRadius: depth / 1.5,
            spreadRadius: depth / 6,
          ),
          // الظل الفاتح الخارجي (يحاكي الحافة العلوية واليسرى)
          BoxShadow(
            color: Colors.white.withOpacity(0.9),
            offset: Offset(-depth / 3, -depth / 3),
            blurRadius: depth / 1.5,
            spreadRadius: depth / 6,
          ),
        ];

        // ظل داخلي خفيف للعمق عند الضغط
        final List<BoxShadow> innerShadows = [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 6),
            blurRadius: 12,
          ),
        ];

        return Transform.translate(
          offset: Offset(0, depth / 6), // يرتفع الكارت قليلاً عند عدم الضغط
          child: GestureDetector(
            onTapDown: (_) => _pressController.forward(),
            onTapUp: (_) => _pressController.reverse(),
            onTapCancel: () => _pressController.reverse(),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                // الحواف الخارجية الـ 3D الرئيسية
                boxShadow: outerShadows,
              ),
              child: Container(
                // طبقة داخلية للعمق + ظل داخلي
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: innerShadows,
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(26),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              VisitDetailScreen(visit: widget.visit),
                        ),
                      );
                      if (result == true && context.mounted) {
                        context.read<VisitCubit>().loadVisits();
                      }
                    },
                    child: Column(
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                mainColor.withOpacity(0.18),
                                Colors.transparent,
                              ],
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                            ),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(26)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar مع حافة 3D صغيرة
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      offset: const Offset(2, 2),
                                      blurRadius: 6,
                                    ),
                                    const BoxShadow(
                                      color: Colors.white,
                                      offset: Offset(-2, -2),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 26,
                                  backgroundColor: mainColor.withOpacity(0.15),
                                  child: Text(
                                    widget.visit.customerName.isNotEmpty
                                        ? widget.visit.customerName[0]
                                        : '?',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: mainColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.visit.customerName,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2D3436),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color:
                                                Colors.grey.withOpacity(0.2)),
                                      ),
                                      child: Text(
                                        widget.visit.proudctName,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (widget.visit.adress != null &&
                                        widget.visit.adress!.isNotEmpty)
                                      Text(
                                        widget.visit.adress!,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                          height: 1.3,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (widget.visit.visitType != null &&
                                      widget.visit.visitType!.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: mainColor,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: mainColor.withOpacity(0.4),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        widget.visit.visitType!,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today_rounded,
                                          size: 14, color: Colors.grey[500]),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.visit.visitDate
                                            .toString()
                                            .substring(0, 10),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Divider
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey.withOpacity(0.15),
                          ),
                        ),

                        // Content
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                icon: Icons.map_rounded,
                                text: widget.visit.location ??
                                    "العنوان غير متوفر",
                                color: const Color(0xFFFF6B6B),
                                onTap: () =>
                                    _openInMaps(context, widget.visit.location),
                                isActionable: true,
                              ),
                              const SizedBox(height: 14),
                              _buildInfoRow(
                                icon: Icons.phone_in_talk_rounded,
                                text: widget.visit.customerPhone ??
                                    "رقم الهاتف غير متوفر",
                                color: const Color(0xFF4ECDC4),
                                onTap: () =>
                                    _makePhoneCall(widget.visit.customerPhone),
                                isActionable: true,
                              ),
                              if (widget.visit.note != null &&
                                  widget.visit.note!.trim().isNotEmpty) ...[
                                const SizedBox(height: 18),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF9C4)
                                        .withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: const Color(0xFFFFF9C4)
                                            .withOpacity(0.6)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.note_alt_outlined,
                                          size: 20, color: Color(0xFFFBC02D)),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          widget.visit.note!,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[800],
                                              height: 1.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Footer
                        Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: mainColor.withOpacity(0.12),
                            borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(26)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'الإجراءات ',
                                style: TextStyle(
                                    color: mainColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                isDone
                                    ? Icons.check_circle_rounded
                                    : Icons.arrow_circle_left_rounded,
                                color: mainColor,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // باقي الدوال كما هي (makePhoneCall, openInMaps, buildInfoRow)
  Future<void> _makePhoneCall(String? phone) async {
    if (phone == null || phone.trim().isEmpty) return;
    final uri = Uri(scheme: 'tel', path: phone.trim());
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openInMaps(BuildContext context, String? address) async {
    final addr = (address ?? '').trim();
    if (addr.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('العنوان غير متوفر')));
      return;
    }
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(addr)}');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('لا يمكن فتح الخرائط')));
    }
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required Color color,
    VoidCallback? onTap,
    bool isActionable = false,
  }) {
    return InkWell(
      onTap: isActionable ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 3)),
                ],
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[750]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isActionable)
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 15, color: Colors.grey.withOpacity(0.6)),
          ],
        ),
      ),
    );
  }
}
