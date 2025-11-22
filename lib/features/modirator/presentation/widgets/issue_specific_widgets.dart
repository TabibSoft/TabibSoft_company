// lib/features/home/presentation/screens/issue_specific_widgets.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tabib_soft_company/features/modirator/export.dart';

class ClientNameField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDropdownVisible;
  final VoidCallback onToggleDropdown;
  final Function(CustomerModel) onCustomerSelected;
  const ClientNameField({
    super.key,
    required this.controller,
    required this.isDropdownVisible,
    required this.onToggleDropdown,
    required this.onCustomerSelected,
  });
  static const Color primaryColor = Color(0xff104D9D);
  InputDecoration _buildDropdownDecoration({
    required String hint,
    required VoidCallback onIconTap,
    required String iconAsset,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white70, fontSize: 16),
      suffixIcon: GestureDetector(
        onTap: onIconTap,
        child: Padding(
          padding: const EdgeInsets.only(right: 15.0, left: 19),
          child: Image.asset(iconAsset, width: 24, height: 24),
        ),
      ),
      filled: true,
      fillColor: primaryColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
    );
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerCubit, CustomerState>(
      builder: (context, state) {
        final filteredCustomers = state.customers;
        return Column(
          children: [
            TextField(
              controller: controller,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
              decoration: _buildDropdownDecoration(
                hint: 'اسم العميل',
                iconAsset: 'assets/images/pngs/dropdown.png',
                onIconTap: onToggleDropdown,
              ),
            ),
            if (isDropdownVisible && filteredCustomers.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                constraints: const BoxConstraints(maxHeight: 300),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: primaryColor, width: 1.5),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: filteredCustomers.length,
                  itemBuilder: (ctx, idx) {
                    final customer = filteredCustomers[idx];
                    return ListTile(
                      title: Text(customer.name ?? ''),
                      onTap: () => onCustomerSelected(customer),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class ProblemTypeDropdown extends StatelessWidget {
  final TextEditingController controller;
  final bool isDropdownVisible;
  final VoidCallback onToggleDropdown;
  const ProblemTypeDropdown({
    super.key,
    required this.controller,
    required this.isDropdownVisible,
    required this.onToggleDropdown,
  });
  static const Color primaryColor = Color(0xff104D9D);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onToggleDropdown,
          child: Container(
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? 'نوع المشكلة' : controller.text,
                    style: TextStyle(
                      color: controller.text.isEmpty
                          ? Colors.white70
                          : Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Image.asset(
                  'assets/images/pngs/dropdown.png',
                  width: 24,
                  height: 24,
                ),
              ],
            ),
          ),
        ),
        if (isDropdownVisible)
          Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 300),
            padding: const EdgeInsets.only(right: 15.0, left: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: primaryColor, width: 1.5),
            ),
            child: BlocBuilder<CustomerCubit, CustomerState>(
              builder: (context, state) {
                if (state.status == CustomerStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state.status == CustomerStatus.failure) {
                  return Column(
                    children: [
                      const Text('فشل في جلب فئات المشكلة'),
                      TextButton(
                        onPressed: () {
                          context
                              .read<CustomerCubit>()
                              .fetchProblemCategories();
                        },
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  );
                } else if (state.problemCategories.isNotEmpty) {
                  return ListView(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    children: state.problemCategories.map((category) {
                      return ListTile(
                        title: Text(category.name),
                        onTap: () {
                          controller.text = category.name;
                          onToggleDropdown();
                        },
                      );
                    }).toList(),
                  );
                } else {
                  return Column(
                    children: [
                      const Text('لا توجد فئات متاحة'),
                      TextButton(
                        onPressed: () {
                          context
                              .read<CustomerCubit>()
                              .fetchProblemCategories();
                        },
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
      ],
    );
  }
}

class DirectionDropdown extends StatelessWidget {
  final TextEditingController controller;
  final bool isDropdownVisible;
  final VoidCallback onToggleDropdown;
  const DirectionDropdown({
    super.key,
    required this.controller,
    required this.isDropdownVisible,
    required this.onToggleDropdown,
  });
  static const Color primaryColor = Color(0xff104D9D);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onToggleDropdown,
          child: Container(
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? 'توجيه إلي' : controller.text,
                    style: TextStyle(
                      color: controller.text.isEmpty
                          ? Colors.white70
                          : Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Image.asset(
                  'assets/images/pngs/dropdown.png',
                  width: 24,
                  height: 24,
                ),
              ],
            ),
          ),
        ),
        if (isDropdownVisible)
          Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 300),
            padding: const EdgeInsets.only(right: 15.0, left: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: primaryColor, width: 1.5),
            ),
            child: BlocBuilder<EngineerCubit, EngineerState>(
              builder: (context, state) {
                if (state.status == EngineerStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state.engineers.isNotEmpty) {
                  return ListView(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    children: state.engineers.map((engineer) {
                      return ListTile(
                        title: Text(engineer.name),
                        onTap: () {
                          controller.text = engineer.name;
                          onToggleDropdown();
                        },
                      );
                    }).toList(),
                  );
                } else {
                  return const Text('لا توجد مهندسين متاحين');
                }
              },
            ),
          ),
      ],
    );
  }
}

