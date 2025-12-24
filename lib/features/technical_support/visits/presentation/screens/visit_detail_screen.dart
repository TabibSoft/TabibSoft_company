import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tabib_soft_company/features/technical_support/visits/data/models/visit_model.dart';
import 'package:tabib_soft_company/features/technical_support/visits/presentation/cubits/visit_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/visits/presentation/widgets/full_screen_image_dialog.dart';
import 'package:tabib_soft_company/features/technical_support/visits/presentation/widgets/simple_note_card.dart';

class VisitDetailScreen extends StatefulWidget {
  final VisitModel visit;

  const VisitDetailScreen({super.key, required this.visit});

  @override
  State<VisitDetailScreen> createState() => _VisitDetailScreenState();
}

class _VisitDetailScreenState extends State<VisitDetailScreen> {
  late TextEditingController _globalNoteController;
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];
  List<String> _uploadedImageUrls = [];
  List<dynamic> _previousNotes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _globalNoteController =
        TextEditingController(text: widget.visit.globalNote ?? '');
    _refreshData(); // تحديث تلقائي عند الدخول
  }

  // دالة التحديث التلقائي
  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    try {
      await context.read<VisitCubit>().fetchVisits(); // جلب أحدث بيانات
      final updatedVisit = context.read<VisitCubit>().state.visits.firstWhere(
          (v) => v.id == widget.visit.id,
          orElse: () => widget.visit);

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
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (_) => Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 50.w,
                height: 5.h,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10))),
            SizedBox(height: 20.h),
            ListTile(
              leading: CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: const Icon(Icons.camera_alt, color: Colors.blue)),
              title: const Text('الكاميرا',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: const Icon(Icons.photo_library, color: Colors.blue)),
              title: const Text('المعرض',
                  style: TextStyle(fontWeight: FontWeight.bold)),
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
      builder: (_) => FullScreenImageDialog(
        imageUrl: path,
        currentIndex: index,
        totalCount: allPaths.length,
        tag: 'img_$index',
        isLocal: !path.startsWith('http'),
      ),
    );
  }

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
          note: _globalNoteController.text.trim().isEmpty
              ? "تم التحديث"
              : _globalNoteController.text.trim(),
          images: imageFiles.isNotEmpty ? imageFiles : null,
          existingImageUrls: widget.visit.existingImages,
        );
      } else {
        await cubit.addVisitDetail(
          visitInstallDetailId: visitId,
          note: _globalNoteController.text.trim().isEmpty
              ? "تم الزيارة"
              : _globalNoteController.text.trim(),
          images: imageFiles.isNotEmpty ? imageFiles : null,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('تم الحفظ بنجاح'), backgroundColor: Colors.green),
      );

      _selectedImages.clear(); // مسح الصور المحلية بعد الحفظ
      await _refreshData(); // تحديث تلقائي بعد الحفظ
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // إنهاء الزيارة + تحديث تلقائي
  Future<void> _markAsDone() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: const Text('تأكيد إنهاء الزيارة'),
        content: const Text('هل أنت متأكد من إتمام الزيارة؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('لا')),
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
        const SnackBar(
            content: Text('تم إنهاء الزيارة بنجاح'),
            backgroundColor: Colors.green),
      );

      await _refreshData(); // تحديث تلقائي بعد "تم"
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل: $e'), backgroundColor: Colors.red));
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: const Text('ملاحظة جديدة'),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'اكتب الملاحظة...',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء')),
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
      await context
          .read<VisitCubit>()
          .addNote(visitInstallId: widget.visit.id, note: text);
      await _refreshData(); // تحديث تلقائي بعد إضافة ملاحظة
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  void dispose() {
    _globalNoteController.dispose();
    super.dispose();
  }

  Widget _buildSectionHeader({required String title, required IconData icon}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, top: 4.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: const Color(0xFF16669E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: const Color(0xFF16669E), size: 22.r),
          ),
          SizedBox(width: 12.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
          ),
          const Spacer(),
          Container(
            width: 40.w,
            height: 2.h,
            decoration: BoxDecoration(
              color: const Color(0xFF16669E).withOpacity(0.3),
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final allImages = [
      ..._uploadedImageUrls,
      ..._selectedImages.map((f) => f.path)
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 120.h,
              pinned: true,
              stretch: true,
              backgroundColor: const Color(0xFF16669E),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'تفاصيل الزيارة',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                centerTitle: true,
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF16669E), Color(0xFF20AAC9)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.all(16.w),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // الملاحظات السابقة
                  _buildSectionHeader(
                    title: 'الملاحظات السابقة (${_previousNotes.length})',
                    icon: Icons.history,
                  ),
                  _buildCard(
                    child: _previousNotes.isEmpty
                        ? Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.h),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.notes_rounded,
                                      size: 40.r, color: Colors.grey[300]),
                                  SizedBox(height: 8.h),
                                  const Text('لا توجد ملاحظات سابقة',
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              ),
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

                              return SimpleNoteCard(
                                note: n,
                                onMarkAsRead: id.isEmpty
                                    ? null
                                    : () async {
                                        if (isRead) return;
                                        try {
                                          await context
                                              .read<VisitCubit>()
                                              .makeNoteRead(noteId: id);
                                          setState(() {
                                            n['isRead'] = true;
                                          });
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text('فشل التحديث'),
                                                backgroundColor: Colors.red),
                                          );
                                        }
                                      },
                                onDelete: id.isEmpty
                                    ? null
                                    : () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        20.r)),
                                            title: const Text('حذف الملاحظة'),
                                            content: const Text(
                                                'هل أنت متأكد من حذف هذه الملاحظة؟'),
                                            actions: [
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, false),
                                                  child: const Text('لا')),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.red),
                                                onPressed: () => Navigator.pop(
                                                    context, true),
                                                child: const Text('نعم، احذف'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          await context
                                              .read<VisitCubit>()
                                              .deleteNote(noteId: id);
                                          await _refreshData();
                                        }
                                      },
                              );
                            },
                          ),
                  ),

                  SizedBox(height: 16.h),

                  // زر إضافة ملاحظة
                  ElevatedButton.icon(
                    onPressed: _showAddNoteDialog,
                    icon: Icon(Icons.add_comment_rounded, size: 22.r),
                    label: Text(
                      'إضافة ملاحظة سريعة',
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF20AAC9),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.r)),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // ملاحظة عامة
                  _buildSectionHeader(
                    title: 'تقرير الزيارة',
                    icon: Icons.edit_note_rounded,
                  ),
                  _buildCard(
                    child: Column(
                      children: [
                        TextField(
                          controller: _globalNoteController,
                          maxLines: 4,
                          style: TextStyle(fontSize: 15.sp),
                          decoration: InputDecoration(
                            hintText: 'اكتب تفاصيل ما تم خلال الزيارة...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.r),
                              borderSide: BorderSide(color: Colors.grey[200]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.r),
                              borderSide: BorderSide(color: Colors.grey[100]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.r),
                              borderSide: const BorderSide(
                                  color: Color(0xFF16669E), width: 1.5),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF1F5F9),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // الصور
                  _buildSectionHeader(
                    title: 'المرفقات (${allImages.length})',
                    icon: Icons.collections_rounded,
                  ),
                  _buildCard(
                    child: Column(
                      children: [
                        if (allImages.isEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.h),
                            child: Column(
                              children: [
                                Icon(Icons.add_a_photo_outlined,
                                    size: 50.r, color: Colors.grey[300]),
                                SizedBox(height: 12.h),
                                Text(
                                  'لا توجد صور مرفقة',
                                  style: TextStyle(
                                      color: Colors.grey[400], fontSize: 14.sp),
                                ),
                              ],
                            ),
                          )
                        else
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10.w,
                              mainAxisSpacing: 10.h,
                            ),
                            itemCount: allImages.length,
                            itemBuilder: (_, i) {
                              final path = allImages[i];
                              final isNetwork = path.startsWith('http');
                              return GestureDetector(
                                onTap: () =>
                                    _showFullScreenImage(path, i, allImages),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Hero(
                                        tag: 'img_$i',
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                          child: isNetwork
                                              ? Image.network(path,
                                                  fit: BoxFit.cover)
                                              : Image.file(File(path),
                                                  fit: BoxFit.cover),
                                        ),
                                      ),
                                      if (!isNetwork)
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: GestureDetector(
                                            onTap: () => _removeLocalImage(
                                                i - _uploadedImageUrls.length),
                                            child: Container(
                                              padding: EdgeInsets.all(4.r),
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(Icons.close,
                                                  size: 14.r,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        SizedBox(height: 16.h),
                        OutlinedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.add_photo_alternate_rounded),
                          label: const Text('إضافة صور جديدة'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF16669E),
                            side: const BorderSide(color: Color(0xFF16669E)),
                            minimumSize: Size(double.infinity, 45.h),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // الأزرار الرئيسية
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _markAsDone,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            elevation: 4,
                            shadowColor: Colors.green.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.r)),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 24.r,
                                  width: 24.r,
                                  child: const CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : Text('إنهاء الزيارة',
                                  style: TextStyle(
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.bold)),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveVisitDetail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16669E),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            elevation: 4,
                            shadowColor:
                                const Color(0xFF16669E).withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.r)),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 24.r,
                                  width: 24.r,
                                  child: const CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : Text('حفظ الإجراء',
                                  style: TextStyle(
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40.h),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
