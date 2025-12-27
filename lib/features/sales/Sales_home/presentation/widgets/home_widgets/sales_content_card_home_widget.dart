import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'package:tabib_soft_company/core/services/locator/get_it_locator.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/data/models/filter/status_model.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/data/models/paginated_sales_model.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/data/repos/update_status_repo.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/cubits/sales_cubit.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/cubits/update/update_status_cubit.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/cubits/update/update_status_state.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/screens/notes/notes_screen.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/addCustomer/product_model.dart';
import 'package:url_launcher/url_launcher.dart';

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

class _SalesContactCardState extends State<SalesContactCard> {
  bool _isExpanded = false;

  static const double outerRadius = 20;
  static const double innerRadius = 35;

  String getProductName() {
    return widget.measurement.productName ?? 'غير متوفر';
  }

  String getLatestNote() {
    return widget.measurement.lastNotee ?? '-';
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _hexToColor(String? hex,
      {Color fallback = const Color.fromARGB(255, 255, 61, 13)}) {
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
    return bg.computeLuminance() > 0.5 ? Colors.black : Colors.white;
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
    // إزالة AnimationController و addPostFrameCallback لتحسين الأداء

    final BorderRadius mainRadius = _isExpanded
        ? const BorderRadius.only(
            topLeft: Radius.circular(innerRadius),
            topRight: Radius.circular(innerRadius),
          )
        : BorderRadius.circular(innerRadius);

    final Border mainBorder = _isExpanded
        ? const Border(
            top: BorderSide(color: Color(0xff20AAC9), width: 3.5),
            left: BorderSide(color: Color(0xff20AAC9), width: 3.5),
            right: BorderSide(color: Color(0xff20AAC9), width: 3.5),
          )
        : const Border(
            top: BorderSide(color: Color(0xff20AAC9), width: 3.5),
            left: BorderSide(color: Color(0xff20AAC9), width: 3.5),
            right: BorderSide(color: Color(0xff20AAC9), width: 3.5),
            bottom: BorderSide(color: Color(0xff20AAC9), width: 3.5),
          );

    const Border expandedBorder = Border(
      bottom: BorderSide(color: Color(0xff20AAC9), width: 3.5),
      left: BorderSide(color: Color(0xff20AAC9), width: 3.5),
      right: BorderSide(color: Color(0xff20AAC9), width: 3.5),
    );

    final Color statusBg = _hexToColor(widget.measurement.statusColor);
    final Color statusFg = _textColorForBackground(statusBg);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Background Layer 1
        Positioned(
          left: 0,
          top: 6.h,
          bottom: -10.h, // Elongated to be slightly longer than the white card
          child: Container(
            width: 390.w,
            decoration: BoxDecoration(
              color: const Color(0xff104D9D),
              borderRadius: BorderRadius.circular(outerRadius),
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
        // Background Layer 2
        Positioned(
          left: 8.w,
          top: -17.h,
          bottom: -10.h,
          right: 2.w,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(outerRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  offset: Offset(4.w, 6.h),
                  blurRadius: 6.r,
                ),
              ],
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Main Content
                Padding(
                  padding: EdgeInsets.only(top: 23.h, left: 30.w, right: 2.w),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: mainRadius,
                      border: mainBorder,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/pngs/new_person.png',
                              width: 30.w,
                              height: 30.h,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                widget.measurement.customerName ?? 'غير معروف',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                _showChangeStatusDialog();
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 8.h),
                                margin: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  color: statusBg,
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  widget.measurement.statusName ?? 'غير معروف',
                                  style: TextStyle(
                                    color: statusFg,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5.h),
                        GestureDetector(
                          onTap: _makePhoneCall,
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/pngs/new_call.png',
                                width: 30.w,
                                height: 25.h,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: SelectableText(
                                  widget.measurement.customerTelephone ??
                                      'غير متوفر',
                                  onTap: _makePhoneCall,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/pngs/new_calender.png',
                              width: 30.w,
                              height: 25.h,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                widget.measurement.date != null
                                    ? formatDate(DateTime.parse(
                                        widget.measurement.date!))
                                    : 'غير متوفر',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color.fromARGB(137, 41, 41, 40),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Dropdown Button
                Positioned(
                  left: 66.w,
                  bottom: 5.h,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _toggleExpand,
                    child: SizedBox(
                      width: 40.w,
                      height: 40.h,
                      child: AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Image.asset("assets/images/pngs/dropdown.png"),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Expanded Content
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _isExpanded
                  ? Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(left: 30.w, right: 2.w),
                      padding: EdgeInsets.symmetric(
                          horizontal: 18.w, vertical: 12.h),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(innerRadius),
                          bottomRight: Radius.circular(innerRadius),
                        ),
                        border: expandedBorder,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'التخصص: ${getProductName()}',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            'العنوان: ${widget.measurement.address ?? 'غير متوفر'}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            'الملاحظات الأخيرة: ${getLatestNote()}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NotesScreen(
                                      measurementId: widget.measurement.id),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff104D9D),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(60.r),
                              ),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ],
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
      duration: const Duration(milliseconds: 1000),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: Color(0xff104D9D),
                    ),
                  ),
                ),
                Text(
                  'تغيير الحالة',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff104D9D),
                  ),
                ),
                SizedBox(height: 20.h),
                if (widget.statuses.isNotEmpty)
                  Flexible(
                    child: SingleChildScrollView(
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 10.w,
                        runSpacing: 10.h,
                        children: widget.statuses.asMap().entries.map((entry) {
                          int index = entry.key;
                          StatusModel status = entry.value;
                          final isCurrent = widget.currentStatusId == status.id;
                          final isSelected =
                              selectedStatusId == status.id && !isCurrent;

                          final double delay = index / widget.statuses.length;
                          final Animation<double> animation =
                              Tween<double>(begin: 0.0, end: 1.0).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve:
                                  Interval(delay, 1.0, curve: Curves.easeOut),
                            ),
                          );

                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.5),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: _animationController,
                                  curve: Interval(delay, 1.0,
                                      curve: Curves.easeOut),
                                ),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12.r),
                                onTap: () {
                                  setState(() {
                                    selectedStatusId = status.id;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14.w,
                                    vertical: 12.h,
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 110.w,
                                    maxWidth: 250.w,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isCurrent
                                        ? const Color(0xFFFFEBEB)
                                        : isSelected
                                            ? const Color(0xff104D9D)
                                            : const Color(0xFFF7FAFB),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: isCurrent
                                          ? const Color(0xFFD32F2F)
                                          : isSelected
                                              ? const Color(0xFF0A3766)
                                              : const Color(0xFFE3E7EB),
                                      width: 1.0,
                                    ),
                                    boxShadow: isCurrent
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFFD32F2F)
                                                  .withOpacity(0.06),
                                              blurRadius: 8.r,
                                              offset: Offset(0, 4.h),
                                            )
                                          ]
                                        : isSelected
                                            ? [
                                                BoxShadow(
                                                  color: const Color(0xff104D9D)
                                                      .withOpacity(0.18),
                                                  blurRadius: 12.r,
                                                  offset: Offset(0, 6.h),
                                                )
                                              ]
                                            : [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.03),
                                                  blurRadius: 6.r,
                                                  offset: Offset(0, 2.h),
                                                )
                                              ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          status.name,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            color: isCurrent
                                                ? const Color(0xFFD32F2F)
                                                : isSelected
                                                    ? Colors.white
                                                    : const Color(0xff104D9D),
                                            fontWeight: isCurrent
                                                ? FontWeight.w600
                                                : isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.w500,
                                            fontSize: 18.sp,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 180),
                                        width: isSelected ? 28.r : 24.r,
                                        height: isSelected ? 28.r : 24.r,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.white.withOpacity(0.18)
                                              : Colors.transparent,
                                          shape: BoxShape.circle,
                                        ),
                                        child: isSelected
                                            ? Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.12),
                                                      blurRadius: 4.r,
                                                      offset: Offset(0, 2.h),
                                                    )
                                                  ],
                                                ),
                                                child: Icon(
                                                  Icons.check,
                                                  size: 16.r,
                                                  color:
                                                      const Color(0xff104D9D),
                                                ),
                                              )
                                            : isCurrent
                                                ? Padding(
                                                    padding:
                                                        EdgeInsets.all(2.r),
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      decoration:
                                                          const BoxDecoration(
                                                        color:
                                                            Color(0xFFD32F2F),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        Icons.circle,
                                                        size: 8.r,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  )
                                                : Container(
                                                    alignment: Alignment.center,
                                                    child: Container(
                                                      width: 10.r,
                                                      height: 10.r,
                                                      decoration:
                                                          const BoxDecoration(
                                                        color:
                                                            Color(0xFFEEF5FA),
                                                        shape: BoxShape.circle,
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
                        }).toList(),
                      ),
                    ),
                  )
                else
                  const Text('لا توجد حالات متاحة'),
                SizedBox(height: 20.h),
                if (state.status == UpdateStatusStatus.loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: CircularProgressIndicator(),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedStatusId != null &&
                              selectedStatusId != widget.currentStatusId
                          ? () {
                              context.read<UpdateStatusCubit>().changeStatus(
                                    measurementId: widget.measurementId,
                                    statusId: selectedStatusId!,
                                  );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff104D9D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                      ),
                      child: Text(
                        'تأكيد التغيير',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
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
