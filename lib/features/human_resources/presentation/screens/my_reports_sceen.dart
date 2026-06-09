import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';
import 'package:tabib_soft_company/core/utils/constant/app_style.dart';

class MyReportsPage extends StatelessWidget {
  const MyReportsPage({super.key});

  static const _rewardItems = [
    _ReportItem(
      title: 'مكافأة أداء شهري',
      amount: '1,250',
      date: '10 مايو 2026',
      description: 'مكافأة تقديرية عن الأداء الممتاز',
      isReward: true,
    ),
    _ReportItem(
      title: 'مكافأة الحضور',
      amount: '420',
      date: '02 مايو 2026',
      description: 'مكافأة الالتزام بالحضور الكامل',
      isReward: true,
    ),
  ];

  static const _deductionItems = [
    _ReportItem(
      title: 'خصم تأخير',
      amount: '80',
      date: '08 مايو 2026',
      description: 'خصم لتأخر الدخول عن الوقت المحدد',
      isReward: false,
    ),
    _ReportItem(
      title: 'خصم انصراف مبكر',
      amount: '140',
      date: '25 أبريل 2026',
      description: 'خصم عن الانصراف قبل نهاية الدوام',
      isReward: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCards(),
                    SizedBox(height: 24.h),
                    _buildSectionTitle('آخر المكافآت', 'عرض الكل'),
                    SizedBox(height: 14.h),
                    ..._rewardItems.map((item) => _ReportRow(item: item)),
                    SizedBox(height: 24.h),
                    _buildSectionTitle('آخر الخصومات', 'عرض الكل'),
                    SizedBox(height: 14.h),
                    ..._deductionItems.map((item) => _ReportRow(item: item)),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColor.primaryColor, AppColor.accentColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.r),
          bottomRight: Radius.circular(30.r),
        ),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 28.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Text(
                'المكافآت والخصومات',
                style: AppStyle.font20_600Weight.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            'رصيدك الحالي في الحساب المالي',
            style: AppStyle.font14_400Weight.copyWith(
              color: Colors.white.withAlpha(218),
            ),
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColor.accentColor.withAlpha(31),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: const Icon(
                    Icons.thumb_up_alt_outlined,
                    color: AppColor.accentColor,
                    size: 22,
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  'المكافآت',
                  style: AppStyle.font14_400Weight.copyWith(
                    color: AppColor.titleColor,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  '1,670',
                  style: AppStyle.font18_600Weight.copyWith(
                    color: AppColor.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColor.secondaryColor.withAlpha(36),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: const Icon(
                    Icons.remove_circle_outline,
                    color: AppColor.secondaryColor,
                    size: 22,
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  'الخصومات',
                  style: AppStyle.font14_400Weight.copyWith(
                    color: AppColor.titleColor,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  '930',
                  style: AppStyle.font18_600Weight.copyWith(
                    color: AppColor.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppStyle.font16_700Weight.copyWith(
            color: AppColor.titleColor,
          ),
        ),
        Text(
          action,
          style: AppStyle.font14_700Weight.copyWith(
            color: AppColor.accentColor,
          ),
        ),
      ],
    );
  }
}

class _ReportRow extends StatelessWidget {
  const _ReportRow({required this.item});

  final _ReportItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: item.isReward
                  ? AppColor.accentColor.withAlpha(36)
                  : AppColor.secondaryColor.withAlpha(36),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              item.isReward ? Icons.arrow_upward : Icons.arrow_downward,
              color: item.isReward
                  ? AppColor.accentColor
                  : AppColor.secondaryColor,
              size: 24.w,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppStyle.font15_500Weight.copyWith(
                    color: AppColor.titleColor,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  item.description,
                  style: AppStyle.font13_400Weight.copyWith(
                    color: AppColor.subTitleColor,
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.date,
                      style: AppStyle.font12_600Weight.copyWith(
                        color: AppColor.hintColor,
                      ),
                    ),
                    Text(
                      '${item.amount} ر.س',
                      style: AppStyle.font15_500Weight.copyWith(
                        color: item.isReward
                            ? AppColor.accentColor
                            : AppColor.secondaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportItem {
  final String title;
  final String description;
  final String amount;
  final String date;
  final bool isReward;

  const _ReportItem({
    required this.title,
    required this.description,
    required this.amount,
    required this.date,
    required this.isReward,
  });
}
