import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';
import 'package:tabib_soft_company/core/utils/constant/app_style.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/cubits/hr_bonus_cubit.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/cubits/hr_bonus_state.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/cubits/hr_deficit_cubit.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/cubits/hr_deficit_state.dart';

class MyReportsPage extends StatefulWidget {
  const MyReportsPage({super.key});

  @override
  State<MyReportsPage> createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> {
  void _loadReports() {
    if (!mounted) return;
    context.read<HrBonusCubit>().fetchBonuses();
    context.read<HrDeficitCubit>().fetchDeficits();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadReports();
  }

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
                    BlocBuilder<HrBonusCubit, HrBonusState>(
                      builder: (context, state) {
                        final isLoading =
                            state.status == HrBonusStatus.loading &&
                                state.bonuses.isEmpty;

                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          child: isLoading
                              ? Skeletonizer(
                                  key: const ValueKey('bonus-skeleton'),
                                  enabled: true,
                                  effect: const ShimmerEffect(
                                    baseColor: Color(0xFFE6EBF2),
                                    highlightColor: Color(0xFFFFFFFF),
                                  ),
                                  child: _buildSectionSkeleton(
                                    isReward: true,
                                  ),
                                )
                              : KeyedSubtree(
                                  key: const ValueKey('bonus-content'),
                                  child: _buildBonusSection(state),
                                ),
                        );
                      },
                    ),
                    SizedBox(height: 24.h),
                    BlocBuilder<HrDeficitCubit, HrDeficitState>(
                      builder: (context, state) {
                        final isLoading =
                            state.status == HrDeficitStatus.loading &&
                                state.deficits.isEmpty;

                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          child: isLoading
                              ? Skeletonizer(
                                  key: const ValueKey('deficit-skeleton'),
                                  enabled: true,
                                  effect: const ShimmerEffect(
                                    baseColor: Color(0xFFE6EBF2),
                                    highlightColor: Color(0xFFFFFFFF),
                                  ),
                                  child: _buildSectionSkeleton(
                                    isReward: false,
                                  ),
                                )
                              : KeyedSubtree(
                                  key: const ValueKey('deficit-content'),
                                  child: _buildDeficitSection(state),
                                ),
                        );
                      },
                    ),
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
          child: BlocBuilder<HrBonusCubit, HrBonusState>(
            builder: (context, state) {
              final isLoading = state.status == HrBonusStatus.loading &&
                  state.bonuses.isEmpty;
              final total = state.bonuses.fold<int>(
                0,
                (sum, item) => sum + (item.defaultMinutes ?? 0),
              );

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: isLoading
                    ? Skeletonizer(
                        key: const ValueKey('bonus-summary-skeleton'),
                        enabled: true,
                        effect: const ShimmerEffect(
                          baseColor: Color(0xFFE6EBF2),
                          highlightColor: Color(0xFFFFFFFF),
                        ),
                        child: _buildSummaryCardSkeleton(),
                      )
                    : KeyedSubtree(
                        key: const ValueKey('bonus-summary-content'),
                        child: _buildSummaryCard(
                          title: 'المكافآت',
                          value: '$total',
                          icon: Icons.thumb_up_alt_outlined,
                          bgColor: AppColor.accentColor.withAlpha(31),
                          iconColor: AppColor.accentColor,
                        ),
                      ),
              );
            },
          ),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: BlocBuilder<HrDeficitCubit, HrDeficitState>(
            builder: (context, state) {
              final isLoading = state.status == HrDeficitStatus.loading &&
                  state.deficits.isEmpty;
              final total = state.deficits.fold<int>(
                0,
                (sum, item) => sum + (item.defaultMinutes ?? 0),
              );

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: isLoading
                    ? Skeletonizer(
                        key: const ValueKey('deficit-summary-skeleton'),
                        enabled: true,
                        effect: const ShimmerEffect(
                          baseColor: Color(0xFFE6EBF2),
                          highlightColor: Color(0xFFFFFFFF),
                        ),
                        child: _buildSummaryCardSkeleton(),
                      )
                    : KeyedSubtree(
                        key: const ValueKey('deficit-summary-content'),
                        child: _buildSummaryCard(
                          title: 'الخصومات',
                          value: '$total',
                          icon: Icons.remove_circle_outline,
                          bgColor: AppColor.secondaryColor.withAlpha(36),
                          iconColor: AppColor.secondaryColor,
                        ),
                      ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 70.w, vertical: 18.h),
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
              color: bgColor,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            title,
            style: AppStyle.font14_400Weight.copyWith(
              color: AppColor.titleColor,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            value,
            style: AppStyle.font18_600Weight.copyWith(
              color: AppColor.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBonusSection(HrBonusState state) {
    final allItems = state.bonuses
        .map(
          (item) => _ReportItem(
            title: item.name ?? 'مكافأة',
            amount: '${item.defaultMinutes ?? 0}',
            isReward: true,
          ),
        )
        .toList();
    final items = allItems.reversed.toList().take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'آخر المكافآت',
          'عرض الكل',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _FullReportListPage(
                title: 'كل المكافآت',
                items: allItems,
                isReward: true,
              ),
            ),
          ),
        ),
        SizedBox(height: 14.h),
        if (items.isEmpty)
          Text(
            'لا توجد مكافآت حالياً',
            style: AppStyle.font13_400Weight.copyWith(
              color: AppColor.subTitleColor,
            ),
          )
        else
          Column(
            children: items.map((item) => _ReportRow(item: item)).toList(),
          ),
      ],
    );
  }

  Widget _buildDeficitSection(HrDeficitState state) {
    final allItems = state.deficits
        .map(
          (item) => _ReportItem(
            title: item.name ?? 'خصم',
            amount: '${item.defaultMinutes ?? 0}',
            isReward: false,
          ),
        )
        .toList();
    final items = allItems.reversed.toList().take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'آخر الخصومات',
          'عرض الكل',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _FullReportListPage(
                title: 'كل الخصومات',
                items: allItems,
                isReward: false,
              ),
            ),
          ),
        ),
        SizedBox(height: 14.h),
        if (items.isEmpty)
          Text(
            'لا توجد خصومات حالياً',
            style: AppStyle.font13_400Weight.copyWith(
              color: AppColor.subTitleColor,
            ),
          )
        else
          Column(
            children: items.map((item) => _ReportRow(item: item)).toList(),
          ),
      ],
    );
  }

  Widget _buildSummaryCardSkeleton() {
    return Container(
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
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: AppColor.accentColor.withAlpha(28),
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
          SizedBox(height: 14.h),
          Container(
            width: 70.w,
            height: 12.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            width: 40.w,
            height: 18.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionSkeleton({required bool isReward}) {
    return Container(
      padding: EdgeInsets.all(14.w),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 110.w,
                height: 12.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Container(
                width: 56.w,
                height: 12.h,
                decoration: BoxDecoration(
                  color: AppColor.accentColor.withAlpha(28),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildSkeletonRow(isReward: isReward),
          SizedBox(height: 10.h),
          _buildSkeletonRow(isReward: isReward),
        ],
      ),
    );
  }

  Widget _buildSkeletonRow({required bool isReward}) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: isReward
                  ? AppColor.accentColor.withAlpha(28)
                  : AppColor.secondaryColor.withAlpha(28),
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120.w,
                  height: 10.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: 80.w,
                  height: 10.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
    String action, {
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppStyle.font16_700Weight.copyWith(
            color: AppColor.titleColor,
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(10.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
            child: Text(
              action,
              style: AppStyle.font14_700Weight.copyWith(
                color: AppColor.accentColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FullReportListPage extends StatelessWidget {
  const _FullReportListPage({
    required this.title,
    required this.items,
    required this.isReward,
  });

  final String title;
  final List<_ReportItem> items;
  final bool isReward;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: Column(
          children: [
            Container(
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
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      Expanded(
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: AppStyle.font20_600Weight.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 48.w),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    isReward
                        ? 'جميع المكافآت المتاحة'
                        : 'جميع الخصومات المتاحة',
                    style: AppStyle.font14_400Weight.copyWith(
                      color: Colors.white.withAlpha(218),
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 24.h),
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          isReward
                              ? 'لا توجد مكافآت متاحة حالياً'
                              : 'لا توجد خصومات متاحة حالياً',
                          style: AppStyle.font14_400Weight.copyWith(
                            color: AppColor.subTitleColor,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return _ReportRow(item: items[index]);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
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
                // Text(
                //   // item.description,
                //   style: AppStyle.font13_400Weight.copyWith(
                //     color: AppColor.subTitleColor,
                //   ),
                // ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Text(
                    //   // item.date,
                    //   style: AppStyle.font12_600Weight.copyWith(
                    //     color: AppColor.hintColor,
                    //   ),
                    // ),
                    Text(
                      '${item.amount} ج.م',
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
  // final String description;
  final String amount;
  // final String date;
  final bool isReward;

  const _ReportItem({
    required this.title,
    // required this.description,
    required this.amount,
    // required this.date,
    required this.isReward,
  });
}
