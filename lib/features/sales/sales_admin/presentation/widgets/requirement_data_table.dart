import 'package:flutter/material.dart';
import '../../data/models/requirement_model.dart';

class RequirementDataTable extends StatelessWidget {
  final List<RequirementReport> requirements;
  final Function(
          String requirementId, String measurementId, String? currentNote)
      onEditNote;
  final Function(RequirementReport req) onViewImages;
  final Function(RequirementReport req) onCustomerTap;
  final ScrollController? scrollController;

  const RequirementDataTable({
    super.key,
    required this.requirements,
    required this.onEditNote,
    required this.onViewImages,
    required this.onCustomerTap,
    this.scrollController,
  });

  static Widget buildCardStatic({
    required BuildContext context,
    required RequirementReport req,
    required Function(
            String requirementId, String measurementId, String? currentNote)
        onEditNote,
    required Function(RequirementReport req) onViewImages,
    required Function(RequirementReport req) onCustomerTap,
  }) {
    return _RequirementCard(
      req: req,
      onEditNote: onEditNote,
      onViewImages: onViewImages,
      onCustomerTap: onCustomerTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (requirements.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 60, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              'لا توجد طلبات حالياً',
              style: TextStyle(
                  fontFamily: 'Amiri', fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: requirements.length,
      padding: const EdgeInsets.symmetric(vertical: 20),
      itemBuilder: (context, index) {
        return _RequirementCard(
          req: requirements[index],
          onEditNote: onEditNote,
          onViewImages: onViewImages,
          onCustomerTap: onCustomerTap,
        );
      },
    );
  }
}

class _RequirementCard extends StatelessWidget {
  final RequirementReport req;
  final Function(
          String requirementId, String measurementId, String? currentNote)
      onEditNote;
  final Function(RequirementReport req) onViewImages;
  final Function(RequirementReport req) onCustomerTap;

  const _RequirementCard({
    required this.req,
    required this.onEditNote,
    required this.onViewImages,
    required this.onCustomerTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDetailsDialog(context, req),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey.shade50,
                  Colors.grey.shade100,
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF104D9D).withOpacity(0.2),
                  offset: const Offset(10, 10),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
                const BoxShadow(
                  color: Colors.white,
                  offset: Offset(-5, -5),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: const Color(0xFF104D9D).withOpacity(0.05),
                  offset: const Offset(0, 4),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.8),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Card Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF104D9D), Color(0xFF1A73E8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0, 4),
                          blurRadius: 4,
                        )
                      ]),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => onCustomerTap(req),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      )
                                    ]),
                                child: const CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Color(0xFF104D9D),
                                  child: Icon(Icons.person,
                                      color: Colors.white, size: 20),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      req.customerName,
                                      style: TextStyle(
                                        fontFamily: 'Amiri',
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        shadows: [
                                          Shadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            offset: const Offset(0, 2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      req.programName,
                                      style: TextStyle(
                                        fontFamily: 'Amiri',
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      _buildStatusChip(req.statusName),
                    ],
                  ),
                ),

                // Card Body
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoRow(
                          Icons.support_agent, 'المهندس', req.salesPersonName),
                      const SizedBox(
                          height:
                              12), // Replaced Divider with spacing for cleaner look
                      _buildInfoRow(Icons.calendar_today, 'تاريخ الإنشاء',
                          _formatDate(req.creationDate)),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.phone_forwarded, 'الاتصال التالي',
                          _formatDate(req.nextCallDate)),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: const Color(0xFFF5F7FA),
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: Colors.grey.withOpacity(0.1)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                                spreadRadius: 0,
                              ) // Inner shadow simulation
                            ]),
                        child: Row(
                          children: [
                            const Icon(Icons.note_alt_outlined,
                                size: 18, color: Color(0xFF104D9D)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                req.note ?? 'لا توجد ملاحظات',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Amiri',
                                  color: Colors.black87,
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Card Footer
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      border:
                          Border(top: BorderSide(color: Colors.grey.shade200))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (req.hasImages)
                        InkWell(
                          onTap: () => onViewImages(req),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            decoration: BoxDecoration(boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ]),
                            child: const Chip(
                              label: Text('صور مرفقة'),
                              labelStyle: TextStyle(
                                  color: Color(0xFF2E7D32),
                                  fontWeight: FontWeight.bold),
                              avatar: Icon(Icons.image,
                                  size: 18, color: Color(0xFF2E7D32)),
                              backgroundColor: Color(0xFFE8F5E9),
                              side: BorderSide.none,
                            ),
                          ),
                        )
                      else
                        const SizedBox(),
                      ElevatedButton.icon(
                        onPressed: () => onEditNote(
                            req.id, req.measurementId ?? req.id, req.adminNote),
                        icon: const Icon(Icons.edit_note, size: 18),
                        label: const Text('تعديل الملاحظة'),
                        style: ElevatedButton.styleFrom(
                          elevation: 4,
                          shadowColor: const Color(0xFF104D9D).withOpacity(0.4),
                          backgroundColor: const Color(0xFF104D9D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF104D9D).withOpacity(0.6)),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
              fontFamily: 'Amiri', fontSize: 13, color: Colors.grey[600]),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'قيد المتابعة':
        color = Colors.orangeAccent;
        break;
      case 'منتهي':
        color = Colors.lightGreenAccent;
        break;
      case 'ملغي':
        color = Colors.redAccent;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontFamily: 'Amiri',
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showDetailsDialog(BuildContext context, RequirementReport req) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (ctx, anim1, anim2) => Container(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            title: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF104D9D)),
                SizedBox(width: 10),
                Text('تفاصيل الطلب',
                    style: TextStyle(
                        fontFamily: 'Amiri', fontWeight: FontWeight.bold)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDialogRow('العميل', req.customerName),
                  _buildDialogRow('المهندس', req.salesPersonName),
                  _buildDialogRow('البرنامج', req.programName),
                  _buildDialogRow('الحالة', req.statusName),
                  _buildDialogRow(
                      'تاريخ الإنشاء', _formatDate(req.creationDate)),
                  _buildDialogRow(
                      'تاريخ الاتصال', _formatDate(req.nextCallDate)),
                  const Divider(),
                  ListTile(
                    title: const Text('ملاحظة المهندس',
                        style: TextStyle(
                            fontFamily: 'Amiri',
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                    subtitle: Text(req.note ?? 'لا توجد',
                        style:
                            const TextStyle(fontFamily: 'Amiri', fontSize: 13)),
                  ),
                  ListTile(
                    title: const Text('ملاحظة الأدمن',
                        style: TextStyle(
                            fontFamily: 'Amiri',
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                    subtitle: Text(req.adminNote ?? 'لا توجد',
                        style:
                            const TextStyle(fontFamily: 'Amiri', fontSize: 13)),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    const Text('إغلاق', style: TextStyle(fontFamily: 'Amiri')),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDialogRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Amiri', color: Colors.grey, fontSize: 13)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final parsed = DateTime.parse(date);
      return '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
    } catch (e) {
      return date;
    }
  }
}
