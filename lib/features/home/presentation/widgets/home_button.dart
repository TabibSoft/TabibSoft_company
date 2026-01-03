import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';

class HomeButton extends StatefulWidget {
  final String iconPath;
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final Color primaryColor;
  final int index; // Added for staggered animation

  const HomeButton({
    super.key,
    required this.iconPath,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.primaryColor = AppColor.primaryColor,
    this.index = 0,
  });

  @override
  State<HomeButton> createState() => _HomeButtonState();
}

class _HomeButtonState extends State<HomeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _depthAnimation; // لتغيير العمق عند الضغط

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _depthAnimation = Tween<double>(begin: 20.0, end: 8.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final backgroundColor =
        Colors.grey.shade100; // خلفية فاتحة ليعمل التأثير الـ Neumorphic جيداً

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (widget.index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: widget.enabled ? widget.onTap : () => _showToast(context),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final depth = _depthAnimation.value;
            final lightShadow = BoxShadow(
              color: Colors.white.withOpacity(0.7),
              offset: Offset(-depth / 2, -depth / 2),
              blurRadius: depth,
            );
            final darkShadow = BoxShadow(
              color: Colors.black.withOpacity(0.15),
              offset: Offset(depth / 2, depth / 2),
              blurRadius: depth,
            );

            return ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: widget.enabled
                      ? [lightShadow, darkShadow]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(0, 4),
                            blurRadius: 10,
                          ),
                        ],
                ),
                child: Stack(
                  children: [
                    // Decorative Gradient Corner (مُعدّل ليتناسب مع Neumorphic)
                    if (widget.enabled)
                      Positioned(
                        top: -20,
                        right: -20,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: widget.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),

                    // Main Content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: widget.enabled
                                    ? [
                                        widget.primaryColor.withOpacity(0.2),
                                        widget.primaryColor.withOpacity(0.05),
                                      ]
                                    : [
                                        Colors.grey.shade200,
                                        Colors.grey.shade100
                                      ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: widget.enabled
                                  ? [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.8),
                                        offset: const Offset(-6, -6),
                                        blurRadius: 12,
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        offset: const Offset(6, 6),
                                        blurRadius: 12,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: widget.enabled
                                ? Image.asset(
                                    widget.iconPath,
                                    width: size.width * 0.12,
                                    height: size.width * 0.12,
                                    fit: BoxFit.contain,
                                  )
                                : Icon(Icons.lock_person_rounded,
                                    size: size.width * 0.1,
                                    color: Colors.grey.shade400),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            widget.label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: widget.enabled
                                  ? const Color(0xFF2D3436)
                                  : Colors.grey.shade500,
                              fontSize: size.width * 0.042,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Lock indicator
                    if (!widget.enabled)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Icon(Icons.lock_outline_rounded,
                            size: 16, color: Colors.grey.shade400),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showToast(BuildContext context) {
    final responses = [
      'إنت بتعمل إيه هنا؟ 🤔',
      'لو ضغطت تاني هنبلغ الإدارة 👮‍♂️',
      'ده مش ليك يا نجم ✨',
      'حاول في مكان تاني يا بطل 🦾',
      'بس يا بــابــا 🤗',
      'وحش الكودينج بيسلم عليك 👋',
      'خليك في حالك يا جميل 🌹'
    ];
    final random = Random().nextInt(responses.length);
    Fluttertoast.showToast(
      msg: responses[random],
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.redAccent,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
