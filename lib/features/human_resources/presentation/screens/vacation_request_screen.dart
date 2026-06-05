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
    final int totalDays = _calculateTotalDays();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FE),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 280.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00337C), Color(0xFF0A4A9C)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(36.r),
                      bottomRight: Radius.circular(36.r),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 18.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              InkWell(
                                onTap: () => Navigator.pop(context),
                                borderRadius: BorderRadius.circular(22.r),
                                child: Container(
                                  width: 46.w,
                                  height: 46.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.16),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_ios_new,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                width: 46.w,
                                height: 46.w,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward,
                                  color: Color(0xFF00337C),
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 26.h),
                          Text(
                            "طلب إجازة",
                            style: TextStyle(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            "قم بتعبئة تفاصيل إجازتك القادمة ليتم مراجعتها",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white.withOpacity(0.9),
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 210.h,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 72.w,
                      height: 72.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        color: Color(0xFF00337C),
                        size: 32,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 250.h,
                  left: 16.w,
                  right: 16.w,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 22.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "نوع الإجازة",
                            style: AppStyle.font14_700Weight.copyWith(
                              color: ProgrammerColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F7FB),
                              borderRadius: BorderRadius.circular(22.r),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: vacationType,
                              hint: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text("اختر نوع الإجازة"),
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 16.h,
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: "annual",
                                  child: Text("إجازة سنوية"),
                                ),
                                DropdownMenuItem(
                                  value: "sick",
                                  child: Text("إجازة مرضية"),
                                ),
                                DropdownMenuItem(
                                  value: "emergency",
                                  child: Text("إجازة طارئة"),
                                ),
                              ],
                              onChanged: (value) =>
                                  setState(() => vacationType = value),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "تاريخ البدء",
                                      style: AppStyle.font14_700Weight.copyWith(
                                        color: ProgrammerColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    _buildDateField(
                                      "mm/dd/yyyy",
                                      startDate,
                                      true,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "تاريخ الانتهاء",
                                      style: AppStyle.font14_700Weight.copyWith(
                                        color: ProgrammerColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    _buildDateField(
                                      "mm/dd/yyyy",
                                      endDate,
                                      false,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 18.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F9FE),
                              borderRadius: BorderRadius.circular(24.r),
                            ),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      totalDays.toString(),
                                      style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF00337C),
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      "يوم",
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: ProgrammerColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "إجمالي عدد الأيام",
                                      style: AppStyle.font14_700Weight,
                                    ),
                                    SizedBox(height: 8.h),
                                    Container(
                                      width: 40.w,
                                      height: 40.w,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE1F1FF),
                                        borderRadius:
                                            BorderRadius.circular(14.r),
                                      ),
                                      child: const Icon(
                                        Icons.calendar_today,
                                        color: Color(0xFF00337C),
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            "سبب الطلب (اختياري)",
                            style: AppStyle.font14_700Weight.copyWith(
                              color: ProgrammerColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          TextField(
                            controller: reasonController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText: "اكتب ملاحظاتك هنا...",
                              filled: true,
                              fillColor: const Color(0xFFF4F7FB),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22.r),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 16.h,
                              ),
                            ),
                          ),
                          SizedBox(height: 18.h),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7E6),
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: Color(0xFFF4A800),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    "سيتم توجيه هذا الطلب إلى مدير الموارد البشرية للمراجعة. سيتم إخطارك بمجرد اتخاذ القرار.",
                                    style: AppStyle.font13_400Weight.copyWith(
                                      color: const Color(0xFF5C5C5C),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24.h),
                          SizedBox(
                            width: double.infinity,
                            height: 56.h,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00337C),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.r),
                                ),
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
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 28.h),
                          Text(
                            "الطلبات الأخيرة",
                            style: AppStyle.font16_700Weight,
                          ),
                          SizedBox(height: 16.h),
                          _buildPreviousRequest(
                            status: "مقبول",
                            statusColor: const Color(0xFF4CAF50),
                            title: "إجازة سنوية",
                            date: "12 أكتوبر - 15 أكتوبر (3 أيام)",
                          ),
                          SizedBox(height: 12.h),
                          _buildPreviousRequest(
                            status: "قيد الانتظار",
                            statusColor: const Color(0xFFF4A800),
                            title: "إجازة مرضية",
                            date: "1 نوفمبر - 2 نوفمبر (يوم واحد)",
                          ),
                          SizedBox(height: 24.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  int _calculateTotalDays() {
    if (startDate == null || endDate == null) return 0;
    final diff = endDate!.difference(startDate!).inDays;
    return diff >= 0 ? diff + 1 : 0;
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
