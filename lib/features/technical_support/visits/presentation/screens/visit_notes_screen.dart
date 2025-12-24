import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/features/technical_support/visits/data/models/visit_model.dart';
import 'package:tabib_soft_company/features/technical_support/visits/presentation/cubits/visit_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/visits/presentation/widgets/visit_info_row.dart';
import 'package:tabib_soft_company/features/technical_support/visits/presentation/widgets/visit_note_card.dart';
import 'package:tabib_soft_company/features/technical_support/visits/presentation/widgets/visit_images_sheet.dart';

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
      builder: (context) => VisitImagesBottomSheet(images: images),
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
                        VisitInfoRow(
                          imagePath: "assets/images/pngs/new_person.png",
                          text: widget.visit.customerName,
                        ),
                        const SizedBox(height: 10),
                        VisitInfoRow(
                          imagePath: "assets/images/pngs/specialization.png",
                          text: widget.visit.customerPhone ?? 'غير متوفر',
                        ),
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
                                  return VisitNoteCard(
                                    note: note,
                                    index: index,
                                    onMarkAsRead: _markAsRead,
                                    onDelete: _deleteNote,
                                    formatDate: _formatDate,
                                  );
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
}
