import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'package:tabib_soft_company/core/services/locator/get_it_locator.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/data/models/filter/status_model.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/data/models/paginated_sales_model.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/data/repos/update_status_repo.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/cubits/sales_cubit.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/cubits/update/update_status_cubit.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/cubits/update/update_status_state.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/screens/notes/notes_screen.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/addCustomer/product_model.dart';
import 'package:url_launcher/url_launcher.dart';

/// ألوان قسم المبيعات - تدرجات زرقاء احترافية

class SalesContactCard extends StatefulWidget {
  final SalesModel measurement;
  final List<ProductModel> products;
  final List<StatusModel> statuses;

  const SalesContactCard({
    super.key,
    required this.measurement,
    required this.products,
    required this.statuses,
  });

  @override
  State<SalesContactCard> createState() => _SalesContactCardState();
}

class _SalesContactCardState extends State<SalesContactCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  String getProductName() {
    return widget.measurement.productName ?? 'غير متوفر';
  }

  String getLatestNote() {
    return widget.measurement.lastNotee ?? '-';
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _hexToColor(String? hex, {Color fallback = SalesColors.primaryOrange}) {
    if (hex == null) return fallback;
    final cleaned = hex.replaceAll('#', '').trim();
    try {
      if (cleaned.length == 6) {
        return Color(int.parse('FF$cleaned', radix: 16));
      } else if (cleaned.length == 8) {
        return Color(int.parse(cleaned, radix: 16));
      } else {
        return fallback;
      }
    } catch (_) {
      return fallback;
    }
  }

  Color _textColorForBackground(Color bg) {
    return bg.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;
  }

  void _showChangeStatusDialog() {
    showDialog(
      context: context,
      builder: (ctx) => BlocProvider<UpdateStatusCubit>(
        create: (_) => UpdateStatusCubit(
          UpdateStatusRepo(ServicesLocator.locator<ApiService>()),
        ),
        child: BlocListener<UpdateStatusCubit, UpdateStatusState>(
          listener: (context, state) {
            if (state.status == UpdateStatusStatus.success) {
              Navigator.pop(context);
              context.read<SalesCubit>().fetchMeasurements(
                    page: 1,
                    pageSize: 20,
                    isRefresh: true,
                  );
            } else if (state.status == UpdateStatusStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.failure?.errMessages ?? 'حدث خطأ')),
              );
            }
          },
          child: ChangeStatusDialog(
            measurementId: widget.measurement.id,
            statuses: widget.statuses,
            currentStatusId: widget.measurement.statusId,
          ),
        ),
      ),
    );
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
  }

  Future<void> _makePhoneCall() async {
    final phone = widget.measurement.customerTelephone;
    if (phone != null && phone.trim().isNotEmpty && phone != 'غير متوفر') {
      final Uri url = Uri(scheme: 'tel', path: phone.trim());
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color statusBg = _hexToColor(widget.measurement.statusColor);
    final Color statusFg = _textColorForBackground(statusBg);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: SalesColors.primaryOrange.withOpacity(0.08),
                blurRadius: 20.r,
                offset: Offset(0, 8.h),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header مع التدرج البرتقالي
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  gradient: SalesColors.headerGradient,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.r),
                    topRight: Radius.circular(24.r),
                  ),
                ),
                child: Row(
                  children: [
                    // أيقونة العميل
                    Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 26.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // اسم العميل
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.measurement.customerName ?? 'غير معروف',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(
                                Icons.category_rounded,
                                size: 14.sp,
                                color: Colors.white70,
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  getProductName(),
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: SalesColors.primaryOrange,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // زر الحالة
                    GestureDetector(
                      onTap: _showChangeStatusDialog,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: statusBg.withOpacity(0.4),
                              blurRadius: 8.r,
                              offset: Offset(0, 2.h),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.measurement.statusName ?? 'غير معروف',
                              style: TextStyle(
                                color: statusFg,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: statusFg,
                              size: 16.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // المحتوى الرئيسي
              Container(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    // رقم الهاتف
                    _buildInfoRow(
                      icon: Icons.phone_rounded,
                      iconBgColor: const Color(0xFFE8F5E9),
                      iconColor: const Color(0xFF4CAF50),
                      content:
                          widget.measurement.customerTelephone ?? 'غير متوفر',
                      onTap: _makePhoneCall,
                      isClickable: true,
                    ),
                    SizedBox(height: 12.h),

                    // التاريخ
                    _buildInfoRow(
                      icon: Icons.calendar_today_rounded,
                      iconBgColor: const Color(0xFFFFF3E0),
                      iconColor: SalesColors.primaryOrange,
                      content: widget.measurement.date != null
                          ? formatDate(DateTime.parse(widget.measurement.date!))
                          : 'غير متوفر',
                    ),

                    // المحتوى الموسع
                    SizeTransition(
                      sizeFactor: _expandAnimation,
                      child: Column(
                        children: [
                          SizedBox(height: 12.h),
                          // فاصل
                          Container(
                            height: 1,
                            margin: EdgeInsets.symmetric(vertical: 8.h),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  SalesColors.borderMedium,
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),

                          // العنوان
                          _buildInfoRow(
                            icon: Icons.location_on_rounded,
                            iconBgColor: const Color(0xFFE3F2FD),
                            iconColor: const Color(0xFF2196F3),
                            content: widget.measurement.address ?? 'غير متوفر',
                          ),
                          SizedBox(height: 12.h),

                          // الملاحظات
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(14.w),
                            decoration: BoxDecoration(
                              color: SalesColors.surfaceLight,
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(
                                color: SalesColors.borderLight,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.sticky_note_2_rounded,
                                      size: 18.sp,
                                      color: SalesColors.primaryOrange,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'آخر ملاحظة',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                        color: SalesColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  getLatestNote(),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: SalesColors.textPrimary,
                                    height: 1.5,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.h),

                          // زر إضافة ملاحظة
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NotesScreen(
                                        measurementId: widget.measurement.id),
                                  ),
                                );
                              },
                              icon: Icon(Icons.add_rounded, size: 22.sp),
                              label: Text(
                                'إضافة ملاحظة',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: SalesColors.secondaryBlue,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // زر التوسيع
              InkWell(
                onTap: _toggleExpand,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24.r),
                  bottomRight: Radius.circular(24.r),
                ),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: SalesColors.surfaceLight,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24.r),
                      bottomRight: Radius.circular(24.r),
                    ),
                    border: const Border(
                      top: BorderSide(
                        color: SalesColors.borderLight,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isExpanded ? 'عرض أقل' : 'عرض المزيد',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: SalesColors.primaryOrange,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: SalesColors.primaryOrange,
                          size: 22.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String content,
    VoidCallback? onTap,
    bool isClickable = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              content,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: isClickable
                    ? SalesColors.primaryOrange
                    : SalesColors.textPrimary,
                decoration: isClickable
                    ? TextDecoration.underline
                    : TextDecoration.none,
                decorationColor: SalesColors.primaryOrange,
              ),
            ),
          ),
          if (isClickable)
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16.sp,
              color: const Color.fromARGB(255, 10, 162, 238),
            ),
        ],
      ),
    );
  }
}

