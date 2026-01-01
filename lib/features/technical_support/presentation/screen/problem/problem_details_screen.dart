import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';
import 'package:tabib_soft_company/features/programmers/data/model/engineer_model.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/engineer_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/problem/problem_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/problem_status/problem_status_model.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/customer_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/customer_state.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/screen/problem/add_tech_task_screen.dart';

class ProblemDetailsScreen extends StatefulWidget {
  final ProblemModel issue;
  const ProblemDetailsScreen({super.key, required this.issue});

  @override
  State<ProblemDetailsScreen> createState() => ProblemDetailsScreenState();
}

class ProblemDetailsScreenState extends State<ProblemDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController nameCtl;
  late TextEditingController addressCtl;
  late TextEditingController issueTitleCtl;
  late TextEditingController issueDetailsCtl;
  late TextEditingController contactCtl;
  late TextEditingController solutionCtl;
  late TextEditingController specialtyCtl;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  ProblemStatusModel? selectedSpecialty;
  EngineerModel? selectedEngineer;
  final List<File> selectedImages = [];
  bool isLoading = false;
  final GlobalKey engineerKey = GlobalKey();
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();

    nameCtl = TextEditingController(
        text: widget.issue.name ?? widget.issue.customerName ?? '');
    addressCtl = TextEditingController(
        text: widget.issue.location ?? widget.issue.adderss ?? '');
    issueTitleCtl =
        TextEditingController(text: widget.issue.problemAddress ?? '');
    issueDetailsCtl = TextEditingController(
        text: widget.issue.details ?? widget.issue.problemDetails ?? '');
    contactCtl = TextEditingController(
        text: widget.issue.telephone ?? widget.issue.customerPhone ?? '');
    solutionCtl = TextEditingController();
    specialtyCtl = TextEditingController(
      text: (widget.issue.products != null && widget.issue.products!.isNotEmpty)
          ? widget.issue.products!.join(', ')
          : '',
    );

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();

    context.read<CustomerCubit>().fetchProblemStatus();
    context.read<EngineerCubit>().fetchEngineers();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSelectedSpecialty();
    });
  }

  void _initializeSelectedSpecialty() {
    final cubit = context.read<CustomerCubit>();
    if (cubit.state.problemStatusList.isNotEmpty &&
        widget.issue.problemStatusId != null) {
      final status = cubit.state.problemStatusList.firstWhere(
        (s) => s.id == widget.issue.problemStatusId,
        orElse: () => cubit.state.problemStatusList.first,
      );
      setState(() {
        selectedSpecialty = status;
      });
    }
  }

  @override
  void dispose() {
    nameCtl.dispose();
    addressCtl.dispose();
    issueTitleCtl.dispose();
    issueDetailsCtl.dispose();
    contactCtl.dispose();
    solutionCtl.dispose();
    specialtyCtl.dispose();
    _refreshController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    if (widget.issue.customerSupportId != null) {
      await context
          .read<CustomerCubit>()
          .fetchProblemDetailsById(widget.issue.customerSupportId!);
    }
    _refreshController.refreshCompleted();
  }

  Color parseHexColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'ff$hex';
    return Color(int.parse(hex, radix: 16));
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await showModalBottomSheet<XFile?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 20.h),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: TechColors.accentCyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt,
                      color: TechColors.accentCyan),
                ),
                title: const Text('التقاط صورة',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () async {
                  Navigator.pop(context,
                      await picker.pickImage(source: ImageSource.camera));
                },
              ),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: TechColors.accentCyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library,
                      color: TechColors.accentCyan),
                ),
                title: const Text('اختيار من المعرض',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () async {
                  Navigator.pop(context,
                      await picker.pickImage(source: ImageSource.gallery));
                },
              ),
              SizedBox(height: 10.h),
            ],
          ),
        );
      },
    );

    if (pickedFile != null) {
      setState(() {
        selectedImages.add(File(pickedFile.path));
      });
    }
  }

  void showFullScreenImage(File imageFile, int index) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.95),
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
                  child: Image.file(imageFile, fit: BoxFit.contain),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: _buildCircleButton(
                  icon: Icons.close,
                  onTap: () => Navigator.pop(context),
                ),
              ),
              Positioned(
                top: 40,
                left: 20,
                child: _buildCircleButton(
                  icon: Icons.delete,
                  color: TechColors.errorRed,
                  onTap: () {
                    setState(() {
                      selectedImages.removeAt(index);
                    });
                    Navigator.pop(context);
                    Fluttertoast.showToast(
                      msg: 'تم حذف الصورة',
                      backgroundColor: TechColors.errorRed,
                      textColor: Colors.white,
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20.w),
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${index + 1} / ${selectedImages.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showHistoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
              ),
              child: Column(
                children: [
                  SizedBox(height: 12.h),
                  Container(
                    width: 50.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: BoxDecoration(
                      color: TechColors.surfaceLight,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            decoration: BoxDecoration(
                              gradient: TechColors.premiumGradient,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Text(
                              'تاريخ المعاملات',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              showTransactionsBottomSheet();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              child: Text(
                                'بيانات قيد التعامل',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color:
                                      TechColors.primaryDark.withOpacity(0.7),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Expanded(
                    child: widget.issue.customerSupport == null ||
                            widget.issue.customerSupport!.isEmpty
                        ? _buildEmptyState(
                            icon: Icons.history,
                            message: 'لا توجد سجلات دعم عملاء',
                          )
                        : ListView.builder(
                            controller: scrollController,
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            itemCount: widget.issue.customerSupport!.length,
                            itemBuilder: (context, index) {
                              final support = widget.issue.customerSupport![
                                  widget.issue.customerSupport!.length -
                                      1 -
                                      index];
                              return _buildHistoryCard(support);
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> support) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 243, 243, 243),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color.fromARGB(255, 180, 180, 180),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: TechColors.primaryDark.withOpacity(0.04),
            blurRadius: 5,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  support['problemAddress'] ?? 'غير محدد',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: TechColors.primaryDark,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: TechColors.accentCyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.support_agent,
                    color: TechColors.accentCyan, size: 20),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            support['details'] ?? 'لا توجد تفاصيل',
            style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(Icons.person, size: 14.r, color: Colors.grey),
              SizedBox(width: 4.w),
              Text(
                support['engName'] ?? 'غير محدد',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
              const Spacer(),
              Icon(Icons.access_time, size: 14.r, color: Colors.grey),
              SizedBox(width: 4.w),
              Text(
                _formatDate(support['dateTime']),
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void showTransactionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
              ),
              child: Column(
                children: [
                  SizedBox(height: 12.h),
                  Container(
                    width: 50.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: BoxDecoration(
                      color: TechColors.surfaceLight,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              showHistoryBottomSheet();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              child: Text(
                                'تاريخ المعاملات',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color:
                                      TechColors.primaryDark.withOpacity(0.7),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            decoration: BoxDecoration(
                              gradient: TechColors.premiumGradient,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Text(
                              'بيانات قيد التعامل',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Expanded(
                    child: widget.issue.underTransactions == null ||
                            widget.issue.underTransactions!.isEmpty
                        ? _buildEmptyState(
                            icon: Icons.pending_actions,
                            message: 'لا توجد معاملات جارية',
                          )
                        : ListView.builder(
                            controller: scrollController,
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            itemCount: widget.issue.underTransactions!.length,
                            itemBuilder: (context, index) {
                              final transaction =
                                  widget.issue.underTransactions![
                                      widget.issue.underTransactions!.length -
                                          1 -
                                          index];
                              return _buildTransactionCard(transaction);
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 243, 243, 243),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color.fromARGB(255, 214, 213, 213),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: TechColors.primaryDark.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  transaction['note'] ?? 'غير محدد',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: TechColors.primaryDark,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _showEditTransactionDialog(
                    transaction['id'],
                    transaction['note'] ?? '',
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: TechColors.accentCyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit,
                      color: TechColors.accentCyan, size: 18),
                ),
              ),
            ],
          ),
          if (transaction['dateTime'] != null) ...[
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.access_time, size: 14.r, color: Colors.grey),
                SizedBox(width: 4.w),
                Text(
                  _formatDate(transaction['dateTime']),
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showEditTransactionDialog(String? id, String currentNote) {
    if (id == null) return;

    final TextEditingController editCtl =
        TextEditingController(text: currentNote);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
          child: Container(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: TechColors.accentCyan.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.edit_note,
                      color: TechColors.accentCyan, size: 32.r),
                ),
                SizedBox(height: 16.h),
                Text(
                  'تعديل البيانات',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: TechColors.primaryDark,
                  ),
                ),
                SizedBox(height: 20.h),
                Container(
                  decoration: BoxDecoration(
                    color: TechColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    controller: editCtl,
                    maxLines: 4,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: 'اكتب التعديل هنا...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16.r),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        child: const Text('إلغاء'),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: TechColors.premiumGradient,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            final newNote = editCtl.text.trim();
                            if (newNote.isEmpty) return;

                            Navigator.pop(context);
                            setState(() => isLoading = true);

                            final cubit = context.read<CustomerCubit>();
                            await cubit.updateUnderTransaction(id, newNote);

                            if (mounted) {
                              if (cubit.state.status ==
                                  CustomerStatus.success) {
                                Fluttertoast.showToast(
                                  msg: '✓ تم التحديث بنجاح',
                                  backgroundColor: TechColors.successGreen,
                                );
                                await _refreshAndReenter();
                              } else {
                                Fluttertoast.showToast(
                                  msg:
                                      cubit.state.errorMessage ?? 'فشل التحديث',
                                  backgroundColor: TechColors.errorRed,
                                );
                                setState(() => isLoading = false);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: const Text('تحديث',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(dynamic dateString) {
    if (dateString == null) return 'غير محدد';
    try {
      final date = DateTime.parse(dateString.toString());
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString.toString();
    }
  }

  Future<void> toggleArchiveStatus() async {
    if (widget.issue.customerSupportId == null) {
      Fluttertoast.showToast(
        msg: 'رقم المشكلة غير متوفر',
        backgroundColor: TechColors.errorRed,
        textColor: Colors.white,
      );
      return;
    }

    final cubit = context.read<CustomerCubit>();
    final newArchiveStatus = !(widget.issue.isArchive ?? false);

    await cubit.isArchiveProblem(
      problemId: widget.issue.customerSupportId!,
      isArchive: newArchiveStatus,
    );

    if (mounted) {
      if (cubit.state.status == CustomerStatus.success) {
        Fluttertoast.showToast(
          msg: newArchiveStatus
              ? 'تم أرشفة المشكلة بنجاح'
              : 'تم إلغاء الأرشفة بنجاح',
          backgroundColor: TechColors.successGreen,
          textColor: Colors.white,
        );
        await cubit.refreshAllData();
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else if (cubit.state.status == CustomerStatus.failure) {
        Fluttertoast.showToast(
          msg: cubit.state.errorMessage ?? 'فشل تغيير حالة الأرشفة',
          backgroundColor: TechColors.errorRed,
          textColor: Colors.white,
        );
      }
    }
  }

  Future<void> saveChanges() async {
    if (isLoading) return;

    if (widget.issue.customerSupportId == null) {
      Fluttertoast.showToast(
        msg: 'خطأ: معرف المشكلة غير موجود',
        backgroundColor: TechColors.errorRed,
        textColor: Colors.white,
      );
      return;
    }

    if (widget.issue.id == null) {
      Fluttertoast.showToast(
        msg: 'خطأ: معرف العميل غير موجود',
        backgroundColor: TechColors.errorRed,
        textColor: Colors.white,
      );
      return;
    }

    if (selectedSpecialty == null) {
      Fluttertoast.showToast(
        msg: 'يرجى اختيار حالة المشكلة أولاً',
        backgroundColor: TechColors.warningOrange,
        textColor: Colors.white,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final cubit = context.read<CustomerCubit>();

      await cubit.createUnderTransaction(
        customerSupportId: widget.issue.customerSupportId!,
        customerId: widget.issue.id!,
        note: solutionCtl.text.trim().isEmpty
            ? 'تم تحديث حالة المشكلة'
            : solutionCtl.text.trim(),
        problemStatusId: selectedSpecialty!.id,
        images: selectedImages.isNotEmpty ? selectedImages : null,
      );

      if (!mounted) return;

      if (cubit.state.status == CustomerStatus.success) {
        Fluttertoast.showToast(
          msg: '✓ تم حفظ التغييرات بنجاح',
          backgroundColor: TechColors.successGreen,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT,
        );

        setState(() => isLoading = false);

        if (selectedSpecialty!.id == 15) {
          await _showArchiveDialogThenExit();
        } else {
          await _refreshAndReenter();
        }
      } else if (cubit.state.status == CustomerStatus.failure) {
        Fluttertoast.showToast(
          msg: cubit.state.errorMessage ?? 'حدث خطأ أثناء الحفظ',
          backgroundColor: TechColors.errorRed,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );
        setState(() => isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'خطأ: ${e.toString()}',
          backgroundColor: TechColors.errorRed,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _showArchiveDialogThenExit() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
          child: Container(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        TechColors.warningOrange,
                        TechColors.warningOrange.withOpacity(0.8)
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.archive_outlined,
                      color: Colors.white, size: 36),
                ),
                SizedBox(height: 20.h),
                Text(
                  'أرشفة المشكلة',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: TechColors.primaryDark,
                  ),
                ),
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: TechColors.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: TechColors.successGreen, size: 24.r),
                      SizedBox(width: 12.w),
                      Text(
                        'تم حل المشكلة بنجاح',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: TechColors.successGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'هل تريد نقل المشكلة إلى الأرشيف الآن؟',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'يمكنك أرشفتها لاحقاً من القائمة الرئيسية',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        child: const Text('لاحقاً'),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              TechColors.warningOrange,
                              TechColors.warningOrange.withOpacity(0.8)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: [
                            BoxShadow(
                              color: TechColors.warningOrange.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).pop(true),
                          icon: const Icon(Icons.archive, color: Colors.white),
                          label: const Text('أرشفة الآن',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
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
        );
      },
    );

    if (!mounted) return;

    if (result == true) {
      await _performArchiveThenExit();
    } else {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _refreshAndReenter() async {
    if (widget.issue.customerSupportId == null) return;

    final cubit = context.read<CustomerCubit>();
    await cubit.fetchProblemDetailsById(widget.issue.customerSupportId!);

    if (mounted) {
      if (cubit.state.status == CustomerStatus.success &&
          cubit.state.selectedProblem != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProblemDetailsScreen(issue: cubit.state.selectedProblem!),
          ),
        );
      } else {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _performArchiveThenExit() async {
    if (widget.issue.customerSupportId == null) {
      Fluttertoast.showToast(
        msg: 'خطأ: معرف المشكلة غير موجود',
        backgroundColor: TechColors.errorRed,
        textColor: Colors.white,
      );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(24.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(TechColors.accentCyan),
          ),
        ),
      ),
    );

    final cubit = context.read<CustomerCubit>();

    await cubit.isArchiveProblem(
      problemId: widget.issue.customerSupportId!,
      isArchive: true,
    );

    if (!mounted) return;

    Navigator.of(context).pop();

    if (cubit.state.status == CustomerStatus.success) {
      Fluttertoast.showToast(
        msg: '✓ تم أرشفة المشكلة بنجاح',
        backgroundColor: TechColors.successGreen,
        textColor: Colors.white,
      );
      Navigator.of(context).pop(true);
    } else {
      Fluttertoast.showToast(
        msg: cubit.state.errorMessage ?? 'فشل في الأرشفة',
        backgroundColor: TechColors.errorRed,
        textColor: Colors.white,
      );
      Navigator.of(context).pop(true);
    }
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: color == Colors.white
              ? Colors.white.withOpacity(0.2)
              : color.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 24.r),
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48.r, color: Colors.grey[300]),
          SizedBox(height: 12.h),
          Text(
            message,
            style: TextStyle(fontSize: 16.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: TechColors.surfaceLight,
        body: Stack(
          children: [
            // Premium Gradient Header
            Container(
              height: 180.h,
              decoration: const BoxDecoration(
                gradient: TechColors.premiumGradient,
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  // Custom AppBar
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    child: Row(
                      children: [
                        _buildCircleButton(
                          icon: Icons.arrow_back_ios_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Center(
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Text(
                                'تفاصيل المشكلة',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                        _buildCircleButton(
                          icon: Icons.history,
                          onTap: showHistoryBottomSheet,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Main Content
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: TechColors.surfaceLight,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32.r),
                          topRight: Radius.circular(32.r),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: TechColors.primaryDark.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: SmartRefresher(
                              controller: _refreshController,
                              enablePullDown: true,
                              enablePullUp: false,
                              header: WaterDropHeader(
                                waterDropColor: TechColors.accentCyan,
                                complete: Icon(Icons.check,
                                    color: TechColors.accentCyan, size: 20.r),
                              ),
                              onRefresh: _onRefresh,
                              child: SingleChildScrollView(
                                padding: EdgeInsets.all(20.r),
                                physics: const BouncingScrollPhysics(),
                                child: FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // Add Task Button
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AddTechTaskScreen(
                                                  customerName: nameCtl.text,
                                                  customerId: widget.issue.id,
                                                  problemId: widget
                                                      .issue.customerSupportId,
                                                  problemStatusId: widget
                                                      .issue.problemStatusId
                                                      ?.toString(),
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16.w,
                                                vertical: 10.h),
                                            decoration: BoxDecoration(
                                              color: TechColors.accentCyan
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(20.r),
                                              border: Border.all(
                                                  color: TechColors.accentCyan
                                                      .withOpacity(0.3)),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.add_task,
                                                    size: 18.r,
                                                    color:
                                                        TechColors.accentCyan),
                                                SizedBox(width: 8.w),
                                                Text(
                                                  'إضافة مهمة',
                                                  style: TextStyle(
                                                    color:
                                                        TechColors.accentCyan,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14.sp,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 20.h),

                                      // Form Fields
                                      _buildField(
                                          label: 'اسم العميل',
                                          controller: nameCtl,
                                          enabled: false),
                                      _buildField(
                                          label: 'رقم التواصل',
                                          controller: contactCtl,
                                          enabled: false),
                                      _buildField(
                                          label: 'التخصص',
                                          controller: specialtyCtl,
                                          enabled: false),

                                      // Status Dropdown
                                      BlocBuilder<CustomerCubit, CustomerState>(
                                        builder: (context, state) {
                                          if (state.problemStatusList.isEmpty) {
                                            return _buildFieldContainer(
                                              label: 'حالة المشكلة',
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 16.w,
                                                    vertical: 16.h),
                                                child: Text('جاري التحميل...',
                                                    style: TextStyle(
                                                        color: Colors.white
                                                            .withOpacity(0.7))),
                                              ),
                                            );
                                          }

                                          final allowedStatusIds = [12, 13, 15];
                                          final filteredStatuses = state
                                              .problemStatusList
                                              .where((s) =>
                                                  s.name.isNotEmpty &&
                                                  allowedStatusIds
                                                      .contains(s.id))
                                              .toList();

                                          if (filteredStatuses.isEmpty) {
                                            return _buildFieldContainer(
                                              label: 'حالة المشكلة',
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 16.w,
                                                    vertical: 16.h),
                                                child: Text(
                                                    'لا توجد حالات متاحة',
                                                    style: TextStyle(
                                                        color: Colors.white
                                                            .withOpacity(0.7))),
                                              ),
                                            );
                                          }

                                          if (selectedSpecialty == null) {
                                            if (widget.issue.problemStatusId !=
                                                null) {
                                              selectedSpecialty =
                                                  filteredStatuses.firstWhere(
                                                (s) =>
                                                    s.id ==
                                                    widget
                                                        .issue.problemStatusId,
                                                orElse: () =>
                                                    filteredStatuses.first,
                                              );
                                            } else {
                                              selectedSpecialty =
                                                  filteredStatuses.first;
                                            }
                                          }

                                          if (!filteredStatuses.any((s) =>
                                              s.id == selectedSpecialty!.id)) {
                                            selectedSpecialty =
                                                filteredStatuses.first;
                                          }

                                          return _buildFieldContainer(
                                            label: 'حالة المشكلة',
                                            child: PopupMenuButton<
                                                ProblemStatusModel>(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.r)),
                                              color: Colors.white,
                                              elevation: 8,
                                              onSelected: (status) => setState(
                                                  () => selectedSpecialty =
                                                      status),
                                              itemBuilder: (context) =>
                                                  filteredStatuses
                                                      .map((status) {
                                                return PopupMenuItem(
                                                  value: status,
                                                  child: Text(
                                                    status.name ?? 'غير محدد',
                                                    style: TextStyle(
                                                        fontSize: 14.sp,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                );
                                              }).toList(),
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 16.w,
                                                    vertical: 16.h),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      selectedSpecialty!.name ??
                                                          'غير محدد',
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16),
                                                    ),
                                                    const Icon(
                                                        Icons.arrow_drop_down,
                                                        color: Colors.white,
                                                        size: 28),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),

                                      _buildField(
                                          label: 'العنوان',
                                          controller: addressCtl,
                                          enabled: false),
                                      _buildField(
                                          label: 'عنوان المشكلة',
                                          controller: issueTitleCtl,
                                          enabled: false),
                                      _buildField(
                                          label: 'تفاصيل المشكلة',
                                          controller: issueDetailsCtl,
                                          enabled: false,
                                          maxLines: 3),
                                      _buildField(
                                        label: 'الحل المقترح',
                                        controller: solutionCtl,
                                        enabled: true,
                                        maxLines: 4,
                                        hintText: 'اكتب تفاصيل الحل هنا...',
                                      ),

                                      SizedBox(height: 20.h),

                                      // Upload Section
                                      _buildUploadSection(),

                                      SizedBox(height: 30.h),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Bottom Buttons
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20.w, vertical: 16.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      TechColors.primaryDark.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, -5),
                                ),
                              ],
                            ),
                            child: widget.issue.problemStatusId == 15
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: _buildActionButton(
                                          label: (widget.issue.isArchive ==
                                                      true ||
                                                  widget.issue
                                                          .statusIsArchieve ==
                                                      true)
                                              ? 'إلغاء الأرشفة'
                                              : 'أرشيف',
                                          color: TechColors.warningOrange,
                                          onTap: isLoading
                                              ? null
                                              : toggleArchiveStatus,
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: _buildActionButton(
                                          label: 'حفظ',
                                          isPrimary: true,
                                          onTap: isLoading ? null : saveChanges,
                                          isLoading: isLoading,
                                        ),
                                      ),
                                    ],
                                  )
                                : _buildActionButton(
                                    label: 'حفظ',
                                    isPrimary: true,
                                    onTap: isLoading ? null : saveChanges,
                                    isLoading: isLoading,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    bool enabled = false,
    int maxLines = 1,
    String? hintText,
  }) {
    return _buildFieldContainer(
      label: label,
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        enabled: enabled,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),
      ),
    );
  }

  Widget _buildFieldContainer({required String label, required Widget child}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: TechColors.primaryDark,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: TechColors.premiumGradient,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: TechColors.accentCyan.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    return Column(
      children: [
        // رفع ملفات
        SizedBox(height: 12.h),
        GestureDetector(
          onTap: pickImage,
          child: Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: TechColors.accentCyan.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                  color: TechColors.accentCyan.withOpacity(0.3),
                  width: 1.5,
                  style: BorderStyle.solid),
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.cloud_upload_outlined,
                        size: 48.r,
                        color: TechColors.accentCyan.withOpacity(0.7)),
                    if (selectedImages.isNotEmpty)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(4.r),
                          decoration: const BoxDecoration(
                            color: TechColors.successGreen,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.check,
                              color: Colors.white, size: 14.r),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  'اضغط لرفع الصور',
                  style: TextStyle(
                    color: TechColors.accentCyan,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (selectedImages.isNotEmpty) ...[
          SizedBox(height: 16.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: selectedImages.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => showFullScreenImage(entry.value, entry.key),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14.r),
                      child: Image.file(entry.value,
                          width: 70.w, height: 70.h, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: -4,
                      right: -4,
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => selectedImages.removeAt(entry.key)),
                        child: Container(
                          padding: EdgeInsets.all(4.r),
                          decoration: const BoxDecoration(
                            color: TechColors.errorRed,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close,
                              color: Colors.white, size: 14.r),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    bool isPrimary = false,
    Color? color,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    final buttonColor = color ?? (isPrimary ? null : TechColors.accentCyan);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54.h,
        decoration: BoxDecoration(
          gradient: isPrimary ? TechColors.premiumGradient : null,
          color: isPrimary
              ? null
              : (onTap == null ? Colors.grey.shade400 : buttonColor),
          borderRadius: BorderRadius.circular(27.r),
          boxShadow: onTap != null
              ? [
                  BoxShadow(
                    color: (isPrimary ? TechColors.accentCyan : buttonColor!)
                        .withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: isLoading
            ? SizedBox(
                height: 22.r,
                width: 22.r,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
