import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_app_bar_widget.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_nav_bar_widget.dart';
import 'package:tabib_soft_company/features/programmers/data/model/engineer_model.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/engineer_cubit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/engineer_state.dart';

class InstalizationScreen extends StatefulWidget {
  const InstalizationScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const borderColor = Color(0xFF56C7F1);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: CustomAppBar(
                title: 'الإعدادات',
                height: 332,
              ),
            ),
            // Replace leading's onPressed

            // The white form card
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
                            borderSide:
                                const BorderSide(color: borderColor, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide:
                                const BorderSide(color: borderColor, width: 2),
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
                          prefixIcon:
                              const Icon(Icons.location_on, color: borderColor),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 14.h, horizontal: 20.w),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide:
                                const BorderSide(color: borderColor, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide:
                                const BorderSide(color: borderColor, width: 2),
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
                            borderSide:
                                const BorderSide(color: borderColor, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide:
                                const BorderSide(color: borderColor, width: 2),
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
                            materialTapTargetSize: MaterialTapTargetSize.padded,
                          ),
                          SizedBox(width: 8.w),
                          Text('طالب تعديلات',
                              style: TextStyle(
                                  fontSize: 16.sp, color: Colors.grey)),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              // TODO: implement attachment picker
                            },
                            child: Image.asset(
                              'assets/images/pngs/upload_pic.png',
                              width: 35.w,
                              height: 35.h,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24.h),

                      // زر الحفظ
                      Center(
                        child: SizedBox(
                          width: 150.w,
                          height: 48.h,
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: implement save action
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: borderColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              padding: EdgeInsets.zero,
                            ),
                            child: Text(
                              'حفظ',
                              style: TextStyle(
                                  fontSize: 18.sp, color: Colors.white),
                            ),
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
        bottomNavigationBar: const CustomNavBar(
          items: [],
          alignment: MainAxisAlignment.spaceBetween,
          padding: EdgeInsets.symmetric(horizontal: 32),
        ),
      ),
    );
  }
}
