import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' as intl;

import 'package:tabib_soft_company/features/programmers/data/model/customization_task_model.dart'; // For Report model if available or define local

// If Report model is not public, I will define a local one or use the one from customization_task_model if applicable.
// Checking TaskDetailsDialog imports, it uses: import 'package:tabib_soft_company/features/programmers/data/model/customization_task_model.dart';
// Let's assume Report is inside it.

class AddTechTaskScreen extends StatefulWidget {
  final String customerName;
  final String? customerId;

  const AddTechTaskScreen({
    super.key,
    required this.customerName,
    this.customerId,
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

  String _status = 'task';

  final List<File> _selectedImages = [];
  final List<Report> _reports =
      []; // Using Report from customization_task_model
  final List<bool> _reportsChecked = [];

  @override
  void initState() {
    super.initState();
    _customerNameController.text = widget.customerName;
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _sortController.dispose();
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

  void _showAddReportDialog() {
    final nameCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    TimeOfDay? selectedTime;
    const primaryBlue = Color(0xff16669E);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: EdgeInsets.all(20.r),
            decoration: const BoxDecoration(
              color: primaryBlue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.add_task_rounded, color: Colors.white),
                SizedBox(width: 12.w),
                const Text(
                  'إضافة تقرير جديد',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'اسم التقرير',
                  prefixIcon: const Icon(Icons.title_rounded, size: 22),
                  hintText: 'مثلاً: تحسين واجهة المستخدم',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'الملاحظات',
                  prefixIcon: const Icon(Icons.note_alt_rounded, size: 22),
                  hintText: 'تفاصيل إضافية حول التقرير...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: primaryBlue,
                          ),
                        ),
                        child: MediaQuery(
                          data: MediaQuery.of(context)
                              .copyWith(alwaysUse24HourFormat: false),
                          child: child!,
                        ),
                      );
                    },
                  );
                  if (picked != null) {
                    setDialogState(() {
                      selectedTime = picked;
                    });
                  }
                },
                borderRadius: BorderRadius.circular(15.r),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(15.r),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_filled_rounded,
                          color: primaryBlue),
                      SizedBox(width: 12.w),
                      Text(
                        selectedTime == null
                            ? 'تحديد الوقت المناسب'
                            : selectedTime!.format(context),
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              selectedTime == null ? Colors.grey : Colors.black,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء',
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                final note = noteCtrl.text.trim();

                if (name.isEmpty || selectedTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('يرجى إكمال جميع الحقول الضرورية')),
                  );
                  return;
                }

                final timeInMinutes =
                    selectedTime!.hour * 60 + selectedTime!.minute;

                setState(() {
                  _reports.add(Report(
                    id: null,
                    name: name,
                    notes: note,
                    finished: false,
                    time: timeInMinutes,
                  ));
                  _reportsChecked.add(false);
                });

                Navigator.of(ctx).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
              child: const Text('إضافة التقرير',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const mainBlueColor = Color(0xFF16669E);
    const secondaryColor = Color(0xFF0B4C99);

    return Directionality(
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
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16))),
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
                          hint: 'اسم العميل', prefixIcon: Icons.person_outline),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('تاريخ البدء'),
                              _buildDatePickerField(context, _startDate, true),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('الموعد النهائي'),
                              _buildDatePickerField(context, _endDate, false),
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
                                decoration:
                                    _inputDecoration(prefixIcon: Icons.sort),
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
                              DropdownButtonFormField<String>(
                                isExpanded: true,
                                initialValue: _status,
                                items: ['task', 'urgent']
                                    .map((e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(
                                          e == 'task' ? ' Task' : 'Urgent',
                                          style: TextStyle(
                                              color: e == 'urgent'
                                                  ? Colors.red
                                                  : Colors.black),
                                        )))
                                    .toList(),
                                onChanged: (v) => setState(() => _status = v!),
                                decoration: _inputDecoration(
                                    prefixIcon: Icons.flag_outlined),
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
                          onPressed: _showAddReportDialog,
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
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        children: [
                          if (_reports.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                children: [
                                  Icon(Icons.description_outlined,
                                      size: 48, color: Colors.grey.shade300),
                                  const SizedBox(height: 8),
                                  Text('لا توجد تقارير مضافة بعد',
                                      style: TextStyle(
                                          color: Colors.grey.shade500)),
                                ],
                              ),
                            )
                          else
                            ..._reports.asMap().entries.map((entry) {
                              return Column(
                                children: [
                                  ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          mainBlueColor.withOpacity(0.1),
                                      child: Text((entry.key + 1).toString(),
                                          style: const TextStyle(
                                              color: mainBlueColor,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    title: Text(entry.value.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                    subtitle: Text(entry.value.notes,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.red),
                                      onPressed: () => setState(() {
                                        _reports.removeAt(entry.key);
                                        _reportsChecked.removeAt(entry.key);
                                      }),
                                    ),
                                  ),
                                  if (entry.key != _reports.length - 1)
                                    const Divider(
                                        height: 1, indent: 16, endIndent: 16),
                                ],
                              );
                            })
                        ],
                      ),
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
                                    borderRadius: BorderRadius.circular(16)),
                                child: Wrap(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Center(
                                          child: Container(
                                              width: 40,
                                              height: 4,
                                              decoration: BoxDecoration(
                                                  color: Colors.grey.shade300,
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
                                      leading: const Icon(Icons.photo_library,
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
                                    color: Colors.grey.shade600, fontSize: 12)),
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
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(file,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover),
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
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم الحفظ (محاكاة)')));
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check, size: 20),
                      label: const Text('حفظ المهمة',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 4),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
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
}
