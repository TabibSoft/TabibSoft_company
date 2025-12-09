import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  late TextEditingController _globalNoteController;
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];
  List<String> _uploadedImageUrls = [];
  List<dynamic> _previousNotes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _globalNoteController = TextEditingController(text: widget.visit.globalNote ?? '');
    _refreshData(); // تحديث تلقائي عند الدخول
  }

  // دالة التحديث التلقائي
  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    try {
      await context.read<VisitCubit>().fetchVisits(); // جلب أحدث بيانات
      final updatedVisit = context
          .read<VisitCubit>()
          .state
          .visits
          .firstWhere((v) => v.id == widget.visit.id, orElse: () => widget.visit);

      setState(() {
        _globalNoteController.text = updatedVisit.globalNote ?? '';
        _uploadedImageUrls = List.from(updatedVisit.existingImages);
        _previousNotes = updatedVisit.previousNotes.reversed.toList();
      });
    } catch (e) {
      // إذا فشل التحديث، نستخدم البيانات القديمة
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // اختيار صورة من الكاميرا أو المعرض
  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (_) => Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 50.w, height: 5.h, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            SizedBox(height: 20.h),
            ListTile(
              leading: CircleAvatar(backgroundColor: Colors.blue[100], child: const Icon(Icons.camera_alt, color: Colors.blue)),
              title: const Text('الكاميرا', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: CircleAvatar(backgroundColor: Colors.blue[100], child: const Icon(Icons.photo_library, color: Colors.blue)),
              title: const Text('المعرض', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked != null) {
      setState(() {
        _selectedImages.add(File(picked.path));
      });
    }
  }

  // حذف صورة محلية
  void _removeLocalImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // عرض الصورة كاملة
  void _showFullScreenImage(String path, int index, List<String> allPaths) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: Hero(
                tag: 'img_$index',
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 5.0,
                  child: path.startsWith('http')
                      ? Image.network(path, fit: BoxFit.contain)
                      : Image.file(File(path), fit: BoxFit.contain),
                ),
              ),
            ),
            Positioned(top: 40.h, right: 20.w, child: _closeButton()),
            Positioned(
              bottom: 30.h,
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center,
                child: Text(
                  'صورة ${index + 1} من ${allPaths.length}',
                  style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _closeButton() => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: CircleAvatar(backgroundColor: Colors.black54, child: Icon(Icons.close, color: Colors.white, size: 28.r)),
      );

  // حفظ التفاصيل + تحديث تلقائي
  Future<void> _saveVisitDetail() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final cubit = context.read<VisitCubit>();
      final String visitId = widget.visit.id;

      final List<MultipartFile> imageFiles = [];
      for (var file in _selectedImages) {
        imageFiles.add(await MultipartFile.fromFile(file.path));
      }

      if (widget.visit.hasVisitDetails) {
        await cubit.editVisitDetail(
          visitInstallDetailId: visitId,
          note: _globalNoteController.text.trim().isEmpty ? "تم التحديث" : _globalNoteController.text.trim(),
          images: imageFiles.isNotEmpty ? imageFiles : null,
          existingImageUrls: widget.visit.existingImages,
        );
      } else {
        await cubit.addVisitDetail(
          visitInstallDetailId: visitId,
          note: _globalNoteController.text.trim().isEmpty ? "تم الزيارة" : _globalNoteController.text.trim(),
          images: imageFiles.isNotEmpty ? imageFiles : null,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم الحفظ بنجاح'), backgroundColor: Colors.green),
      );

      await _refreshData(); // تحديث تلقائي بعد الحفظ
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // إنهاء الزيارة + تحديث تلقائي
  Future<void> _markAsDone() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: const Text('تأكيد إنهاء الزيارة'),
        content: const Text('هل أنت متأكد من إتمام الزيارة؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('لا')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('نعم، تم'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      setState(() => _isLoading = true);
      await context.read<VisitCubit>().makeVisitDone(visitId: widget.visit.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إنهاء الزيارة بنجاح'), backgroundColor: Colors.green),
      );

      await _refreshData(); // تحديث تلقائي بعد "تم"
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // إضافة ملاحظة + تحديث تلقائي
  void _showAddNoteDialog() async {
    final ctrl = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: const Text('ملاحظة جديدة'),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'اكتب الملاحظة...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );

    if (result != true) return;
    final text = ctrl.text.trim();
    if (text.isEmpty) return;

    try {
      await context.read<VisitCubit>().addNote(visitInstallId: widget.visit.id, note: text);
      await _refreshData(); // تحديث تلقائي بعد إضافة ملاحظة
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  void dispose() {
    _globalNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allImages = [..._uploadedImageUrls, ..._selectedImages.map((f) => f.path)];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('تفاصيل الزيارة'),
        centerTitle: true,
        backgroundColor: const Color(0xFF16669E),
        foregroundColor: Colors.white,
        ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: ListView(
            children: [
              // الملاحظات السابقة (بدون اسم المرسل)
 // الملاحظات السابقة (مع إمكانية تحديد "مقروءة" بالضغط)
Card(
  child: Padding(
    padding: EdgeInsets.all(16.w),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.history, color: Color(0xFF16669E)),
            SizedBox(width: 8.w),
            Text('الملاحظات السابقة (${_previousNotes.length})',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
          ],
        ),
        const Divider(),
        _previousNotes.isEmpty
            ? Padding(
                padding: EdgeInsets.symmetric(vertical: 30.h),
                child: const Center(
                  child: Text('لا توجد ملاحظات', style: TextStyle(color: Colors.grey)),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _previousNotes.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (_, i) {
                  final n = _previousNotes[i];
                  final bool isRead = n['isRead'] == true;
                  final String id = n['id']?.toString() ?? '';

                  return Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: isRead ? Colors.grey[50] : Colors.blue[50],
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: isRead ? Colors.grey[300]! : Colors.blue[400]!,
                        width: 1.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // أيقونة الحالة + الضغط لتغييرها
                        GestureDetector(
                         onTap: id.isEmpty
    ? null
    : () async {
        if (isRead) return; // لو مقروءة بالفعل

        try {
          await context.read<VisitCubit>().makeNoteRead(noteId: id);

          // نحدث الحالة محليًا فورًا (حتى لو الـ API مش بيحدثها)
          setState(() {
            n['isRead'] = true;
          });

          // اختياري: نعمل refresh عشان نجيب باقي التغييرات
          // await _refreshData();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل التحديث'), backgroundColor: Colors.red),
          );
        }
      
                                  
                                },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: EdgeInsets.all(10.r),
                            decoration: BoxDecoration(
                              color: isRead ? Colors.green.withOpacity(0.15) : Colors.orange.withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isRead ? Colors.green : Colors.orange,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              isRead ? Icons.mark_email_read : Icons.mark_email_unread,
                              color: isRead ? Colors.green[700] : Colors.orange[700],
                              size: 26.r,
                            ),
                          ),
                        ),

                        SizedBox(width: 14.w),

                        // نص الملاحظة
                        Expanded(
                          child: Text(
                            n['note'] ?? '',
                            style: TextStyle(
                              fontSize: 15.5.sp,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          ),
                        ),

                        SizedBox(width: 10.w),

                        // زر الحذف
                        if (id.isNotEmpty)
                          GestureDetector(
                            onTap: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('حذف الملاحظة'),
                                  content: const Text('هل أنت متأكد من حذف هذه الملاحظة؟'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('لا')),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('نعم، احذف', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await context.read<VisitCubit>().deleteNote(noteId: id);
                                await _refreshData();
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.delete_outline, color: Colors.red[600], size: 22.r),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
      ],
    ),
  ),
),
              SizedBox(height: 16.h),

              // زر إضافة ملاحظة
              ElevatedButton.icon(
                onPressed: _showAddNoteDialog,
                icon: const Icon(Icons.add_circle),
                label: const Text('إضافة ملاحظة جديدة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BCD4),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
              ),

              SizedBox(height: 20.h),

              // ملاحظة عامة
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(children: [Icon(Icons.note_alt, color: Color(0xFF16669E)), SizedBox(width: 8), Text('ملاحظة عامة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
                      SizedBox(height: 12.h),
                      TextField(
                        controller: _globalNoteController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'اكتب الملاحظة العامة...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                          filled: true,
                          fillColor: Colors.blue[50],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // الصور
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('الصور (${allImages.length})', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                          TextButton.icon(onPressed: _pickImage, icon: const Icon(Icons.add_photo_alternate), label: const Text('إضافة صورة')),
                        ],
                      ),
                      const Divider(),
                      allImages.isEmpty
                          ? Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 30.h), child: const Text('لا توجد صور')))
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 12.w,
                                mainAxisSpacing: 12.h,
                              ),
                              itemCount: allImages.length,
                              itemBuilder: (_, i) {
                                final path = allImages[i];
                                final isNetwork = path.startsWith('http');
                                return GestureDetector(
                                  onTap: () => _showFullScreenImage(path, i, allImages),
                                  child: Stack(
                                    children: [
                                      Hero(
                                        tag: 'img_$i',
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12.r),
                                          child: isNetwork
                                              ? Image.network(path, width: double.infinity, height: double.infinity, fit: BoxFit.cover)
                                              : Image.file(File(path), fit: BoxFit.cover),
                                        ),
                                      ),
                                      if (!isNetwork)
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: GestureDetector(
                                            onTap: () => _removeLocalImage(i - _uploadedImageUrls.length),
                                            child: CircleAvatar(radius: 14.r, backgroundColor: Colors.red, child: const Icon(Icons.close, size: 18, color: Colors.white)),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 40.h),

              // الأزرار: تم + حفظ
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _markAsDone,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 18.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('تم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveVisitDetail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BCD4),
                        padding: EdgeInsets.symmetric(vertical: 18.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('حفظ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}
