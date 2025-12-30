import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/data/models/notes/add_note_model.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/data/models/notes/sales_detail_model.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/cubits/notes/add_note_cubit.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/cubits/notes/add_note_state.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/cubits/notes/sales_details_cubit.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/cubits/notes/sales_details_state.dart';
import 'package:intl/intl.dart' as intl;

class NotesScreen extends StatefulWidget {
  final String measurementId;
  final String? customerName;
  final String? customerPhone;
  final bool isFromNotification;

  const NotesScreen(
      {super.key,
      required this.measurementId,
      this.customerName,
      this.customerPhone,
      this.isFromNotification = false});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _expectedCommentController =
      TextEditingController();

  DateTime? _nextCallDate;
  TimeOfDay? _fromTime;
  TimeOfDay? _toTime;
  final List<String> _imagePaths = [];
  late Timer _timer;
  bool _dateChanged = false;
  bool _fromTimeChanged = false;
  bool _toTimeChanged = false;

  @override
  void initState() {
    super.initState();
    context
        .read<SalesDetailsCubit>()
        .fetchDealDetails(id: widget.measurementId);
    _nextCallDate = DateTime.now();
    _fromTime = TimeOfDay.now();
    int toHour = _fromTime!.hour + 1;
    _toTime = TimeOfDay(hour: toHour % 24, minute: _fromTime!.minute);
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          if (!_dateChanged) {
            _nextCallDate = DateTime.now();
          }
          if (!_fromTimeChanged) {
            _fromTime = TimeOfDay.now();
          }
          if (!_toTimeChanged) {
            int toHour = _fromTime!.hour + 1;
            _toTime = TimeOfDay(hour: toHour % 24, minute: _fromTime!.minute);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _notesController.dispose();
    _expectedCommentController.dispose();
    super.dispose();
  }

  // --- Logic Helpers ---

  Future<void> _selectDate(BuildContext context, StateSetter setState) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _nextCallDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: SalesColors.primaryBlue,
              onPrimary: Colors.white,
              onSurface: SalesColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _nextCallDate) {
      setState(() {
        _nextCallDate = picked;
        _dateChanged = true;
      });
    }
  }

  Future<void> _selectTime(
      BuildContext context, bool isFrom, StateSetter setState) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isFrom
          ? (_fromTime ?? TimeOfDay.now())
          : (_toTime ?? TimeOfDay.now()),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: SalesColors.primaryBlue,
              onPrimary: Colors.white,
              onSurface: SalesColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromTime = picked;
          _fromTimeChanged = true;
        } else {
          _toTime = picked;
          _toTimeChanged = true;
        }
      });
    }
  }

  Future<void> _pickImage(StateSetter setState) async {
    final ImagePicker picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library,
                    color: SalesColors.primaryBlue),
                title: const Text('معرض الصور'),
                onTap: () async {
                  Navigator.pop(bc);
                  final XFile? image =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      _imagePaths.add(image.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera,
                    color: SalesColors.primaryBlue),
                title: const Text('الكاميرا'),
                onTap: () async {
                  Navigator.pop(bc);
                  final XFile? image =
                      await picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    setState(() {
                      _imagePaths.add(image.path);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        body: Stack(
          children: [
            // Background Header Decoration
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 200.h,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: SalesColors.headerGradient,
                ),
              ),
            ),

            Column(
              children: [
                // Custom AppBar
                SafeArea(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios,
                              color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r)),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Text(
                          'سجل الملاحظات ',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),

                // Main Content
                Expanded(
                  child: BlocBuilder<SalesDetailsCubit, SalesDetailsState>(
                    builder: (context, state) {
                      if (state.status == SalesDetailsStatus.loading) {
                        return const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white));
                      } else if (state.status == SalesDetailsStatus.loaded) {
                        final detail = state.detail!;

                        // Parse Data
                        List<Map<String, dynamic>> allNotes = [];
                        for (var requirement
                            in detail.measurementRequirement.reversed) {
                          if (requirement.notes != null) {
                            final normalizedImages =
                                (requirement.requireImages ?? <String>[])
                                    .map((img) => img.replaceAll(r'\', '/'))
                                    .toList();
                            allNotes.add({
                              'note': requirement.notes,
                              'images': normalizedImages,
                              'date': requirement.creatDate ?? detail.date,
                              'expectedComment':
                                  requirement.exepectedComment ?? '',
                            });
                          }
                        }
                        if (detail.note != null) {
                          allNotes.add({
                            'note': detail.note,
                            'images': <String>[],
                            'date': detail.date,
                            'expectedComment': '',
                          });
                        }

                        // Sorting by date descending
                        allNotes.sort((a, b) => (b['date'] as DateTime)
                            .compareTo(a['date'] as DateTime));

                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FD),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30.r),
                              topRight: Radius.circular(30.r),
                            ),
                          ),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              children: [
                                SizedBox(height: 20.h),
                                if (widget.isFromNotification) ...[
                                  _buildCustomerInfoCard(detail),
                                  SizedBox(height: 20.h),
                                ],
                                // 1. Statistics & Chart Card
                                _buildStatsCard(allNotes, detail),

                                SizedBox(height: 20.h),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 20.w),
                                  child: Row(
                                    children: [
                                      Text(
                                        'سجل الملاحظات ',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          color: SalesColors.textPrimary,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12.w, vertical: 6.h),
                                        decoration: BoxDecoration(
                                          color: SalesColors.primaryBlue
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20.r),
                                        ),
                                        child: Text(
                                          '${allNotes.length} ملاحظة',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.bold,
                                            color: SalesColors.primaryBlue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 16.h),

                                // 2. Timeline Notes
                                if (allNotes.isEmpty)
                                  _buildEmptyState()
                                else
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20.w),
                                    itemCount: allNotes.length,
                                    itemBuilder: (context, index) {
                                      final noteData = allNotes[index];
                                      final isLast =
                                          index == allNotes.length - 1;
                                      return _TimelineNoteItem(
                                        note: noteData['note'],
                                        date: noteData['date'],
                                        images: noteData['images'],
                                        expectedComment:
                                            noteData['expectedComment'],
                                        isLast: isLast,
                                      );
                                    },
                                  ),

                                SizedBox(height: 100.h),
                              ],
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ],
            ),

            // Floating Action Button
            Positioned(
              left: 20.w,
              bottom: 20.h,
              child: FloatingActionButton.extended(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AddNoteDialogContent(
                      measurementId: widget.measurementId,
                      nextCallDate: _nextCallDate,
                      fromTime: _fromTime,
                      toTime: _toTime,
                      imagePaths: _imagePaths,
                      notesController: _notesController,
                      expectedCommentController: _expectedCommentController,
                      onPickImage: _pickImage,
                    ),
                  );
                },
                backgroundColor: SalesColors.primaryBlue,
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r)),
                icon:
                    const Icon(Icons.add_comment_rounded, color: Colors.white),
                label: Text(
                  'تدوين ملاحظة',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widgets ---

  Widget _buildStatsCard(
      List<Map<String, dynamic>> notes, SalesDetailModel detail) {
    // Generate Chart Data
    // Group notes by date (Day/Month/Year) to unique keys
    Map<String, int> chartData = {};
    Map<String, DateTime> dateMap = {}; // Helper to sort keys by date

    if (notes.isEmpty) {
      // Default empty state placeholders
      DateTime now = DateTime.now();
      chartData["${now.day}/${now.month}"] = 0;
      dateMap["${now.day}/${now.month}"] = now;
    } else {
      for (var n in notes) {
        DateTime date = n['date'];
        String key = "${date.day}/${date.month}";

        // We use year in key to differentiate same day diff year if needed, but display only D/M
        // For sorting correctlness, let's keep a full date map
        if (!chartData.containsKey(key)) {
          chartData[key] = 0;
          dateMap[key] = date;
        }
        chartData[key] = (chartData[key] ?? 0) + 1;
      }
    }

    // Sort keys by date
    var sortedKeys = chartData.keys.toList()
      ..sort((k1, k2) => dateMap[k1]!.compareTo(dateMap[k2]!));

    // Take last 7 days of activity if more exist, to fit the screen
    if (sortedKeys.length > 7) {
      sortedKeys = sortedKeys.sublist(sortedKeys.length - 7);
    }

    // Build final map for display
    Map<String, int> displayData = {};
    for (var key in sortedKeys) {
      displayData[key] = chartData[key]!;
    }

    // Find max for scaling
    int maxNotes = 1;
    displayData.forEach((_, v) {
      if (v > maxNotes) maxNotes = v;
    });

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1F3D).withOpacity(0.06),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: SalesColors.surfaceLight,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(Icons.bar_chart_rounded,
                    color: SalesColors.primaryBlue, size: 28.sp),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تحليل الملاحظات',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: SalesColors.textPrimary,
                    ),
                  ),
                  Text(
                    'أيام النشاط',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: SalesColors.textMuted,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    notes.length.toString(),
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w900,
                      color: SalesColors.primaryBlue,
                    ),
                  ),
                  Text(
                    'إجمالي',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: SalesColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // The Chart
          SizedBox(
            height: 120.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: displayData.entries
                  .toList()
                  .asMap()
                  .entries
                  .map((mappedEntry) {
                int index = mappedEntry.key;
                var entry = mappedEntry.value;
                // Highlight the first column (Start) with Orange
                bool isStartColumn = index == 0;
                Color barColor = isStartColumn
                    ? const Color(0xFFFFA000)
                    : SalesColors.primaryBlue;

                double fillPercent = entry.value / maxNotes;
                // Ensure at least a tiny bar is visible if count > 0
                if (fillPercent == 0 && entry.value > 0) fillPercent = 0.1;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (entry.value > 0)
                      Container(
                        margin: EdgeInsets.only(bottom: 6.h),
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: barColor,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          entry.value.toString(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: fillPercent),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOutQuart,
                      builder: (context, value, child) {
                        return Container(
                          width: 8.w,
                          height: (120.h * 0.6) * (value == 0 ? 0.05 : value),
                          decoration: BoxDecoration(
                            color: value == 0
                                ? Colors.grey.withOpacity(0.2)
                                : barColor,
                            borderRadius: BorderRadius.circular(10.r),
                            gradient: value > 0
                                ? LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: isStartColumn
                                        ? [
                                            const Color(0xFFFFA000),
                                            const Color(0xFFFFD54F)
                                          ]
                                        : [
                                            SalesColors.primaryBlue,
                                            SalesColors.secondaryBlue
                                          ],
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: SalesColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoCard(SalesDetailModel detail) {
    // Attempt to find the next call date from requirements
    DateTime? nextCall;
    if (detail.measurementRequirement.isNotEmpty) {
      // Logic to find 'next' call could be complex, for now let's take the latest entered expected call date
      for (var req in detail.measurementRequirement) {
        if (req.exepectedCallDate != null) {
          if (nextCall == null || req.exepectedCallDate!.isAfter(nextCall)) {
            nextCall = req.exepectedCallDate;
          }
        }
      }
    }

    // Parse Name and Phone if combined
    String displayName = widget.customerName ?? 'غير متوفر';
    String displayPhone = widget.customerPhone ?? 'غير متوفر';

    // If customerName contains a phone number (digits > 6), split it
    if (widget.customerName != null) {
      final phoneRegex =
          RegExp(r'[\d+]{7,}'); // Matches sequence of 7 or more digits/pluses
      final match = phoneRegex.firstMatch(widget.customerName!);
      if (match != null) {
        String extractedPhone = match.group(0)!;
        displayPhone = extractedPhone;
        // Remove phone from name and trim
        displayName =
            widget.customerName!.replaceAll(extractedPhone, '').trim();
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 4.w,
                height: 24.h,
                decoration: BoxDecoration(
                  color: SalesColors.primaryBlue,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                'معلومات العميل',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: SalesColors.primaryBlue,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          const Divider(height: 1, color: SalesColors.borderLight),
          SizedBox(height: 16.h),

          // Details grid
          _buildInfoRow(
              'الاشعار:', 'تم اضافة عميل جديد'), // Static for now as requested
          // _buildInfoRow('العميل:', displayName),
          _buildInfoRow(
            ' العميل :',
            displayPhone,
          ),
          _buildInfoRow('المهندس:', detail.engineerName),
          _buildInfoRow(
            'تاريخ الصفقة:',
            intl.DateFormat('yyyy-MM-dd').format(detail.date),
          ),
          _buildInfoRow(
            'المكالمة الآتية:',
            nextCall != null
                ? intl.DateFormat('yyyy-MM-dd').format(nextCall)
                : 'غير محدد',
          ),
          _buildInfoRow('الملاحظة:', detail.note ?? 'لا يوجد'),
          Divider(height: 24.h, color: SalesColors.borderLight),
          _buildInfoRow(
            'إجمالي الصفقة:',
            '${detail.total} ج.م',
            isBold: true,
          ),
          _buildInfoRow('الخصم:', '${detail.discount} ج.م'),
          _buildInfoRow(
            'الإجمالي النهائي:',
            '${detail.endTotal} ج.م',
            isBold: true,
            valueColor: SalesColors.primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {bool isPhone = false, bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: SalesColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                color: valueColor ??
                    (isPhone
                        ? SalesColors.primaryBlue
                        : SalesColors.textPrimary),
                decoration: isPhone ? TextDecoration.underline : null,
                decorationColor:
                    isPhone ? SalesColors.primaryBlue.withOpacity(0.5) : null,
              ),
              textAlign: TextAlign
                  .left, // Align values to the left for better readability
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 40.h),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(30.w),
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ]),
              child: Icon(Icons.history_edu_rounded,
                  size: 60.sp, color: SalesColors.borderMedium),
            ),
            SizedBox(height: 16.h),
            Text(
              'لا توجد سجلات بعد',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: SalesColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'ابدأ بإضافة ملاحظة جديدة للعميل',
              style: TextStyle(
                fontSize: 14.sp,
                color: SalesColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineNoteItem extends StatefulWidget {
  final String note;
  final DateTime date;
  final List<String> images;
  final String expectedComment;
  final bool isLast;

  const _TimelineNoteItem({
    required this.note,
    required this.date,
    required this.images,
    required this.expectedComment,
    required this.isLast,
  });

  @override
  State<_TimelineNoteItem> createState() => _TimelineNoteItemState();
}

class _TimelineNoteItemState extends State<_TimelineNoteItem>
    with SingleTickerProviderStateMixin {
  bool _isImagesExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Timeline Line (Positioned behind content)
        if (!widget.isLast)
          Positioned(
            top: 14.w,
            bottom: 0,
            left: 15.w - 1,
            width: 2,
            child: Container(
              color: SalesColors.borderMedium.withOpacity(0.5),
            ),
          ),

        // Content Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dot Column
            SizedBox(
              width: 30.w,
              child: Column(
                children: [
                  // The Dot
                  Container(
                    width: 14.w,
                    height: 14.w,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: SalesColors.primaryBlue, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: SalesColors.primaryBlue.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          )
                        ]),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),

            // Card Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: 24.h),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      bottomLeft: Radius.circular(20.r),
                      bottomRight: Radius.circular(20.r),
                      topRight: Radius.circular(
                          4.r), // Sharp corner pointing to timeline
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1DA1F2).withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date Header
                        Row(
                          children: [
                            Icon(Icons.access_time_filled,
                                size: 14.sp, color: SalesColors.textMuted),
                            SizedBox(width: 6.w),
                            Text(
                              intl.DateFormat('yyyy/MM/dd  hh:mm a', 'en')
                                  .format(widget.date),
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: SalesColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),

                        // Note Body
                        Text(
                          widget.note,
                          style: TextStyle(
                            fontSize: 15.sp,
                            height: 1.6,
                            color: SalesColors.textPrimary,
                          ),
                        ),

                        // Expected Comment
                        if (widget.expectedComment.isNotEmpty) ...[
                          SizedBox(height: 14.h),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFFFFF8E1), // Amber/Gold Light
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                  color:
                                      const Color(0xFFFFD54F).withOpacity(0.5)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.lightbulb,
                                        color: const Color(0xFFFFA000),
                                        size: 16.sp),
                                    SizedBox(width: 6.w),
                                    Text(
                                      'التعليق',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(
                                            0xFFFFA000), // Amber Dark
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  widget.expectedComment,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Images Accordion
                        if (widget.images.isNotEmpty) ...[
                          SizedBox(height: 16.h),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isImagesExpanded = !_isImagesExpanded;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: SalesColors.surfaceLight,
                                borderRadius: BorderRadius.circular(10.r),
                                border:
                                    Border.all(color: SalesColors.borderLight),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                      _isImagesExpanded
                                          ? Icons.keyboard_arrow_up_rounded
                                          : Icons.keyboard_arrow_down_rounded,
                                      color: SalesColors.primaryBlue,
                                      size: 20.sp),
                                  SizedBox(width: 8.w),
                                  Text(
                                    _isImagesExpanded
                                        ? 'إخفاء الصور المرفقة'
                                        : 'عرض الصور المرفقة (${widget.images.length})',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold,
                                      color: SalesColors.primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.fastOutSlowIn,
                            child: _isImagesExpanded
                                ? Padding(
                                    padding: EdgeInsets.only(top: 12.h),
                                    child: Wrap(
                                      spacing: 8.w,
                                      runSpacing: 8.h,
                                      children: List.generate(
                                          widget.images.length, (index) {
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    _ImageGalleryScreen(
                                                  images: widget.images,
                                                  initialIndex: index,
                                                  heroTags: List.generate(
                                                    widget.images.length,
                                                    (i) =>
                                                        'note_${widget.date.millisecondsSinceEpoch}_img_$i',
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          child: Hero(
                                            tag:
                                                'note_${widget.date.millisecondsSinceEpoch}_img_$index',
                                            child: Container(
                                              width: 60.w,
                                              height: 60.w,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      widget.images[index]),
                                                  fit: BoxFit.cover,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Reuse the same Dialog and Gallery Screen from before, just strictly defining them here to be self-contained
class AddNoteDialogContent extends StatefulWidget {
  final String measurementId;
  final DateTime? nextCallDate;
  final TimeOfDay? fromTime;
  final TimeOfDay? toTime;
  final List<String> imagePaths;
  final TextEditingController notesController;
  final TextEditingController expectedCommentController;
  final Function(StateSetter) onPickImage;

  const AddNoteDialogContent({
    super.key,
    required this.measurementId,
    required this.nextCallDate,
    required this.fromTime,
    required this.toTime,
    required this.imagePaths,
    required this.notesController,
    required this.expectedCommentController,
    required this.onPickImage,
  });

  @override
  State<AddNoteDialogContent> createState() => _AddNoteDialogContentState();
}

class _AddNoteDialogContentState extends State<AddNoteDialogContent> {
  late DateTime? _selectedDate;
  late TimeOfDay? _selectedFromTime;
  late TimeOfDay? _selectedToTime;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.nextCallDate;
    _selectedFromTime = widget.fromTime;
    _selectedToTime = widget.toTime;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: SalesColors.primaryBlue,
              onPrimary: Colors.white,
              onSurface: SalesColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isFrom) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: SalesColors.primaryBlue,
              onPrimary: Colors.white,
              onSurface: SalesColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          _selectedFromTime = picked;
        } else {
          _selectedToTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddNoteCubit, AddNoteState>(
      listener: (context, state) {
        if (state.status == AddNoteStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إضافة الملاحظة بنجاح')),
          );
          Navigator.pop(context);
          context
              .read<SalesDetailsCubit>()
              .fetchDealDetails(id: widget.measurementId);
          widget.notesController.clear();
          widget.expectedCommentController.clear();
          widget.imagePaths.clear();
        } else if (state.status == AddNoteStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('فشل في إضافة الملاحظة: ${state.errorMessage}')),
          );
        }
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                decoration: BoxDecoration(
                  gradient: SalesColors.headerGradient,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.r),
                    topRight: Radius.circular(24.r),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.edit_note_rounded,
                        color: Colors.white, size: 28.sp),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        'إضافة ملاحظة جديدة',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Notes Input
                      Text(
                        'الملاحظة',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: SalesColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: SalesColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: SalesColors.borderLight),
                        ),
                        child: TextField(
                          controller: widget.notesController,
                          style: TextStyle(
                              fontSize: 16.sp, color: SalesColors.textPrimary),
                          maxLines: 4,
                          minLines: 2,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'اكتب تفاصيل الملاحظة هنا...',
                          ),
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // Expected Comment Input
                      Text(
                        'التعليق',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: SalesColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: SalesColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: SalesColors.borderLight),
                        ),
                        child: TextField(
                          controller: widget.expectedCommentController,
                          style: TextStyle(
                              fontSize: 14.sp, color: SalesColors.textPrimary),
                          maxLines: 2,
                          minLines: 1,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'مثال: العميل مهتم بالعرض...',
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Date & Time Selection
                      Row(
                        children: [
                          Expanded(
                            child: _buildTimePickerBox(
                              context: context,
                              icon: Icons.calendar_today_rounded,
                              label: 'التاريخ',
                              value: _selectedDate == null
                                  ? 'اختر'
                                  : '${_selectedDate!.day}/${_selectedDate!.month}',
                              onTap: () => _selectDate(context),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: _buildTimePickerBox(
                              context: context,
                              icon: Icons.access_time_rounded,
                              label: 'من',
                              value:
                                  _selectedFromTime?.format(context) ?? '--:--',
                              onTap: () => _selectTime(context, true),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: _buildTimePickerBox(
                              context: context,
                              icon: Icons.access_time_rounded,
                              label: 'إلى',
                              value:
                                  _selectedToTime?.format(context) ?? '--:--',
                              onTap: () => _selectTime(context, false),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20.h),

                      // Image Upload
                      GestureDetector(
                        onTap: () => widget.onPickImage(setState),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 12.h, horizontal: 16.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                                color: SalesColors.primaryBlue,
                                style: BorderStyle.solid),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined,
                                  color: SalesColors.primaryBlue, size: 20.sp),
                              SizedBox(width: 8.w),
                              Text(
                                'إرفاق صور (${widget.imagePaths.length})',
                                style: TextStyle(
                                  color: SalesColors.primaryBlue,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (widget.imagePaths.isNotEmpty) ...[
                        SizedBox(height: 12.h),
                        SizedBox(
                          height: 70.h,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.imagePaths.length,
                            separatorBuilder: (_, __) => SizedBox(width: 8.w),
                            itemBuilder: (context, index) {
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.r),
                                    child: Image.file(
                                      File(widget.imagePaths[index]),
                                      width: 70.h,
                                      height: 70.h,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: -5,
                                    right: -5,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          widget.imagePaths.removeAt(index);
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close,
                                            size: 12, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],

                      SizedBox(height: 24.h),

                      // Submit Button
                      BlocBuilder<AddNoteCubit, AddNoteState>(
                        builder: (context, state) {
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: state.status == AddNoteStatus.loading
                                  ? null
                                  : () {
                                      if (widget.notesController.text.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content:
                                                  Text('يرجى إدخال ملاحظة')),
                                        );
                                        return;
                                      }

                                      String? timeFrom;
                                      if (_selectedFromTime != null) {
                                        final hh = _selectedFromTime!.hour
                                            .toString()
                                            .padLeft(2, '0');
                                        final mm = _selectedFromTime!.minute
                                            .toString()
                                            .padLeft(2, '0');
                                        timeFrom = '$hh:$mm:00';
                                      }

                                      String? timeTo;
                                      if (_selectedToTime != null) {
                                        final hh = _selectedToTime!.hour
                                            .toString()
                                            .padLeft(2, '0');
                                        final mm = _selectedToTime!.minute
                                            .toString()
                                            .padLeft(2, '0');
                                        timeTo = '$hh:$mm:00';
                                      }

                                      final dto = AddNoteDto(
                                        measurementId: widget.measurementId,
                                        notes: widget.notesController.text,
                                        expectedComment: widget
                                                .expectedCommentController
                                                .text
                                                .isNotEmpty
                                            ? widget
                                                .expectedCommentController.text
                                            : null,
                                        expectedCallDate: _selectedDate,
                                        expectedCallTimeFrom: timeFrom,
                                        expectedCallTimeTo: timeTo,
                                        imageFiles: widget.imagePaths.isNotEmpty
                                            ? widget.imagePaths
                                            : null,
                                      );
                                      context.read<AddNoteCubit>().addNote(dto);
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: SalesColors.primaryBlue,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                elevation: 4,
                                shadowColor:
                                    SalesColors.primaryBlue.withOpacity(0.4),
                              ),
                              child: state.status == AddNoteStatus.loading
                                  ? SizedBox(
                                      width: 24.w,
                                      height: 24.w,
                                      child: const CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2),
                                    )
                                  : Text(
                                      'حفظ الملاحظة',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          );
                        },
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

  Widget _buildTimePickerBox({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: SalesColors.surfaceLight,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: SalesColors.borderMedium.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16.sp, color: SalesColors.textSecondary),
                SizedBox(width: 4.w),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: SalesColors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: SalesColors.primaryBlue,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageGalleryScreen extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final List<String> heroTags;

  const _ImageGalleryScreen({
    required this.images,
    required this.initialIndex,
    required this.heroTags,
  });

  @override
  State<_ImageGalleryScreen> createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<_ImageGalleryScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(widget.images[index]),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 3,
                heroAttributes:
                    PhotoViewHeroAttributes(tag: widget.heroTags[index]),
                errorBuilder: (context, error, stackTrace) => Center(
                    child: Icon(Icons.error, color: Colors.white, size: 50.sp)),
              );
            },
            itemCount: widget.images.length,
            loadingBuilder: (context, event) => Center(
              child: CircularProgressIndicator(
                value: event == null
                    ? 0
                    : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
                color: Colors.white,
              ),
            ),
            backgroundDecoration: const BoxDecoration(
              color: Colors.black,
            ),
            pageController: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          Positioned(
            top: 40.h,
            right: 16.w,
            child: SafeArea(
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
          if (widget.images.length > 1)
            Positioned(
              bottom: 30.h,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.images.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
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
