import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';
import 'package:tabib_soft_company/core/utils/constant/app_style.dart';
import 'package:tabib_soft_company/features/human_resources/data/models/create_hr_remote_work_request_model.dart';
import 'package:tabib_soft_company/features/human_resources/data/models/hr_remote_work_request_model.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/cubits/hr_remote_work_cubit.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/cubits/hr_remote_work_state.dart';

class WorkFromHomeScreen extends StatefulWidget {
  const WorkFromHomeScreen({super.key});

  @override
  State<WorkFromHomeScreen> createState() => _WorkFromHomeScreenState();
}

class _WorkFromHomeScreenState extends State<WorkFromHomeScreen> {
  DateTime? startDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HrRemoteWorkCubit>().fetchRemoteWorkRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HrRemoteWorkCubit, HrRemoteWorkState>(
      listener: (context, state) {
        if (state.status == HrRemoteWorkStatus.submitSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تقديم طلب العمل عن بعد بنجاح')),
          );
        }
        if (state.status == HrRemoteWorkStatus.error && state.failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.failure!.errMessages)),
          );
        }
        if (state.status == HrRemoteWorkStatus.requestDetailLoaded &&
            state.selectedRequest != null) {
          _showRequestDetail(context, state.selectedRequest!);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F8FE),
        body: RefreshIndicator(
          onRefresh: () =>
              context.read<HrRemoteWorkCubit>().fetchRemoteWorkRequests(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Header
                Container(
                  height: 214.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00579B), Color(0xFF00A8D8)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32.r),
                      bottomRight: Radius.circular(32.r),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 18.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Spacer(),
                              Text(
                                'طلب عمل عن بعد',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                width: 44.w,
                                height: 44.w,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.16),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 14.h),
                          Text(
                            'يرجى تعبئة التفاصيل أدناه لإرسال طلبك للمراجعة',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.95),
                              fontSize: 14.sp,
                              height: 1.7,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                // White card
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 22.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('تاريخ العمل عن بعد'),
                          SizedBox(height: 10.h),
                          _buildDateTile(
                            text: startDate != null
                                ? _formatDate(startDate!)
                                : 'dd/mm/yyyy',
                            onTap: () => _pickDate(context),
                          ),
                          SizedBox(height: 16.h),
                          SizedBox(height: 20.h),
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F8FF),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 34.w,
                                  height: 34.w,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDEEFFF),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: const Icon(
                                    Icons.info_outline,
                                    color: Color(0xFF00A8D8),
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'سياسة العمل عن بعد',
                                        style:
                                            AppStyle.font14_700Weight.copyWith(
                                          color: ProgrammerColors.textPrimary,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        'يخضع الطلب لموافقة المدير المباشر وقسم الموارد البشرية. يرجى التأكد من توفر اتصال مستقر بالإنترنت خلال ساعات العمل الرسمية.',
                                        style:
                                            AppStyle.font13_400Weight.copyWith(
                                          color: const Color(0xFF5A6774),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24.h),
                          BlocBuilder<HrRemoteWorkCubit, HrRemoteWorkState>(
                            builder: (context, remoteWorkState) {
                              final isSubmitting = remoteWorkState.status ==
                                  HrRemoteWorkStatus.submitting;
                              return SizedBox(
                                width: double.infinity,
                                height: 54.h,
                                child: ElevatedButton(
                                  onPressed: isSubmitting
                                      ? null
                                      : () {
                                          if (startDate == null) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'الرجاء تحديد تاريخ البدء'),
                                              ),
                                            );
                                            return;
                                          }
                                          final request =
                                              CreateHrRemoteWorkRequestModel(
                                            startDate: startDate!,
                                          );
                                          context
                                              .read<HrRemoteWorkCubit>()
                                              .submitRemoteWork(request);
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00A8D8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                  ),
                                  child: isSubmitting
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : Text(
                                          'إرسال الطلب',
                                          style: AppStyle.font16_700Weight
                                              .copyWith(
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 12.h),
                          SizedBox(
                            width: double.infinity,
                            height: 54.h,
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  startDate = null;
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                side:
                                    const BorderSide(color: Color(0xFF9EA4AE)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                              ),
                              child: Text(
                                'إلغاء',
                                style: AppStyle.font16_700Weight.copyWith(
                                  color: const Color(0xFF5A6774),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 22.h),

                // Recent requests title
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'طلباتك الأخيرة',
                      style: AppStyle.font18_600Weight.copyWith(
                        color: ProgrammerColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: BlocBuilder<HrRemoteWorkCubit, HrRemoteWorkState>(
                    builder: (context, remoteWorkState) {
                      if (remoteWorkState.status ==
                              HrRemoteWorkStatus.loadingRequests &&
                          remoteWorkState.requests.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final requests = remoteWorkState.requests;

                      if (requests.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          child: Text(
                            'لم يتم تقديم طلبات بعد.',
                            style: AppStyle.font14_400Weight.copyWith(
                              color: const Color(0xFF5A6774),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      return Column(
                        children: List.generate(
                          requests.length,
                          (index) {
                            final request = requests[index];
                            return Column(
                              children: [
                                GestureDetector(
                                  onTap: request.id != null
                                      ? () {
                                          context
                                              .read<HrRemoteWorkCubit>()
                                              .fetchRemoteWorkRequestById(
                                                  request.id!);
                                        }
                                      : null,
                                  child: _buildRecentRequestCardFromRequest(
                                      request),
                                ),
                                if (index != requests.length - 1)
                                  SizedBox(height: 12.h),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: AppStyle.font14_700Weight.copyWith(
        color: ProgrammerColors.textPrimary,
      ),
    );
  }

  Widget _buildDateTile({required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F7FB),
          borderRadius: BorderRadius.circular(22.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: AppStyle.font14_400Weight.copyWith(
                  color: text == 'dd/mm/yyyy'
                      ? const Color(0xFF9EA4AE)
                      : ProgrammerColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.calendar_today,
              color: Color(0xFF00A8D8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentRequestCard({
    required String status,
    required Color statusColor,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          status,
                          style: AppStyle.font12_600Weight.copyWith(
                            color: statusColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(icon, color: statusColor, size: 22),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    title,
                    style: AppStyle.font16_700Weight.copyWith(
                      color: ProgrammerColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    subtitle,
                    style: AppStyle.font13_400Weight.copyWith(
                      color: ProgrammerColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 6.w,
            height: 90.h,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20.r),
                bottomRight: Radius.circular(20.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRequestCardFromRequest(HrRemoteWorkRequestModel request) {
    final statusString = request.status ?? 'جديد';
    final statusColor = request.status == 'Rejected'
        ? const Color(0xFFEB5757)
        : request.status?.contains('Pending') == true
            ? const Color(0xFFF4A800)
            : const Color(0xFF4CAF50);
    final subtitle = request.status == 'Rejected'
        ? 'تم رفض الطلب${request.rejectionReason != null ? ': ${request.rejectionReason}' : ''}'
        : request.status?.contains('Pending') == true
            ? 'يتم مراجعة طلبك من قبل الموارد البشرية.'
            : 'تم تقديم طلبك بنجاح.';

    return _buildRecentRequestCard(
      status: statusString,
      statusColor: statusColor,
      title: request.date != null ? _formatDate(request.date!) : 'بدون تاريخ',
      subtitle: subtitle,
      icon: request.status == 'Rejected'
          ? Icons.cancel
          : request.status?.contains('Pending') == true
              ? Icons.access_time
              : Icons.home_work,
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime initial = startDate ?? now;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        startDate = picked;
      });
    }
  }

  void _showRequestDetail(
      BuildContext context, HrRemoteWorkRequestModel request) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تفاصيل طلب العمل عن بعد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('الاسم: ${request.employeeName ?? '-'}'),
            const SizedBox(height: 8),
            Text(
                'التاريخ: ${request.date != null ? _formatDate(request.date!) : '-'}'),
            const SizedBox(height: 8),
            Text('الحالة: ${request.status ?? '-'}'),
            if (request.rejectionReason != null) ...[
              const SizedBox(height: 8),
              Text('سبب الرفض: ${request.rejectionReason}'),
            ],
            const SizedBox(height: 8),
            Text(
                'تاريخ الإنشاء: ${request.createdDate != null ? _formatDate(request.createdDate!) : '-'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }
}
