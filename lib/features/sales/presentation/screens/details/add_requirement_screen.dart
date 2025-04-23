import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';

class AddRequirementPopup extends StatefulWidget {
  final String measurementId;
  final ApiService apiService;

  const AddRequirementPopup({
    super.key,
    required this.measurementId,
    required this.apiService,
  });

  @override
  _AddRequirementPopupState createState() => _AddRequirementPopupState();
}

class _AddRequirementPopupState extends State<AddRequirementPopup> {
  String? _selectedStatus;
  final List<String> _statuses = ['جارٍ الاتصال', 'مكتمل', 'ملغى'];
  final TextEditingController _notesController = TextEditingController();
  DateTime? _nextCallDate;
  TimeOfDay? _nextCallTime;
  final List<File> _images = [];
  bool _isLoading = false;
  int _currentTab = 0;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => _nextCallDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _nextCallTime = picked);
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _images.addAll(images.map((e) => File(e.path)));
      });
    }
  }

  Future<void> _submit() async {
    if (_selectedStatus == null ||
        _nextCallDate == null ||
        _nextCallTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final nowUtc = DateTime.now().toUtc();
      final id = const Uuid().v4();
      final data = {
        'id': id,
        'measurementId': widget.measurementId,
        'status': _selectedStatus,
        'notes': _notesController.text,
        'nextCallDate': _nextCallDate!.toUtc().toIso8601String(),
        'nextCallTime':
            '${_nextCallTime!.hour.toString().padLeft(2, '0')}:${_nextCallTime!.minute.toString().padLeft(2, '0')}:00',
        'createdDate': nowUtc.toIso8601String(),
        'model': 'default_model',
      };

      List<MultipartFile>? files;
      if (_images.isNotEmpty) {
        files = await Future.wait(
          _images.map((file) => MultipartFile.fromFile(file.path)),
        );
      }

      await widget.apiService.addRequirement(data, files);

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إضافة المتطلب بنجاح')),
      );
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في إضافة المتطلب: ${e.message}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.9;
    return WillPopScope(
      onWillPop: () async {
        // السماح بالإغلاق باستخدام زر العودة في الهاتف
        return true;
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF56C7F1), width: 2),
          ),
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          content: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: width,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 20.h),
                        // الحالة
                        Row(
                          children: [
                            const Text('الحالة:',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedStatus,
                                hint: const Text(''),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 20),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF56C7F1), width: 2),
                                  ),
                                ),
                                items: _statuses
                                    .map((s) => DropdownMenuItem(
                                        value: s, child: Text(s)))
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _selectedStatus = v),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // ملاحظات
                        TextField(
                          controller: _notesController,
                          maxLines: 3,
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            hintText: 'ملاحظات',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                  color: Color(0xFF56C7F1), width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // تاريخ المكالمه القادمة
                        GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                  color: const Color(0xFF56C7F1), width: 2),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    color: Color(0xFF56C7F1)),
                                const SizedBox(width: 8),
                                Text(
                                  _nextCallDate != null
                                      ? _nextCallDate!
                                          .toLocal()
                                          .toString()
                                          .split(' ')[0]
                                      : 'تاريخ المكالمة القادمة',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // وقت المكالمة القادمة
                        GestureDetector(
                          onTap: _pickTime,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                  color: const Color(0xFF56C7F1), width: 2),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time,
                                    color: Color(0xFF56C7F1)),
                                const SizedBox(width: 8),
                                Text(
                                  _nextCallTime != null
                                      ? _nextCallTime!.format(context)
                                      : 'وقت المكالمة القادمة',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // رفع الصور & تسجيل
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _pickImages,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                      color: const Color(0xFF56C7F1), width: 2),
                                ),
                                child: const Icon(Icons.folder,
                                    color: Color(0xFF56C7F1)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF56C7F1),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white))
                                    : const Text('تسجيل',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // شريط التبويب السفلي
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color(0xFF56C7F1), width: 2),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              _buildTab('التعليق', 0),
                              _buildTab('الوقت', 1),
                              _buildTab('التاريخ', 2),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -5,
                left: -2,
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.blue,
                    size: 32,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _currentTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF56C7F1) : Colors.transparent,
            borderRadius: BorderRadius.horizontal(
              left: index == 0 ? const Radius.circular(28) : Radius.zero,
              right: index == 2 ? const Radius.circular(28) : Radius.zero,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
