import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tabib_soft_company/core/utils/constant/app_style.dart';

class MyRequestsPage extends StatelessWidget {
  const MyRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // ================== Header ==================
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00337C), Color(0xFF1E5AA8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu,
                              color: Colors.white, size: 28),
                          onPressed: () {},
                        ),
                        Text(
                          "طلباتي",
                          style: AppStyle.font24_700Weight
                              .copyWith(color: Colors.white),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "تتبع حالة طلباتك الإدارية والمالية بكل سهولة",
                      style: AppStyle.font14_400Weight.copyWith(
                        color: Colors.white.withOpacity(0.95),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Search
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
            child: TextField(
              decoration: InputDecoration(
                hintText: "ابحث عن طلب معين...",
                prefixIcon: const Icon(Icons.search, color: Color(0xFF7D848D)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 14.h),
              ),
            ),
          ),

          // Tabs
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              children: [
                _buildTab("مباشرة عم", false),
                _buildTab("سلف", false),
                _buildTab("إجازات", false),
                _buildTab("الكل", true),
              ],
            ),
          ),

          SizedBox(height: 12.h),

          // Requests List
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              children: [
                _buildRequestCard(
                  status: "تم الموافقة",
                  statusColor: const Color(0xFF4CAF50),
                  title: "طلب إجازة سنوية",
                  requestNumber: "REQ-8291# :رقم الطلب",
                  date: "2023 أكتوبر 12",
                  icon: Icons.calendar_today,
                ),
                _buildRequestCard(
                  status: "قيد المراجعة",
                  statusColor: const Color(0xFFF4A800),
                  title: "طلب سلفة مالية",
                  requestNumber: "REQ-8295# :رقم الطلب",
                  date: "2023 أكتوبر 18",
                  icon: Icons.account_balance_wallet,
                ),
                _buildRequestCard(
                  status: "مرفوض",
                  statusColor: const Color(0xFFE53935),
                  title: "طلب تعديل دوام",
                  requestNumber: "REQ-8280# :رقم الطلب",
                  date: "2023 أكتوبر 05",
                  icon: Icons.access_time,
                ),
                _buildRequestCard(
                  status: "قيد المراجعة",
                  statusColor: const Color(0xFFF4A800),
                  title: "تجديد بطاقة الموظف",
                  requestNumber: "REQ-8302# :رقم الطلب",
                  date: "2023 أكتوبر 20",
                  icon: Icons.badge,
                ),
              ],
            ),
          ),

          // New Request Section
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: const BoxDecoration(
              color: Color(0xFFF0F4FF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Text(
                  "هل لديك طلب جديد؟",
                  style: AppStyle.font14_400Weight.copyWith(
                    color: const Color(0xFF546E7A),
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  height: 56.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
                    ),
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                    child: Text(
                      "تقديم طلب جديد",
                      style: AppStyle.font16_700Weight
                          .copyWith(color: Colors.white),
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
                // Left Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 4.h),
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
                      SizedBox(height: 10.h),
                      Text(
                        title,
                        style: AppStyle.font16_700Weight.copyWith(
                          color: const Color(0xFF001233),
                        ),
                      ),
                      SizedBox(height: 4.h),
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
                            "تاريخ التقديم $date",
                            style: AppStyle.font13_400Weight.copyWith(
                              color: const Color(0xFF7D848D),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "< التفاصيل",
                        style: AppStyle.font14_700Weight.copyWith(
                          color: const Color(0xFF19A7CE),
                        ),
                      ),
                    ],
                  ),
                ),
                // Right Icon
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: const Color(0xFF00337C), size: 28),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