class StatusDropdown extends StatelessWidget {
  final TextEditingController controller;
  final bool isDropdownVisible;
  final VoidCallback onToggleDropdown;
  final Function(ProblemStatusModel) onStatusSelected;
  const StatusDropdown({
    super.key,
    required this.controller,
    required this.isDropdownVisible,
    required this.onToggleDropdown,
    required this.onStatusSelected,
  });
  static const Color primaryColor = Color(0xff104D9D);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onToggleDropdown,
          child: Container(
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? 'حالة المشكلة' : controller.text,
                    style: TextStyle(
                      color: controller.text.isEmpty
                          ? Colors.white70
                          : Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Image.asset(
                  'assets/images/pngs/dropdown.png',
                  width: 24,
                  height: 24,
                ),
              ],
            ),
          ),
        ),
        if (isDropdownVisible)
          Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 300),
            padding: const EdgeInsets.only(right: 15.0, left: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: primaryColor, width: 1.5),
            ),
            child: BlocBuilder<CustomerCubit, CustomerState>(
              builder: (context, state) {
                if (state.status == CustomerStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state.status == CustomerStatus.failure) {
                  return Column(
                    children: [
                      const Text('فشل في جلب حالات المشكلة'),
                      TextButton(
                        onPressed: () {
                          context.read<CustomerCubit>().fetchProblemStatus();
                        },
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  );
                } else if (state.problemStatusList.isNotEmpty) {
                  return ListView(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    children: state.problemStatusList.map((status) {
                      return ListTile(
                        title: Text(status.name),
                        onTap: () {
                          controller.text = status.name;
                          onStatusSelected(status);
                          onToggleDropdown();
                        },
                      );
                    }).toList(),
                  );
                } else {
                  return Column(
                    children: [
                      const Text('لا توجد حالات متاحة'),
                      TextButton(
                        onPressed: () {
                          context.read<CustomerCubit>().fetchProblemStatus();
                        },
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
      ],
    );
  }
}

class ImagePickerWidget extends StatelessWidget {
  final Function(File) onImagePicked;
  const ImagePickerWidget({
    super.key,
    required this.onImagePicked,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => ImagePickerBottomSheet(
            onImagePicked: onImagePicked,
          ),
        );
      },
      child: Image.asset(
        'assets/images/pngs/upload_pic.png',
        width: 100,
        height: 100,
      ),
    );
  }
}

class ImagePickerBottomSheet extends StatelessWidget {
  final Function(File) onImagePicked;
  const ImagePickerBottomSheet({
    super.key,
    required this.onImagePicked,
  });
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('الكاميرا'),
            onTap: () async {
              final picker = ImagePicker();
              final pickedFile =
                  await picker.pickImage(source: ImageSource.camera);
              if (pickedFile != null && pickedFile.path.isNotEmpty) {
                onImagePicked(File(pickedFile.path));
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('فشل في اختيار الصورة')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text('المعرض'),
            onTap: () async {
              final picker = ImagePicker();
              final pickedFile =
                  await picker.pickImage(source: ImageSource.gallery);
              if (pickedFile != null && pickedFile.path.isNotEmpty) {
                onImagePicked(File(pickedFile.path));
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('فشل في اختيار الصورة')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}