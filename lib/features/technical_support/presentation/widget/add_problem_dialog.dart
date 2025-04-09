import 'package:flutter/material.dart';

class AddProblemDialog extends StatelessWidget {
  final TextEditingController field1Controller;
  final TextEditingController field2Controller;
  final List<String> selectedImageUrls;
  final VoidCallback onSave;
  final VoidCallback onShowImagePicker;
  final Color primaryColor;

  const AddProblemDialog({
    super.key,
    required this.field1Controller,
    required this.field2Controller,
    required this.selectedImageUrls,
    required this.onSave,
    required this.onShowImagePicker,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return field1Controller.text.isEmpty &&
            field2Controller.text.isEmpty &&
            selectedImageUrls.isEmpty;
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: field1Controller,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'تفاصيل المشكلة',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: primaryColor,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: primaryColor,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 16.0,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: field2Controller,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'تفاصيل الحل',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: primaryColor,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: primaryColor,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 16.0,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: onShowImagePicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 16.0,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: primaryColor,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    selectedImageUrls.isEmpty
                        ? 'اضغط لعرض الصور الملحقة'
                        : 'تم اختيار ${selectedImageUrls.length} صورة',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                ),
                child: const Text(
                  'حفظ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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