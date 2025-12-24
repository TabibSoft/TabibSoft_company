import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tabib_soft_company/features/programmers/data/model/engineer_model.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/engineer_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/problem/problem_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/problem_status/problem_status_model.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/customer_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/customer_state.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/screen/problem/add_tech_task_screen.dart';

class ProblemDetailsScreen extends StatefulWidget {
  final ProblemModel issue;
  const ProblemDetailsScreen({super.key, required this.issue});

  @override
  State<ProblemDetailsScreen> createState() => ProblemDetailsScreenState();
}

class ProblemDetailsScreenState extends State<ProblemDetailsScreen> {
  late TextEditingController nameCtl;
  late TextEditingController addressCtl;
  late TextEditingController issueTitleCtl;
  late TextEditingController issueDetailsCtl;
  late TextEditingController contactCtl;
  late TextEditingController solutionCtl;
  late TextEditingController specialtyCtl;

  ProblemStatusModel? selectedSpecialty;
  EngineerModel? selectedEngineer;
  final List<File> selectedImages = [];
  bool isLoading = false;
  final GlobalKey engineerKey = GlobalKey();
  final RefreshController _refreshController = RefreshController();

  static const Color gradientTop = Color(0xFF104D9D);
  static const Color fieldBlue = Color(0xFF0B4C99);
  static const Color checkColor = Color(0xFF2FD6F2);

