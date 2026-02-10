import 'dart:math' as math;
import 'package:flutter/material.dart';

class CodingLoader extends StatefulWidget {
  const CodingLoader({super.key});

  @override
  State<CodingLoader> createState() => _CodingLoaderState();
}

class _CodingLoaderState extends State<CodingLoader>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _barController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _barController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Chart Icon
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF104D9D), Color(0xFF20AAC9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF104D9D).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: AnimatedBuilder(
                animation: _barController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: SalesChartPainter(
                      progress: _barController.value,
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Loading Text
          const Text(
            "جارٍ تحميل البيانات",
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF104D9D),
            ),
          ),

          const SizedBox(height: 16),

          // Animated dots
          AnimatedBuilder(
            animation: _barController,
            builder: (context, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  final delay = index * 0.3;
                  final value = math.sin(
                      (_barController.value * 2 * math.pi) + (delay * math.pi));
                  final opacity = ((value + 1) / 2).clamp(0.3, 1.0);

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF104D9D).withOpacity(opacity),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}

class SalesChartPainter extends CustomPainter {
  final double progress;

  SalesChartPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw animated bar chart
    final barPaint = Paint()..color = Colors.white;

    const barWidth = 12.0;
    const spacing = 8.0;
    const totalWidth = (barWidth * 4) + (spacing * 3);
    final startX = centerX - (totalWidth / 2);

    for (int i = 0; i < 4; i++) {
      // Animate each bar with different phase
      final phase = (progress + (i * 0.25)) % 1.0;
      final heightMultiplier = 0.4 + (math.sin(phase * math.pi * 2) * 0.3);
      const maxHeight = 50.0;
      final barHeight = maxHeight * heightMultiplier;

      final x = startX + (i * (barWidth + spacing));
      final y = centerY + 20 - barHeight;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(4),
        ),
        barPaint,
      );
    }

    // Draw trend line
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(startX - 5, centerY);

    for (int i = 0; i <= 4; i++) {
      final phase = (progress + (i * 0.25)) % 1.0;
      final yOffset = math.sin(phase * math.pi * 2) * 15;
      final x = startX + (i * (barWidth + spacing));
      final y = centerY - 10 + yOffset;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);

    // Draw small circle at end of trend line
    final dotPaint = Paint()..color = Colors.white;
    final lastPhase = (progress + 1.0) % 1.0;
    final lastY = centerY - 10 + (math.sin(lastPhase * math.pi * 2) * 15);
    canvas.drawCircle(
      Offset(startX + (4 * (barWidth + spacing)), lastY),
      4,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(SalesChartPainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

class AnimatedBuilder extends StatelessWidget {
  final Listenable animation;
  final Widget Function(BuildContext, Widget?) builder;

  const AnimatedBuilder({
    super.key,
    required this.animation,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return _AnimatedBuilderWidget(animation: animation, builder: builder);
  }
}

class _AnimatedBuilderWidget extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;

  const _AnimatedBuilderWidget({
    required Listenable animation,
    required this.builder,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}
