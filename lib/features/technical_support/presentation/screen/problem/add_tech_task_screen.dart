import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'package:tabib_soft_company/core/networking/dio_factory.dart';

import 'package:tabib_soft_company/features/technical_support/data/model/customization/add_customization_request_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customization/situation_status_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/repo/customization_repo.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customization/add_customization_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customization/add_customization_state.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/situation_status/situation_status_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/situation_status/situation_status_state.dart';

// If Report model is not public, I will define a local one or use the one from customization_task_model if applicable.
// Checking TaskDetailsDialog imports, it uses: import 'package:tabib_soft_company/features/programmers/data/model/customization_task_model.dart';
// Let's assume Report is inside it.

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

class _AddTechTaskScreenState extends State<AddTechTaskScreen> {
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _sortController =
      TextEditingController(text: '0');

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  // Selected situation status - now stores the full model with ID
  SituationStatusModel? _selectedStatus;

  final List<File> _selectedImages = [];
  // Using controllers to manage dynamic text fields for reports
  final List<TextEditingController> _reportControllers = [];

  @override
  void initState() {
    super.initState();
    _customerNameController.text = widget.customerName ?? '';
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _sortController.dispose();
    // Dispose all report controllers
    for (var controller in _reportControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
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
    const mainBlueColor = Color(0xFF16669E);
    const secondaryColor = Color(0xFF0B4C99);

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
              builder: (context) =>
                  const Center(child: CircularProgressIndicator()),
            );
          } else if (state is AddCustomizationSuccess) {
            Navigator.of(context).pop(); // Pop loading dialog
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم حفظ المهمة بنجاح')),
            );
            Navigator.of(context).pop(); // Pop screen
          } else if (state is AddCustomizationFailure) {
            Navigator.of(context).pop(); // Pop loading dialog
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('خطأ في الحفظ: ${state.errorMessage}')),
            );
          }
        },
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: const Color(0xFFF3F4F6),
            appBar: AppBar(
              title: const Text('إضافة تذكرة جديدة',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
              backgroundColor: mainBlueColor,
              elevation: 2,
              iconTheme: const IconThemeData(color: Colors.white),
              centerTitle: true,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(16))),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Main Form Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: mainBlueColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.note_add_outlined,
                                  color: mainBlueColor),
                            ),
                            const SizedBox(width: 12),
                            Text('بيانات التذكرة',
                                style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                          ],
                        ),
                        const Divider(height: 32),
                        _buildLabel('اسم العميل'),
                        TextField(
                          controller: _customerNameController,
                          readOnly: true,
                          decoration: _inputDecoration(
                              hint: 'اسم العميل',
                              prefixIcon: Icons.person_outline),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('تاريخ البدء'),
                                  _buildDatePickerField(
                                      context, _startDate, true),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('الموعد النهائي'),
                                  _buildDatePickerField(
                                      context, _endDate, false),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('الترتيب (Sort)'),
                                  TextField(
                                    controller: _sortController,
                                    keyboardType: TextInputType.number,
                                    decoration: _inputDecoration(
                                        prefixIcon: Icons.sort),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('الحالة'),
                                  BlocBuilder<SituationStatusCubit,
                                      SituationStatusState>(
                                    builder: (context, state) {
                                      if (state is SituationStatusLoading) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            border: Border.all(
                                                color: Colors.grey.shade300),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Center(
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2),
                                            ),
                                          ),
                                        );
                                      } else if (state
                                          is SituationStatusSuccess) {
                                        final statuses = state.statuses;
                                        return DropdownButtonFormField<
                                            SituationStatusModel>(
                                          isExpanded: true,
                                          initialValue: _selectedStatus,
                                          hint: const Text('اختر الحالة'),
                                          items: statuses
                                              .map((status) => DropdownMenuItem(
                                                    value: status,
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          width: 12,
                                                          height: 12,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: _parseColor(
                                                                status.color),
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        Text(
                                                          status.name,
                                                          style: TextStyle(
                                                            color: _parseColor(
                                                                status.color),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ))
                                              .toList(),
                                          onChanged: (v) => setState(
                                              () => _selectedStatus = v),
                                          decoration: _inputDecoration(),
                                        );
                                      } else if (state
                                          is SituationStatusFailure) {
                                        return Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade50,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                color: Colors.red.shade200),
                                          ),
                                          child: Text(
                                            'خطأ في تحميل الحالات',
                                            style: TextStyle(
                                                color: Colors.red.shade700),
                                          ),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Reports Section
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.assignment_outlined,
                                      color: Colors.orange),
                                ),
                                const SizedBox(width: 12),
                                Text('التقارير',
                                    style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87)),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: _addNewReportField,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('إضافة تقرير'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mainBlueColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Dynamic Reports List
                        if (_reportControllers.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(32.0),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.post_add_rounded,
                                    size: 48, color: Colors.grey.shade300),
                                const SizedBox(height: 8),
                                Text('اضغط على "إضافة تقرير" للبدء',
                                    style:
                                        TextStyle(color: Colors.grey.shade500)),
                              ],
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _reportControllers.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _reportControllers[index],
                                      maxLines: 5,
                                      decoration: InputDecoration(
                                        hintText: 'اكتب تفاصيل التقرير هنا...',
                                        hintStyle: TextStyle(
                                            color: Colors.grey.shade400),
                                        contentPadding:
                                            const EdgeInsets.all(16),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                        focusedBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(12)),
                                          borderSide: BorderSide(
                                              color: Color(0xFF16669E),
                                              width: 1.5),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: InkWell(
                                      onTap: () => _removeReportField(index),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.delete_outline,
                                            color: Colors.red, size: 24),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Attachments Section
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.attach_file,
                                  color: Colors.purple),
                            ),
                            const SizedBox(width: 12),
                            Text('المرفقات',
                                style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                builder: (context) {
                                  return Container(
                                    margin: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    child: Wrap(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Center(
                                              child: Container(
                                                  width: 40,
                                                  height: 4,
                                                  decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade300,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2)))),
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.camera_alt,
                                              color: mainBlueColor),
                                          title: const Text('التقاط صورة'),
                                          onTap: () {
                                            Navigator.pop(context);
                                            _pickImage(ImageSource.camera);
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(
                                              Icons.photo_library,
                                              color: mainBlueColor),
                                          title: const Text('اختيار من المعرض'),
                                          onTap: () {
                                            Navigator.pop(context);
                                            _pickImage(ImageSource.gallery);
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                    ),
                                  );
                                });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: mainBlueColor,
                                    width: 1,
                                    style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(12),
                                color: mainBlueColor.withOpacity(0.02)),
                            child: Column(
                              children: [
                                Icon(Icons.cloud_upload_outlined,
                                    size: 40,
                                    color: mainBlueColor.withOpacity(0.7)),
                                const SizedBox(height: 8),
                                const Text('اضغط هنا لرفع الملفات',
                                    style: TextStyle(
                                        color: mainBlueColor,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text('يمكنك اختيار صور من الكاميرا أو المعرض',
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                        if (_selectedImages.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: _selectedImages.map((file) {
                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    GestureDetector(
                                      onTap: () =>
                                          _showImagePreview(context, file),
                                      child: Hero(
                                        tag: 'image_${file.path}',
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.file(file,
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: -8,
                                      right: -8,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedImages.remove(file);
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.close,
                                              color: Colors.white, size: 14),
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey.shade700,
                              side: BorderSide(color: Colors.grey.shade400),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          child: const Text('إلغاء',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Builder(
                          builder: (context) {
                            return ElevatedButton.icon(
                              onPressed: () => _saveTask(context),
                              icon: const Icon(Icons.check, size: 20),
                              label: const Text('حفظ المهمة',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: secondaryColor,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  elevation: 4),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveTask(BuildContext context) async {
    // Basic Validation
    if (_customerNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اسم العميل مطلوب')),
      );
      return;
    }

    // Validate status selection
    if (_selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار الحالة')),
      );
      return;
    }

    // Reports Mapping
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

    // final userId = CacheHelper.getString(key: 'userId'); // Removed as per fix

    final request = AddCustomizationRequestModel(
      customerId: widget.customerId,
      customerName: widget.customerName,
      startDate: _startDate,
      deadLine: _endDate,
      sort: int.tryParse(_sortController.text) ?? 0,
      statusId: _selectedStatus!.id, // Uses selected status ID from dropdown
      customerSupportId: widget.problemId, // Uses passed Problem ID
      images: _selectedImages,
      reports: formattedReports,
    );

    context.read<AddCustomizationCubit>().addCustomization(request);
  }

  Widget _buildDatePickerField(
      BuildContext context, DateTime date, bool isStart) {
    return GestureDetector(
      onTap: () => _pickDate(context, isStart),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(intl.DateFormat('yyyy/MM/dd').format(date),
                style: const TextStyle(fontWeight: FontWeight.w500)),
            const Icon(Icons.calendar_month_rounded,
                size: 20, color: Color(0xFF16669E)),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint, IconData? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: Colors.grey.shade400)
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFF16669E), width: 1.5),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }

  /// Parses a hex color string (e.g., "#0000ff" or "ff8000") to a Color
  Color _parseColor(String colorString) {
    try {
      String hex = colorString.replaceAll('#', '').trim();
      if (hex.length == 6) {
        hex = 'FF$hex'; // Add full opacity if not present
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return Colors.grey; // Default fallback color
    }
  }

  /// Shows a full-screen preview of the selected image
  void _showImagePreview(BuildContext context, File imageFile) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            // Full screen image with zoom capability
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Hero(
                    tag: 'image_${imageFile.path}',
                    child: Image.file(
                      imageFile,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            // Close button
            Positioned(
              top: 40,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
            // Image name at the bottom
            Positioned(
              bottom: 40,
              left: 16,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  imageFile.path.split('/').last,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
