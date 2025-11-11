import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tabib_soft_company/core/services/locator/get_it_locator.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/widgets/home_widgets/home_skeltonizer_widget.dart';
import 'package:tabib_soft_company/features/sales/today_calls/data/models/today_call_model.dart';
import 'package:tabib_soft_company/features/sales/today_calls/presentation/cubit/today_call_cubit.dart';
import 'package:tabib_soft_company/features/sales/today_calls/presentation/cubit/today_call_state.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TodayCallsScreen extends StatefulWidget {
  const TodayCallsScreen({super.key});

  static const double horizontalPadding = 16.0;

  @override
  State<TodayCallsScreen> createState() => _TodayCallsScreenState();
}

class _TodayCallsScreenState extends State<TodayCallsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  late final TodayCallsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = ServicesLocator.locator<TodayCallsCubit>();
    _cubit.fetchTodayCalls();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodayCallsCubit, TodayCallsState>(
      bloc: _cubit,
      builder: (context, state) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const SizedBox.shrink(),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.topLeft,
                colors: [
                  Color(0xff104D9D),
                  Color(0xFF20AAC9),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Center(
                    child: Image.asset(
                      'assets/images/pngs/TS_Logo0.png',
                      width: 140,
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: TodayCallsScreen.horizontalPadding),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            offset: const Offset(0, 6),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              textDirection: TextDirection.rtl,
                              decoration: const InputDecoration(
                                hintText: 'البحث عن مكالمات...',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          ///زرار الفلتره بتاع المكالمات
                          // GestureDetector(
                          //   onTap: () {
                          //     showModalBottomSheet(
                          //       context: context,
                          //       isScrollControlled: true,
                          //       builder: (_) => const FilterBottomSheet(
                          //         currentStatusId: null,
                          //         currentProductId: null,
                          //         currentFrom: null,
                          //         currentTo: null,
                          //         products: [],
                          //         statuses: [],
                          //       ),
                          //     );
                          //   },
                          //   child: Image.asset(
                          //     'assets/images/pngs/filter.png',
                          //     width: 28,
                          //     height: 28,
                          //   ),
                          // ),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3F5F6),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                      ),
                      child: RefreshIndicator(
                        onRefresh: () async {
                          _cubit.fetchTodayCalls();
                        },
                        child: _buildCallsContent(state),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCallsContent(TodayCallsState state) {
    final filteredCalls = state.calls.where((call) {
      return call.customerName
              ?.toLowerCase()
              .contains(_searchQuery.toLowerCase()) ??
          false;
    }).toList();

    if (state.status == TodayCallsStatus.loading) {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(
            horizontal: TodayCallsScreen.horizontalPadding, vertical: 8),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(height: 20),
        itemBuilder: (_, __) => SkeletonCard(),
      );
    } else if (state.status == TodayCallsStatus.error) {
      return Center(
        child: Text(
          state.errorMessage ?? 'حدث خطأ أثناء تحميل المكالمات',
          style: const TextStyle(color: Colors.red, fontSize: 16),
          textDirection: TextDirection.rtl,
        ),
      );
    } else if (filteredCalls.isEmpty) {
      return Center(
        child: Text(
          'لا توجد مكالمات اليوم',
          style: TextStyle(color: Colors.grey[700], fontSize: 16),
          textDirection: TextDirection.rtl,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
          horizontal: TodayCallsScreen.horizontalPadding, vertical: 12),
      itemCount: filteredCalls.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return CallCard(call: filteredCalls[index]);
      },
    );
  }
}

class CallCard extends StatefulWidget {
  final TodayCallModel call;

  const CallCard({super.key, required this.call});

  @override
  State<CallCard> createState() => _CallCardState();
}

class _CallCardState extends State<CallCard> {
  bool _isExpanded = false;
  final GlobalKey _expandedKey = GlobalKey();
  double _bottomOffset = -7.0;

  static const double cardHeight = 200;
  static const double outerRadius = 10;
  static const double innerRadius = 19;

  @override
  Widget build(BuildContext context) {
    final BorderRadius mainRadius = _isExpanded
        ? const BorderRadius.only(
            topLeft: Radius.circular(innerRadius),
            topRight: Radius.circular(innerRadius),
          )
        : BorderRadius.circular(innerRadius);

    List<String> allImages = widget.call.requireImages ?? [];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: cardHeight.h,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                left: 0,
                right: 0,
                top: 32.h,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: mainRadius,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(height: 5.h),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.call.customerName ?? 'عميل غير معروف',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.grey[800],
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                          SizedBox(width: 8.w),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final Uri phoneUri = Uri(
                                  scheme: 'tel',
                                  path: widget.call.customerPhone);
                              if (await canLaunchUrl(phoneUri)) {
                                await launchUrl(phoneUri);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('لا يمكن فتح تطبيق الهاتف')),
                                );
                              }
                            },
                            child: Text(
                              widget.call.customerPhone ?? 'رقم غير متوفر',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color.fromARGB(255, 104, 102, 102),
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                          SizedBox(width: 8.w),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          Text(
                            'موعد المكالمة: ${widget.call.exepectedCallDate?.toLocal().day.toString().padLeft(2, '0') ?? '--'}/${widget.call.exepectedCallDate?.toLocal().month.toString().padLeft(2, '0') ?? '--'}/${widget.call.exepectedCallDate?.toLocal().year ?? '----'}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey[800],
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                          SizedBox(width: 13.w),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      if (widget.call.notes != null)
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'ملاحظات: ${widget.call.notes}',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      const Color.fromARGB(255, 104, 102, 102),
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                            ),
                            SizedBox(width: 8.w),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 230.w,
                left: 0,
                bottom: -30.h,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                    if (_isExpanded) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_expandedKey.currentContext != null) {
                          final RenderBox renderBox =
                              _expandedKey.currentContext!.findRenderObject()
                                  as RenderBox;
                          final height = renderBox.size.height;
                          setState(() {
                            _bottomOffset = -(height + 7.h);
                          });
                        }
                      });
                    } else {
                      _bottomOffset = -7.0.h;
                    }
                  },
                  child: Transform.rotate(
                    angle: _isExpanded
                        ? math.pi
                        : 0, // Rotate 180 degrees when expanded
                    child: Image.asset("assets/images/pngs/dropdown.png"),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_isExpanded)
          Container(
            key: _expandedKey,
            margin: EdgeInsets.only(left: 2.w),
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 184, 137, 137),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(innerRadius),
                bottomRight: Radius.circular(innerRadius),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (allImages.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: Center(
                      child: Text(
                        'لا يوجد صور',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  )
                else
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 10.h,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(
                      allImages.length,
                      (index) => Image.network(
                        allImages[index],
                        width: 100.w,
                        height: 100.h,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.error, size: 100);
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
