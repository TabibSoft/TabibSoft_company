import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:tabib_soft_company/features/technical_support/presentation/widget/image_picker_sheet.dart';

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