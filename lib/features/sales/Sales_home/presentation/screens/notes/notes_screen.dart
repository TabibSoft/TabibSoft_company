
import 'dart:io';
import 'dart:math' as math;
import 'dart:async'; // Add this

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/data/models/notes/add_note_model.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/cubits/notes/add_note_cubit.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/cubits/notes/add_note_state.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/cubits/notes/sales_details_cubit.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/cubits/notes/sales_details_state.dart';

class NotesScreen extends StatefulWidget {
  final String measurementId;

  const NotesScreen({super.key, required this.measurementId});

  static const double horizontalPadding = 16.0;

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _installingNoteController =
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
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _notesController.dispose();
    _addressController.dispose();
    _locationController.dispose();
    _installingNoteController.dispose();
    super.dispose();
  }

  /// --- Helper: convert TimeOfDay? to "HH:mm:00" or return null if null
  String? _timeOfDayToHms(TimeOfDay? t) {
    if (t == null) return null;
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm:00';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _nextCallDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
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
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
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
                leading: const Icon(Icons.photo_camera),
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
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.topRight,
              colors: [
                Color(0xff104D9D),
                Color(0xFF20AAC9),
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 18),
                    Center(
                      child: Image.asset(
                        'assets/images/pngs/TS_Logo0.png',
                        width: 140,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 12),
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
                        child:
                            BlocBuilder<SalesDetailsCubit, SalesDetailsState>(
                          builder: (context, state) {
                            if (state.status == SalesDetailsStatus.loading) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (state.status ==
                                SalesDetailsStatus.loaded) {
                              final detail = state.detail!;
                              // Collect all notes and their associated images, ordered from newest to oldest
                              List<Map<String, dynamic>> allNotes = [];
                              // Add notes from measurementRequirement in reverse order (newest first)
                              for (var requirement
                                  in detail.measurementRequirement.reversed) {
                                if (requirement.notes != null) {
                                  final normalizedImages = (requirement.requireImages ?? <String>[])
                                      .map((img) => img.replaceAll(r'\', '/'))
                                      .toList();
                                  allNotes.add({
                                    'note': requirement.notes,
                                    'images': normalizedImages,
                                    'date': requirement.creatDate ?? detail.date, // Assuming creatDate exists in requirement model
                                  });
                                }
                              }
                              // Add the main note at the end (assuming it's the oldest)
                              if (detail.note != null) {
                                allNotes.add({
                                  'note': detail.note,
                                  'images': <String>[],
                                  'date': detail.date, // Use detail.date for main note
                                });
                              }
                              return ListView(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: NotesScreen.horizontalPadding,
                                    vertical: 8),
                                children: [
                                  if (allNotes.isEmpty)
                                    Padding(
                                      padding: EdgeInsets.all(16.w),
                                      child: Center(
                                        child: Text(
                                          'لا توجد ملاحظات',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    ...allNotes.map((noteData) {
                                      final note = noteData['note'] as String;
                                      final images =
                                          noteData['images'] as List<String>;
                                      final date = noteData['date'] as DateTime;
                                      return Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 4.h),
                                        child: _NoteCard(
                                          note: note,
                                          images: images,
                                          date: date,
                                        ),
                                      );
                                    }),
                                ],
                              );
                            } else if (state.status ==
                                SalesDetailsStatus.error) {
                              return const Center(
                                  child: Text('خطأ في التحميل'));
                            } else {
                              return const Center(
                                  child: Text('لا توجد بيانات'));
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: -3,
                  bottom: 0.5,
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext dialogContext) {
                          bool hasData = false;
                          void updateHasData(StateSetter setState) {
                            setState(() {
                              hasData = _notesController.text.isNotEmpty ||
                                  _addressController.text.isNotEmpty ||
                                  _locationController.text.isNotEmpty ||
                                  _installingNoteController.text.isNotEmpty ||
                                  _nextCallDate != null ||
                                  _fromTime != null ||
                                  _toTime != null ||
                                  _imagePaths.isNotEmpty;
                            });
                          }

                          _notesController.addListener(() {
                            updateHasData((f) => f());
                          });
                          _addressController.addListener(() {
                            updateHasData((f) => f());
                          });
                          _locationController.addListener(() {
                            updateHasData((f) => f());
                          });
                          _installingNoteController.addListener(() {
                            updateHasData((f) => f());
                          });

                          return StatefulBuilder(
                            builder: (context, setState) {
                              return BlocListener<AddNoteCubit, AddNoteState>(
                                listener: (context, state) {
                                  if (state.status == AddNoteStatus.success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('تم إضافة الملاحظة بنجاح')),
                                    );
                                    Navigator.pop(dialogContext);
                                    context
                                        .read<SalesDetailsCubit>()
                                        .fetchDealDetails(
                                            id: widget.measurementId);
                                  } else if (state.status ==
                                      AddNoteStatus.failure) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'فشل في إضافة الملاحظة: ${state.errorMessage}')),
                                    );
                                  }
                                },
                                child: Dialog(
                                  backgroundColor: Colors.transparent,
                                  child: Stack(
                                    children: [
                                      SingleChildScrollView(
                                        child: Container(
                                          padding: EdgeInsets.all(16.w),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20.r),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(height: 5.h),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 16.w,
                                                    vertical: 12.h),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xff104D9D),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.r),
                                                ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: TextField(
                                                        controller:
                                                            _notesController,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 18.sp,
                                                        ),
                                                        decoration:
                                                            const InputDecoration(
                                                          hintText:
                                                              'أدخل الملاحظات',
                                                          hintStyle: TextStyle(
                                                            color:
                                                                Colors.white70,
                                                          ),
                                                          border:
                                                              InputBorder.none,
                                                        ),
                                                        keyboardType:
                                                            TextInputType
                                                                .multiline,
                                                        maxLines: null,
                                                        minLines: 3,
                                                        onChanged: (_) =>
                                                            updateHasData(
                                                                setState),
                                                      ),
                                                    ),
                                                    const Icon(Icons.edit,
                                                        color: Colors.white),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 10.h),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 16.w,
                                                    vertical: 12.h),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xff104D9D),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.r),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          _selectDate(context)
                                                              .then((_) =>
                                                                  updateHasData(
                                                                      setState));
                                                        },
                                                        child: Text(
                                                          _nextCallDate == null
                                                              ? 'اختر التاريخ'
                                                              : '${_nextCallDate!.day}/${_nextCallDate!.month}/${_nextCallDate!.year}',
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18.sp,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const Icon(
                                                        Icons.calendar_today,
                                                        color: Colors.white),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 10.h),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 16.w,
                                                              vertical: 12.h),
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xff104D9D),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.r),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                _selectTime(
                                                                  context,
                                                                  true,
                                                                  setState,
                                                                ).then((_) =>
                                                                    updateHasData(
                                                                        setState));
                                                              },
                                                              child: Text(
                                                                _fromTime ==
                                                                        null
                                                                    ? 'من'
                                                                    : _fromTime!
                                                                        .format(
                                                                            context),
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      18.sp,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          const Icon(
                                                              Icons.access_time,
                                                              color:
                                                                  Colors.white),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 10.w),
                                                  Expanded(
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 16.w,
                                                              vertical: 12.h),
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xff104D9D),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.r),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                _selectTime(
                                                                  context,
                                                                  false,
                                                                  setState,
                                                                ).then((_) =>
                                                                    updateHasData(
                                                                        setState));
                                                              },
                                                              child: Text(
                                                                _toTime == null
                                                                    ? 'الى'
                                                                    : _toTime!
                                                                        .format(
                                                                            context),
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      18.sp,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          const Icon(
                                                              Icons.access_time,
                                                              color:
                                                                  Colors.white),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 20.h),
                                              Column(
                                                children: [
                                                  Text(
                                                    'رفع الملفات',
                                                    style: TextStyle(
                                                      fontSize: 18.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  SizedBox(width: 10.w),
                                                  GestureDetector(
                                                    onTap: () =>
                                                        _pickImage(setState)
                                                            .then((_) =>
                                                                updateHasData(
                                                                    setState)),
                                                    child: Stack(
                                                      children: [
                                                        Image.asset(
                                                          'assets/images/pngs/pictures_folder.png',
                                                          width: 50.w,
                                                          height: 50.h,
                                                        ),
                                                        if (_imagePaths
                                                            .isNotEmpty)
                                                          Positioned(
                                                            right: 0,
                                                            top: 0,
                                                            child: Container(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(2.w),
                                                              decoration:
                                                                  const BoxDecoration(
                                                                color:
                                                                    Colors.red,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              child: Text(
                                                                _imagePaths
                                                                    .length
                                                                    .toString(),
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      12.sp,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (_imagePaths.isNotEmpty)
                                                SizedBox(
                                                  height: 100.h,
                                                  child: ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount:
                                                        _imagePaths.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Padding(
                                                        padding:
                                                            EdgeInsets.all(8.w),
                                                        child: Image.file(
                                                          File(_imagePaths[
                                                              index]),
                                                          width: 80.w,
                                                          height: 80.h,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              if (hasData)
                                                SizedBox(height: 20.h),
                                              if (hasData)
                                                BlocBuilder<AddNoteCubit,
                                                    AddNoteState>(
                                                  builder: (context, state) {
                                                    return ElevatedButton(
                                                      onPressed: state.status ==
                                                              AddNoteStatus
                                                                  .loading
                                                          ? null
                                                          : () {
                                                              if (_notesController
                                                                  .text
                                                                  .isEmpty) {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  const SnackBar(
                                                                      content: Text(
                                                                          'يرجى إدخال ملاحظة')),
                                                                );
                                                                return;
                                                              }
                                                              final dto =
                                                                  AddNoteDto(
                                                                measurementId:
                                                                    widget
                                                                        .measurementId,
                                                                notes:
                                                                    _notesController
                                                                        .text,
                                                                expectedCallDate:
                                                                    _nextCallDate,
                                                                expectedCallTimeFrom:
                                                                    _timeOfDayToHms(
                                                                        _fromTime),
                                                                expectedCallTimeTo:
                                                                    _timeOfDayToHms(
                                                                        _toTime),
                                                                imageFiles: _imagePaths
                                                                        .isNotEmpty
                                                                    ? _imagePaths
                                                                    : null,
                                                              );
                                                              context
                                                                  .read<
                                                                      AddNoteCubit>()
                                                                  .addNote(dto);
                                                            },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            const Color(
                                                                0xff104D9D),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.r),
                                                        ),
                                                      ),
                                                      child: state.status ==
                                                              AddNoteStatus
                                                                  .loading
                                                          ? const CircularProgressIndicator(
                                                              valueColor:
                                                                  AlwaysStoppedAnimation<
                                                                      Color>(
                                                                Colors.white,
                                                              ),
                                                            )
                                                          : Text(
                                                              'حفظ',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 18.sp,
                                                              ),
                                                            ),
                                                    );
                                                  },
                                                ),
                                              SizedBox(height: 10.h),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: IconButton(
                                          icon: const Icon(Icons.close,
                                              color: Colors.black),
                                          onPressed: () =>
                                              Navigator.pop(dialogContext),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ).then((_) {
                        _notesController.removeListener(() {});
                        _addressController.removeListener(() {});
                        _locationController.removeListener(() {});
                        _installingNoteController.removeListener(() {});
                      });
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          'assets/images/pngs/Ellipse_3.png',
                          width: 90.w,
                          height: 90.h,
                          fit: BoxFit.contain,
                        ),
                        Text(
                          '+',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30.sp,
                            fontWeight: FontWeight.bold,
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
      ),
    );
  }
}

class _NoteCard extends StatefulWidget {
  final String note;
  final List<String> images;
  final DateTime date;

  const _NoteCard({
    required this.note,
    required this.images,
    required this.date,
  });

  @override
  State<_NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<_NoteCard> {
  bool _isExpanded = false;
  final GlobalKey _expandedKey = GlobalKey();
  double _bottomOffset = -7.0;

  static const double cardHeight = 200;
  static const double innerRadius = 19;

  @override
  Widget build(BuildContext context) {
    final BorderRadius mainRadius = _isExpanded
        ? const BorderRadius.only(
            topLeft: Radius.circular(innerRadius),
            topRight: Radius.circular(innerRadius),
          )
        : BorderRadius.circular(innerRadius);

    final bool hasImages = widget.images.isNotEmpty;

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5.h),
                      Row(
                        children: [
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              widget.note,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.grey[800],
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          SizedBox(width: 8.w),
                          Text(
                            '${widget.date.toLocal().day.toString().padLeft(2, '0')}/${widget.date.toLocal().month.toString().padLeft(2, '0')}/${widget.date.toLocal().year}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(width: 13.w),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (hasImages)
                Positioned(
                  right: 16.w,
                  bottom: _bottomOffset,
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
                      angle: _isExpanded ? math.pi : 0,
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
            margin: EdgeInsets.only(right: 2.w),
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 184, 137, 137),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(innerRadius),
                bottomRight: Radius.circular(innerRadius),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.images.isEmpty)
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
                      widget.images.length,
                      (index) => Image.network(
                        widget.images[index],
                        width: 100.w,
                        height: 100.h,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100.w,
                            height: 100.h,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: const Icon(Icons.error, size: 50, color: Colors.red),
                          );
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
