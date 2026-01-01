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
                                    engineer.name,
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
                                        engineer.telephone,
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
                              _assignProblem(context, engineer.id);
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

  @override
  Widget build(BuildContext context) {
    final Color statusColor =
        _hexToColor(widget.issue.porblemColor ?? widget.issue.statusColor);
    final timeAgo = _formatTimeAgo(widget.issue.problemDate);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: TechColors.cardBg,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: statusColor.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(_isPressed ? 0.15 : 0.08),
              blurRadius: _isPressed ? 15 : 20,
              offset: Offset(0, _isPressed ? 4 : 8),
              spreadRadius: _isPressed ? 0 : 2,
            ),
            BoxShadow(
              color: TechColors.primaryDark.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: Column(
            children: [
              // Status indicator bar
              Container(
                height: 4.h,
                decoration: BoxDecoration(
                  color: statusColor,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Customer avatar
                        Container(
                          width: 42.w,
                          height: 42.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                statusColor.withOpacity(0.8),
                                statusColor,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: statusColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              (widget.issue.customerName?.isNotEmpty == true)
                                  ? widget.issue.customerName![0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        // Customer info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Top spacing
                              SizedBox(height: 2.h), // كومنت: مسافة علوية

                              // Name and Type in one row
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      widget.issue.customerName ?? 'غير معروف',
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w800,
                                        color: TechColors.primaryDark,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6.w,
                                      vertical: 2.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      widget.issue.problemtype ?? 'غير محدد',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w700,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Time ago
                              if (timeAgo.isNotEmpty) ...[
                                SizedBox(height: 2.h),
                                Text(
                                  timeAgo,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],

                              // Bottom spacing
                              SizedBox(height: 2.h), // كومنت: مسافة سفلية
                            ],
                          ),
                        ),
                        // Action buttons
                        _buildQuickActions(context),
                      ],
                    ),
                    SizedBox(height: 5.h),
                    // Phone row
                    _buildInfoRow(
                      icon: Icons.phone_rounded,
                      iconColor: TechColors.successGreen,
                      content: widget.issue.phone ?? 'غير متوفر',
                      isClickable: true,
                      onTap: () => _makePhoneCall(context),
                    ),
                    SizedBox(height: 5.h),
                    // Date row
                    _buildInfoRow(
                      icon: Icons.schedule_rounded,
                      iconColor: TechColors.warningOrange,
                      content: _formatDate(widget.issue.problemDate),
                    ),
                    SizedBox(height: 5.h),
                    // Problem description
                    if (widget.issue.problemAddress?.isNotEmpty == true)
                      Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: TechColors.surfaceLight,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.report_problem_rounded,
                              color: TechColors.warningOrange,
                              size: 20.r,
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                widget.issue.problemAddress!,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      TechColors.primaryDark.withOpacity(0.8),
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Products chips
                    if (widget.issue.products != null &&
                        widget.issue.products!.isNotEmpty) ...[
                      SizedBox(height: 14.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: widget.issue.products!.take(3).map((product) {
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
                              color: TechColors.accentLight.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: TechColors.accentCyan.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.inventory_2_rounded,
                                  color: TechColors.accentCyan,
                                  size: 14.r,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: TechColors.primaryMid,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      if (widget.issue.products!.length > 3)
                        Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Text(
                            '+${widget.issue.products!.length - 3} منتجات أخرى',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                    SizedBox(height: 16.h),
                    // Details button
                    _buildDetailsButton(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Transfer to engineer button
        _buildActionButton(
          icon: Icons.swap_horiz_rounded,
          color: TechColors.accentCyan,
          onTap: () => _showEngineerSelectionDialog(context),
        ),
        SizedBox(width: 8.w),
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
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: color, size: 20.r),
            if (badge != null)
              Positioned(
                top: 4.h,
                right: 4.w,
                child: Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String content,
    bool isClickable = false,
    VoidCallback? onTap,
  }) {
    final widget = Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: iconColor, size: 18.r),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            content,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isClickable
                  ? TechColors.accentCyan
                  : TechColors.primaryDark.withOpacity(0.8),
              decoration: isClickable ? TextDecoration.underline : null,
            ),
          ),
        ),
        if (isClickable)
          Icon(
            Icons.call_rounded,
            color: iconColor,
            size: 18.r,
          ),
      ],
    );

    if (isClickable && onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: widget,
      );
    }
    return widget;
  }

  Widget _buildDetailsButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [TechColors.accentCyan, TechColors.primaryMid],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: TechColors.accentCyan.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: () async {
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

            // Show loading
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
                        valueColor: AlwaysStoppedAnimation<Color>(
                            TechColors.accentCyan),
                      ),
                    ),
                  );
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
                final result = await Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        ProblemDetailsScreen(issue: updatedProblem),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        ),
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.05, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOut,
                          )),
                          child: child,
                        ),
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                );

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
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.visibility_rounded,
                  color: Colors.white,
                  size: 20.r,
                ),
                SizedBox(width: 8.w),
                Text(
                  'عرض التفاصيل',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
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
                        engineer.name,
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
                            engineer.telephone,
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
