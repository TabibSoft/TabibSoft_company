import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';
import 'package:tabib_soft_company/core/utils/constant/app_style.dart';
import 'package:tabib_soft_company/features/human_resources/data/models/create_hr_leave_request_model.dart';
import 'package:tabib_soft_company/features/human_resources/data/models/hr_leave_request_model.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/cubits/hr_leave_cubit.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/cubits/hr_leave_state.dart';

class VacationRequestScreen extends StatefulWidget {
  const VacationRequestScreen({super.key});

  @override
  State<VacationRequestScreen> createState() => _VacationRequestScreenState();
}

class _VacationRequestScreenState extends State<VacationRequestScreen> {
  String? vacationType;
  DateTime? startDate;
  DateTime? endDate;
  final TextEditingController reasonController = TextEditingController();

  bool get _isLeaveHoursType => vacationType == 'LeaveHours';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HrLeaveCubit>().fetchLeaveTypes();
      context.read<HrLeaveCubit>().fetchMyLeaves();
    });
  }

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int totalDays = _calculateTotalDays();
    final int totalHours = _calculateRequestedHours();

    return BlocListener<HrLeaveCubit, HrLeaveState>(
      listener: (context, state) {
        if (state.status == HrLeaveStatus.error && state.failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.failure!.errMessages),
              backgroundColor: Colors.red,
            ),
          );
        }
        if (state.status == HrLeaveStatus.submitSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إرسال الطلب بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            vacationType = null;
            startDate = null;
            endDate = null;
            reasonController.clear();
          });
          context.read<HrLeaveCubit>().fetchLeaveTypes();
          context.read<HrLeaveCubit>().fetchMyLeaves();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F8FE),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 280.h,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00337C), Color(0xFF0A4A9C)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(36.r),
                        bottomRight: Radius.circular(36.r),
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 18.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                // InkWell(
                                //   onTap: () => Navigator.pop(context),
                                //   borderRadius: BorderRadius.circular(22.r),
                                //   child: Container(
                                //     width: 46.w,
                                //     height: 46.w,
                                //     decoration: BoxDecoration(
                                //       color: Colors.white.withOpacity(0.16),
                                //       shape: BoxShape.circle,
                                //     ),
                                //     child: const Icon(
                                //       Icons.arrow_back_ios_new,
                                //       color: Colors.white,
                                //       size: 20,
                                //     ),
                                //   ),
                                // ),
                                const Spacer(),
                                InkWell(
                                  onTap: () => Navigator.pop(context),
                                  borderRadius: BorderRadius.circular(22.r),
                                  child: Container(
                                    width: 46.w,
                                    height: 46.w,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.16),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 26.h),
                            Text(
                              "طلب إجازة",
                              style: TextStyle(
                                fontSize: 26.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              "قم بتعبئة تفاصيل إجازتك القادمة ليتم مراجعتها",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.white.withOpacity(0.9),
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Padding(
                  //   padding: EdgeInsets.only(top: 210.h),
                  //   child: Center(
                  //     child: Container(
                  //       width: 72.w,
                  //       height: 72.w,
                  //       decoration: BoxDecoration(
                  //         color: Colors.white,
                  //         shape: BoxShape.circle,
                  //         boxShadow: [
                  //           BoxShadow(
                  //             color: Colors.black.withOpacity(0.15),
                  //             blurRadius: 16,
                  //             offset: const Offset(0, 10),
                  //           ),
                  //         ],
                  //       ),
                  //       child: const Icon(
                  //         Icons.calendar_today,
                  //         color: Color(0xFF00337C),
                  //         size: 32,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: 250.h,
                      left: 16.w,
                      right: 16.w,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18.w,
                          vertical: 22.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "نوع الإجازة",
                              style: AppStyle.font14_700Weight.copyWith(
                                color: ProgrammerColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4F7FB),
                                borderRadius: BorderRadius.circular(22.r),
                              ),
                              child: BlocBuilder<HrLeaveCubit, HrLeaveState>(
                                builder: (context, state) {
                                  final types = state.leaveTypes;
                                  return DropdownButtonFormField<String>(
                                    initialValue: vacationType,
                                    hint: const Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 12),
                                      child: Text("اختر نوع الإجازة"),
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 16.h,
                                      ),
                                    ),
                                    items: types
                                        .where((e) => e.name != null)
                                        .map(
                                          (e) => DropdownMenuItem<String>(
                                            value: e.name,
                                            child: Text(
                                              e.displayName ?? e.name ?? '',
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        vacationType = value;
                                        startDate = null;
                                        endDate = null;
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 20.h),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _isLeaveHoursType
                                            ? "وقت البدء"
                                            : "تاريخ البدء",
                                        style:
                                            AppStyle.font14_700Weight.copyWith(
                                          color: ProgrammerColors.textPrimary,
                                        ),
                                      ),
                                      SizedBox(height: 10.h),
                                      _buildDateField(
                                        _isLeaveHoursType
                                            ? "--:--"
                                            : "mm/dd/yyyy",
                                        startDate,
                                        true,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _isLeaveHoursType
                                            ? "وقت الانتهاء"
                                            : "تاريخ الانتهاء",
                                        style:
                                            AppStyle.font14_700Weight.copyWith(
                                          color: ProgrammerColors.textPrimary,
                                        ),
                                      ),
                                      SizedBox(height: 10.h),
                                      _buildDateField(
                                        _isLeaveHoursType
                                            ? "--:--"
                                            : "mm/dd/yyyy",
                                        endDate,
                                        false,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 18.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F9FE),
                                borderRadius: BorderRadius.circular(24.r),
                              ),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _isLeaveHoursType
                                            ? totalHours.toString()
                                            : totalDays.toString(),
                                        style: TextStyle(
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF00337C),
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        _isLeaveHoursType ? "ساعة" : "يوم",
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: ProgrammerColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _isLeaveHoursType
                                            ? "إجمالي عدد الساعات"
                                            : "إجمالي عدد الأيام",
                                        style: AppStyle.font14_700Weight,
                                      ),
                                      SizedBox(height: 8.h),
                                      Container(
                                        width: 40.w,
                                        height: 40.w,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE1F1FF),
                                          borderRadius:
                                              BorderRadius.circular(14.r),
                                        ),
                                        child: const Icon(
                                          Icons.calendar_today,
                                          color: Color(0xFF00337C),
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20.h),
                            Text(
                              "سبب الطلب (اختياري)",
                              style: AppStyle.font14_700Weight.copyWith(
                                color: ProgrammerColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            TextField(
                              controller: reasonController,
                              maxLines: 5,
                              decoration: InputDecoration(
                                hintText: "اكتب ملاحظاتك هنا...",
                                filled: true,
                                fillColor: const Color(0xFFF4F7FB),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(22.r),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 16.h,
                                ),
                              ),
                            ),
                            SizedBox(height: 18.h),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7E6),
                                borderRadius: BorderRadius.circular(18.r),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: Color(0xFFF4A800),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Text(
                                      "سيتم توجيه هذا الطلب إلى مدير الموارد البشرية للمراجعة. سيتم إخطارك بمجرد اتخاذ القرار.",
                                      style: AppStyle.font13_400Weight.copyWith(
                                        color: const Color(0xFF5C5C5C),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 24.h),
                            SizedBox(
                              width: double.infinity,
                              height: 56.h,
                              child: BlocBuilder<HrLeaveCubit, HrLeaveState>(
                                builder: (context, state) {
                                  final isSubmitting =
                                      state.status == HrLeaveStatus.submitting;
                                  return ElevatedButton(
                                    onPressed: isSubmitting
                                        ? null
                                        : () => _submitLeaveRequest(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF00337C),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.r),
                                      ),
                                    ),
                                    child: isSubmitting
                                        ? SizedBox(
                                            width: 22.w,
                                            height: 22.w,
                                            child:
                                                const CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.send,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 8.w),
                                              Text(
                                                "إرسال الطلب",
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 28.h),
                            Text(
                              "الطلبات الأخيرة",
                              style: AppStyle.font16_700Weight,
                            ),
                            SizedBox(height: 16.h),
                            BlocBuilder<HrLeaveCubit, HrLeaveState>(
                              builder: (context, state) {
                                final requests = state.leaveRequests;

                                if (state.status == HrLeaveStatus.loadingRequests &&
                                    requests.isEmpty) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                if (requests.isEmpty) {
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 24.h),
                                    child: Text(
                                      "لا توجد طلبات حالياً",
                                      style: AppStyle.font13_400Weight.copyWith(
                                        color: ProgrammerColors.textSecondary,
                                      ),
                                    ),
                                  );
                                }

                                final recent = requests.take(5).toList();
                                return Column(
                                  children: [
                                    ...List.generate(recent.length, (index) {
                                      final request = recent[index];
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          bottom: index == recent.length - 1
                                              ? 24.h
                                              : 12.h,
                                        ),
                                        child: _buildPreviousRequest(
                                          status: _statusLabel(request.status),
                                          statusColor:
                                              _statusColor(request.status),
                                          title: _leaveTypeLabel(request.leaveType),
                                          date: _requestDateSummary(request),
                                        ),
                                      );
                                    }),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitLeaveRequest(BuildContext context) async {
    if (vacationType == null) {
      _showValidationMessage('اختر نوع الإجازة أولاً');
      return;
    }
    if (startDate == null || endDate == null) {
      _showValidationMessage(
        _isLeaveHoursType
            ? 'اختر وقت البداية ووقت النهاية'
            : 'اختر تاريخ البداية وتاريخ النهاية',
      );
      return;
    }
    if (endDate!.isBefore(startDate!)) {
      _showValidationMessage(
        _isLeaveHoursType
            ? 'وقت النهاية يجب أن يكون بعد وقت البداية'
            : 'تاريخ النهاية يجب أن يكون بعد تاريخ البداية',
      );
      return;
    }

    final hoursRequested = _isLeaveHoursType ? _calculateRequestedHours() : 0;
    if (_isLeaveHoursType && hoursRequested <= 0) {
      _showValidationMessage('الحد الأدنى للاستئذان ساعة واحدة');
      return;
    }
    if (_isLeaveHoursType && hoursRequested > 2) {
      _showValidationMessage('الحد الأقصى للاستئذان ساعتان في اليوم');
      return;
    }

    final request = CreateHrLeaveRequestModel(
      leaveType: vacationType!,
      startDate: startDate!,
      endDate: endDate!,
      hoursRequested: _isLeaveHoursType ? hoursRequested : 0,
    );

    await context.read<HrLeaveCubit>().createLeave(request);
  }

  void _showValidationMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
      ),
    );
  }

  int _calculateTotalDays() {
    if (_isLeaveHoursType) return 0;
    if (startDate == null || endDate == null) return 0;
    final diff = endDate!.difference(startDate!).inDays;
    return diff >= 0 ? diff + 1 : 0;
  }

  int _calculateRequestedHours() {
    if (startDate == null || endDate == null) return 0;
    final minutes = endDate!.difference(startDate!).inMinutes;
    if (minutes <= 0) return 0;
    return (minutes / 60).ceil();
  }

  Widget _buildDateField(String hint, DateTime? date, bool isStart) {
    return GestureDetector(
      onTap: () async {
        if (_isLeaveHoursType) {
          final pickedTime = await showTimePicker(
            context: context,
            initialTime: date != null
                ? TimeOfDay(hour: date.hour, minute: date.minute)
                : TimeOfDay.now(),
          );
          if (pickedTime == null) return;

          final base = DateTime.now();
          final picked = DateTime(
            base.year,
            base.month,
            base.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          setState(() {
            if (isStart) {
              startDate = picked;
            } else {
              endDate = picked;
            }
          });
          return;
        }

        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2024),
          lastDate: DateTime(2027),
        );
        if (picked != null) {
          setState(() {
            if (isStart) {
              startDate = picked;
            } else {
              endDate = picked;
            }
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFF5F5F5)),
        ),
        child: Text(
          date != null
              ? _isLeaveHoursType
                  ? "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}"
                  : "${date.month}/${date.day}/${date.year}"
              : hint,
          style: TextStyle(
            color: date != null ? Colors.black : const Color(0xFFAEAEAE),
            fontSize: 15.sp,
          ),
        ),
      ),
    );
  }

  String _leaveTypeLabel(String? value) {
    switch (value) {
      case 'RegularVacation':
        return 'إجازة اعتيادية';
      case 'Casual':
        return 'إجازة عارضة';
      case 'Sick':
        return 'إجازة مرضية';
      case 'LeaveHours':
        return 'استئذان (ساعات)';
      default:
        return value ?? 'طلب إجازة';
    }
  }

  String _statusLabel(String? value) {
    switch (value) {
      case 'Approved':
        return 'مقبول';
      case 'Rejected':
        return 'مرفوض';
      case 'PendingLevel1':
      case 'PendingLevel2':
        return 'قيد الانتظار';
      default:
        return value ?? 'قيد المراجعة';
    }
  }

  Color _statusColor(String? value) {
    switch (value) {
      case 'Approved':
        return const Color(0xFF4CAF50);
      case 'Rejected':
        return const Color(0xFFE53935);
      case 'PendingLevel1':
      case 'PendingLevel2':
      default:
        return const Color(0xFFF4A800);
    }
  }

  String _requestDateSummary(HrLeaveRequestModel request) {
    final start = request.startDate;
    final end = request.endDate;
    final days = request.totalDays ?? 0;
    final hours = request.hoursRequested ?? 0;

    if (start == null || end == null) {
      return request.createdDate?.toString() ?? '';
    }

    final startText = '${start.day}/${start.month}/${start.year}';
    final endText = '${end.day}/${end.month}/${end.year}';

    if (request.leaveType == 'LeaveHours') {
      return '$startText ($hours ساعة)';
    }

    return '$startText - $endText ($days يوم)';
  }

  Widget _buildPreviousRequest({
    required String status,
    required Color statusColor,
    required String title,
    required String date,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppStyle.font15_500Weight),
                Text(date,
                    style: AppStyle.font13_400Weight
                        .copyWith(color: ProgrammerColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
