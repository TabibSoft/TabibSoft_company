import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tabib_soft_company/features/technical_support/visits/data/models/visit_model.dart';
import 'package:tabib_soft_company/features/technical_support/visits/presentation/cubits/visit_cubit.dart';

class VisitDetailScreen extends StatefulWidget {
  final VisitModel visit;

  const VisitDetailScreen({super.key, required this.visit});

  @override
  State<VisitDetailScreen> createState() => _VisitDetailScreenState();
}

class _VisitDetailScreenState extends State<VisitDetailScreen> {
  final _noteController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];

  bool _printChecked = false;
  bool _iconChecked = false;
  bool _attendanceChecked = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // دالة اختيار صورة (كاميرا أو معرض)
  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.blue),
            title: const Text('الكاميرا'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library, color: Colors.blue),
            title: const Text('المعرض'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    );

    if (source == null) return;

    final pickedFile =
        await _picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    }
  }

  // دالة حذف صورة
  void _removeImage(File image) {
    setState(() {
      _selectedImages.remove(image);
    });
  }

  // دالة إرسال البيانات للـ API
  Future<void> _addVisitDetail() async {
    if (_noteController.text.trim().isEmpty && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("يرجى كتابة ملاحظة أو إرفاق صورة على الأقل")),
      );
      return;
    }

    List<String> actions = [];
    if (_printChecked) actions.add("طباعة");
    if (_iconChecked) actions.add("أيقون");
    if (_attendanceChecked) actions.add("الحضور");

    String finalNote = _noteController.text.trim();
    if (actions.isNotEmpty) {
      finalNote += "\n\nالإجراءات المنفذة: ${actions.join('، ')}";
    }

    var formData = FormData.fromMap({
      'VisitInstallDetailId': widget.visit.id,
      'Note': finalNote.isEmpty ? "تم الزيارة بدون ملاحظات" : finalNote,
    });

    for (var image in _selectedImages) {
      String fileName = image.path.split('/').last;
      formData.files.add(MapEntry(
        'Images',
        await MultipartFile.fromFile(image.path, filename: fileName),
      ));
    }

    try {
      await context.read<VisitCubit>().addVisitDetail(formData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تم إضافة الإجراء بنجاح"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("فشل الإرسال: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const mainBlueColor = Color(0xFF16669E);
    const fieldBlueColor = Color(0xFF104D9D);
    const cyanButtonColor = Color(0xFF00BCD4);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: mainBlueColor,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Icon(
                  Icons.monitor_heart_outlined,
                  size: 80,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildBlueFieldRow("اسم العميل:",
                            widget.visit.customerName, fieldBlueColor),
                        const SizedBox(height: 15),
                        _buildBlueFieldRow(
                            "رقم العميل:", "غير متوفر", fieldBlueColor),
                        const SizedBox(height: 15),
                        _buildBlueFieldRow(
                          "مهندس المبيعات:",
                          widget.visit.engineerName ?? "غير محدد",
                          fieldBlueColor,
                          isDropdown: true,
                        ),
                        const SizedBox(height: 15),
                        _buildBlueFieldRow(
                            "ملاحظات المبيعات:", "--", fieldBlueColor),
                        const SizedBox(height: 15),
                        _buildBlueFieldRow("السعر:", "--", fieldBlueColor),
                        const SizedBox(height: 15),

                        // حقل الملاحظات
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 100,
                              child: Text("ملاحظات:",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  color: fieldBlueColor,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: TextField(
                                  controller: _noteController,
                                  style: const TextStyle(color: Colors.white),
                                  maxLines: 4,
                                  textAlign: TextAlign.right,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(12),
                                    hintText: "اكتب ملاحظاتك هنا...",
                                    hintStyle: TextStyle(color: Colors.white70),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        // Checkboxes
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildCheckboxLabel("طباعة", _printChecked,
                                (v) => setState(() => _printChecked = v!)),
                            _buildCheckboxLabel("أيقون", _iconChecked,
                                (v) => setState(() => _iconChecked = v!)),
                            _buildCheckboxLabel("الحضور", _attendanceChecked,
                                (v) => setState(() => _attendanceChecked = v!)),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // رفع ملفات (بالطريقة الجميلة)
                        Column(
                          children: [
                            const Text("رفع ملفات",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: _pickImage,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset(
                                    "assets/images/pngs/upload_pic.png",
                                    width: 60,
                                    height: 60,
                                    errorBuilder: (_, __, ___) => const Icon(
                                        Icons.folder_open,
                                        size: 60,
                                        color: Colors.blue),
                                  ),
                                  if (_selectedImages.isNotEmpty)
                                    const Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: CircleAvatar(
                                        radius: 10,
                                        backgroundColor: Colors.white,
                                        child: Icon(Icons.check_circle,
                                            color: Colors.green, size: 20),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // عرض الصور المختارة
                        if (_selectedImages.isNotEmpty) ...[
                          const SizedBox(height: 15),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: _selectedImages.map((image) {
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      image,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: -8,
                                    right: -8,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(image),
                                      child: const CircleAvatar(
                                        radius: 12,
                                        backgroundColor: Colors.red,
                                        child: Icon(Icons.close,
                                            color: Colors.white, size: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ],

                        const SizedBox(height: 40),

                        // الأزرار
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 120,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text("سيتم تفعيل الأرشيف قريباً")),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: cyanButtonColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                ),
                                child: const Text("أرشيف",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                              ),
                            ),
                            const SizedBox(width: 20),
                            SizedBox(
                              width: 120,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _addVisitDetail,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: cyanButtonColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                ),
                                child: const Text("حفظ",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlueFieldRow(String label, String value, Color fieldColor,
      {bool isDropdown = false}) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
              textAlign: TextAlign.right),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
                color: fieldColor, borderRadius: BorderRadius.circular(10)),
            alignment: Alignment.centerRight,
            child: Row(
              children: [
                if (isDropdown)
                  const Icon(Icons.keyboard_arrow_down,
                      color: Colors.lightBlueAccent, size: 30),
                if (isDropdown) const SizedBox(width: 8),
                Expanded(
                  child: Text(value,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxLabel(
      String label, bool value, Function(bool?)? onChanged) {
    return Row(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            fillColor: WidgetStateProperty.resolveWith((states) =>
                states.contains(WidgetState.selected)
                    ? Colors.blue
                    : Colors.grey[300]),
            side: BorderSide.none,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
      ],
    );
  }
}
