import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'package:tabib_soft_company/core/networking/dio_factory.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';

import 'package:tabib_soft_company/features/technical_support/data/model/customization/add_customization_request_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customization/situation_status_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/repo/customization_repo.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customization/add_customization_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customization/add_customization_state.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/situation_status/situation_status_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/situation_status/situation_status_state.dart';

class AddTechTaskScreen extends StatefulWidget {
  final String? customerId;
  final String? customerName;
  final String? problemId;
  final String? problemStatusId;

  const AddTechTaskScreen({
    super.key,
    required this.customerId,
    required this.customerName,
    required this.problemId,
    required this.problemStatusId,
  });

  @override
  State<AddTechTaskScreen> createState() => _AddTechTaskScreenState();
}

class _AddTechTaskScreenState extends State<AddTechTaskScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _sortController =
      TextEditingController(text: '0');

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  SituationStatusModel? _selectedStatus;

  final List<File> _selectedImages = [];
  final List<TextEditingController> _reportControllers = [];

  @override
  void initState() {
    super.initState();
    _customerNameController.text = widget.customerName ?? '';

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _sortController.dispose();
    for (var controller in _reportControllers) {
      controller.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: TechColors.accentCyan,
              onPrimary: Colors.white,
              onSurface: TechColors.primaryDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    if (source == ImageSource.gallery) {
      final pickedFiles = await picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(pickedFiles.map((f) => File(f.path)));
        });
      }
    } else {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImages.add(File(pickedFile.path));
        });
      }
    }
  }

  void _addNewReportField() {
    setState(() {
      _reportControllers.add(TextEditingController());
    });
  }

  void _removeReportField(int index) {
    setState(() {
      _reportControllers[index].dispose();
      _reportControllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AddCustomizationCubit(
            CustomizationRepository(ApiService(DioFactory.getDio())),
          ),
        ),
        BlocProvider(
          create: (context) => SituationStatusCubit(
            ApiService(DioFactory.getDio()),
          )..getSituationStatuses(),
        ),
      ],
      child: BlocListener<AddCustomizationCubit, AddCustomizationState>(
        listener: (context, state) {
          if (state is AddCustomizationLoading) {
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
                    valueColor:
                        AlwaysStoppedAnimation<Color>(TechColors.accentCyan),
                  ),
                ),
              ),
            );
          } else if (state is AddCustomizationSuccess) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8.w),
                    const Text('تم حفظ المهمة بنجاح'),
                  ],
                ),
                backgroundColor: TechColors.successGreen,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
            Navigator.of(context).pop();
          } else if (state is AddCustomizationFailure) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('خطأ: ${state.errorMessage}'),
                backgroundColor: TechColors.errorRed,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        },
        child: Directionality(
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
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
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
                                    'إضافة تذكرة جديدة',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 40.w),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Form Body
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
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(20.r),
                            physics: const BouncingScrollPhysics(),
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Main Form Card
                                  _buildSectionCard(
                                    icon: Icons.assignment_outlined,
                                    iconColor: TechColors.accentCyan,
                                    title: 'بيانات التذكرة',
                                    children: [
                                      _buildLabel('اسم العميل'),
                                      _buildTextField(
                                        controller: _customerNameController,
                                        readOnly: true,
                                        prefixIcon: Icons.person_outline,
                                      ),
                                      SizedBox(height: 16.h),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _buildLabel('تاريخ البدء'),
                                                _buildDateField(
                                                    context, _startDate, true),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _buildLabel('الموعد النهائي'),
                                                _buildDateField(
                                                    context, _endDate, false),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16.h),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _buildLabel('الترتيب'),
                                                _buildTextField(
                                                  controller: _sortController,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  prefixIcon: Icons.sort,
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
                                                _buildLabel('الحالة'),
                                                _buildStatusDropdown(),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 20.h),

                                  // Reports Section
                                  _buildSectionCard(
                                    icon: Icons.description_outlined,
                                    iconColor: TechColors.warningOrange,
                                    title: 'التقارير',
                                    trailing: _buildAddButton(
                                        'إضافة تقرير', _addNewReportField),
                                    children: [
                                      if (_reportControllers.isEmpty)
                                        _buildEmptyState(
                                          icon: Icons.post_add_rounded,
                                          message:
                                              'اضغط على "إضافة تقرير" للبدء',
                                        )
                                      else
                                        ...List.generate(
                                            _reportControllers.length, (index) {
                                          return Padding(
                                            padding:
                                                EdgeInsets.only(bottom: 12.h),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: _buildTextField(
                                                    controller:
                                                        _reportControllers[
                                                            index],
                                                    maxLines: 4,
                                                    hint:
                                                        'اكتب تفاصيل التقرير...',
                                                  ),
                                                ),
                                                SizedBox(width: 8.w),
                                                Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 8.h),
                                                  child: _buildCircleButton(
                                                    icon: Icons.delete_outline,
                                                    color: TechColors.errorRed,
                                                    onTap: () =>
                                                        _removeReportField(
                                                            index),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                    ],
                                  ),

                                  SizedBox(height: 20.h),

                                  // Attachments Section
                                  _buildSectionCard(
                                    icon: Icons.attach_file_rounded,
                                    iconColor: TechColors.primaryMid,
                                    title: 'المرفقات',
                                    children: [
                                      _buildUploadArea(),
                                      if (_selectedImages.isNotEmpty) ...[
                                        SizedBox(height: 16.h),
                                        _buildImagePreviewGrid(),
                                      ],
                                    ],
                                  ),

                                  SizedBox(height: 28.h),

                                  // Action Buttons
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.grey[700],
                                            side: BorderSide(
                                                color: Colors.grey.shade400),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 14.h),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14.r),
                                            ),
                                          ),
                                          child: Text(
                                            'إلغاء',
                                            style: TextStyle(
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        flex: 2,
                                        child: Builder(
                                          builder: (context) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                gradient:
                                                    TechColors.premiumGradient,
                                                borderRadius:
                                                    BorderRadius.circular(14.r),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: TechColors.accentCyan
                                                        .withOpacity(0.3),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 6),
                                                  ),
                                                ],
                                              ),
                                              child: ElevatedButton.icon(
                                                onPressed: () =>
                                                    _saveTask(context),
                                                icon: const Icon(
                                                    Icons.check_rounded,
                                                    size: 20),
                                                label: Text(
                                                  'حفظ المهمة',
                                                  style: TextStyle(
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  foregroundColor: Colors.white,
                                                  shadowColor:
                                                      Colors.transparent,
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 14.h),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            14.r),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 24.h),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ========== HELPER WIDGETS ==========

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: color == Colors.white
              ? Colors.white.withOpacity(0.2)
              : color.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: color == Colors.white
                ? Colors.white.withOpacity(0.3)
                : color.withOpacity(0.3),
          ),
        ),
        child: Icon(icon, color: color, size: 20.r),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<Widget> children,
    Widget? trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: TechColors.primaryDark.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: iconColor, size: 22.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: TechColors.primaryDark,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          SizedBox(height: 16.h),
          Divider(color: Colors.grey.shade200, height: 1),
          SizedBox(height: 16.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: TechColors.primaryDark.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    bool readOnly = false,
    int maxLines = 1,
    String? hint,
    IconData? prefixIcon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: TechColors.surfaceLight,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: TechColors.primaryDark,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: TechColors.accentCyan, size: 20.r)
              : null,
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context, DateTime date, bool isStart) {
    return GestureDetector(
      onTap: () => _pickDate(context, isStart),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: TechColors.surfaceLight,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              intl.DateFormat('yyyy/MM/dd').format(date),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
                color: TechColors.primaryDark,
              ),
            ),
            Icon(Icons.calendar_today_rounded,
                size: 18.r, color: TechColors.accentCyan),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return BlocBuilder<SituationStatusCubit, SituationStatusState>(
      builder: (context, state) {
        if (state is SituationStatusLoading) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            decoration: BoxDecoration(
              color: TechColors.surfaceLight,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: TechColors.accentCyan),
              ),
            ),
          );
        } else if (state is SituationStatusSuccess) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: TechColors.surfaceLight,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: DropdownButtonFormField<SituationStatusModel>(
              isExpanded: true,
              initialValue: _selectedStatus,
              hint: Text('اختر الحالة',
                  style:
                      TextStyle(color: Colors.grey.shade500, fontSize: 14.sp)),
              items: state.statuses.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _parseColor(status.color),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        status.name,
                        style: TextStyle(
                          color: _parseColor(status.color),
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (v) => setState(() => _selectedStatus = v),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
            ),
          );
        } else if (state is SituationStatusFailure) {
          return Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: TechColors.errorRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: TechColors.errorRed.withOpacity(0.3)),
            ),
            child: Text(
              'خطأ في تحميل الحالات',
              style: TextStyle(color: TechColors.errorRed, fontSize: 12.sp),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAddButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: TechColors.accentCyan.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: TechColors.accentCyan.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 16.r, color: TechColors.accentCyan),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                color: TechColors.accentCyan,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(28.r),
      decoration: BoxDecoration(
        color: TechColors.surfaceLight,
        borderRadius: BorderRadius.circular(16.r),
        border:
            Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(icon, size: 42.r, color: Colors.grey.shade300),
          SizedBox(height: 8.h),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadArea() {
    return GestureDetector(
      onTap: _showImagePickerSheet,
      child: Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: TechColors.accentCyan.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
              color: TechColors.accentCyan.withOpacity(0.3),
              width: 1.5,
              style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            Icon(Icons.cloud_upload_outlined,
                size: 40.r, color: TechColors.accentCyan.withOpacity(0.7)),
            SizedBox(height: 8.h),
            Text(
              'اضغط هنا لرفع الملفات',
              style: TextStyle(
                color: TechColors.accentCyan,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'يمكنك اختيار صور من الكاميرا أو المعرض',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12.sp),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 16.h),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: TechColors.accentCyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    const Icon(Icons.camera_alt, color: TechColors.accentCyan),
              ),
              title: const Text('التقاط صورة',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
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
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreviewGrid() {
    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: _selectedImages.asMap().entries.map((entry) {
        final index = entry.key;
        final file = entry.value;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: () => _showImagePreview(context, file),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: Image.file(file,
                    width: 90.w, height: 90.h, fit: BoxFit.cover),
              ),
            ),
            Positioned(
              top: -6,
              right: -6,
              child: GestureDetector(
                onTap: () => setState(() => _selectedImages.removeAt(index)),
                child: Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: const BoxDecoration(
                    color: TechColors.errorRed,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: Colors.white, size: 14.r),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  void _showImagePreview(BuildContext context, File imageFile) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) => Dialog(
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
              top: 50,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTask(BuildContext context) async {
    if (_customerNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('اسم العميل مطلوب'),
          backgroundColor: TechColors.errorRed,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (_selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('يرجى اختيار الحالة'),
          backgroundColor: TechColors.warningOrange,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final List<Map<String, dynamic>> formattedReports = _reportControllers
        .where((c) => c.text.isNotEmpty)
        .map((c) => {
              'Note': c.text,
              'Name':
                  c.text.length > 20 ? '${c.text.substring(0, 20)}...' : c.text,
              'Time': 0,
              'Finshed': false,
              'IsTested': false,
            })
        .toList();

    final request = AddCustomizationRequestModel(
      customerId: widget.customerId,
      customerName: widget.customerName,
      startDate: _startDate,
      deadLine: _endDate,
      sort: int.tryParse(_sortController.text) ?? 0,
      statusId: _selectedStatus!.id,
      customerSupportId: widget.problemId,
      images: _selectedImages,
      reports: formattedReports,
    );

    context.read<AddCustomizationCubit>().addCustomization(request);
  }

  Color _parseColor(String colorString) {
    try {
      String hex = colorString.replaceAll('#', '').trim();
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return TechColors.accentCyan;
    }
  }
}
