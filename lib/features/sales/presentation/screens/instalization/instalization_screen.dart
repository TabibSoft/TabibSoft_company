import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_app_bar_widget.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_nav_bar_widget.dart';
import 'package:tabib_soft_company/features/programmers/data/model/engineer_model.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/engineer_cubit.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/engineer_state.dart';
import 'package:tabib_soft_company/features/sales/data/model/measurement_done/measurement_done_model.dart';
import 'package:tabib_soft_company/features/sales/presentation/cubit/inistallation/installation_cubit.dart';
import 'package:tabib_soft_company/features/sales/presentation/cubit/inistallation/installation_state.dart';
import 'dart:io';

class InstalizationScreen extends StatefulWidget {
  final String measurementId;

  const InstalizationScreen({super.key, required this.measurementId});

  @override
  State<InstalizationScreen> createState() => _InstalizationScreenState();
}

class _InstalizationScreenState extends State<InstalizationScreen> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;
  EngineerModel? _selectedEngineer;
  bool _modificationRequested = false;
  File? _attachment;

  @override
  void initState() {
    super.initState();
    context.read<EngineerCubit>().fetchEngineers();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickAttachment() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _attachment = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const borderColor = Color(0xFF56C7F1);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: BlocListener<InstallationCubit, InstallationState>(
          listener: (context, state) {
            if (state.status == InstallationStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم الحفظ بنجاح')),
              );
              Navigator.of(context).pop();
            } else if (state.status == InstallationStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('فشل في الحفظ: ${state.errorMessage}')),
              );
            }
          },
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: CustomAppBar(
                  title: 'التسطيب',
                  height: 332,
                  leading: IconButton(
                    icon: Image.asset(
                      'assets/images/pngs/back.png',
                      width: 30,
                      height: 30,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              Positioned(
                top: size.height * 0.23,
                left: size.width * 0.05,
                right: size.width * 0.05,
                bottom: 0,
                child: SingleChildScrollView(
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: borderColor, width: 2),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // العنوان
                        TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            hintText: 'العنوان',
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 16.sp),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 14.h, horizontal: 20.w),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                  color: borderColor, width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                  color: borderColor, width: 2),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        // الموقع
                        TextField(
                          controller: _locationController,
                          decoration: InputDecoration(
                            hintText: 'الموقع',
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 16.sp),
                            prefixIcon: const Icon(Icons.location_on,
                                color: borderColor),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 14.h, horizontal: 20.w),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                  color: borderColor, width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                  color: borderColor, width: 2),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        // التاريخ
                        GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            height: 54.h,
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            decoration: BoxDecoration(
                              border: Border.all(color: borderColor, width: 2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    color: borderColor),
                                SizedBox(width: 12.w),
                                Text(
                                  _selectedDate != null
                                      ? '${_selectedDate!.toLocal()}'
                                          .split(' ')[0]
                                      : 'التاريخ',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 16.sp),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        // المهندس
                        BlocBuilder<EngineerCubit, EngineerState>(
                          builder: (context, state) {
                            final items = state.engineers;
                            return DropdownButtonFormField<EngineerModel>(
                              value: _selectedEngineer,
                              hint: Text('المهندس',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 16.sp)),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 14.h, horizontal: 20.w),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                      color: borderColor, width: 2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                      color: borderColor, width: 2),
                                ),
                              ),
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: Colors.grey),
                              menuMaxHeight: 220.h, // Set max height to half

                              items: items
                                  .map((eng) => DropdownMenuItem(
                                        value: eng,
                                        child: Text(eng.name),
                                      ))
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedEngineer = val),
                            );
                          },
                        ),
                        SizedBox(height: 16.h),
                        // ملاحظات
                        TextField(
                          controller: _notesController,
                          maxLines: 4,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: InputDecoration(
                            hintText: 'ملاحظات',
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 16.sp),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 14.h, horizontal: 20.w),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                  color: borderColor, width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                  color: borderColor, width: 2),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        // طلب تعديلات ورفع مرفق
                        Row(
                          children: [
                            Checkbox(
                              value: _modificationRequested,
                              onChanged: (v) => setState(
                                  () => _modificationRequested = v ?? false),
                              activeColor: borderColor,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.padded,
                            ),
                            SizedBox(width: 8.w),
                            Text('طالب تعديلات',
                                style: TextStyle(
                                    fontSize: 16.sp, color: Colors.grey)),
                            const Spacer(),
                            GestureDetector(
                              onTap: _pickAttachment,
                              child: Image.asset(
                                'assets/images/pngs/upload_pic.png',
                                width: 35.w,
                                height: 35.h,
                              ),
                            ),
                          ],
                        ),
                        if (_attachment != null) ...[
                          SizedBox(height: 8.h),
                          Text(
                            'تم اختيار مرفق: ${_attachment!.path.split('/').last}',
                            style:
                                TextStyle(fontSize: 14.sp, color: Colors.grey),
                          ),
                        ],
                        SizedBox(height: 24.h),
                        // زر الحفظ
                        Center(
                          child: SizedBox(
                            width: 150.w,
                            height: 48.h,
                            child: BlocBuilder<InstallationCubit,
                                InstallationState>(
                              builder: (context, state) {
                                return ElevatedButton(
                                  onPressed: state.status ==
                                          InstallationStatus.loading
                                      ? null
                                      : () {
                                          if (_titleController.text.isEmpty ||
                                              _locationController
                                                  .text.isEmpty ||
                                              _selectedDate == null ||
                                              _selectedEngineer == null) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'يرجى ملء جميع الحقول المطلوبة')),
                                            );
                                            return;
                                          }

                                          final dto = MeasurementDoneDto(
                                            id: widget.measurementId,
                                            adress: _titleController.text,
                                            location: _locationController.text,
                                            installingDate: _selectedDate!,
                                            realEngineerId:
                                                _selectedEngineer!.id,
                                            note: _notesController.text,
                                            hasCustomization:
                                                _modificationRequested,
                                            offerId: 'default_offer_id',
                                            total: 0.0,
                                            customerId: 'default_customer_id',
                                            createdAt: DateTime.now(),
                                            updatedAt: DateTime.now(),
                                            teacnicalSupportDate:
                                                DateTime.now(),
                                            image: _attachment?.path,
                                            installingNote: null,
                                            customerReview: null,
                                            endDate: null,
                                          );

                                          context
                                              .read<InstallationCubit>()
                                              .makeMeasurementDone(dto);
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: borderColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    padding: EdgeInsets.zero,
                                  ),
                                  child:
                                      state.status == InstallationStatus.loading
                                          ? const CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            )
                                          : Text(
                                              'حفظ',
                                              style: TextStyle(
                                                  fontSize: 18.sp,
                                                  color: Colors.white),
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
              ),
            ],
          ),
        ),
        bottomNavigationBar: const CustomNavBar(
          items: [],
          alignment: MainAxisAlignment.spaceBetween,
          padding: EdgeInsets.symmetric(horizontal: 32),
        ),
      ),
    );
  }
}
