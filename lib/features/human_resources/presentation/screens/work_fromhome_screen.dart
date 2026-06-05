import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';
import 'package:tabib_soft_company/core/utils/constant/app_style.dart';

class WorkFromHomeScreen extends StatefulWidget {
  const WorkFromHomeScreen({super.key});

  @override
  State<WorkFromHomeScreen> createState() => _WorkFromHomeScreenState();
}

class _WorkFromHomeScreenState extends State<WorkFromHomeScreen> {
  DateTime? startDate;
  DateTime? endDate;
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController tasksController = TextEditingController();

  @override
  void dispose() {
    reasonController.dispose();
    tasksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FE),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              height: 214.h,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00579B), Color(0xFF00A8D8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32.r),
                  bottomRight: Radius.circular(32.r),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Spacer(),
                          Text(
                            'طلب عمل عن بعد',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 44.w,
                            height: 44.w,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.16),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),
                      Text(
                        'يرجى تعبئة التفاصيل أدناه لإرسال طلبك للمراجعة',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 14.sp,
                          height: 1.7,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // White card
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 22.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('تاريخ البدء'),
                      SizedBox(height: 10.h),
                      _buildDateTile(
                        text: startDate != null
                            ? '${_formatDate(startDate!)}'
                            : 'mm/dd/yyyy',
                        onTap: () => _pickDate(context, true),
                      ),
                      SizedBox(height: 16.h),
                      _buildFieldLabel('تاريخ الانتهاء'),
                      SizedBox(height: 10.h),
                      _buildDateTile(
                        text: endDate != null
                            ? '${_formatDate(endDate!)}'
                            : 'mm/dd/yyyy',
                        onTap: () => _pickDate(context, false),
                      ),
                      SizedBox(height: 20.h),
                      _buildFieldLabel('سبب الطلب'),
                      SizedBox(height: 10.h),
                      TextField(
                        controller: reasonController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'اشرح بإيجاز سبب رغبتك في العمل عن بعد...',
                          hintStyle: AppStyle.font14_400Weight.copyWith(
                            color: const Color(0xFF9EA4AE),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF4F7FB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.r),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
                        ),
                      ),
                      SizedBox(height: 18.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: 36.w,
                            height: 36.w,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6F7FF),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Color(0xFF00A8D8),
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            'ملخص المهام المخطط لها',
                            style: AppStyle.font14_700Weight.copyWith(
                              color: ProgrammerColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      TextField(
                        controller: tasksController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'أدخل مهمة...',
                          hintStyle: AppStyle.font14_400Weight.copyWith(
                            color: const Color(0xFF9EA4AE),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF4F7FB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.r),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F8FF),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 34.w,
                              height: 34.w,
                              decoration: BoxDecoration(
                                color: const Color(0xFFDEEFFF),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: const Icon(
                                Icons.info_outline,
                                color: Color(0xFF00A8D8),
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'سياسة العمل عن بعد',
                                    style: AppStyle.font14_700Weight.copyWith(
                                      color: ProgrammerColors.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'يخضع الطلب لموافقة المدير المباشر وقسم الموارد البشرية. يرجى التأكد من توفر اتصال مستقر بالإنترنت خلال ساعات العمل الرسمية.',
                                    style: AppStyle.font13_400Weight.copyWith(
                                      color: const Color(0xFF5A6774),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),
                      SizedBox(
                        width: double.infinity,
                        height: 54.h,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00A8D8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                          ),
                          child: Text(
                            'إرسال الطلب',
                            style: AppStyle.font16_700Weight.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      SizedBox(
                        width: double.infinity,
                        height: 54.h,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF9EA4AE)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                          ),
                          child: Text(
                            'إلغاء',
                            style: AppStyle.font16_700Weight.copyWith(
                              color: const Color(0xFF5A6774),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 22.h),

            // Recent requests title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'طلباتك الأخيرة',
                  style: AppStyle.font18_600Weight.copyWith(
                    color: ProgrammerColors.textPrimary,
                  ),
                ),
              ),
            ),
            SizedBox(height: 14.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Column(
                children: [
                  _buildRecentRequestCard(
                    status: 'مقبول',
                    statusColor: const Color(0xFF4CAF50),
                    title: '15 أكتوبر - 17 أكتوبر',
                    subtitle: 'تم قبول طلبك بنجاح، يرجى متابعة التعليمات.',
                    icon: Icons.home_work,
                  ),
                  SizedBox(height: 12.h),
                  _buildRecentRequestCard(
                    status: 'قيد الانتظار',
                    statusColor: const Color(0xFFF4A800),
                    title: '22 أكتوبر - 22 أكتوبر',
                    subtitle: 'يتم مراجعة طلبك من قبل مدير الموارد البشرية.',
                    icon: Icons.access_time,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: AppStyle.font14_700Weight.copyWith(
        color: ProgrammerColors.textPrimary,
      ),
    );
  }

  Widget _buildDateTile({required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F7FB),
          borderRadius: BorderRadius.circular(22.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: AppStyle.font14_400Weight.copyWith(
                  color: text == 'mm/dd/yyyy'
                      ? const Color(0xFF9EA4AE)
                      : ProgrammerColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.calendar_today,
              color: Color(0xFF00A8D8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentRequestCard({
    required String status,
    required Color statusColor,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
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
                      Icon(icon, color: statusColor, size: 22),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    title,
                    style: AppStyle.font16_700Weight.copyWith(
                      color: ProgrammerColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    subtitle,
                    style: AppStyle.font13_400Weight.copyWith(
                      color: ProgrammerColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 6.w,
            height: 90.h,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20.r),
                bottomRight: Radius.circular(20.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final DateTime now = DateTime.now();
    final DateTime initial = isStart
        ? (startDate ?? now)
        : (endDate ?? startDate ?? now);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
          if (endDate != null && endDate!.isBefore(picked)) {
            endDate = null;
          }
        } else {
          endDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }
}
