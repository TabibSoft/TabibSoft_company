import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'package:uuid/uuid.dart';

class AddRequirementPopup extends StatefulWidget {
  final String measurementId;
  final ApiService apiService;

  const AddRequirementPopup({
    super.key,
    required this.measurementId,
    required this.apiService,
  });

  @override
  State<AddRequirementPopup> createState() => _AddRequirementPopupState();
}

class _AddRequirementPopupState extends State<AddRequirementPopup> {
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _exepectedCommentController =
      TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime? _exepectedCallDate;
  TimeOfDay? _exepectedCallTimeFrom;
  TimeOfDay? _exepectedCallTimeTo;
  final List<File> _imageFiles = [];
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _exepectedCallDate) {
      setState(() {
        _exepectedCallDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isTimeFrom) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isTimeFrom) {
          _exepectedCallTimeFrom = picked;
        } else {
          _exepectedCallTimeTo = picked;
        }
      });
    }
  }

  Future<void> _showImageSourceDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('اختر مصدر الصورة'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _pickImageFromCamera();
                },
                child: const Text('الكاميرا'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _pickImagesFromGallery();
                },
                child: const Text('المعرض'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('إلغاء'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _imageFiles.add(File(image.path));
      });
    }
  }

  Future<void> _pickImagesFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    setState(() {
      _imageFiles.addAll(images.map((image) => File(image.path)).toList());
    });
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes:00';
  }

  Future<void> _submitRequirement() async {
    if (_exepectedCallDate == null ||
        _exepectedCallTimeFrom == null ||
        _exepectedCallTimeTo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now().toUtc();
      final data = {
        "id": const Uuid().v4(),
        "createdUser": null,
        "lastEditUser": null,
        "createdDate": now.toIso8601String(),
        "lastEditDate": now.toIso8601String(),
        "measurementId": widget.measurementId,
        "notes": _notesController.text,
        "exepectedCallDate": _exepectedCallDate!.toUtc().toIso8601String(),
        "exepectedCallTimeFrom": _formatTimeOfDay(_exepectedCallTimeFrom!),
        "exepectedCallTimeTo": _formatTimeOfDay(_exepectedCallTimeTo!),
        "date": null,
        "exepectedComment": _exepectedCommentController.text,
        "note": _noteController.text,
        "communicationId": null,
        "model": "default_model",
      };

      final imageFiles = _imageFiles.isNotEmpty
          ? await Future.wait(
              _imageFiles
                  .map((file) async => await MultipartFile.fromFile(file.path))
                  .toList(),
            )
          : null;

      await widget.apiService.addRequirement(data, imageFiles);

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إضافة المتطلب بنجاح')),
      );
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في إضافة المتطلب: ${e.message}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF56C7F1), width: 3),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        content: SizedBox(
          width: size.width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              _buildTextField(
                controller: _notesController,
                label: 'ملاحظات',
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: _buildTextField(
                    controller: TextEditingController(
                      text: _exepectedCallDate != null
                          ? _exepectedCallDate.toString().split(' ')[0]
                          : '',
                    ),
                    label: 'تاريخ الاتصال المتوقع',
                    suffixIcon: const Icon(Icons.calendar_today,
                        color: Color(0xFF56C7F1)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectTime(context, true),
                      child: AbsorbPointer(
                        child: _buildTextField(
                          controller: TextEditingController(
                            text: _exepectedCallTimeFrom != null
                                ? _exepectedCallTimeFrom!.format(context)
                                : '',
                          ),
                          label: 'بدايه المكالمة',
                          suffixIcon: const Icon(Icons.access_time,
                              color: Color(0xFF56C7F1)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectTime(context, false),
                      child: AbsorbPointer(
                        child: _buildTextField(
                          controller: TextEditingController(
                            text: _exepectedCallTimeTo != null
                                ? _exepectedCallTimeTo!.format(context)
                                : '',
                          ),
                          label: 'نهايه المكالمة',
                          suffixIcon: const Icon(Icons.access_time,
                              color: Color(0xFF56C7F1)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _exepectedCommentController,
                label: 'تعليق متوقع',
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _noteController,
                label: 'ملاحظة',
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _showImageSourceDialog, // استدعاء الدالة الجديدة
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0xFF56C7F1).withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.image, color: Color(0xFF56C7F1)),
                      const SizedBox(width: 8),
                      Text(
                        _imageFiles.isEmpty
                            ? 'رفع الصور'
                            : '${_imageFiles.length} صور مختارة',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildButton(
                    label: 'إلغاء',
                    onPressed: () => Navigator.of(context).pop(),
                    color: Colors.grey,
                  ),
                  _buildButton(
                    label: 'موافق',
                    onPressed: _submitRequirement,
                    color: const Color(0xFF56C7F1),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: const Color(0xFF56C7F1).withOpacity(0.5),
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: const Color(0xFF56C7F1).withOpacity(0.5),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return SizedBox(
      width: 120,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
