import 'dart:async';
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
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';

class TechCardContent extends StatefulWidget {
  final ProblemModel issue;
  final VoidCallback? onDetailsPressed;

  const TechCardContent({
    super.key,
    required this.issue,
    this.onDetailsPressed,
  });

  @override
  State<TechCardContent> createState() => _TechCardContentState();
}

class _TechCardContentState extends State<TechCardContent>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'غير متوفر';
    try {
      final DateTime date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatTimeAgo(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final DateTime date = DateTime.parse(dateStr);
      final Duration difference = DateTime.now().difference(date);

      if (difference.inMinutes < 60) {
        return 'منذ ${difference.inMinutes} دقيقة';
      } else if (difference.inHours < 24) {
        return 'منذ ${difference.inHours} ساعة';
      } else if (difference.inDays < 7) {
        return 'منذ ${difference.inDays} يوم';
      } else {
        return '';
      }
    } catch (_) {
      return '';
    }
  }

  void _makePhoneCall(BuildContext context) async {
    final phone = widget.issue.phone ?? widget.issue.phone;
    if (phone != null && phone.isNotEmpty && phone != 'غير متوفر') {
      final Uri url = Uri(scheme: 'tel', path: phone);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    }
  }

  void _assignProblem(BuildContext context, String engineerId) async {
    final problemId = widget.issue.id;

    final String? problemStatusIdFromIssue = (() {
      try {
        final dynamic val = (widget.issue as dynamic).problemStatusId;
        if (val != null) return val.toString();
      } catch (_) {}
      try {
        final dynamic val = (widget.issue as dynamic).statusId;
        if (val != null) return val.toString();
      } catch (_) {}
      try {
        final dynamic val = (widget.issue as dynamic).status;
        if (val != null) return val.toString();
      } catch (_) {}
      return null;
    })();

    if (problemId == null ||
        engineerId.isEmpty ||
        widget.issue.customerId == null ||
        (problemStatusIdFromIssue == null ||
            problemStatusIdFromIssue.isEmpty)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'خطأ: لا يمكن تعيين المشكلة. تأكد من توفر جميع البيانات المطلوبة',
            ),
            backgroundColor: TechColors.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
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
          return Center(
            child: Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: const CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(TechColors.accentCyan),
              ),
            ),
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
        customerId: widget.issue.customerId!,
      );

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 20.r),
                SizedBox(width: 8.w),
                const Text('تم تحويل المشكلة إلى المهندس بنجاح'),
              ],
            ),
            backgroundColor: TechColors.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
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
            backgroundColor: TechColors.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
            backgroundColor: TechColors.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
            borderRadius: BorderRadius.circular(24.r),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: TechColors.primaryDark.withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    padding: EdgeInsets.all(20.r),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [TechColors.accentCyan, TechColors.primaryMid],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: TechColors.accentCyan.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.assignment_turned_in_rounded,
                      color: Colors.white,
                      size: 40.r,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'تأكيد التحويل',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: TechColors.primaryDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  // Engineer info card
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: TechColors.surfaceLight,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: TechColors.accentCyan.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'هل تريد تحويل هذه المشكلة إلى:',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.r),
                              decoration: BoxDecoration(
                                color: TechColors.accentCyan.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.engineering_rounded,
                                color: TechColors.accentCyan,
                                size: 24.r,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    engineer.name ?? '',
                                    style: TextStyle(
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.w700,
                                      color: TechColors.primaryDark,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.phone_rounded,
                                        color: Colors.grey[500],
                                        size: 14.r,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        engineer.telephone ?? '',
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: Colors.grey[600],
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
                      ],
                    ),
                  ),
                  SizedBox(height: 28.h),
                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: Text(
                            'إلغاء',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                TechColors.accentCyan,
                                TechColors.primaryMid
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14.r),
                            boxShadow: [
                              BoxShadow(
                                color: TechColors.accentCyan.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14.r),
                              onTap: () =>
                                  Navigator.of(dialogContext).pop(true),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 20.r,
                                    ),
                                    SizedBox(width: 6.w),
                                    Text(
                                      'تأكيد',
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w700,
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 12.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: TechColors.accentCyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.engineering_rounded,
                        color: TechColors.accentCyan,
                        size: 24.r,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'اختر المهندس',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: TechColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: Colors.grey[200]),
              // Engineers list
              Expanded(
                child: BlocBuilder<EngineerCubit, EngineerState>(
                  builder: (blocContext, state) {
                    if (state.status == EngineerStatus.loading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              TechColors.accentCyan),
                        ),
                      );
                    }

                    if (state.status == EngineerStatus.failure) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              color: TechColors.errorRed,
                              size: 48.r,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'فشل تحميل قائمة المهندسين',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state.engineers.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_off_rounded,
                              color: Colors.grey[400],
                              size: 48.r,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'لا يوجد مهندسون متاحون',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: EdgeInsets.all(16.w),
                      itemCount: state.engineers.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (listContext, index) {
                        final engineer = state.engineers[index];
                        return _EngineerCard(
                          engineer: engineer,
                          onTap: () async {
                            Navigator.of(dialogContext).pop();

                            if (!context.mounted) return;

                            final confirmed = await _showConfirmationDialog(
                              context,
                              engineer,
                            );

                            if (!context.mounted) return;

                            if (confirmed == true) {
                              _assignProblem(context, engineer.id ?? '');
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showImagesBottomSheet(BuildContext context) {
    final images = widget.issue.images;
    if (images == null || images.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          child: Column(
            children: [
              // Handle + Title
              Padding(
                padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
                child: Column(
                  children: [
                    Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_library_rounded,
                          color: TechColors.accentCyan,
                          size: 24.r,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'صور المشكلة',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                            color: TechColors.primaryDark,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: TechColors.accentCyan.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${images.length}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: TechColors.accentCyan,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(
                height: 24.h,
                color: Colors.grey[200],
              ),
              // Images Grid
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: GridView.builder(
                    controller: scrollController,
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
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(
                                color: TechColors.primaryDark.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.r),
                            child: Material(
                              color: Colors.white,
                              child: InkWell(
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
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          color: TechColors.surfaceLight,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  const AlwaysStoppedAnimation(
                                                      TechColors.accentCyan),
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
                                        color: TechColors.surfaceLight,
                                        child: Icon(
                                          Icons.image_not_supported_rounded,
                                          size: 40.r,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                    ),
                                    // Number badge
                                    Positioned(
                                      top: 8.h,
                                      right: 8.w,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                          vertical: 4.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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

  Color _hexToColor(String? hex, {Color fallback = const Color(0xFF2C7DA0)}) {
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

  Future<void> _openProblemDetails(BuildContext context) async {
    if (widget.issue.id == null || widget.issue.id!.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('معرف المشكلة غير متوفر'),
            backgroundColor: TechColors.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
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
        barrierColor: Colors.black.withOpacity(0.85),
        builder: (BuildContext dialogContext) {
          return const _CodeLoadingOverlay();
        },
      );
    }

    try {
      await context
          .read<CustomerCubit>()
          .fetchProblemDetailsById(widget.issue.id!);

      if (!context.mounted) return;

      Navigator.of(context).pop();

      final updatedProblem =
          context.read<CustomerCubit>().state.selectedProblem;

      if (updatedProblem != null) {
        final result = await showProblemDetailsSheet(context, updatedProblem);

        if (result == true && context.mounted) {
          context.read<CustomerCubit>().refreshAllData();
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('فشل تحميل تفاصيل المشكلة'),
              backgroundColor: TechColors.errorRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: TechColors.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color statusColor =
        _hexToColor(widget.issue.porblemColor ?? widget.issue.statusColor);
    final timeAgo = _formatTimeAgo(widget.issue.problemDate);

    return GestureDetector(
      onTap: () => _openProblemDetails(context),
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            // Colored glow shadow
            BoxShadow(
              color: statusColor.withOpacity(_isPressed ? 0.25 : 0.15),
              blurRadius: _isPressed ? 14 : 22,
              offset: Offset(0, _isPressed ? 4 : 8),
              spreadRadius: _isPressed ? 0 : 1,
            ),
            // Subtle dark shadow for depth
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Colored left accent bar ──────────────────────────
                Container(
                  width: 5.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        statusColor,
                        statusColor.withOpacity(0.55),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),

                // ── Card body ────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─ Header row ─────────────────────────────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Avatar
                            Container(
                              width: 46.w,
                              height: 46.w,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    statusColor.withOpacity(0.80),
                                    statusColor,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: statusColor.withOpacity(0.30),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  (widget.issue.customerName?.isNotEmpty ==
                                          true)
                                      ? widget.issue.customerName![0]
                                          .toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),

                            // Name + type + time
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        widget.issue.customerName ??
                                            'غير معروف',
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF0D1B2A),
                                          letterSpacing: -0.2,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(width: 6.w),
                                      // Type pill
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 3.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.10),
                                          borderRadius:
                                              BorderRadius.circular(20.r),
                                          border: Border.all(
                                            color:
                                                statusColor.withOpacity(0.25),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          widget.issue.problemtype ??
                                              'غير محدد',
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w700,
                                            color: statusColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // SizedBox(height: 5.h),
                                  if (timeAgo.isNotEmpty) ...[
                                    SizedBox(width: 7.w),
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 11.r,
                                      color: Colors.grey[450],
                                    ),
                                    SizedBox(width: 3.w),
                                    Text(
                                      timeAgo,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: Colors.grey[500],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // Action buttons
                            SizedBox(width: 8.w),
                            _buildQuickActions(context),
                          ],
                        ),

                        SizedBox(height: 12.h),
                        Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey.shade100),
                        SizedBox(height: 10.h),

                        // ─ Products chips ──────────────────────────────
                        if (widget.issue.products != null &&
                            widget.issue.products!.isNotEmpty) ...[
                          Wrap(
                            spacing: 6.w,
                            runSpacing: 6.h,
                            children:
                                widget.issue.products!.take(3).map((product) {
                              final String name = product is Map
                                  ? (product['name'] ??
                                      product['productName'] ??
                                      product['title'] ??
                                      'منتج')
                                  : product.toString();
                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEBF5FB),
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color:
                                        TechColors.accentCyan.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.local_hospital_rounded,
                                      color: TechColors.accentCyan,
                                      size: 11.r,
                                    ),
                                    SizedBox(width: 5.w),
                                    Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF1565C0),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          if (widget.issue.products!.length > 3)
                            Padding(
                              padding: EdgeInsets.only(top: 5.h),
                              child: Text(
                                '+${widget.issue.products!.length - 3} منتجات أخرى',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                          SizedBox(height: 10.h),
                        ],

                        // ─ Problem description ─────────────────────────
                        if (widget.issue.problemAddress?.isNotEmpty ==
                            true) ...[
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 9.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E1),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color:
                                    TechColors.warningOrange.withOpacity(0.22),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(4.r),
                                  decoration: BoxDecoration(
                                    color: TechColors.warningOrange
                                        .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(7.r),
                                  ),
                                  child: Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    color: TechColors.warningOrange,
                                    size: 13.r,
                                  ),
                                ),
                                SizedBox(width: 9.w),
                                Expanded(
                                  child: Text(
                                    widget.issue.problemAddress!,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF4A3000),
                                      height: 1.5,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10.h),
                        ],

                        // ─ Info chips row ──────────────────────────────
                        Row(
                          children: [
                            // Phone chip
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _makePhoneCall(context),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 8.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: TechColors.successGreen
                                        .withOpacity(0.07),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: TechColors.successGreen
                                          .withOpacity(0.20),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.phone_rounded,
                                        color: TechColors.successGreen,
                                        size: 14.r,
                                      ),
                                      SizedBox(width: 7.w),
                                      Expanded(
                                        child: Text(
                                          widget.issue.phone ?? 'غير متوفر',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w700,
                                            color: TechColors.successGreen,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            // Date chip
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: TechColors.warningOrange
                                      .withOpacity(0.07),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: TechColors.warningOrange
                                        .withOpacity(0.18),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      color: TechColors.warningOrange,
                                      size: 13.r,
                                    ),
                                    SizedBox(width: 7.w),
                                    Expanded(
                                      child: Text(
                                        _formatDate(widget.issue.problemDate),
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF8B4513),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Transfer to engineer button
        _buildActionButton(
          icon: Icons.swap_horiz_rounded,
          color: Colors.black45,
          onTap: () => _showEngineerSelectionDialog(context),
        ),
        // Images button
        if (widget.issue.images != null && widget.issue.images!.isNotEmpty)
          _buildActionButton(
            icon: Icons.photo_library_rounded,
            color: TechColors.warningOrange,
            badge: widget.issue.images!.length.toString(),
            onTap: () => _showImagesBottomSheet(context),
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    String? badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: color, size: 18.r),
            if (badge != null)
              Positioned(
                top: 3.h,
                right: 3.w,
                child: Container(
                  width: 14.r,
                  height: 14.r,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      badge,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 7.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getPrimaryProductLabel() {
    final products = widget.issue.products;
    if (products == null || products.isEmpty) return '';
    final product = products.first;
    if (product is Map) {
      return (product['name'] ??
              product['productName'] ??
              product['title'] ??
              product['label'] ??
              '')
          .toString();
    }
    return product.toString();
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String content,
    bool isClickable = false,
    VoidCallback? onTap,
  }) {
    final row = Row(
      children: [
        Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: Icon(icon, color: iconColor, size: 15.r),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            content,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color:
                  isClickable ? TechColors.accentCyan : const Color(0xFF334155),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isClickable)
          Container(
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(
              Icons.call_rounded,
              color: iconColor,
              size: 13.r,
            ),
          ),
      ],
    );

    if (isClickable && onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: row,
      );
    }
    return row;
  }
}

// Engineer card widget
class _EngineerCard extends StatelessWidget {
  final EngineerModel engineer;
  final VoidCallback onTap;

  const _EngineerCard({
    required this.engineer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFF2C7DA0).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A2647).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2C7DA0), Color(0xFF144272)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.engineering_rounded,
                      color: Colors.white,
                      size: 24.r,
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        engineer.name ?? '',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0A2647),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_rounded,
                            size: 14.r,
                            color: Colors.grey[500],
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            engineer.telephone ?? '',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C7DA0).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16.r,
                    color: const Color(0xFF2C7DA0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Code-Typing Loading Overlay
//  Simulates a developer typing real Dart/API code while data is fetched.
// ─────────────────────────────────────────────────────────────────────────────

class _CodeSpan {
  final String text;
  final Color color;
  const _CodeSpan(this.text, this.color);
}

class _CodeLoadingOverlay extends StatefulWidget {
  const _CodeLoadingOverlay();

  @override
  State<_CodeLoadingOverlay> createState() => _CodeLoadingOverlayState();
}

class _CodeLoadingOverlayState extends State<_CodeLoadingOverlay>
    with TickerProviderStateMixin {
  // ── Syntax color palette (VS Code Dark+) ──────────────────────────
  static const Color _kKeyword = Color(0xFF569CD6); // blue
  static const Color _kString = Color(0xFFCE9178); // orange
  static const Color _kComment = Color(0xFF6A9955); // green
  static const Color _kFunction = Color(0xFFDCDCAA); // yellow
  static const Color _kType = Color(0xFF4EC9B0); // teal
  static const Color _kSymbol = Color(0xFFD4D4D4); // white-ish
  static const Color _kNumber = Color(0xFFB5CEA8); // light green
  static const Color _kVariable = Color(0xFF9CDCFE); // light blue

  // ── Lines of "code" to stream ──────────────────────────────────────
  static final List<List<_CodeSpan>> _lines = [
    [
      _sp("import ", _kKeyword),
      _sp("'package:tabib/api/support.dart'", _kString),
      _sp(";", _kSymbol)
    ],
    [
      _sp("import ", _kKeyword),
      _sp("'package:tabib/models/problem.dart'", _kString),
      _sp(";", _kSymbol)
    ],
    [_sp("", _kSymbol)],
    [_sp("// ── جاري تحميل تفاصيل المشكلة ──", _kComment)],
    [
      _sp("Future", _kType),
      _sp("<", _kSymbol),
      _sp("ProblemModel", _kType),
      _sp("> ", _kSymbol),
      _sp("fetchDetails", _kFunction),
      _sp("(", _kSymbol),
      _sp("String ", _kKeyword),
      _sp("id", _kVariable),
      _sp(") async {", _kSymbol)
    ],
    [
      _sp("  final ", _kKeyword),
      _sp("endpoint", _kVariable),
      _sp(" = ", _kSymbol),
      _sp("'/api/Problem/GetTechnicalSupportData/'", _kString),
      _sp(";", _kSymbol)
    ],
    [
      _sp("  final ", _kKeyword),
      _sp("response", _kVariable),
      _sp(" = ", _kSymbol),
      _sp("await ", _kKeyword),
      _sp("dio", _kVariable),
      _sp(".", _kSymbol),
      _sp("get", _kFunction),
      _sp("(endpoint + id);", _kSymbol)
    ],
    [_sp("", _kSymbol)],
    [
      _sp("  // status: ", _kComment),
      _sp("200 OK", _kNumber),
      _sp(" ✓", _kComment)
    ],
    [
      _sp("  final ", _kKeyword),
      _sp("data", _kVariable),
      _sp(" = ", _kSymbol),
      _sp("response", _kVariable),
      _sp(".data;", _kSymbol)
    ],
    [
      _sp("  final ", _kKeyword),
      _sp("problem", _kVariable),
      _sp(" = ", _kSymbol),
      _sp("ProblemModel", _kType),
      _sp(".", _kSymbol),
      _sp("fromJson", _kFunction),
      _sp("(data);", _kSymbol)
    ],
    [_sp("", _kSymbol)],
    [
      _sp("  // customerSupport: ", _kComment),
      _sp("3", _kNumber),
      _sp(" records found", _kComment)
    ],
    [
      _sp("  return ", _kKeyword),
      _sp("problem", _kVariable),
      _sp(";", _kSymbol)
    ],
    [_sp("}", _kSymbol)],
    [_sp("", _kSymbol)],
    [_sp("// ✅ ", _kComment), _sp("Ready — opening details…", _kComment)],
  ];

  static _CodeSpan _sp(String t, Color c) => _CodeSpan(t, c);

  // ── State ──────────────────────────────────────────────────────────
  int _visibleLines = 0; // how many lines are fully shown
  int _currentChar = 0; // how many chars of the current line are shown
  bool _cursorOn = true;
  Timer? _typingTimer;
  Timer? _cursorTimer;
  late AnimationController _progressCtrl;
  late AnimationController _glowCtrl;

  String get _currentLineText => _visibleLines < _lines.length
      ? _lines[_visibleLines].map((s) => s.text).join()
      : '';

  @override
  void initState() {
    super.initState();

    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _cursorTimer = Timer.periodic(const Duration(milliseconds: 530), (_) {
      if (mounted) setState(() => _cursorOn = !_cursorOn);
    });

    _scheduleNextChar();
  }

  void _scheduleNextChar() {
    if (_visibleLines >= _lines.length) return;

    final lineLen = _currentLineText.length;
    final isEmptyLine = lineLen == 0;
    final delay = isEmptyLine
        ? const Duration(milliseconds: 120)
        : const Duration(milliseconds: 38);

    _typingTimer = Timer(delay, () {
      if (!mounted) return;
      setState(() {
        if (isEmptyLine || _currentChar >= lineLen) {
          _visibleLines++;
          _currentChar = 0;
        } else {
          _currentChar++;
        }
      });
      _scheduleNextChar();
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _cursorTimer?.cancel();
    _progressCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: AnimatedBuilder(
          animation: _glowCtrl,
          builder: (_, child) => Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF569CD6)
                    .withOpacity(0.3 + _glowCtrl.value * 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF569CD6)
                      .withOpacity(0.12 + _glowCtrl.value * 0.12),
                  blurRadius: 32,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: child,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Title bar ────────────────────────────────────────
              _buildTitleBar(),

              // ── Code area ────────────────────────────────────────
              Container(
                constraints:
                    const BoxConstraints(maxHeight: 280, minHeight: 160),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: SingleChildScrollView(
                  reverse: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Fully completed lines
                      for (int i = 0;
                          i < _visibleLines && i < _lines.length;
                          i++)
                        _buildLine(_lines[i], null),

                      // Currently typing line
                      if (_visibleLines < _lines.length)
                        _buildPartialLine(
                          _lines[_visibleLines],
                          _currentChar,
                          _cursorOn,
                        ),
                    ],
                  ),
                ),
              ),

              // ── Progress bar ─────────────────────────────────────
              _buildProgressBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Title bar (like VS Code) ─────────────────────────────────────
  Widget _buildTitleBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF2D2D2D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          // Traffic-light dots
          _dot(const Color(0xFFFF5F57)),
          const SizedBox(width: 6),
          _dot(const Color(0xFFFFBD2E)),
          const SizedBox(width: 6),
          _dot(const Color(0xFF28C840)),
          const SizedBox(width: 12),
          // File tab
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.code_rounded, size: 13, color: Color(0xFF569CD6)),
                SizedBox(width: 5),
                Text(
                  'support_service.dart',
                  style: TextStyle(
                    color: Color(0xFFCCCCCC),
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Blinking record dot = "executing"
          AnimatedBuilder(
            animation: _glowCtrl,
            builder: (_, __) => Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF28C840)
                        .withOpacity(0.4 + _glowCtrl.value * 0.6),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'Running…',
                  style: TextStyle(
                    color: const Color(0xFF28C840)
                        .withOpacity(0.5 + _glowCtrl.value * 0.5),
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color c) => Container(
        width: 11,
        height: 11,
        decoration: BoxDecoration(shape: BoxShape.circle, color: c),
      );

  // ── Fully completed line ─────────────────────────────────────────
  Widget _buildLine(List<_CodeSpan> spans, _) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12.5,
            height: 1.6,
          ),
          children: [
            // Line number
            TextSpan(
              text: '  ',
              style: TextStyle(color: Colors.white.withOpacity(0.15)),
            ),
            ...spans.map((s) =>
                TextSpan(text: s.text, style: TextStyle(color: s.color))),
          ],
        ),
      ),
    );
  }

  // ── Partially typed line with cursor ─────────────────────────────
  Widget _buildPartialLine(
      List<_CodeSpan> spans, int charCount, bool cursorVisible) {
    // Flatten spans into char list
    final fullText = spans.map((s) => s.text).join();
    final shown = fullText.length > charCount
        ? fullText.substring(0, charCount)
        : fullText;

    // Re-apply span colors to shown chars
    final List<InlineSpan> children = [];
    int consumed = 0;
    for (final span in spans) {
      if (consumed >= shown.length) break;
      final end = (consumed + span.text.length).clamp(0, shown.length);
      final part = shown.substring(consumed, end);
      if (part.isNotEmpty) {
        children.add(TextSpan(text: part, style: TextStyle(color: span.color)));
      }
      consumed = end;
    }

    // Blinking cursor block
    if (cursorVisible) {
      children.add(
        WidgetSpan(
          child: Container(
            width: 7.5,
            height: 15,
            color: const Color(0xFFAEAFAD),
            margin: const EdgeInsets.only(left: 1),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12.5,
            height: 1.6,
          ),
          children: [
            TextSpan(
              text: '  ',
              style: TextStyle(color: Colors.white.withOpacity(0.15)),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  // ── Progress bar ─────────────────────────────────────────────────
  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.terminal_rounded,
                  size: 12, color: Color(0xFF6A9955)),
              const SizedBox(width: 6),
              const Text(
                'Connecting to API…',
                style: TextStyle(
                  color: Color(0xFF6A9955),
                  fontSize: 10.5,
                  fontFamily: 'monospace',
                ),
              ),
              const Spacer(),
              AnimatedBuilder(
                animation: _progressCtrl,
                builder: (_, __) => Text(
                  '${((_visibleLines / _lines.length) * 100).toInt()}%',
                  style: const TextStyle(
                    color: Color(0xFF569CD6),
                    fontSize: 10.5,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _visibleLines / _lines.length,
              backgroundColor: const Color(0xFF3C3C3C),
              valueColor: AlwaysStoppedAnimation<Color>(
                Color.lerp(
                      const Color(0xFF569CD6),
                      const Color(0xFF4EC9B0),
                      _visibleLines / _lines.length,
                    ) ??
                    const Color(0xFF569CD6),
              ),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}
