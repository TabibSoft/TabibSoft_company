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
  bool _isLoading = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // جمع جميع الصور من visitInstallDetails
  List<String> _getAllImagesFromVisitDetails() {
    List<String> allImages = [];

    if (widget.visit.visitInstallDetails != null) {
      for (var detail in widget.visit.visitInstallDetails!) {
        if (detail is Map && detail.containsKey('images')) {
          final images = detail['images'];
          if (images is List) {
            for (var img in images) {
              if (img is String && img.isNotEmpty) {
                allImages.add(img);
              }
            }
          }
        }
      }
    }

    return allImages;
  }

  // عرض Bottom Sheet بالصور
  void _showImagesBottomSheet() {
    final images = _getAllImagesFromVisitDetails();

    if (images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("لا توجد صور متاحة"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'صور الزيارة',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF16669E),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16669E),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${images.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Grid of images
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return _buildNetworkImageThumbnail(
                      images[index], index, images);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // عرض صورة من الشبكة كـ thumbnail
  Widget _buildNetworkImageThumbnail(
      String imageUrl, int index, List<String> allImages) {
    return GestureDetector(
      onTap: () => _showFullScreenNetworkImage(imageUrl, index, allImages),
      child: Hero(
        tag: 'network_image_$index',
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    strokeWidth: 2,
                    color: const Color(0xFF16669E),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.broken_image,
                    color: Colors.grey,
                    size: 40,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // عرض الصورة بشكل كامل من الشبكة
  void _showFullScreenNetworkImage(
      String imageUrl, int currentIndex, List<String> allImages) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            // الصورة
            Center(
              child: Hero(
                tag: 'network_image_$currentIndex',
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: Colors.white,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                color: Colors.white, size: 60),
                            SizedBox(height: 10),
                            Text(
                              'فشل تحميل الصورة',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // زر الإغلاق
            Positioned(
              top: 40,
              right: 20,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            // عداد الصور
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'صورة ${currentIndex + 1} من ${allImages.length}',
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
      ),
    );
  }

  // اختيار صورة من الكاميرا أو المعرض
  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.camera_alt, color: Colors.blue),
              ),
              title: const Text('الكاميرا',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.photo_library, color: Colors.blue),
              ),
              title: const Text('المعرض',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 10),
          ],
        ),
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

  // عرض الصورة بشكل كامل مع إمكانية الحذف
  void _showFullScreenImage(File imageFile, int index) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.file(
                  imageFile,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            Positioned(
              top: 40,
              left: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white, size: 30),
                  onPressed: () {
                    setState(() {
                      _selectedImages.removeAt(index);
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم حذف الصورة'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'صورة ${index + 1} من ${_selectedImages.length}',
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
      ),
    );
  }

  // إرسال تفاصيل الزيارة مع التحقق من visitInstallDetails
  Future<void> _addVisitDetail() async {
    if (_noteController.text.trim().isEmpty && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("يرجى كتابة ملاحظة أو إرفاق صورة على الأقل")),
      );
      return;
    }

    String finalNote = _noteController.text.trim();
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
      setState(() => _isLoading = true);

      // التحقق من visitInstallDetails لاختيار الـ endpoint المناسب
      if (widget.visit.hasVisitDetails) {
        // استخدام EditVisitDetail
        await context.read<VisitCubit>().editVisitDetail(
              visitInstallDetailId: widget.visit.id,
              note: finalNote,
              images: imageFiles.isNotEmpty ? imageFiles : null,
            );
      } else {
        // استخدام AddVisitDetail
        await context.read<VisitCubit>().addVisitDetail(
              visitInstallDetailId: widget.visit.id,
              note: finalNote,
              images: imageFiles.isNotEmpty ? imageFiles : null,
            );
      }

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تم إضافة الإجراء بنجاح"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("فشل الإرسال: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // دالة تعيين الزيارة كـ "تم"
Future<void> _markVisitAsDone() async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text('تأكيد إتمام الزيارة'),
      content: const Text('هل أنت متأكد من أنك تريد تعليم هذه الزيارة كمنتهية؟'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('تأكيد', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );

  if (confirmed != true) return;

  try {
    setState(() => _isLoading = true);

    await context.read<VisitCubit>().makeVisitDone(visitId: widget.visit.id);

    if (mounted) {
      setState(() => _isLoading = false);
      
      // إظهار رسالة النجاح
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("تم تعليم الزيارة كمنتهية بنجاح"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      // الرجوع للشاشة السابقة مع إرجاع true لتحديث القائمة
      Navigator.pop(context, true);
    }
  } catch (e) {
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("فشل التحديث: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    const mainBlueColor = Color(0xFF16669E);
    const fieldBlueColor = Color(0xFF104D9D);
    const cyanButtonColor = Color(0xFF00BCD4);

    final imagesCount = _getAllImagesFromVisitDetails().length;

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
          actions: [
            // أيقونة عرض الصور
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.photo_library,
                      color: Colors.white, size: 28),
                  onPressed: _showImagesBottomSheet,
                  tooltip: 'عرض صور الزيارة',
                ),
                if (imagesCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        '$imagesCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
          ],
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
                            widget.visit.customerPhone ?? 'غير متوفر',
                            fieldBlueColor),
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
                            children:
                                _selectedImages.asMap().entries.map((entry) {
                              final index = entry.key;
                              final image = entry.value;
                              return GestureDetector(
                                onTap: () => _showFullScreenImage(image, index),
                                child: Stack(
                                  children: [
                                    Hero(
                                      tag: 'image_$index',
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          image,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: -8,
                                      right: -8,
                                      child: GestureDetector(
                                        onTap: () => _removeImage(image),
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const CircleAvatar(
                                            radius: 12,
                                            backgroundColor: Colors.red,
                                            child: Icon(Icons.close,
                                                color: Colors.white, size: 16),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                        const SizedBox(height: 40),

                        // أزرار الحفظ و "تم"
                        _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: cyanButtonColor,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 120,
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: _markVisitAsDone,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                      ),
                                      child: const Text("تم",
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
                                            borderRadius:
                                                BorderRadius.circular(30)),
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
}