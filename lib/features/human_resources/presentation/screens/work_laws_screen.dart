// work_laws_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tabib_soft_company/core/services/locator/get_it_locator.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';
import 'package:tabib_soft_company/features/human_resources/data/models/hr_labor_law_model.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/cubits/hr_labor_law_cubit.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/cubits/hr_labor_law_state.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkLawsPage extends StatelessWidget {
  const WorkLawsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ServicesLocator.hrLaborLawCubit..fetchLaborLaws(),
      child: BlocBuilder<HrLaborLawCubit, HrLaborLawState>(
        builder: (context, state) {
          final lawsTitle = state.response?.title ?? 'لائحة العمل';
          final categories =
              state.response?.data ?? const <HrLaborLawCategoryModel>[];

          return Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              children: [
                _buildHeader(context, lawsTitle),
                _buildSearchSection(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.status == HrLaborLawStatus.loading)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 24.h),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (categories.isNotEmpty)
                          ..._buildLaborLawCategories(categories)
                        else ...[
                          _buildChapterOne(),
                          SizedBox(height: 24.h),
                          _buildChapterTwo(),
                          SizedBox(height: 24.h),
                          _buildDigitalEnvironment(),
                          SizedBox(height: 24.h),
                          _buildChapterThree(),
                        ],
                        SizedBox(height: 24.h),
                        _buildPDFSection(context),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, [String title = 'لائحة العمل']) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00579B), Color(0xFF00A8D8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36.r),
          bottomRight: Radius.circular(36.r),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Spacer(),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(22.r),
                  child: Container(
                    width: 46.w,
                    height: 46.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                // const Spacer(),
                // Container(
                //   padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                //   decoration: BoxDecoration(
                //     color: Colors.white.withValues(alpha: 0.14),
                //     borderRadius: BorderRadius.circular(18.r),
                //   ),
                //   child: Text(
                //     'سياسة العمل',
                //     style: TextStyle(
                //       fontSize: 12.sp,
                //       color: Colors.white,
                //       fontWeight: FontWeight.w600,
                //     ),
                //   ),
                // ),
              ],
            ),
            SizedBox(height: 26.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'الدليل الشامل للحقوق والواجبات وسياسات الموارد البشرية لعام 2024',
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.white.withValues(alpha: 0.92),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColor.containerColor,
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: AppColor.borderContainerColor),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: AppColor.hintColor,
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'ابحث عن مادة أو موضوع معين...',
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: AppColor.hintColor,
                ),
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.symmetric(vertical: 14.h),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterOne() {
    return _buildExpandableCard(
      title: 'الباب الأول: التوظيف والتعيين',
      subtitle: 'المواد الأساسية المتعلقة بالتعيين والوثائق',
      initiallyExpanded: true,
      children: [
        _buildArticleCard(
          number: '1',
          title: 'فترة التجربة',
          content:
              'تخضع جميع التعيينات الجديدة لفترة تجربة مدتها 90 يوماً. قابلة للتحديد لمرة واحدة بموافقة الطرفين خطياً.',
        ),
        SizedBox(height: 12.h),
        _buildArticleCard(
          number: '2',
          title: 'الوثائق المطلوبة',
          content:
              'يجب تقديم كافة الشهادات العلمية والخبرات العملية الموثقة قبل توقيع العقد النهائي.',
        ),
      ],
    );
  }

  Widget _buildChapterTwo() {
    return _buildExpandableCard(
      title: 'الباب الثاني: أوقات العمل والراحة',
      subtitle: 'الدوام، الاستراحات، والضوابط الأساسية',
      children: [
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: AppColor.lightBg,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Center(
            child: Text(
              'سيتم إضافة المواد قريباً',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColor.subTitleColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDigitalEnvironment() {
    return _buildExpandableCard(
      title: 'بيئة العمل الرقمية',
      subtitle: 'سياسة استخدام الأجهزة والعمل عن بعد 2024',
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColor.secondaryColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            'بيئة العمل الرقمية',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColor.secondaryColor,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'سياسة استخدام الأجهزة والعمل عن بعد 2024',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.titleColor,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColor.secondaryColor,
                size: 20.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'يُسمح بالعمل عن بعد يومي الاثنين والخميس من كل أسبوع بعد موافقة المدير المباشر',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColor.titleColor,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChapterThree() {
    return _buildExpandableCard(
      title: 'الباب الثالث: الإجازات والعطلات',
      subtitle: 'الأنواع والمدة المسموح بها',
      children: [
        _buildVacationCard(
          title: 'الإجازة السنوية',
          days: '21 يوم',
          color: Colors.green,
        ),
        SizedBox(height: 10.h),
        _buildVacationCard(
          title: 'إجازة المرض',
          days: '15 يوم',
          color: Colors.orange,
        ),
        SizedBox(height: 10.h),
        _buildVacationCard(
          title: 'إجازة الطوارئ',
          days: '3 أيام',
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildVacationCard({
    required String title,
    required String days,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade50,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.beach_access_outlined,
                  color: color,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColor.titleColor,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              days,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLaborLawCategories(
    List<HrLaborLawCategoryModel> categories,
  ) {
    final widgets = <Widget>[];

    for (var index = 0; index < categories.length; index++) {
      final category = categories[index];
      widgets.add(
        _buildExpandableCard(
          title: category.category,
          subtitle: '${category.articles.length} بند',
          initiallyExpanded: index == 0,
          children: [
            for (final article in category.articles)
              Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _buildArticleCard(
                  number: article.articleNumber,
                  title: article.title,
                  content: article.content,
                ),
              ),
          ],
        ),
      );
      widgets.add(SizedBox(height: 24.h));
    }

    return widgets;
  }

  Widget _buildPDFSection(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openPdfAsset(context),
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColor.primaryColor,
                AppColor.primaryColor.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppColor.primaryColor.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.picture_as_pdf,
                  color: Colors.white,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'النسخة الكاملة PDF',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'تحديث ديسمبر 2023 (1.6)',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColor.secondaryColor,
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Row(
                  children: [
                    Text(
                      'تحميل',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.download_rounded,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableCard({
    required String title,
    String? subtitle,
    bool initiallyExpanded = false,
    required List<Widget> children,
  }) {
    return _ExpandableCard(
      title: title,
      subtitle: subtitle,
      initiallyExpanded: initiallyExpanded,
      children: children,
    );
  }

  Future<void> _openPdfAsset(BuildContext context) async {
    try {
      final byteData = await rootBundle.load(
        'assets/images/pngs/تعميم الحضور والانصراف.pdf',
      );
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/تعميم الحضور والانصراف.pdf');
      await file.writeAsBytes(
        byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
        flush: true,
      );

      final uri = Uri.file(file.path);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح الملف. حاول مرة أخرى.')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء تحميل الملف: $e')),
      );
    }
  }

  Widget _buildArticleCard({
    required String number,
    required String title,
    required String content,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade400),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade50,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: AppColor.secondaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColor.secondaryColor,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.titleColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.only(right: 40.w),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColor.subTitleColor,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandableCard extends StatefulWidget {
  const _ExpandableCard({
    required this.title,
    this.subtitle,
    this.initiallyExpanded = false,
    required this.children,
  });

  final String title;
  final String? subtitle;
  final bool initiallyExpanded;
  final List<Widget> children;

  @override
  State<_ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<_ExpandableCard>
    with SingleTickerProviderStateMixin {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColor.borderContainerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18.r),
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColor.titleColor,
                            ),
                          ),
                          if (widget.subtitle != null) ...[
                            SizedBox(height: 4.h),
                            Text(
                              widget.subtitle!,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColor.subTitleColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeInOutCubic,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColor.primaryColor,
                        size: 22.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Padding(
                    padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: widget.children,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
