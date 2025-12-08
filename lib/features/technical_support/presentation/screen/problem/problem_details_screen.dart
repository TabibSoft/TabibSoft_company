import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tabib_soft_company/features/programmers/data/model/engineer_model.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/engineer_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/problem/problem_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/problem_status/problem_status_model.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/customer_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/customer_state.dart';

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

  ProblemStatusModel? selectedSpecialty;
  EngineerModel? selectedEngineer;
  final List<File> selectedImages = [];
  bool isLoading = false;

  final GlobalKey engineerKey = GlobalKey();

  static const Color gradientTop = Color(0xFF104D9D);
  static const Color fieldBlue = Color(0xFF0B4C99);
  static const Color checkColor = Color(0xFF2FD6F2);

  @override
  void initState() {
    super.initState();
    nameCtl = TextEditingController(text: widget.issue.customerName ?? '');
    addressCtl = TextEditingController(text: widget.issue.adderss ?? '');
    issueTitleCtl =
        TextEditingController(text: widget.issue.problemAddress ?? '');
    issueDetailsCtl =
        TextEditingController(text: widget.issue.problemDetails ?? '');
    contactCtl = TextEditingController(text: widget.issue.customerPhone ?? '');
    solutionCtl = TextEditingController();

    context.read<CustomerCubit>().fetchProblemStatus();
    context.read<EngineerCubit>().fetchEngineers();
  }

  @override
  void dispose() {
    nameCtl.dispose();
    addressCtl.dispose();
    issueTitleCtl.dispose();
    issueDetailsCtl.dispose();
    contactCtl.dispose();
    solutionCtl.dispose();
    super.dispose();
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
                  child: const Icon(
                    Icons.camera_alt,
                    color: checkColor,
                  ),
                ),
                title: const Text(
                  'التقاط صورة',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
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
                  child: const Icon(
                    Icons.photo_library,
                    color: checkColor,
                  ),
                ),
                title: const Text(
                  'اختيار من المعرض',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
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

  /// هنا التعديل المهم: بعد نجاح الأرشفة نرجع true لـ Navigator.pop
  Future<void> toggleArchiveStatus() async {
    if (widget.issue.id == null) {
      Fluttertoast.showToast(
        msg: 'رقم المشكلة غير متوفر',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    final cubit = context.read<CustomerCubit>();
    final newArchiveStatus = !(widget.issue.isArchive ?? false);

    await cubit.isArchiveProblem(
      problemId: widget.issue.id!,
      isArchive: newArchiveStatus,
    );

    // لو العملية نجحت، حالة الـ Cubit هتكون success
    if (mounted && cubit.state.status == CustomerStatus.success) {
      Fluttertoast.showToast(
        msg: newArchiveStatus
            ? 'تم أرشفة المشكلة بنجاح'
            : 'تم إلغاء الأرشفة بنجاح',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      // إرجاع true حتى تلتقطها TechnicalSupportScreen وتعمل refreshAllData
      Navigator.pop(context, true);
    } else if (mounted && cubit.state.status == CustomerStatus.failure) {
      Fluttertoast.showToast(
        msg: cubit.state.errorMessage ?? 'فشل تغيير حالة الأرشفة',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> saveChanges() async {
    if (solutionCtl.text.trim().isEmpty && selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('من فضلك أدخل الحل أو أرفق صوراً قبل الحفظ'),
        ),
      );
      return;
    }

    String finalNote = solutionCtl.text.trim();
    if (finalNote.isEmpty) finalNote = '';

    List<MultipartFile> imageFiles = [];
    for (var image in selectedImages) {
      final fileName = image.path.split('/').last;
      imageFiles.add(
        await MultipartFile.fromFile(
          image.path,
          filename: fileName,
        ),
      );
    }

    try {
      setState(() => isLoading = true);
      final cubit = context.read<CustomerCubit>();

      await cubit.createUnderTransaction(
        customerSupportId: widget.issue.id!,
        customerId: widget.issue.customerId!,
        note: finalNote,
        problemStatusId: selectedSpecialty?.id ?? widget.issue.problemStatusId!,
      );

      if (mounted && cubit.state.status == CustomerStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ التعديلات بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else if (mounted && cubit.state.status == CustomerStatus.failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cubit.state.errorMessage ?? 'فشل حفظ التعديلات'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ غير متوقع: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
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
          Expanded(child: field),
          SizedBox(width: 12.w),
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
              trailingText != null ? '$value  -  $trailingText' : value,
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
                    ? '$displayValue  -  $trailingText'
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
    return BlocListener<CustomerCubit, CustomerState>(
      listener: (context, state) {
        if (isLoading) {
          if (state.status == CustomerStatus.success) {
            Fluttertoast.showToast(
              msg: 'تم حفظ البيانات بنجاح',
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );
            setState(() {
              isLoading = false;
            });
            if (mounted) Navigator.pop(context, true);
          } else if (state.status == CustomerStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'حدث خطأ أثناء الحفظ'),
                backgroundColor: Colors.red,
              ),
            );
            setState(() {
              isLoading = false;
            });
          }
        }
      },
      child: Scaffold(
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
                  icon: const Icon(Icons.arrow_forward_ios),
                  color: Colors.white,
                  onPressed: () => Navigator.of(context).pop(),
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
                      const SizedBox(height: 24),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              buildReadOnlyField(
                                label: 'اسم العميل',
                                controller: nameCtl,
                              ),
                              buildReadOnlyField(
                                label: 'رقم التواصل',
                                controller: contactCtl,
                              ),
                              BlocBuilder<CustomerCubit, CustomerState>(
                                builder: (context, state) {
                                  if (state.problemStatusList.isEmpty) {
                                    return buildLabeledField(
                                      field: buildDisabledDropdown(
                                          value: 'لا توجد حالات متاحة'),
                                      label: 'حالة المشكلة',
                                    );
                                  }

                                  final filteredStatuses = state
                                      .problemStatusList
                                      .where((s) => s.name.isNotEmpty)
                                      .toList();

                                  if (filteredStatuses.isEmpty) {
                                    return buildLabeledField(
                                      field: buildDisabledDropdown(
                                          value: 'لا توجد حالات متاحة'),
                                      label: 'حالة المشكلة',
                                    );
                                  }

                                  if (selectedSpecialty == null ||
                                      !filteredStatuses.any((s) =>
                                          s.id == selectedSpecialty!.id)) {
                                    selectedSpecialty =
                                        filteredStatuses.firstWhere(
                                      (s) =>
                                          s.id == widget.issue.problemStatusId,
                                      orElse: () => filteredStatuses.first,
                                    );
                                  }

                                  return buildLabeledField(
                                    field:
                                        buildDropdownButton<ProblemStatusModel>(
                                      displayValue:
                                          selectedSpecialty!.name ?? '',
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
                                          status.name ?? '',
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
                                    ' رفع ملفات',
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
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: buildBottomButton(
                                label: (widget.issue.isArchive ?? false)
                                    ? 'إلغاء الأرشفة'
                                    : 'أرشيف',
                                color: fieldBlue,
                                onTap: toggleArchiveStatus,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: buildBottomButton(
                                label: 'حفظ',
                                color: fieldBlue,
                                onTap: isLoading ? null : saveChanges,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
          SizedBox(width: 12.w),
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
