// lib/features/home/presentation/widgets/mediator_widgets.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class RowField extends StatelessWidget {
  const RowField({super.key, required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Color(0xFF2D2D2D)),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

Widget boxedText(TextEditingController c,
    {TextInputType type = TextInputType.text}) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xff104D9D),
      borderRadius: BorderRadius.circular(12),
    ),
    child: TextFormField(
      controller: c,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: TextStyle(color: Colors.white70),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? ' مطلوب' : null,
    ),
  );
}

Widget boxedMultiline(TextEditingController c) {
  return Container(
    height: 100.h,
    decoration: BoxDecoration(
      color: const Color(0xff104D9D),
      borderRadius: BorderRadius.circular(12),
    ),
    child: TextFormField(
      controller: c,
      maxLines: null,
      expands: true,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: TextStyle(color: Colors.white70),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? ' مطلوب' : null,
    ),
  );
}

Widget dropdownBox(TextEditingController c, {VoidCallback? onTap}) {
  return Container(
    height: 52,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: Colors.orange,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Center(
      child: TextFormField(
        controller: c,
        readOnly: true,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'اختر',
          hintStyle: const TextStyle(color: Colors.white70),
          isCollapsed: true,
          suffixIcon: Padding(
            padding: const EdgeInsetsDirectional.only(end: 6),
            child: Image.asset(
              'assets/images/pngs/dropdown.png',
              width: 10,
              height: 14,
              fit: BoxFit.contain,
              color: Colors.white,
            ),
          ),
        ),
        validator: (v) => (v == null || v.trim().isEmpty) ? ' مطلوب' : null,
        onTap: onTap,
      ),
    ),
  );
}

Widget dateBox({
  required String value,
  required VoidCallback onTap,
  IconData icon = Icons.calendar_month,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xff104D9D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );
}

Widget dialogGrabberAndTitle(String title) {
  return Column(
    children: [
      Container(
        width: 50,
        height: 5,
        margin: const EdgeInsets.only(top: 6, bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      Text(
        title,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F5FA8)),
      ),
    ],
  );
}

Widget saveButton({required VoidCallback onPressed, bool isLoading = false}) {
  return SizedBox(
    width: double.infinity,
    height: 48,
    child: ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF20AAC9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text('حفظ',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    ),
  );
}

class DatePickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onConfirm;

  const DatePickerDialog(
      {super.key, required this.initialDate, required this.onConfirm});

  @override
  State<DatePickerDialog> createState() => _DatePickerDialogState();
}

class _DatePickerDialogState extends State<DatePickerDialog> {
  late DateTime _temp;

  @override
  void initState() {
    super.initState();
    _temp = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: const Color(0xFF104D9D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: SizedBox(
          width: 360,
          child: Theme(
            data: ThemeData.dark(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                const Text('اختر التاريخ',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 18)),
                const Divider(height: 20, color: Colors.white70),
                CalendarDatePicker(
                  initialDate: _temp,
                  firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  onDateChanged: (d) => setState(() => _temp = d),
                ),
                const Divider(height: 20, color: Colors.white70),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style:
                              OutlinedButton.styleFrom(foregroundColor: Colors.white),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('إلغاء'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF20AAC9)),
                          onPressed: () {
                            widget.onConfirm(_temp);
                            Navigator.pop(context);
                          },
                          child: const Text('تأكيد'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget imagesUploadSection({
  required List<String> imagePaths,
  required VoidCallback onPickImage,
}) {
  return Column(
    children: [
      Text(
        'رفع الملفات',
        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 10.h),
      GestureDetector(
        onTap: onPickImage,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset('assets/images/pngs/pictures_folder.png',
                width: 90.w, height: 90.h),
            if (imagePaths.isNotEmpty)
              Positioned(
                right: 0,
                top: 0,
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.red,
                  child: Text(imagePaths.length.toString(),
                      style: TextStyle(fontSize: 12.sp, color: Colors.white)),
                ),
              ),
            const Text('+', style: TextStyle(color: Colors.white, fontSize: 30)),
          ],
        ),
      ),
      if (imagePaths.isNotEmpty)
        SizedBox(
          height: 100.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: imagePaths.length,
            itemBuilder: (context, i) => Padding(
              padding: EdgeInsets.all(8.w),
              child: Image.file(File(imagePaths[i]),
                  width: 80.w, height: 80.h, fit: BoxFit.cover),
            ),
          ),
        ),
    ],
  );
}