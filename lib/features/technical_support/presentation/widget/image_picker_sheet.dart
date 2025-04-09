import 'package:flutter/material.dart';

class ImagePickerBottomSheet extends StatefulWidget {
  final List<String> imageUrls;
  final List<String> selectedImageUrls;

  const ImagePickerBottomSheet({
    super.key,
    required this.imageUrls,
    required this.selectedImageUrls,
  });

  static const Color primaryColor = Color(0xFF56C7F1);

  @override
  State<ImagePickerBottomSheet> createState() => _ImagePickerBottomSheetState();
}

class _ImagePickerBottomSheetState extends State<ImagePickerBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height * 2 / 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'اختر صورة',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ImagePickerBottomSheet.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: widget.imageUrls.length,
                itemBuilder: (context, index) {
                  final isSelected = widget.selectedImageUrls.contains(widget.imageUrls[index]);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          widget.selectedImageUrls.remove(widget.imageUrls[index]);
                        } else {
                          widget.selectedImageUrls.add(widget.imageUrls[index]);
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? ImagePickerBottomSheet.primaryColor : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              widget.imageUrls[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          if (isSelected)
                            const Positioned(
                              top: 5,
                              right: 5,
                              child: Icon(
                                Icons.check_circle,
                                color: ImagePickerBottomSheet.primaryColor,
                                size: 24,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ImagePickerBottomSheet.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),
              child: const Text(
                'تم',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}