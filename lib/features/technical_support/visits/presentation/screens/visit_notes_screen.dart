import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/features/technical_support/visits/data/models/visit_model.dart';
import 'package:tabib_soft_company/features/technical_support/visits/presentation/cubits/visit_cubit.dart';

class VisitNotesScreen extends StatefulWidget {
  final VisitModel visit;

  const VisitNotesScreen({super.key, required this.visit});

  @override
  State<VisitNotesScreen> createState() => _VisitNotesScreenState();
}

class _VisitNotesScreenState extends State<VisitNotesScreen> {
  final _noteController = TextEditingController();
  List<dynamic> _notes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingNotes();
  }

  void _loadExistingNotes() {
    if (widget.visit.visitInstallDetails != null) {
      final List<dynamic> allNotes = [];

      for (var detail in widget.visit.visitInstallDetails!) {
        // التحقق من وجود notes داخل كل detail
        if (detail is Map && detail.containsKey('notes')) {
          final notes = detail['notes'];
          if (notes is List) {
            allNotes.addAll(notes);
          }
        }
      }

      setState(() {
        _notes = allNotes;
      });

      // طباعة للتأكد من البيانات
      print('Loaded ${_notes.length} notes');
      if (_notes.isNotEmpty) {
        print('First note: ${_notes[0]}');
      }
    }
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

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _addNote() async {
    if (_noteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى كتابة ملاحظة")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final note = await context.read<VisitCubit>().addNote(
            visitInstallId: widget.visit.id,
            note: _noteController.text.trim(),
          );

      setState(() {
        _notes.insert(0, note.toJson());
        _noteController.clear();
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تم إضافة الملاحظة بنجاح"),
            backgroundColor: Colors.green,
          ),
        );

        // إرجاع true للشاشة السابقة
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("فشل الإضافة: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAsRead(String noteId, int index) async {
    print('Attempting to mark note as read: $noteId');

    try {
      await context.read<VisitCubit>().makeNoteRead(noteId: noteId);

      setState(() {
        if (_notes[index] is Map) {
          _notes[index]['isRead'] = true;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تم تعيين الملاحظة كمقروءة"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error marking note as read: $e');
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

  Future<void> _deleteNote(String noteId, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('تأكيد الحذف'),
        content: const Text('هل تريد حذف هذه الملاحظة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // حذف الملاحظة من الـ API
      await context.read<VisitCubit>().deleteNote(noteId: noteId);

      // حذف من القائمة المحلية
      setState(() {
        _notes.removeAt(index);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تم حذف الملاحظة بنجاح"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // إعادة تحميل البيانات من الخادم
        await context.read<VisitCubit>().fetchVisits();

        // إعادة تحميل الملاحظات
        _loadExistingNotes();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("فشل الحذف: $e"),
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
          title: const Text(
            'الملاحظات',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                    child: Column(
                      children: [
                        _buildInfoRow('العميل:', widget.visit.customerName),
                        const SizedBox(height: 10),
                        _buildInfoRow('الهاتف:',
                            widget.visit.customerPhone ?? 'غير متوفر'),
                        const SizedBox(height: 25),

                        // حقل إضافة ملاحظة
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'إضافة ملاحظة جديدة',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: mainBlueColor,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                  color: fieldBlueColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextField(
                                  controller: _noteController,
                                  style: const TextStyle(color: Colors.white),
                                  maxLines: 3,
                                  textAlign: TextAlign.right,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(12),
                                    hintText: "اكتب ملاحظتك هنا...",
                                    hintStyle: TextStyle(color: Colors.white70),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              SizedBox(
                                width: double.infinity,
                                height: 45,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _addNote,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: cyanButtonColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'إضافة الملاحظة',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),

                        // قائمة الملاحظات
                        Row(
                          children: [
                            const Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'الملاحظات السابقة',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: mainBlueColor,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: mainBlueColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_notes.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),

                        // عرض الملاحظات
                        _notes.isEmpty
                            ? SizedBox(
                                height: 200,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.note_outlined,
                                        size: 80,
                                        color: Colors.grey[300],
                                      ),
                                      const SizedBox(height: 15),
                                      Text(
                                        'لا توجد ملاحظات بعد',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _notes.length,
                                itemBuilder: (context, index) {
                                  final note = _notes[index];
                                  return _buildNoteCard(note, index);
                                },
                              ),

                        const SizedBox(height: 20),
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

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF16669E),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(dynamic note, int index) {
    // التعامل الآمن مع البيانات
    if (note is! Map) {
      return const SizedBox.shrink();
    }

    final String noteId = note['id']?.toString() ?? '';
    final String noteText = note['note']?.toString() ?? '';
    final bool isRead = note['isRead'] == true;
    final String createdDate =
        note['createdDate']?.toString() ?? note['date']?.toString() ?? '';

    // إضافة print للتحقق من الـ ID
    print('Note ID: $noteId, isRead: $isRead');

    final Color cardColor =
        isRead ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1);

    final Color borderColor = isRead ? Colors.green : Colors.red;

    final Color statusIconColor = isRead ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: statusIconColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isRead ? Icons.check_circle : Icons.circle_outlined,
                  color: statusIconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      noteText,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _formatDate(createdDate),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // أيقونة العين - تظهر فقط إذا كان noteId موجود وليس فارغ
              if (!isRead && noteId.isNotEmpty)
                InkWell(
                  onTap: () => _markAsRead(noteId, index),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.visibility,
                      color: Colors.blue,
                      size: 22,
                    ),
                  ),
                ),

              const SizedBox(width: 8),

              // أيقونة الحذف - تظهر فقط إذا كان noteId موجود
              if (noteId.isNotEmpty)
                InkWell(
                  onTap: () => _deleteNote(noteId, index),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 22,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusIconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isRead ? Icons.visibility : Icons.visibility_off,
                  size: 14,
                  color: statusIconColor,
                ),
                const SizedBox(width: 5),
                Text(
                  isRead ? 'تم القراءة' : 'غير مقروءة',
                  style: TextStyle(
                    fontSize: 12,
                    color: statusIconColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'اليوم ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays == 1) {
        return 'أمس';
      } else if (difference.inDays < 7) {
        return 'منذ ${difference.inDays} أيام';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }
}
