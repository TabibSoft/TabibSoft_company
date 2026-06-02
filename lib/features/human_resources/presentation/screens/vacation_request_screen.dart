import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';
import 'package:tabib_soft_company/core/utils/constant/app_style.dart';

class VacationRequestScreen extends StatefulWidget {
  const VacationRequestScreen({super.key});

  @override
  State<VacationRequestScreen> createState() => _VacationRequestScreenState();
}

class _VacationRequestScreenState extends State<VacationRequestScreen> {
  String? vacationType;
  DateTime? startDate;
  DateTime? endDate;
  final TextEditingController reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              height: 180.h,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00337C), Color(0xFF0A4A9C)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      Text(
                        "طلب إجازة",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
              ),
            ),

            // Main Content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),

                  // Calendar Icon
                  Center(
                    child: Container(
                      width: 64.w,
                      height: 64.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        size: 32,
                        color: Color(0xFF00337C),
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Vacation Type
                  Text("نوع الإجازة",
                      style: AppStyle.font14_700Weight
                          .copyWith(color: ProgrammerColors.textPrimary)),
                  SizedBox(height: 8.h),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFF5F5F5)),
                    ),
                    child: DropdownButtonFormField<String>(
                      initialValue: vacationType,
                      hint: const Text("اختر نوع الإجازة"),
                      decoration: InputDecoration(
                        border: AppStyle.borderDone(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: "annual", child: Text("إجازة سنوية")),
                        DropdownMenuItem(
                            value: "sick", child: Text("إجازة مرضية")),
                        DropdownMenuItem(
                            value: "emergency", child: Text("إجازة طارئة")),
                      ],
                      onChanged: (value) =>
                          setState(() => vacationType = value),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Dates Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("تاريخ البدء",
                                style: AppStyle.font14_700Weight.copyWith(
                                    color: ProgrammerColors.textPrimary)),
                            SizedBox(height: 8.h),
                            _buildDateField("mm/dd/yyyy", startDate, true),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("تاريخ الانتهاء",
                                style: AppStyle.font14_700Weight.copyWith(
                                    color: ProgrammerColors.textPrimary)),
                            SizedBox(height: 8.h),
                            _buildDateField("mm/dd/yyyy", endDate, false),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // Total Days
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      children: [
                        const Text("يوم ",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("0",
                            style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF00337C))),
                        const Spacer(),
                        Text("إجمالي عدد الأيام",
                            style: AppStyle.font14_700Weight),
                        const SizedBox(width: 8),
                        const Icon(Icons.calendar_today,
                            color: Color(0xFF00337C)),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Reason (Optional)
                  Text("سبب الطلب (اختياري)",
                      style: AppStyle.font14_700Weight
                          .copyWith(color: ProgrammerColors.textPrimary)),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: reasonController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "...اكتب ملاحظاتك هنا",
                      filled: true,
                      fillColor: Colors.white,
                      border: AppStyle.borderDone(),
                      enabledBorder: AppStyle.borderDone(),
                      focusedBorder: AppStyle.borderDone().copyWith(
                        borderSide: const BorderSide(color: Color(0xFF19A7CE)),
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Info Box
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7E6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: Color(0xFFF4A800)),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            "سيتم توجيه هذا الطلب إلى مدير الموارد البشرية للمراجعة. سيتم إخطارك بمجرد اتخاذ القرار.",
                            style: AppStyle.font13_400Weight
                                .copyWith(color: const Color(0xFF5C5C5C)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00337C),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send, color: Colors.white),
                          SizedBox(width: 8.w),
                          Text(
                            "إرسال الطلب",
                            style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // Previous Requests
                  Text("الطلبات الأخيرة", style: AppStyle.font16_700Weight),
                  SizedBox(height: 16.h),

                  // First Previous Request
                  _buildPreviousRequest(
                    status: "مقبول",
                    statusColor: const Color(0xFF4CAF50),
                    title: "إجازة سنوية",
                    date: "(3 أيام) 12 أكتوبر - 15 أكتوبر",
                  ),

                  SizedBox(height: 12.h),

                  // Second Previous Request
                  _buildPreviousRequest(
                    status: "قيد الانتظار",
                    statusColor: const Color(0xFFF4A800),
                    title: "إجازة مرضية",
                    date: "(يوم واحد) 1 نوفمبر - 2 نوفمبر",
                  ),

                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(String hint, DateTime? date, bool isStart) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2024),
          lastDate: DateTime(2027),
        );
        if (picked != null) {
          setState(() {
            if (isStart)
              startDate = picked;
            else
              endDate = picked;
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFF5F5F5)),
        ),
        child: Text(
          date != null ? "${date.month}/${date.day}/${date.year}" : hint,
          style: TextStyle(
            color: date != null ? Colors.black : const Color(0xFFAEAEAE),
            fontSize: 15.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildPreviousRequest({
    required String status,
    required Color statusColor,
    required String title,
    required String date,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppStyle.font15_500Weight),
                Text(date,
                    style: AppStyle.font13_400Weight
                        .copyWith(color: ProgrammerColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
