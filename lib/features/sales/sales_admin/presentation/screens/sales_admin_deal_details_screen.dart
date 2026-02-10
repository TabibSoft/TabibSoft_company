import 'package:flutter/material.dart';

class SalesAdminDealDetailsScreen extends StatefulWidget {
  final String dealId;
  final String customerName;

  const SalesAdminDealDetailsScreen({
    super.key,
    required this.dealId,
    required this.customerName,
  });

  @override
  State<SalesAdminDealDetailsScreen> createState() =>
      _SalesAdminDealDetailsScreenState();
}

//  "requirementId": "050f846f-aeec-45c7-bf82-08de648ebc51",
//  "measurementId": "b5caa9b8-4216-4d20-d877-08de648ebc50",

class _SalesAdminDealDetailsScreenState
    extends State<SalesAdminDealDetailsScreen> {
  // Mock Data
  final Map<String, dynamic> dealDetails = {
    'id': 2932,
    'customer': 'عبد الله ناصف',
    'engineer': 'Hasnaa Fathi',
    'product': 'عيادة أطفال',
    'status': 'new',
    'date': '2025-12-31',
    'offer': 'Choose..',
    'price': 12000,
    'priceAfterOffer': 12000,
    'discount': 0,
    'endTotal': 12000,
    'paid': 0,
    'rest': 12000,
    'notes': 'ملاحظات هامة حول العميل',
    'location': 'الموقع الجغرافي للعيادة',
    'requirements': [
      {
        'note': 'عميل جديد مهتم جدا',
        'nextCall': '2026-01-01',
        'timeFrom': '09:41 AM',
        'timeTo': '09:41 AM',
        'createDate': '2025-12-31',
        'communication': 'Phone',
        'adminNote': 'No admin note',
      },
      {
        'note': 'تم الاتصال ولم يرد',
        'nextCall': '2026-01-05',
        'timeFrom': '10:00 AM',
        'timeTo': '10:30 AM',
        'createDate': '2026-01-02',
        'communication': 'WhatsApp',
        'adminNote': 'يرجى المحاولة مرة أخرى',
      },
    ]
  };

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoSection(),
                    const SizedBox(height: 20),
                    _buildFinancialSection(),
                    const SizedBox(height: 20),
                    _buildLocationNotesSection(),
                    const SizedBox(height: 20),
                    _buildRequirementsSection(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF104D9D),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.customerName,
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF104D9D), Color(0xFF20AAC9)],
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
            ),
          ),
          child: const Center(
            child: Opacity(
              opacity: 0.1,
              child:
                  Icon(Icons.business_center, size: 100, color: Colors.white),
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return _buildSectionCard(
      title: 'بيانات الصفقة',
      icon: Icons.info_outline,
      children: [
        _buildDetailItem('رقم المعرف', '${dealDetails['id']}', Icons.tag),
        _buildDetailItem(
            'المهندس المسؤول', dealDetails['engineer'], Icons.person),
        _buildDetailItem('المنتج', dealDetails['product'], Icons.shopping_bag),
        _buildDetailItem('الحالة', dealDetails['status'], Icons.flag),
        _buildDetailItem('التاريخ', dealDetails['date'], Icons.calendar_today),
      ],
    );
  }

  Widget _buildFinancialSection() {
    return _buildSectionCard(
      title: 'البيانات المالية',
      icon: Icons.monetization_on_outlined,
      headerColor: const Color(0xFF2E7D32),
      children: [
        Row(
          children: [
            Expanded(child: _buildMoneyCard('السعر', dealDetails['price'])),
            const SizedBox(width: 10),
            Expanded(
                child: _buildMoneyCard('الإجمالي', dealDetails['endTotal'])),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
                child: _buildMoneyCard('المدفوع', dealDetails['paid'],
                    color: Colors.green)),
            const SizedBox(width: 10),
            Expanded(
                child: _buildMoneyCard('المتبقي', dealDetails['rest'],
                    color: Colors.redAccent)),
          ],
        ),
        const SizedBox(height: 10),
        _buildDetailItem('الخصم', '${dealDetails['discount']}', Icons.discount),
      ],
    );
  }

  Widget _buildLocationNotesSection() {
    return _buildSectionCard(
      title: 'الملاحظات والموقع',
      icon: Icons.location_on_outlined,
      children: [
        _buildDetailItem('الملاحظات', dealDetails['notes'], Icons.note),
        const SizedBox(height: 10),
        _buildDetailItem('الموقع', dealDetails['location'], Icons.map),
      ],
    );
  }

  Widget _buildRequirementsSection() {
    final requirements = dealDetails['requirements'] as List;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
          child: Text(
            'سجل المتابعات',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF104D9D),
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: requirements.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final req = requirements[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border(
                  right: BorderSide(
                    color: index == 0
                        ? const Color(0xFF104D9D)
                        : Colors.grey.withOpacity(0.5),
                    width: 4,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        req['createDate'],
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF104D9D).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          req['communication'],
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            color: Color(0xFF104D9D),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    req['note'],
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const Divider(height: 20),
                  Row(
                    children: [
                      Icon(Icons.perm_phone_msg,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'الاتصال القادم: ${req['nextCall']}',
                        style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 12,
                            color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  if (req['adminNote'] != 'No admin note')
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.amber.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.admin_panel_settings,
                              size: 16, color: Colors.amber),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'ملاحظة الأدمن: ${req['adminNote']}',
                              style: TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 12,
                                  color: Colors.amber[900]),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Color headerColor = const Color(0xFF104D9D),
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: headerColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: headerColor),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: headerColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[400]),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Amiri',
                color: Colors.grey[600],
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Amiri',
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoneyCard(String label, dynamic amount,
      {Color color = const Color(0xFF104D9D)}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Amiri',
              color: color.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$amount ج.م',
            style: TextStyle(
              fontFamily: 'Amiri',
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
