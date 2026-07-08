// work_laws_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MethodChannel, rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tabib_soft_company/core/services/locator/get_it_locator.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';
import 'package:tabib_soft_company/features/human_resources/data/models/hr_labor_law_model.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/cubits/hr_labor_law_cubit.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/cubits/hr_labor_law_state.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/widgets/work_laws_widgets.dart';

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
                WorkLawsHeader(title: lawsTitle),
                const WorkLawsSearchSection(),
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
                        WorkLawsPdfSection(onTap: () => _openPdfAsset(context)),
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
    return WorkLawsVacationCard(
      title: title,
      days: days,
      color: color,
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

  Widget _buildExpandableCard({
    required String title,
    String? subtitle,
    bool initiallyExpanded = false,
    required List<Widget> children,
  }) {
    return WorkLawsExpandableCard(
      title: title,
      subtitle: subtitle,
      initiallyExpanded: initiallyExpanded,
      children: children,
    );
  }

  static const MethodChannel _fileOpenerChannel =
      MethodChannel('tabib_soft_company/file_opener');

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

      final result = await _fileOpenerChannel.invokeMethod<bool>(
        'openFile',
        {
          'path': file.path,
          'mimeType': 'application/pdf',
        },
      );

      if (result != true) {
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
    return WorkLawsArticleCard(
      number: number,
      title: title,
      content: content,
    );
  }
}
