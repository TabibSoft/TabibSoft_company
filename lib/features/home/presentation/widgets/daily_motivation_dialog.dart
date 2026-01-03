import 'package:flutter/material.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';

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
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // Main Container
                Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  margin: const EdgeInsets.only(top: 40),
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: TechColors.primaryDark.withOpacity(0.3),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Fancy Quote Icons
                      Icon(Icons.format_quote_rounded,
                          size: 40,
                          color: TechColors.accentCyan.withOpacity(0.1)),

                      const SizedBox(height: 12),

                      // Motivation Text
                      Text(
                        (widget.message.isEmpty)
                            ? "يومك جميل ومليء بالإنجازات! 🌟"
                            : widget.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          height: 1.5,
                          color: Color(0xFF2D3436),
                          fontWeight: FontWeight.w800,
                          fontFamily:
                              'Cairo', // Using Cairo as standard for app
                        ),
                      ),

                      const SizedBox(height: 12),

                      Transform.rotate(
                        angle: 3.14,
                        child: Icon(Icons.format_quote_rounded,
                            size: 40,
                            color: TechColors.accentCyan.withOpacity(0.1)),
                      ),

                      const SizedBox(height: 30),

                      // Action Button
                      GestureDetector(
                        onTap: () {
                          if (widget.onClose != null) {
                            widget.onClose!();
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: TechColors.premiumGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: TechColors.accentCyan.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'يلا بينا نشوف شغلنا 🚀',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Floating Icon Header
                Positioned(
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFA500).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                        const BoxShadow(
                          color: Colors.white,
                          spreadRadius: 6,
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 42,
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
