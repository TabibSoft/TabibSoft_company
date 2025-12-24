import 'package:flutter/material.dart';
import 'package:tabib_soft_company/core/export.dart';

class AdhkarInfoCard extends StatelessWidget {
  final String currentAdhkar;
  final VoidCallback onDismiss;

  const AdhkarInfoCard({
    super.key,
    required this.currentAdhkar,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Material(
      type: MaterialType.transparency,
      child: Container(
        // تحديد عرض البطاقة كنسبة من عرض الشاشة
        width: size.width * 0.85,
        // تنسيق الحواشي الداخلية
        padding: const EdgeInsets.only(left: 10, right: 16, top: 16, bottom: 8),
        // مسافة خارجية للبطاقة
        margin: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
            color: AppColor
                .primaryColor, // خلفية حمراء احترافية (Professional Red)
            // حواف دائرية من جهة اليسار فقط لتعطي إيحاء الانبثاق
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              bottomLeft: Radius.circular(24),
            ),
            // إضافة ظل ناعم للبطاقة لإبرازها
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD93025).withOpacity(0.4), // ظل أحمر خفيف
                blurRadius: 20,
                offset: const Offset(4, 8),
              ),
            ],
            // حدود خفيفة لتحديد الإطار
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // أيقونة القلب للتعبير عن الروحانيات (Heart Icon)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white, // خلفية بيضاء للأيقونة
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4))
                      ]),
                  child: const Text(
                    '📿',
                    style: TextStyle(
                      // color: AppColor.primaryColor,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 14), // مسافة بين الأيقونة والنص

                // محتوى الذكر (The Adhkar Text)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // عنوان صغير
                      const Text('ذكر وتذكير 📿',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70, // لون أبيض شفاف
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Amiri',
                          )),
                      const SizedBox(height: 4),
                      // نص الذكر الفعلي - أبيض للتباين على الخلفية الحمراء
                      Text(
                        currentAdhkar.isEmpty ? 'سبحان الله' : currentAdhkar,
                        style: const TextStyle(
                          fontSize: 18, // حجم خط واضح
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // أبيض ناصع
                          height: 1.5,
                          fontFamily: 'Amiri',
                        ),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // زر إغلاق صغير (Close Button)
                GestureDetector(
                  onTap: onDismiss,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle),
                    child:
                        const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // شريط التقدم الزمني (Time Progress Bar)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: const LinearProgressIndicator(
                minHeight: 4,
                backgroundColor: Colors.white24, // خلفية شفافة للشريط
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.white), // تقدم أبيض
              ),
            )
          ],
        ),
      ),
    );
  }
}
