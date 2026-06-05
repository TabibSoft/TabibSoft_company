import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tabib_soft_company/core/utils/constant/app_style.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';

class MyRequestsPage extends StatelessWidget {
  const MyRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FE),
      body: Column(
        children: [
          // Header with curved gradient
          Container(
            height: 220.h,
            decoration: BoxDecoration(
              gradient: ProgrammerColors.headerGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(36.r),
                bottomRight: Radius.circular(36.r),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        // Circular menu button
                        Container(
                          width: 48.w,
                          height: 48.w,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white),
                            onPressed: () {},
                          ),
                        ),
                        const Spacer(),
                        // Title aligned right
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'طلباتي',
                              style: AppStyle.font24_700Weight.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            SizedBox(
                              width: 220.w,
                              child: Text(
                                'تتبع حالة طلباتك الإدارية والمالية بكل سهولة',
                                style: AppStyle.font14_400Weight.copyWith(
                                  color: Colors.white.withOpacity(0.95),
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Search box overlapping header
          Transform.translate(
            offset: Offset(0, -28.h),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'ابحث عن طلب معين...',
                    hintStyle: AppStyle.font14_400Weight.copyWith(
                        color: const Color(0xFF7D848D)),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF7D848D)),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // Tabs
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              children: [
                _buildTab('مباشرة عم', false),
                _buildTab('سلف', false),
                _buildTab('إجازات', false),
                _buildTab('الكل', true),
              ],
            ),
          ),

          SizedBox(height: 12.h),

          // Requests List with floating add button
          Expanded(
            child: Stack(
              children: [
                ListView(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                  children: [
                    _buildRequestCard(
                      status: 'تم الموافقة',
                      statusColor: const Color(0xFF4CAF50),
                      title: 'طلب إجازة سنوية',
                      requestNumber: 'REQ-8291# :رقم الطلب',
                      date: '2023 أكتوبر 12',
                      icon: Icons.calendar_today,
                    ),
                    _buildRequestCard(
                      status: 'قيد المراجعة',
                      statusColor: const Color(0xFFF4A800),
                      title: 'طلب سلفة مالية',
                      requestNumber: 'REQ-8295# :رقم الطلب',
                      date: '2023 أكتوبر 18',
                      icon: Icons.account_balance_wallet,
                    ),
                    _buildRequestCard(
                      status: 'مرفوض',
                      statusColor: const Color(0xFFE53935),
                      title: 'طلب تعديل دوام',
                      requestNumber: 'REQ-8280# :رقم الطلب',
                      date: '2023 أكتوبر 05',
                      icon: Icons.access_time,
                    ),
                    _buildRequestCard(
                      status: 'قيد المراجعة',
                      statusColor: const Color(0xFFF4A800),
                      title: 'تجديد بطاقة الموظف',
                      requestNumber: 'REQ-8302# :رقم الطلب',
                      date: '2023 أكتوبر 20',
                      icon: Icons.badge,
                    ),
                    SizedBox(height: 24.h),

                    // Bottom CTA
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 8.w),
                      padding: EdgeInsets.symmetric(vertical: 28.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAE6FF),
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF15A0C8),
                            padding: EdgeInsets.symmetric(
                                horizontal: 28.w, vertical: 12.h),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r)),
                          ),
                          child: Text(
                            'تقديم طلب جديد',
                            style: AppStyle.font16_700Weight
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),

                // Floating add button
                Positioned(
                  left: 20.w,
                  bottom: 140.h,
                  child: Container(
                    width: 56.w,
                    height: 56.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF17C3B2),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.14),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text, bool isSelected) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00337C) : Colors.white,
          borderRadius: BorderRadius.circular(30.r),
          border:
              isSelected ? null : Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Center(
          child: Text(
            text,
            style: AppStyle.font14_700Weight.copyWith(
              color: isSelected ? Colors.white : const Color(0xFF001233),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard({
    required String status,
    required Color statusColor,
    required String title,
    required String requestNumber,
    required String date,
    required IconData icon,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Colored vertical bar on the RIGHT
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 6.w,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r),
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main content (right-to-left)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Status badge
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              status,
                              style: AppStyle.font12_600Weight.copyWith(
                                color: statusColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Icon square on the right inside card
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        title,
                        style: AppStyle.font16_700Weight.copyWith(
                          color: const Color(0xFF001233),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        requestNumber,
                        style: AppStyle.font14_400Weight.copyWith(
                          color: const Color(0xFF7D848D),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 18, color: Color(0xFF7D848D)),
                          SizedBox(width: 6.w),
                          Text(
                            date,
                            style: AppStyle.font13_400Weight.copyWith(
                              color: const Color(0xFF7D848D),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: Text(
                          'التفاصيل',
                          style: AppStyle.font14_700Weight.copyWith(
                            color: const Color(0xFF19A7CE),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Icon square at the right edge of card content
                Container(
                  width: 56.w,
                  height: 56.w,
                  margin: EdgeInsets.only(left: 12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF6FF),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFE6F0FF)),
                  ),
                  child: Icon(icon, color: const Color(0xFF00337C), size: 26),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
