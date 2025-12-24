import 'package:flutter/material.dart';

class DailyMotivationDialog extends StatefulWidget {
  final String message;
  final VoidCallback? onClose;
  const DailyMotivationDialog({super.key, required this.message, this.onClose});

  @override
  State<DailyMotivationDialog> createState() => _DailyMotivationDialogState();
}

class _DailyMotivationDialogState extends State<DailyMotivationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // =========================================================================
  // بناء واجهة الحوار التحفيزية (Motivation Dialog Build)
  // يعتمد على التصميم النظيف، والتباين العالي، والعناصر العائمة
  // =========================================================================
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent, // خلفية شفافة للحوار نفسه
        child: ScaleTransition(
          scale: _scaleAnimation, // حركة تكبير عند الظهور
          child: FadeTransition(
            opacity: _opacityAnimation, // تأثير تلاشي
            child: Stack(
              clipBehavior: Clip.none, // للسماح للأيقونة بالخروج عن حدود الكارد
              alignment: Alignment.topCenter,
              children: [
                // 1. حاوية المحتوى الرئيسية (Main Content Card)
                Container(
                  width: MediaQuery.of(context).size.width * 0.88, // عرض 88%
                  margin: const EdgeInsets.only(
                      top: 45), // ترك مساحة للأيقونة العائمة
                  padding:
                      const EdgeInsets.fromLTRB(25, 65, 25, 25), // حواشي داخلية
                  decoration: BoxDecoration(
                    color: Colors
                        .white, // خلفية بيضاء نقية (White Background) - حل مشكلة التباين
                    borderRadius:
                        BorderRadius.circular(32), // حواف دائرية ناعمة
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F5FA8).withOpacity(0.25),
                        blurRadius: 60,
                        offset: const Offset(0, 20),
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // علامة تنصيص علوية (Top Quote Icon)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.format_quote_rounded,
                              size: 36, color: Colors.grey.withOpacity(0.15)),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // 2. نص الرسالة التحفيزية (The Message Text)
                      // استخدام خط واضح ولون غامق لضمان القراءة
                      Text(
                        // استخدام نص احتياطي في حالة فراغ الرسالة
                        (widget.message.isEmpty)
                            ? "يومك جميل ومليء بالإنجازات! 🌟"
                            : widget.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 21, // حجم خط كبير
                          height: 1.6, // تباعد أسطر مريح
                          color: Color(
                              0xFF2D3436), // لون أسود فحمي للتباين العالي (Black-Charcoal)
                          fontWeight: FontWeight.w700, // سمك خط عريض
                          fontFamily: 'Amiri',
                        ),
                      ),
                      const SizedBox(height: 10),

                      // علامة تنصيص سفلية (Bottom Quote Icon)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Transform.rotate(
                            angle: 3.14, // تدوير الأيقونة
                            child: Icon(Icons.format_quote_rounded,
                                size: 36, color: Colors.grey.withOpacity(0.15)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 35),

                      // 3. زر الإجراء (Action Button)
                      // زر بتدرج لوني يعطي طابع الحداثة والنشاط
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF0F5FA8),
                              Color(0xFF00C6FF)
                            ], // تدرج أزرق وسماوي
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F5FA8).withOpacity(0.35),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              if (widget.onClose != null) {
                                widget.onClose!();
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
                            splashColor:
                                Colors.white.withOpacity(0.2), // تأثير ضغطة
                            child: const Center(
                              child: Text(
                                'يلا بينا نشوف شغلنا 🚀', // نص الزر
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Colors.white, // نص أبيض على خلفية متدرجة
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 4. الأيقونة العائمة (Floating Header Icon)
                // تظهر فوق الكارد كعنصر جمالي بارز
                Positioned(
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFCC00), // لون أصفر ذهبي (Golden)
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFFCC00),
                          Color(0xFFFF9500)
                        ], // تدرج ذهبي وبرتقالي
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFCC00).withOpacity(0.5),
                          blurRadius: 25,
                          offset: const Offset(0, 12),
                        ),
                        const BoxShadow(
                          color: Colors.white,
                          blurRadius: 0,
                          spreadRadius:
                              8, // حدود بيضاء تفصل الأيقونة عن الخلفية
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome, // أيقونة النجوم/السحر
                      size: 48,
                      color: Colors.white,
                    ),
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
