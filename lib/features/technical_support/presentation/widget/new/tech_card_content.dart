import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/customer_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/screen/problem/problem_details_screen.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/widget/new/full_screen_image_viewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'package:tabib_soft_company/core/services/locator/get_it_locator.dart';
import 'package:dio/dio.dart';
import 'package:tabib_soft_company/features/programmers/data/model/engineer_model.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/engineer_cubit.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/engineer_state.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/problem/problem_model.dart';

class TechCardContent extends StatelessWidget {
  final ProblemModel issue;
  final VoidCallback? onDetailsPressed;

  const TechCardContent({
    super.key,
    required this.issue,
    this.onDetailsPressed,
  });

  void _makePhoneCall(BuildContext context) async {
    final phone = issue.phone ?? issue.phone;
    if (phone != null && phone.isNotEmpty && phone != 'غير متوفر') {
      final Uri url = Uri(scheme: 'tel', path: phone);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    }
  }

  void _assignProblem(BuildContext context, String engineerId) async {
    final problemId = issue.id;

    final String? problemStatusIdFromIssue = (() {
      try {
        final dynamic val = (issue as dynamic).problemStatusId;
        if (val != null) return val.toString();
      } catch (_) {}
      try {
        final dynamic val = (issue as dynamic).statusId;
        if (val != null) return val.toString();
      } catch (_) {}
      try {
        final dynamic val = (issue as dynamic).status;
        if (val != null) return val.toString();
      } catch (_) {}
      return null;
    })();

    if (problemId == null ||
        engineerId.isEmpty ||
        issue.customerId == null ||
        (problemStatusIdFromIssue == null ||
            problemStatusIdFromIssue.isEmpty)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'خطأ: لا يمكن تعيين المشكلة. تأكد من توفر جميع البيانات المطلوبة',
            ),
          ),
        );
      }
      return;
    }

    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
    }

    try {
      final apiService = ServicesLocator.locator<ApiService>();

      await apiService.changeProblemStatus(
        customerSupportId: problemId,
        engineerId: engineerId,
        problemStatusId: problemStatusIdFromIssue,
        customerId: issue.customerId!,
      );

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحويل المشكلة إلى المهندس بنجاح'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        context.read<CustomerCubit>().refreshAllData();
      }
    } on DioException catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (context.mounted) {
        String errorMessage = 'حدث خطأ في الاتصال بالخادم';
        if (e.response != null) {
          errorMessage =
              'فشل تحويل المشكلة. رمز الخطأ: ${e.response!.statusCode}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ غير متوقع: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<bool?> _showConfirmationDialog(
    BuildContext context,
    EngineerModel engineer,
  ) async {
    if (!context.mounted) return null;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.r),
          ),
          elevation: 10,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFFF8FBFF),
                  Color(0xFFFFFFFF),
                ],
              ),
              borderRadius: BorderRadius.circular(28.r),
              border: Border.all(
                color: const Color(0xFF20AAC9),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF20AAC9).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF20AAC9), Color(0xFF104D9D)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF20AAC9).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.assignment_turned_in_rounded,
                      color: Colors.white,
                      size: 48.r,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'تأكيد التحويل',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF104D9D),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F8FF),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: const Color(0xFF20AAC9).withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'هل تريد تحويل هذه المشكلة إلى المهندس؟',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_rounded,
                                color: const Color(0xFF20AAC9),
                                size: 24.r,
                              ),
                              SizedBox(width: 8.w),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      engineer.name,
                                      style: TextStyle(
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF104D9D),
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.phone,
                                          color: Colors.grey[600],
                                          size: 14.r,
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          engineer.telephone,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 28.h),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: Colors.grey[400]!,
                              width: 2,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16.r),
                              onTap: () =>
                                  Navigator.of(dialogContext).pop(false),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.close_rounded,
                                      color: Colors.grey[700],
                                      size: 22.r,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'إلغاء',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF20AAC9), Color(0xFF104D9D)],
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF20AAC9).withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16.r),
                              onTap: () =>
                                  Navigator.of(dialogContext).pop(true),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: Colors.white,
                                      size: 22.r,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'تأكيد',
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
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEngineerSelectionDialog(BuildContext context) {
    context.read<EngineerCubit>().fetchEngineers();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocBuilder<EngineerCubit, EngineerState>(
          builder: (blocContext, state) {
            if (state.status == EngineerStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == EngineerStatus.failure) {
              return AlertDialog(
                title: const Text('خطأ'),
                content: Text(
                  'فشل تحميل قائمة المهندسين: ${state.errorMessage}',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('إغلاق'),
                  ),
                ],
              );
            }

            if (state.engineers.isEmpty) {
              return AlertDialog(
                title: const Text('تنبيه'),
                content: const Text('لا يوجد مهندسون متاحون حاليًا.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('إغلاق'),
                  ),
                ],
              );
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.engineering_rounded,
                    color: const Color(0xFF20AAC9),
                    size: 28.r,
                  ),
                  SizedBox(width: 12.w),
                  const Text('اختر المهندس'),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.engineers.length,
                  itemBuilder: (listContext, index) {
                    final engineer = state.engineers[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: const Color(0xFF20AAC9).withOpacity(0.3),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF20AAC9),
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 24.r,
                          ),
                        ),
                        title: Text(
                          engineer.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 14.r,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4.w),
                            Text(engineer.telephone),
                          ],
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 18.r,
                          color: const Color(0xFF20AAC9),
                        ),
                        onTap: () async {
                          Navigator.of(dialogContext).pop();

                          if (!context.mounted) return;

                          final confirmed = await _showConfirmationDialog(
                            context,
                            engineer,
                          );

                          if (!context.mounted) return;

                          if (confirmed == true) {
                            _assignProblem(context, engineer.id);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('إلغاء'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showImageFullScreen(BuildContext context, String url) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 40.h,
                right: 20.w,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    iconSize: 28.r,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showImagesBottomSheet(BuildContext context) {
    final images = issue.images;
    if (images == null || images.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.65, // يبدأ من ثلثي الشاشة تقريبًا
        minChildSize: 0.4, // أقل ارتفاع ممكن
        maxChildSize: 0.92, // أقصى ارتفاع (يمكن السحب للأعلى)
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // شريط السحب + العنوان
              Padding(
                padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
                child: Column(
                  children: [
                    Container(
                      width: 40.w,
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'صور المشكلة • ${images.length}',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF104D9D),
                      ),
                    ),
                    Divider(
                      height: 32.h,
                      thickness: 1,
                      indent: 60.w,
                      endIndent: 60.w,
                      color: Colors.grey[300],
                    ),
                  ],
                ),
              ),

              // GridView مع Scroll داخلي
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: GridView.builder(
                    controller: scrollController, // مهم جدًا للـ scroll الداخلي
                    padding: EdgeInsets.only(bottom: 20.h, top: 8.h),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14.w,
                      mainAxisSpacing: 14.h,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      final String imageUrl = images[index].toString();

                      return Hero(
                        tag: 'problem_image_$index',
                        child: Material(
                          borderRadius: BorderRadius.circular(20.r),
                          elevation: 8,
                          shadowColor: Colors.black.withOpacity(0.2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.r),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20.r),
                              onTap: () {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    opaque: false,
                                    barrierColor:
                                        Colors.black.withOpacity(0.95),
                                    transitionDuration:
                                        const Duration(milliseconds: 300),
                                    pageBuilder: (_, __, ___) =>
                                        FullScreenImageViewer(
                                      imageUrl: imageUrl,
                                      heroTag: 'problem_image_$index',
                                    ),
                                  ),
                                );
                              },
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: Colors.grey[100],
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            valueColor:
                                                const AlwaysStoppedAnimation(
                                                    Color(0xFF20AAC9)),
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (_, __, ___) => Container(
                                      color: Colors.grey[200],
                                      child: Icon(
                                          Icons.image_not_supported_outlined,
                                          size: 50.r,
                                          color: Colors.grey[500]),
                                    ),
                                  ),
                                  // تدرج + رقم الصورة
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10.h),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.7),
                                          ],
                                        ),
                                      ),
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          shadows: const [
                                            Shadow(
                                              blurRadius: 6,
                                              color: Colors.black54,
                                              offset: Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _hexToColor(String? hex, {Color fallback = const Color(0xFF6BABFA)}) {
    if (hex == null || hex.isEmpty) return fallback;
    final cleaned = hex.replaceAll('#', '').trim();
    try {
      if (cleaned.length == 6) {
        return Color(int.parse('FF$cleaned', radix: 16));
      } else if (cleaned.length == 8) {
        return Color(int.parse(cleaned, radix: 16));
      }
    } catch (_) {}
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final Color statusColor =
        _hexToColor(issue.porblemColor ?? issue.statusColor);
    final Color textColor =
        statusColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 13.h,
            child: Container(
              width: 390.w,
              height: 275.h,
              decoration: BoxDecoration(
                color: const Color(0xff104D9D),
                borderRadius: BorderRadius.circular(25.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    offset: Offset(4.w, 6.h),
                    blurRadius: 12.r,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 23.h, left: 20.w, right: 0.w),
            child: Container(
              height: 250.h,
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 30.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.r),
                border: Border.all(color: const Color(0xff20AAC9), width: 4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/pngs/new_person.png',
                        width: 38.w,
                        height: 38.h,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          issue.customerName ?? 'غير معروف',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showEngineerSelectionDialog(context),
                        child: Container(
                          padding: EdgeInsets.all(6.r),
                          margin: EdgeInsets.only(left: 8.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFF20AAC9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                offset: Offset(1.w, 2.h),
                                blurRadius: 4.r,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.directions_outlined,
                            color: Colors.white,
                            size: 26.r,
                          ),
                        ),
                      ),
                      if (issue.images != null && issue.images!.isNotEmpty)
                        GestureDetector(
                          onTap: () => _showImagesBottomSheet(context),
                          child: Container(
                            padding: EdgeInsets.all(6.r),
                            margin: EdgeInsets.only(left: 8.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  offset: Offset(1.w, 2.h),
                                  blurRadius: 4.r,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.image_rounded,
                              color: const Color(0xFF20AAC9),
                              size: 24.r,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: () => _makePhoneCall(context),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/pngs/new_call.png',
                          width: 34.w,
                          height: 34.h,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: SelectableText(
                            issue.phone ?? issue.phone ?? 'غير متوفر',
                            style: TextStyle(
                              fontSize: 19.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey[850],
                            ),
                            textDirection: TextDirection.rtl,
                            onTap: () => _makePhoneCall(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/images/pngs/specialization.png',
                          width: 24.r,
                          height: 24.r,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (issue.products != null &&
                                issue.products!.isNotEmpty)
                              Wrap(
                                spacing: 8.w,
                                runSpacing: 6.h,
                                children:
                                    issue.products!.take(3).map((product) {
                                  final String name = product is Map
                                      ? (product['name'] ??
                                          product['productName'] ??
                                          product['title'] ??
                                          'منتج')
                                      : product.toString();

                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 6.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20.r),
                                      border: Border.all(
                                        color: statusColor,
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: statusColor,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              )
                            else
                              Row(
                                children: [
                                  Text(
                                    issue.problemtype ?? 'نوع التخصص غير متاح',
                                    style: TextStyle(
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'نوع التخصص غير متاح',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color.fromARGB(
                                        255,
                                        231,
                                        110,
                                        110,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            if (issue.products != null &&
                                issue.products!.length > 3)
                              Padding(
                                padding: EdgeInsets.only(top: 6.h),
                                child: Text(
                                  '+${issue.products!.length - 3} منتجات أخرى',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: const Color(0xffFF9800),
                        size: 34.r,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          issue.problemAddress ?? 'لا توجد تفاصيل',
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 110.w,
            bottom: -5.h,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF20AAC9), Color(0xFF1E96BA)],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF20AAC9).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () async {
                    print('🎯 Button pressed - Issue ID: ${issue.id}');

                    // تحقق من وجود ID
                    if (issue.id == null || issue.id!.isEmpty) {
                      print('❌ Issue ID is null or empty');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('معرف المشكلة غير متوفر'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                      return;
                    }

                    // عرض Loading
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext dialogContext) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      );
                    }

                    try {
                      print(
                          '📡 Calling fetchProblemDetailsById with ID: ${issue.id}');

                      // ✅ جلب البيانات من API
                      await context
                          .read<CustomerCubit>()
                          .fetchProblemDetailsById(issue.id!);

                      if (!context.mounted) return;

                      Navigator.of(context).pop(); // إغلاق Loading

                      final updatedProblem =
                          context.read<CustomerCubit>().state.selectedProblem;

                      print(
                          '📦 Selected problem after fetch: ${updatedProblem?.id}');
                      print(
                          '📋 CustomerSupport count: ${updatedProblem?.customerSupport?.length ?? 0}');
                      print(
                          '📋 UnderTransactions count: ${updatedProblem?.underTransactions?.length ?? 0}');

                      if (updatedProblem != null) {
                        print('✅ Opening ProblemDetailsScreen');
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ProblemDetailsScreen(issue: updatedProblem),
                          ),
                        );

                        if (result == true && context.mounted) {
                          context.read<CustomerCubit>().refreshAllData();
                        }
                      } else {
                        print('❌ updatedProblem is null');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('فشل تحميل تفاصيل المشكلة'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      print('❌ Exception in onTap: $e');
                      if (context.mounted) {
                        Navigator.of(context).pop(); // إغلاق Loading
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('حدث خطأ: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 36.w,
                      vertical: 12.h,
                    ),
                    child: Text(
                      'تفاصيل',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
