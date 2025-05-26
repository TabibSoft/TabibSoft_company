import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/problem/problem_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/problem_status/problem_status_model.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/customer_cubit.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/customer_state.dart';


class ProblemStatusDialog extends StatefulWidget {
  final ProblemModel issue;

  const ProblemStatusDialog({
    super.key,
    required this.issue,
  });

  

  @override
  _ProblemStatusDialogState createState() => _ProblemStatusDialogState();
}

class _ProblemStatusDialogState extends State<ProblemStatusDialog> {
  late TextEditingController _detailsController;
  ProblemStatusModel? _selectedStatus;
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _detailsController =
        TextEditingController(text: widget.issue.details ?? '');
    context.read<CustomerCubit>().fetchProblemStatus();
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('الكاميرا'),
            onTap: () async {
              Navigator.pop(
                  context, await picker.pickImage(source: ImageSource.camera));
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('المعرض'),
            onTap: () async {
              Navigator.pop(
                  context, await picker.pickImage(source: ImageSource.gallery));
            },
          ),
        ],
      ),
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProblemStatus() async {
    if (_selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار حالة المشكلة')),
      );
      return;
    }

    if (_detailsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال تفاصيل الحل')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await context.read<CustomerCubit>().createUnderTransaction(
          customerSupportId: widget.issue.id,
          customerId: widget.issue.customerId,
          note: _detailsController.text,
          problemStatusId: _selectedStatus!.id,
        );

    final state = context.read<CustomerCubit>().state;
    if (state.status == CustomerStatus.success) {
      // تحديث الحالة مباشرة في قائمة techSupportIssues
      final updatedIssues = state.techSupportIssues.map((issue) {
        if (issue.id == widget.issue.id) {
          return issue.copyWith(
            problemtype: _selectedStatus!.name,
            problemStatusId: _selectedStatus!.id,
            details: _detailsController.text,
            image: _selectedImage?.path ?? issue.image,
          );
        }
        return issue;
      }).toList();

      context.read<CustomerCubit>().emit(state.copyWith(
            techSupportIssues: updatedIssues,
            status: CustomerStatus.success,
          ));

      Fluttertoast.showToast(
        msg: 'تم إنشاء المعاملة بنجاح',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      Navigator.pop(context);
    } else if (state.status == CustomerStatus.failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage ?? 'فشل في إنشاء المعاملة')),
      );
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFF2196F3);

    return WillPopScope(
      onWillPop: () async {
        return _detailsController.text.isEmpty && _selectedImage == null;
      },
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderColor, width: 2),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'تفاصيل المشكلة:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.issue.problemDetails ?? '',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  BlocBuilder<CustomerCubit, CustomerState>(
                    builder: (context, state) {
                      if (state.status == CustomerStatus.loading &&
                          state.problemStatusList.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state.status == CustomerStatus.success &&
                          state.problemStatusList.isNotEmpty) {
                        if (_selectedStatus == null &&
                            widget.issue.problemStatusId != null) {
                          _selectedStatus = state.problemStatusList.firstWhere(
                            (s) => s.id == widget.issue.problemStatusId,
                            orElse: () => state.problemStatusList[0],
                          );
                        }
                        final unique = state.problemStatusList.toSet().toList();
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: borderColor, width: 2),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButton<ProblemStatusModel>(
                            value:
                                unique.any((s) => s.id == _selectedStatus?.id)
                                    ? _selectedStatus
                                    : null,
                            isExpanded: true,
                            underline: const SizedBox(),
                            hint: const Text('حالة المشكلة'),
                            items: unique.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(status.name),
                              );
                            }).toList(),
                            onChanged: (v) =>
                                setState(() => _selectedStatus = v),
                          ),
                        );
                      } else {
                        return const Text('فشل في جلب الحالات');
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: borderColor, width: 2),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _detailsController,
                            decoration: const InputDecoration(
                              hintText: 'تفاصيل الحل',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_selectedImage != null) ...[
                    const SizedBox(height: 8),
                    Image.file(_selectedImage!,
                        height: 80, width: 80, fit: BoxFit.cover),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _pickImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: borderColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'الملحقات',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _updateProblemStatus,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: borderColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'حفظ',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.blue, size: 32),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}