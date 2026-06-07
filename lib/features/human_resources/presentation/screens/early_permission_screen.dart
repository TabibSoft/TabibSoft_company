import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';
import 'package:tabib_soft_company/core/utils/constant/app_style.dart';

class EarlyPermissionScreen extends StatefulWidget {
  const EarlyPermissionScreen({super.key});

  @override
  State<EarlyPermissionScreen> createState() => _EarlyPermissionScreenState();
}

class _EarlyPermissionScreenState extends State<EarlyPermissionScreen> {
  DateTime? selectedDate;
  TimeOfDay? exitTime;
  TimeOfDay? returnTime;
  final TextEditingController reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FE),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Header with gradient
                Container(
                  height: 280.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF00579B),
                        Color(0xFF00A8D8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(36.r),
                      bottomRight: Radius.circular(36.r),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 16.h,
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
                                  width: 48.w,
                                  height: 48.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
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
                                width: 48.w,
                                height: 48.w,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 28.h),
                          Text(
                            'طلب إذن مبكر',
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'يرجى تعبئة البيانات الضرورية للحصول على الموافقة',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white.withOpacity(0.95),
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // White card overlapping
                Padding(
                  padding: EdgeInsets.only(
                    top: 220.h,
                    left: 16.w,
                    right: 16.w,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28.r),
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
                        vertical: 24.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Today's Date Section
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: Color(0xFF00A8D8),
                                size: 22,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'تاريخ الآن',
                                style: AppStyle.font14_700Weight.copyWith(
                                  color: ProgrammerColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          GestureDetector(
                            onTap: () => _selectDate(context),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 14.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4F7FB),
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Text(
                                '${selectedDate?.day.toString().padLeft(2, '0')}/${selectedDate?.month.toString().padLeft(2, '0')}/${selectedDate?.year}',
                                style: AppStyle.font14_700Weight.copyWith(
                                  color: ProgrammerColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),

                          // Exit Time and Expected Return Row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.schedule,
                                          color: Color(0xFF00A8D8),
                                          size: 20,
                                        ),
                                        SizedBox(width: 6.w),
                                        Text(
                                          'وقت الخروج',
                                          style: AppStyle.font14_700Weight
                                              .copyWith(
                                            color: ProgrammerColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10.h),
                                    GestureDetector(
                                      onTap: () => _selectTime(context, true),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 14.w,
                                          vertical: 12.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF4F7FB),
                                          borderRadius:
                                              BorderRadius.circular(16.r),
                                        ),
                                        child: Text(
                                          exitTime != null
                                              ? '${exitTime!.hour.toString().padLeft(2, '0')}:${exitTime!.minute.toString().padLeft(2, '0')}'
                                              : '--:--',
                                          style: AppStyle.font14_700Weight
                                              .copyWith(
                                            color: exitTime != null
                                                ? ProgrammerColors.textPrimary
                                                : const Color(0xFFAEAEAE),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.access_time,
                                          color: Color(0xFF00A8D8),
                                          size: 20,
                                        ),
                                        SizedBox(width: 6.w),
                                        Expanded(
                                          child: Text(
                                            'العودة المتوقعة',
                                            style: AppStyle.font14_700Weight
                                                .copyWith(
                                              color:
                                                  ProgrammerColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10.h),
                                    GestureDetector(
                                      onTap: () => _selectTime(context, false),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 14.w,
                                          vertical: 12.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF4F7FB),
                                          borderRadius:
                                              BorderRadius.circular(16.r),
                                        ),
                                        child: Text(
                                          returnTime != null
                                              ? '${returnTime!.hour.toString().padLeft(2, '0')}:${returnTime!.minute.toString().padLeft(2, '0')}'
                                              : '--:--',
                                          style: AppStyle.font14_700Weight
                                              .copyWith(
                                            color: returnTime != null
                                                ? ProgrammerColors.textPrimary
                                                : const Color(0xFFAEAEAE),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),

                          // Reason Section
                          Row(
                            children: [
                              const Icon(
                                Icons.note_outlined,
                                color: Color(0xFF00A8D8),
                                size: 22,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'سبب الاستئذان',
                                style: AppStyle.font14_700Weight.copyWith(
                                  color: ProgrammerColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          TextField(
                            controller: reasonController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText: 'اكتب السبب بالتفصيل هنا...',
                              filled: true,
                              fillColor: const Color(0xFFF4F7FB),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.r),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 12.h,
                              ),
                            ),
                          ),
                          SizedBox(height: 18.h),

                          // Info Box
                          Container(
                            padding: EdgeInsets.all(14.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F8FF),
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: const Color(0xFFE1F0FF),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: Color(0xFF00A8D8),
                                  size: 20,
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Text(
                                    'سيتم إرسال الطلب إلى مدير المراجعة. التأكد من تحديد الوقت بدقة لتجنب التأخير على صحح الحضور.',
                                    style: AppStyle.font13_400Weight.copyWith(
                                      color: const Color(0xFF546E7A),
                                    ),
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
                                backgroundColor: const Color(0xFF15A0C8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.send,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'إرسال الطلب',
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
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isExitTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isExitTime) {
          exitTime = picked;
        } else {
          returnTime = picked;
        }
      });
    }
  }

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }
}