  @override
  void initState() {
    super.initState();

    nameCtl = TextEditingController(
        text: widget.issue.name ?? widget.issue.customerName ?? '');
    addressCtl = TextEditingController(
        text: widget.issue.location ?? widget.issue.adderss ?? '');
    issueTitleCtl =
        TextEditingController(text: widget.issue.problemAddress ?? '');
    issueDetailsCtl = TextEditingController(
        text: widget.issue.details ?? widget.issue.problemDetails ?? '');
    contactCtl = TextEditingController(
        text: widget.issue.telephone ?? widget.issue.customerPhone ?? '');
    solutionCtl = TextEditingController();
    specialtyCtl = TextEditingController(
      text: (widget.issue.products != null && widget.issue.products!.isNotEmpty)
          ? widget.issue.products!.join(', ')
          : '',
    );

    context.read<CustomerCubit>().fetchProblemStatus();
    context.read<EngineerCubit>().fetchEngineers();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSelectedSpecialty();
    });
  }

  void _initializeSelectedSpecialty() {
    final cubit = context.read<CustomerCubit>();
    if (cubit.state.problemStatusList.isNotEmpty &&
        widget.issue.problemStatusId != null) {
      final status = cubit.state.problemStatusList.firstWhere(
        (s) => s.id == widget.issue.problemStatusId,
        orElse: () => cubit.state.problemStatusList.first,
      );
      setState(() {
        selectedSpecialty = status;
      });
    }
  }

  @override
  void dispose() {
    nameCtl.dispose();
    addressCtl.dispose();
    issueTitleCtl.dispose();
    issueDetailsCtl.dispose();
    contactCtl.dispose();
    solutionCtl.dispose();
    specialtyCtl.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    if (widget.issue.customerSupportId != null) {
      await context
          .read<CustomerCubit>()
          .fetchProblemDetailsById(widget.issue.customerSupportId!);
    }
    _refreshController.refreshCompleted();
  }

  Color parseHexColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'ff$hex';
    return Color(int.parse(hex, radix: 16));
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await showModalBottomSheet<XFile?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
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
                    color: checkColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt, color: checkColor),
                ),
                title: const Text('التقاط صورة',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () async {
                  Navigator.pop(context,
                      await picker.pickImage(source: ImageSource.camera));
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: checkColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library, color: checkColor),
                ),
                title: const Text('اختيار من المعرض',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () async {
                  Navigator.pop(context,
                      await picker.pickImage(source: ImageSource.gallery));
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );

    if (pickedFile != null) {
      setState(() {
        selectedImages.add(File(pickedFile.path));
      });
    }
  }

  void showFullScreenImage(File imageFile, int index) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.file(imageFile, fit: BoxFit.contain),
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
                    icon: const Icon(Icons.close),
                    color: Colors.white,
                    iconSize: 30,
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
                    icon: const Icon(Icons.delete),
                    color: Colors.white,
                    iconSize: 30,
                    onPressed: () {
                      setState(() {
                        selectedImages.removeAt(index);
                      });
                      Navigator.pop(context);
                      Fluttertoast.showToast(
                        msg: 'تم حذف الصورة',
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
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
                    '${index + 1} / ${selectedImages.length}',
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
        );
      },
    );
  }

  void showHistoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: fieldBlue,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Text(
                              ' تاريخ المعاملات ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              showTransactionsBottomSheet();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: const Text(
                                ' بيانات قيدالتعامل',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: widget.issue.customerSupport == null ||
                            widget.issue.customerSupport!.isEmpty
                        ? const Center(
                            child: Text(
                              'لا توجد سجلات دعم عملاء',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: widget.issue.customerSupport!.length,
                            itemBuilder: (context, index) {
                              final support = widget.issue.customerSupport![
                                  widget.issue.customerSupport!.length -
                                      1 -
                                      index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              support['problemAddress'] ??
                                                  'غير محدد',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: fieldBlue,
                                              ),
                                            ),
                                          ),
                                          const Icon(Icons.support_agent,
                                              color: checkColor, size: 24),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        support['details'] ?? 'لا توجد تفاصيل',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          const Icon(Icons.person,
                                              size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            support['engName'] ?? 'غير محدد',
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey),
                                          ),
                                          const Spacer(),
                                          const Icon(Icons.access_time,
                                              size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatDate(support['dateTime']),
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                      if (support['createdUser'] != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'بواسطة: ${support['createdUser']}',
                                          style: const TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void showTransactionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              showHistoryBottomSheet();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: const Text(
                                '  تاريخ المعاملات ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: fieldBlue,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Text(
                              ' بيانات قيدالتعامل',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: widget.issue.underTransactions == null ||
                            widget.issue.underTransactions!.isEmpty
                        ? const Center(
                            child: Text(
                              'لا توجد معاملات جارية',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: widget.issue.underTransactions!.length,
                            itemBuilder: (context, index) {
                              final transaction =
                                  widget.issue.underTransactions![
                                      widget.issue.underTransactions!.length -
                                          1 -
                                          index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              transaction['note'] ?? 'غير محدد',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: fieldBlue,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit,
                                                    color: fieldBlue, size: 20),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  _showEditTransactionDialog(
                                                    transaction['id'],
                                                    transaction['note'] ?? '',
                                                  );
                                                },
                                              ),
                                              // const Icon(Icons.pending_actions,
                                              //     color: Colors.orange,
                                              //     size: 24),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      if (transaction['dateTime'] != null)
                                        Row(
                                          children: [
                                            const Icon(Icons.access_time,
                                                size: 16, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(
                                              _formatDate(
                                                  transaction['dateTime']),
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditTransactionDialog(String? id, String currentNote) {
    if (id == null) return;

    final TextEditingController editCtl =
        TextEditingController(text: currentNote);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('تعديل البيانات',
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: editCtl,
            maxLines: 4,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: 'اكتب التعديل هنا...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: fieldBlue),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final newNote = editCtl.text.trim();
                if (newNote.isEmpty) return;

                Navigator.pop(context);
                setState(() => isLoading = true);

                final cubit = context.read<CustomerCubit>();
                await cubit.updateUnderTransaction(id, newNote);

                if (mounted) {
                  if (cubit.state.status == CustomerStatus.success) {
                    Fluttertoast.showToast(
                      msg: '✓ تم التحديث بنجاح',
                      backgroundColor: Colors.green,
                    );
                    await _refreshAndReenter();
                  } else {
                    Fluttertoast.showToast(
                      msg: cubit.state.errorMessage ?? 'فشل التحديث',
                      backgroundColor: Colors.red,
                    );
                    setState(() => isLoading = false);
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: fieldBlue),
              child: const Text('تحديث', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(dynamic dateString) {
    if (dateString == null) return 'غير محدد';
    try {
      final date = DateTime.parse(dateString.toString());
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString.toString();
    }
  }

  // ⭐ دالة الأرشفة/إلغاء الأرشفة المحسّنة
  Future<void> toggleArchiveStatus() async {
    if (widget.issue.customerSupportId == null) {
      Fluttertoast.showToast(
        msg: 'رقم المشكلة غير متوفر',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      print('❌ Debug: customerSupportId is null');
      return;
    }

    final cubit = context.read<CustomerCubit>();
    final newArchiveStatus = !(widget.issue.isArchive ?? false);

    print('🗄️ Archiving ProblemId: ${widget.issue.customerSupportId}');
    print('🗄️ Archive status: $newArchiveStatus');

    await cubit.isArchiveProblem(
      problemId: widget.issue.customerSupportId!,
      isArchive: newArchiveStatus,
    );

    if (mounted) {
      if (cubit.state.status == CustomerStatus.success) {
        Fluttertoast.showToast(
          msg: newArchiveStatus
              ? 'تم أرشفة المشكلة بنجاح'
              : 'تم إلغاء الأرشفة بنجاح',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        // ⭐ تحديث البيانات والخروج
        await cubit.refreshAllData();
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else if (cubit.state.status == CustomerStatus.failure) {
        Fluttertoast.showToast(
          msg: cubit.state.errorMessage ?? 'فشل تغيير حالة الأرشفة',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  // ⭐ دالة الحفظ المحسّنة بالكامل
  // ⭐ دالة الحفظ المحسّنة - مع لوجيك خروج واضح
  Future<void> saveChanges() async {
    if (isLoading) return;

    if (widget.issue.customerSupportId == null) {
      Fluttertoast.showToast(
        msg: 'خطأ: معرف المشكلة غير موجود',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    if (widget.issue.id == null) {
      Fluttertoast.showToast(
        msg: 'خطأ: معرف العميل غير موجود',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    if (selectedSpecialty == null) {
      Fluttertoast.showToast(
        msg: 'يرجى اختيار حالة المشكلة أولاً',
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final cubit = context.read<CustomerCubit>();

      print('💾 Saving - customerSupportId: ${widget.issue.customerSupportId}');
      print('💾 Saving - customerId: ${widget.issue.id}');
      print('💾 Saving - statusId: ${selectedSpecialty!.id}');
      print('💾 Saving - images count: ${selectedImages.length}');

      await cubit.createUnderTransaction(
        customerSupportId: widget.issue.customerSupportId!,
        customerId: widget.issue.id!,
        note: solutionCtl.text.trim().isEmpty
            ? 'تم تحديث حالة المشكلة'
            : solutionCtl.text.trim(),
        problemStatusId: selectedSpecialty!.id,
        images: selectedImages.isNotEmpty ? selectedImages : null,
      );

      if (!mounted) return;

      if (cubit.state.status == CustomerStatus.success) {
        print('✅ Save successful');

        Fluttertoast.showToast(
          msg: '✓ تم حفظ التغييرات بنجاح',
          backgroundColor: Colors.green,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT,
        );

        setState(() => isLoading = false);

        // ⭐ إذا كانت الحالة 15 → اعرض Dialog ثم اخرج
        if (selectedSpecialty!.id == 15) {
          print('📦 Status is 15, showing archive dialog');
          await _showArchiveDialogThenExit();
        } else {
          // ⭐ أي حالة أخرى (12، 13) → اخرج وادخل تاني للتحديث
          print('🔄 Refreshing and re-entering (status != 15)');
          await _refreshAndReenter();
        }
      } else if (cubit.state.status == CustomerStatus.failure) {
        print('❌ Save failed: ${cubit.state.errorMessage}');

        Fluttertoast.showToast(
          msg: cubit.state.errorMessage ?? 'حدث خطأ أثناء الحفظ',
          backgroundColor: Colors.red,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );

        setState(() => isLoading = false);
      }
    } catch (e) {
      print('❌ Error in saveChanges: $e');

      if (mounted) {
        Fluttertoast.showToast(
          msg: 'خطأ: ${e.toString()}',
          backgroundColor: Colors.red,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );

        setState(() => isLoading = false);
      }
    }
  }

// ⭐ دالة عرض Dialog الأرشفة ثم الخروج
  Future<void> _showArchiveDialogThenExit() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.archive_outlined,
                  color: Colors.orange.shade700,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'أرشفة المشكلة',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تم حل المشكلة بنجاح ✓',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'هل تريد نقل المشكلة إلى الأرشيف الآن؟',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'يمكنك أرشفتها لاحقاً من القائمة الرئيسية',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'لاحقاً',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.archive, color: Colors.white),
              label: const Text(
                'أرشفة الآن',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    // ⭐ سواء اختار الأرشفة أو "لاحقاً"، نخرج من الشاشة
    if (result == true) {
      // المستخدم اختار الأرشفة
      print('🗄️ User chose to archive, performing archive then exit');
      await _performArchiveThenExit();
    } else {
      // المستخدم اختار "لاحقاً"
      print('⏭️ User chose later, exiting without archive');
      Navigator.of(context).pop(true);
    }
  }

  // ⭐ دالة الخروج والدخول التلقائي للتحديث
  Future<void> _refreshAndReenter() async {
    if (widget.issue.customerSupportId == null) return;

    final cubit = context.read<CustomerCubit>();
    await cubit.fetchProblemDetailsById(widget.issue.customerSupportId!);

    if (mounted) {
      if (cubit.state.status == CustomerStatus.success &&
          cubit.state.selectedProblem != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProblemDetailsScreen(issue: cubit.state.selectedProblem!),
          ),
        );
      } else {
        setState(() => isLoading = false);
      }
    }
  }

// ⭐ دالة تنفيذ الأرشفة ثم الخروج
  Future<void> _performArchiveThenExit() async {
    if (widget.issue.customerSupportId == null) {
      Fluttertoast.showToast(
        msg: 'خطأ: معرف المشكلة غير موجود',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      // حتى لو فشل، اخرج
      if (mounted) {
        Navigator.of(context).pop(true);
      }
      return;
    }

    // عرض مؤشر تحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    final cubit = context.read<CustomerCubit>();

    print('🗄️ Archiving ProblemId: ${widget.issue.customerSupportId}');

    await cubit.isArchiveProblem(
      problemId: widget.issue.customerSupportId!,
      isArchive: true,
    );

    if (!mounted) return;

    // إغلاق مؤشر التحميل
    Navigator.of(context).pop();

    if (cubit.state.status == CustomerStatus.success) {
      print('✅ Archive successful, exiting...');

      Fluttertoast.showToast(
        msg: '✓ تم أرشفة المشكلة بنجاح',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      // ⭐ الخروج بعد النجاح
      Navigator.of(context).pop(true);
    } else {
      print('❌ Archive failed: ${cubit.state.errorMessage}');

      Fluttertoast.showToast(
        msg: cubit.state.errorMessage ?? 'فشل في الأرشفة',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );

      // ⭐ حتى لو فشلت الأرشفة، اخرج
      Navigator.of(context).pop(true);
    }
  }

// ⭐ دالة الأرشفة/إلغاء الأرشفة من الزر
// Future<void> toggleArchiveStatus() async {
//   if (widget.issue.customerSupportId == null) {
//     Fluttertoast.showToast(
//       msg: 'رقم المشكلة غير متوفر',
//       backgroundColor: Colors.red,
//       textColor: Colors.white,
//     );
//     print('❌ Debug: customerSupportId is null');
//     return;
//   }

//   final cubit = context.read<CustomerCubit>();
//   final newArchiveStatus = !(widget.issue.isArchive ?? false);

//   print('🗄️ Toggling archive - ProblemId: ${widget.issue.customerSupportId}');
//   print('🗄️ New archive status: $newArchiveStatus');

//   await cubit.isArchiveProblem(
//     problemId: widget.issue.customerSupportId!,
//     isArchive: newArchiveStatus,
//   );

//   if (!mounted) return;

//   if (cubit.state.status == CustomerStatus.success) {
//     Fluttertoast.showToast(
//       msg: newArchiveStatus
//           ? 'تم أرشفة المشكلة بنجاح'
//           : 'تم إلغاء الأرشفة بنجاح',
//       backgroundColor: Colors.green,
//       textColor: Colors.white,
//     );

//     // ⭐ الخروج مع تحديث
//     print('🔙 Exiting after archive toggle');
//     Navigator.pop(context, true);
//   } else {
//     Fluttertoast.showToast(
//       msg: cubit.state.errorMessage ?? 'فشل تغيير حالة الأرشفة',
//       backgroundColor: Colors.red,
//       textColor: Colors.white,
//     );
//   }
// }

  // ⭐ دالة عرض Dialog الأرشفة
  Future<void> _showArchiveDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.archive_outlined,
                  color: Colors.orange.shade700,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'أرشفة المشكلة',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تم حل المشكلة بنجاح ✓',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'هل تريد أرشفة هذه المشكلة؟',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'يمكنك الأرشفة الآن أو لاحقاً من القائمة',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'لاحقاً',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.archive, color: Colors.white),
              label: const Text(
                'أرشفة الآن',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (mounted) {
      if (result == true) {
        // ✅ المستخدم اختار الأرشفة
        await _performArchive();
      } else {
        // ✅ المستخدم اختار "لاحقاً" - تحديث وخروج
        final cubit = context.read<CustomerCubit>();
        print('🔄 User chose later, refreshing data...');
        await cubit.refreshAllData();
        print('✅ Data refreshed, exiting...');
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      }
    }
  }

  // ⭐ دالة تنفيذ الأرشفة
  Future<void> _performArchive() async {
    if (widget.issue.customerSupportId == null) {
      Fluttertoast.showToast(
        msg: 'خطأ: معرف المشكلة غير موجود',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      // حتى في حالة الخطأ، حدّث البيانات واخرج
      final cubit = context.read<CustomerCubit>();
      await cubit.refreshAllData();
      if (mounted) {
        Navigator.of(context).pop(true);
      }
      return;
    }

    // عرض مؤشر تحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );

    final cubit = context.read<CustomerCubit>();

    print('🗄️ Archiving ProblemId: ${widget.issue.customerSupportId}');

    await cubit.isArchiveProblem(
      problemId: widget.issue.customerSupportId!,
      isArchive: true,
    );

    if (mounted) {
      // إغلاق مؤشر التحميل
      Navigator.of(context).pop();

      if (cubit.state.status == CustomerStatus.success) {
        Fluttertoast.showToast(
          msg: '✓ تم أرشفة المشكلة بنجاح',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        // ⭐ تحديث البيانات والخروج
        print('🔄 Archive successful, refreshing data...');
        await cubit.refreshAllData();
        print('✅ Data refreshed, exiting...');
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else if (cubit.state.status == CustomerStatus.failure) {
        Fluttertoast.showToast(
          msg: cubit.state.errorMessage ?? 'فشل في الأرشفة',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );

        // ⭐ حتى لو فشلت الأرشفة، حدّث البيانات واخرج
        print('❌ Archive failed, but still refreshing data...');
        await cubit.refreshAllData();
        print('✅ Data refreshed, exiting...');
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      }
    }
  }

  void showEngineersMenu(List<EngineerModel> engineers) async {
    if (engineerKey.currentContext == null) return;

    final RenderBox button =
        engineerKey.currentContext!.findRenderObject()! as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final selected = await showMenu<EngineerModel?>(
      context: context,
      position: position,
      constraints: const BoxConstraints(maxHeight: 250),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      items: <PopupMenuEntry<EngineerModel?>>[
        PopupMenuItem<EngineerModel?>(
          value: null,
          enabled: true,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const Row(
              children: [
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'بدون مهندس',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Color.fromARGB(255, 240, 15, 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ...engineers.map(
          (eng) => PopupMenuItem<EngineerModel>(
            value: eng,
            enabled: true,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: fieldBlue,
                  radius: 18,
                  child: Text(
                    eng.name.isNotEmpty ? eng.name[0].toUpperCase() : '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                title: Text(
                  eng.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),
      ],
    );

    if (selected != null) {
      setState(() {
        selectedEngineer = selected;
      });
    }
  }

  Widget buildLabeledField({
    required Widget field,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(child: field),
        ],
      ),
    );
  }

  Widget buildDisabledDropdown({
    required String value,
    String? trailingText,
  }) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: fieldBlue.withOpacity(0.7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              trailingText != null ? '$value - $trailingText' : value,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(
            Icons.arrow_drop_down,
            color: Colors.white.withOpacity(0.5),
            size: 30,
          ),
        ],
      ),
    );
  }

  Widget buildDropdownButton<T>({
    required String displayValue,
    String? trailingText,
    required List<T> items,
    required ValueChanged<T> onSelected,
    required Widget Function(T) itemBuilder,
  }) {
    return PopupMenuButton<T>(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      elevation: 8,
      onSelected: onSelected,
      itemBuilder: (BuildContext context) {
        return items
            .map(
              (item) => PopupMenuItem<T>(
                value: item,
                child: itemBuilder(item),
              ),
            )
            .toList();
      },
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: fieldBlue,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                trailingText != null
                    ? '$displayValue - $trailingText'
                    : displayValue,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.arrow_drop_down,
              color: Colors.white,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: gradientTop,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 40.h,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/images/pngs/TS_Logo0.png',
                  height: 70.h,
                  color: Colors.white.withOpacity(0.3),
                  colorBlendMode: BlendMode.modulate,
                ),
              ),
            ),
            Positioned(
              top: 10.h,
              right: 10.w,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                color: Colors.white,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Positioned(
              top: 10.h,
              left: 10.w,
              child: IconButton(
                icon: const Icon(Icons.history),
                color: Colors.white,
                iconSize: 28,
                tooltip: 'عرض السجل التاريخي',
                onPressed: showHistoryBottomSheet,
              ),
            ),
            Positioned.fill(
              top: 120.h,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFDFDFD),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.only(top: 12, right: 20),
                    //   child: Align(
                    //     alignment: Alignment.centerRight,
                    //     child: IconButton(
                    //       icon: const Icon(
                    //         Icons.photo_library_outlined,
                    //         color: Colors.black87,
                    //         size: 28,
                    //       ),
                    //       tooltip: 'صور دعم العملاء',
                    //       onPressed: showCustomerSupportImages,
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 8),
                    Expanded(
                      child: SmartRefresher(
                        controller: _refreshController,
                        enablePullDown: true,
                        enablePullUp: false,
                        header: const WaterDropHeader(
                          waterDropColor: fieldBlue,
                          complete: Icon(Icons.check, color: fieldBlue),
                        ),
                        onRefresh: _onRefresh,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddTechTaskScreen(
                                            customerName: nameCtl.text,
                                            customerId: widget.issue.id,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.add_task, size: 18),
                                    label: const Text('إضافة مهمة'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: fieldBlue,
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              buildReadOnlyField(
                                label: 'اسم العميل',
                                controller: nameCtl,
                              ),
                              buildReadOnlyField(
                                label: 'رقم التواصل',
                                controller: contactCtl,
                              ),
                              buildReadOnlyField(
                                label: 'التخصص',
                                controller: specialtyCtl,
                              ),
                              BlocBuilder<CustomerCubit, CustomerState>(
                                builder: (context, state) {
                                  if (state.problemStatusList.isEmpty) {
                                    return buildLabeledField(
                                      field: buildDisabledDropdown(
                                          value: 'جاري التحميل...'),
                                      label: 'حالة المشكلة',
                                    );
                                  }

                                  final allowedStatusIds = [12, 13, 15];

                                  final filteredStatuses = state
                                      .problemStatusList
                                      .where((s) =>
                                          s.name.isNotEmpty &&
                                          allowedStatusIds.contains(s.id))
                                      .toList();

                                  if (filteredStatuses.isEmpty) {
                                    return buildLabeledField(
                                      field: buildDisabledDropdown(
                                          value: 'لا توجد حالات متاحة'),
                                      label: 'حالة المشكلة',
                                    );
                                  }

                                  if (selectedSpecialty == null) {
                                    if (widget.issue.problemStatusId != null) {
                                      selectedSpecialty =
                                          filteredStatuses.firstWhere(
                                        (s) =>
                                            s.id ==
                                            widget.issue.problemStatusId,
                                        orElse: () => filteredStatuses.first,
                                      );
                                    } else {
                                      selectedSpecialty =
                                          filteredStatuses.first;
                                    }
                                  }

                                  if (!filteredStatuses.any(
                                      (s) => s.id == selectedSpecialty!.id)) {
                                    selectedSpecialty = filteredStatuses.first;
                                  }

                                  return buildLabeledField(
                                    field:
                                        buildDropdownButton<ProblemStatusModel>(
                                      displayValue:
                                          selectedSpecialty!.name ?? 'غير محدد',
                                      trailingText: null,
                                      items: filteredStatuses,
                                      onSelected: (status) {
                                        setState(() {
                                          selectedSpecialty = status;
                                        });
                                      },
                                      itemBuilder: (status) => ListTile(
                                        dense: true,
                                        title: Text(
                                          status.name ?? 'غير محدد',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    label: 'حالة المشكلة',
                                  );
                                },
                              ),
                              buildReadOnlyField(
                                label: 'العنوان',
                                controller: addressCtl,
                              ),
                              buildReadOnlyField(
                                label: 'عنوان المشكلة',
                                controller: issueTitleCtl,
                              ),
                              buildReadOnlyField(
                                label: 'تفاصيل المشكلة',
                                controller: issueDetailsCtl,
                                maxLines: 4,
                              ),
                              buildEditableField(
                                label: 'الحل المقترح',
                                controller: solutionCtl,
                                maxLines: 5,
                                hintText: 'اكتب تفاصيل الحل هنا...',
                              ),
                              const SizedBox(height: 20),
                              Column(
                                children: [
                                  const Text(
                                    'رفع ملفات',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: pickImage,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/images/pngs/upload_pic.png',
                                          width: 50,
                                          height: 50,
                                        ),
                                        if (selectedImages.isNotEmpty)
                                          Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                                size: 14,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (selectedImages.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: selectedImages
                                          .asMap()
                                          .entries
                                          .map(
                                            (entry) => GestureDetector(
                                              onTap: () => showFullScreenImage(
                                                  entry.value, entry.key),
                                              child: Stack(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    child: Image.file(
                                                      entry.value,
                                                      width: 60,
                                                      height: 60,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 0,
                                                    right: 0,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          selectedImages
                                                              .removeAt(
                                                                  entry.key);
                                                        });
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2),
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: Colors.red,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: const Icon(
                                                          Icons.close,
                                                          color: Colors.white,
                                                          size: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: widget.issue.problemStatusId == 15
                          ? Row(
                              children: [
                                Expanded(
                                  child: buildBottomButton(
                                    label: (widget.issue.isArchive == true ||
                                            widget.issue.statusIsArchieve ==
                                                true)
                                        ? 'إلغاء الأرشفة'
                                        : 'أرشيف',
                                    color: Colors.deepOrange.shade700,
                                    onTap:
                                        isLoading ? null : toggleArchiveStatus,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: buildBottomButton(
                                    label: 'حفظ',
                                    color: fieldBlue,
                                    onTap: isLoading ? null : saveChanges,
                                  ),
                                ),
                              ],
                            )
                          : buildBottomButton(
                              label: 'حفظ',
                              color: fieldBlue,
                              onTap: isLoading ? null : saveChanges,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildReadOnlyField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return buildField(
      label: label,
      controller: controller,
      maxLines: maxLines,
      enabled: false,
    );
  }

  Widget buildEditableField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    String? hintText,
  }) {
    return buildField(
      label: label,
      controller: controller,
      maxLines: maxLines,
      enabled: true,
      hintText: hintText,
    );
  }

  Widget buildField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    bool enabled = false,
    String? hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: maxLines == 1
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              constraints: BoxConstraints(
                minHeight: maxLines == 1 ? 56 : 90,
              ),
              decoration: BoxDecoration(
                color: enabled ? fieldBlue : fieldBlue.withOpacity(0.7),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: controller,
                maxLines: maxLines,
                enabled: enabled,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                  hintText: hintText,
                  hintStyle: const TextStyle(
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBottomButton({
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: onTap == null ? Colors.grey.shade400 : color,
          borderRadius: BorderRadius.circular(30),
        ),
        alignment: Alignment.center,
        child: isLoading && label == 'حفظ'
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
