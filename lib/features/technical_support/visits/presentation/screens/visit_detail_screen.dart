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

  // Checkboxes للإجراءات المنفذة أثناء الزيارة (تُضاف للملاحظة تلقائيًا)
  final bool _printChecked = false; // تم طباعة الفاتورة أو الأوراق
  final bool _iconChecked = false; // تم تركيب الأيقونة أو اللوجو
  final bool _attendanceChecked = false; // تم تسجيل الحضور أو توقيع العميل

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // اختيار صورة من الكاميرا أو المعرض
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

  // حذف صورة مرفوعة
  void _removeImage(File image) {
    setState(() => _selectedImages.remove(image));
  }

  // إرسال تفاصيل الزيارة (Note + Images فقط + VisitInstallDetailId)
  Future<void> _addVisitDetail() async {
    if (_noteController.text.trim().isEmpty && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("يرجى كتابة ملاحظة أو إرفاق صورة على الأقل")),
      );
      return;
    }

    // جمع الإجراءات المختارة من الـ Checkboxes
    List<String> actions = [];
    if (_printChecked) actions.add("طباعة");
    if (_iconChecked) actions.add("أيقون");
    if (_attendanceChecked) actions.add("الحضور");

    String finalNote = _noteController.text.trim();
    if (actions.isNotEmpty) {
      finalNote += "\n\nالإجراءات المنفذة: ${actions.join('، ')}";
    }
    if (finalNote.isEmpty) {
      finalNote = "تم الزيارة بدون ملاحظات";
    }

    // تحويل الصور إلى MultipartFile
    List<MultipartFile> imageFiles = [];
    for (var image in _selectedImages) {
      final fileName = image.path.split('/').last;
      imageFiles
          .add(await MultipartFile.fromFile(image.path, filename: fileName));
    }

    try {
      await context.read<VisitCubit>().addVisitDetail(
            visitInstallDetailId: widget.visit.id,
            note: finalNote,
            images: imageFiles.isNotEmpty ? imageFiles : null,
          );

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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        backgroundColor: mainBlueColor,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'assets/images/pngs/TS_Logo0.png',
                  width: 110,
                  height: 110,
                  fit: BoxFit.contain,
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
                        // اسم العميل
                        _buildBlueFieldRow("اسم العميل:",
                            widget.visit.customerName, fieldBlueColor),
                        const SizedBox(height: 15),
                        _buildBlueFieldRow(
                            "رقم العميل:",
                            widget.visit.customerPhone ?? 'غير  متوفر',
                            fieldBlueColor),
                        const SizedBox(height: 15),
                        // _buildBlueFieldRow(
                        //     "ملاحظات المبيعات:", "--", fieldBlueColor),
                        // const SizedBox(height: 15),
                        // _buildBlueFieldRow("السعر:", "--", fieldBlueColor),
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

                        // Checkboxes للإجراءات المنفذة

                        const SizedBox(height: 20),

                        // رفع الصور
                        Column(
                          children: [
                            const Text("رفع صور",
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
                                    child: Image.file(image,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover),
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

                        // أزرار الحفظ والأرشيف
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

  // حقل أزرق عادي
  Widget _buildBlueFieldRow(String label, String value, Color fieldColor) {
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
            child: Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
    );
  }

  // Checkbox مع تسمية
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
