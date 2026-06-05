import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';
import 'package:tabib_soft_company/core/utils/constant/app_style.dart';

class SalaryAdvanceScreen extends StatefulWidget {
  const SalaryAdvanceScreen({super.key});

  @override
  State<SalaryAdvanceScreen> createState() => _SalaryAdvanceScreenState();
}

class _SalaryAdvanceScreenState extends State<SalaryAdvanceScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  String duration = '3 أشهر';

  @override
  void dispose() {
    amountController.dispose();
    reasonController.dispose();
    super.dispose();
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
                Container(
                  height: 220.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color(0xFF00579B), const Color(0xFF00A8D8)],
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
                      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'طلب سلفة من الراتب',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            'يمكنك تقديم طلب سلفة مالية بحد أقصى 50% من راتبك الشهري الأساسي.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.95),
                              fontSize: 14.sp,
                              height: 1.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                               Positioned(
                  top: 240.h,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32.r),
                        topRight: Radius.circular(32.r),
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 24.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 24,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 22.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionLabel('المبلغ المطلوب', icon: Icons.monetization_on_outlined),
                                  SizedBox(height: 10.h),
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF4F7FB),
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: TextField(
                                      controller: amountController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                        hintText: '0.00',
                                        hintStyle: AppStyle.font14_400Weight.copyWith(
                                          color: const Color(0xFF9EA4AE),
                                        ),
                                        border: InputBorder.none,
                                      ),
                                      style: AppStyle.font16_700Weight.copyWith(
                                        color: ProgrammerColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20.h),
                                  _buildSectionLabel('فترة السداد', icon: Icons.date_range_outlined),
                                  SizedBox(height: 10.h),
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF4F7FB),
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: DropdownButtonFormField<String>(
                                      value: duration,
                                      decoration: const InputDecoration(border: InputBorder.none),
                                      items: const [
                                        DropdownMenuItem(value: '3 أشهر', child: Text('3 أشهر')),
                                        DropdownMenuItem(value: '6 أشهر', child: Text('6 أشهر')),
                                        DropdownMenuItem(value: '12 أشهر', child: Text('12 أشهر')),
                                      ],
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(() => duration = value);
                                        }
                                      },
                                      style: AppStyle.font14_700Weight.copyWith(
                                        color: ProgrammerColors.textPrimary,
                                      ),
                                      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF7D848D)),
                                    ),
                                  ),
                                  SizedBox(height: 20.h),
                                  _buildSectionLabel('سبب الطلب', icon: Icons.note_outlined),
                                  SizedBox(height: 10.h),
                                  TextField(
                                    controller: reasonController,
                                    maxLines: 5,
                                    decoration: InputDecoration(
                                      hintText: 'يرجى توضيح سبب السلفة...',
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
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Container(
                            padding: EdgeInsets.all(18.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF5FF),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40.w,
                                  height: 40.w,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDEF0FF),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: const Icon(
                                    Icons.info_outline,
                                    color: Color(0xFF00579B),
                                  ),
                                ),
                                SizedBox(width: 14.w),
                                Expanded(
                                  child: Text(
                                    'سيتم مراجعة الطلب من قبل إدارة الموارد البشرية. الموافقة النهائية تعتمد على السياسة المالية والالتزامات القائمة.',
                                    style: AppStyle.font13_400Weight.copyWith(
                                      color: const Color(0xFF5A6B7C),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 22.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: SizedBox(
                            width: double.infinity,
                            height: 56.h,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00A8D8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'إرسال الطلب',
                                    style: AppStyle.font16_700Weight.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  const Icon(Icons.arrow_forward, color: Colors.white),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 28.h),
                      ],
                    ),
                  ),
                ),
        Positioned(
                  top: 170.h,
                  left: 16.w,
                  right: 16.w,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          title: 'الحد المتاح',
                          amount: '6,250 ج.م',
                          borderColor: const Color(0xFFF4A800),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildSummaryCard(
                          title: 'الراتب الأساسي',
                          amount: '12,500 ج.م',
                          borderColor: const Color(0xFF00A8D8),
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String amount,
    required Color borderColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: borderColor.withOpacity(0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppStyle.font14_700Weight.copyWith(
              color: ProgrammerColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            amount,
            style: TextStyle(
              color: ProgrammerColors.textPrimary,
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, {required IconData icon}) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF00A8D8), size: 20),
        SizedBox(width: 8.w),
        Text(
          label,
          style: AppStyle.font14_700Weight.copyWith(
            color: ProgrammerColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