class ChangeStatusDialog extends StatefulWidget {
  final String measurementId;
  final List<StatusModel> statuses;
  final String? currentStatusId;

  const ChangeStatusDialog({
    super.key,
    required this.measurementId,
    required this.statuses,
    this.currentStatusId,
  });

  @override
  State<ChangeStatusDialog> createState() => _ChangeStatusDialogState();
}

class _ChangeStatusDialogState extends State<ChangeStatusDialog>
    with TickerProviderStateMixin {
  String? selectedStatusId;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    selectedStatusId = widget.currentStatusId;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UpdateStatusCubit, UpdateStatusState>(
      builder: (context, state) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 400.w,
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28.r),
              boxShadow: [
                BoxShadow(
                  color: SalesColors.primaryOrange.withOpacity(0.15),
                  blurRadius: 30.r,
                  offset: Offset(0, 15.h),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    gradient: SalesColors.headerGradient,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28.r),
                      topRight: Radius.circular(28.r),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44.w,
                        height: 44.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.swap_horiz_rounded,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Text(
                          'تغيير الحالة',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                        ),
                        icon: Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 22.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: widget.statuses.isNotEmpty
                        ? SingleChildScrollView(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 10.w,
                              runSpacing: 10.h,
                              children:
                                  widget.statuses.asMap().entries.map((entry) {
                                int index = entry.key;
                                StatusModel status = entry.value;
                                final isCurrent =
                                    widget.currentStatusId == status.id;
                                final isSelected =
                                    selectedStatusId == status.id && !isCurrent;

                                final double delay =
                                    index / widget.statuses.length;
                                final Animation<double> animation =
                                    Tween<double>(begin: 0.0, end: 1.0).animate(
                                  CurvedAnimation(
                                    parent: _animationController,
                                    curve: Interval(delay, 1.0,
                                        curve: Curves.easeOutBack),
                                  ),
                                );

                                return FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: animation,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16.r),
                                      onTap: () {
                                        setState(() {
                                          selectedStatusId = status.id;
                                        });
                                      },
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 18.w,
                                          vertical: 14.h,
                                        ),
                                        constraints: BoxConstraints(
                                          minWidth: 120.w,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: isSelected
                                              ? SalesColors.primaryGradient
                                              : null,
                                          color: isCurrent
                                              ? const Color(0xFFFFF3E0)
                                              : isSelected
                                                  ? null
                                                  : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(16.r),
                                          border: Border.all(
                                            color: isCurrent
                                                ? SalesColors.primaryOrange
                                                : isSelected
                                                    ? Colors.transparent
                                                    : SalesColors.borderMedium,
                                            width: isCurrent ? 2 : 1.5,
                                          ),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: SalesColors
                                                        .primaryOrange
                                                        .withOpacity(0.35),
                                                    blurRadius: 12.r,
                                                    offset: Offset(0, 6.h),
                                                  )
                                                ]
                                              : [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.04),
                                                    blurRadius: 8.r,
                                                    offset: Offset(0, 2.h),
                                                  )
                                                ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              width: 24.r,
                                              height: 24.r,
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? Colors.white
                                                    : isCurrent
                                                        ? SalesColors
                                                            .primaryOrange
                                                        : SalesColors
                                                            .borderMedium,
                                                shape: BoxShape.circle,
                                              ),
                                              child: isSelected || isCurrent
                                                  ? Icon(
                                                      isCurrent
                                                          ? Icons
                                                              .check_circle_rounded
                                                          : Icons.check_rounded,
                                                      size: 16.r,
                                                      color: isSelected
                                                          ? SalesColors
                                                              .primaryOrange
                                                          : Colors.white,
                                                    )
                                                  : null,
                                            ),
                                            SizedBox(width: 10.w),
                                            Flexible(
                                              child: Text(
                                                status.name,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: isCurrent
                                                      ? SalesColors
                                                          .primaryOrange
                                                      : isSelected
                                                          ? Colors.white
                                                          : SalesColors
                                                              .textPrimary,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15.sp,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          )
                        : Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.inbox_rounded,
                                  size: 48.sp,
                                  color: SalesColors.textMuted,
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  'لا توجد حالات متاحة',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: SalesColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),

                // Footer Button
                Container(
                  padding: EdgeInsets.all(20.w),
                  child: state.status == UpdateStatusStatus.loading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: SalesColors.primaryOrange,
                            strokeWidth: 3,
                          ),
                        )
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: selectedStatusId != null &&
                                    selectedStatusId != widget.currentStatusId
                                ? () {
                                    context
                                        .read<UpdateStatusCubit>()
                                        .changeStatus(
                                          measurementId: widget.measurementId,
                                          statusId: selectedStatusId!,
                                        );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: SalesColors.primaryOrange,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: SalesColors.borderMedium,
                              disabledForegroundColor: SalesColors.textMuted,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_rounded, size: 22.sp),
                                SizedBox(width: 10.w),
                                Text(
                                  'تأكيد التغيير',
                                  style: TextStyle(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
