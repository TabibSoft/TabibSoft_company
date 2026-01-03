import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tabib_soft_company/core/export.dart';
import 'package:tabib_soft_company/core/helpers/extensions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _backgroundController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _bgMoveAnimation;

  @override
  void initState() {
    super.initState();

    // Main entrance animations
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Continuous pulse effect for the logo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Background decorative movement
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
    ]).animate(_mainController);

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutQuart),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _bgMoveAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      _backgroundController,
    );

    _mainController.forward();
    Future.delayed(const Duration(seconds: 4), checkLoginStatus);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  void checkLoginStatus() {
    if (!mounted) return;
    String token = CacheHelper.getString(key: 'loginToken');
    if (token.isNotEmpty) {
      context.pushReplacementNamed(homeScreen);
    } else {
      context.pushReplacementNamed(loginScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TechColors.primaryDark,
      body: Stack(
        children: [
          // 1. Premium Gradient Base
          Container(
            decoration: const BoxDecoration(
              gradient: TechColors.premiumGradient,
            ),
          ),

          // 2. Animated Background Decorative Elements (Blobs)
          AnimatedBuilder(
            animation: _bgMoveAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  _buildAnimatedBlob(
                    top: 100.h + (math.sin(_bgMoveAnimation.value) * 30),
                    left: -50.w + (math.cos(_bgMoveAnimation.value) * 20),
                    size: 200.r,
                    color: Colors.white.withOpacity(0.05),
                  ),
                  _buildAnimatedBlob(
                    bottom: 150.h + (math.cos(_bgMoveAnimation.value) * 40),
                    right: -30.w + (math.sin(_bgMoveAnimation.value) * 30),
                    size: 250.r,
                    color: TechColors.accentCyan.withOpacity(0.1),
                  ),
                ],
              );
            },
          ),

          // 3. Watermark Logo with Entrance Animation
          Positioned(
            top: -50.h,
            right: -80.w,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Opacity(
                opacity: 0.08,
                child: Transform.rotate(
                  angle: -0.2,
                  child: SizedBox(
                    width: 450.w,
                    height: 450.h,
                    child: Image.asset(
                      'assets/images/pngs/TS_Logo0.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 4. Main Animated Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        padding: EdgeInsets.all(25.r),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: TechColors.accentCyan.withOpacity(0.2),
                              blurRadius: 40,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Hero(
                          tag: 'app_logo',
                          child: Image.asset(
                            'assets/images/pngs/TS_Logo1.png',
                            width: 380.w,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 5. Professional Footer with Staggered Slide
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 50.h),
                  child: Text(
                    'All Rights Reserved © AhmedEshora 2025',
                    style: AppStyle.font11_400Weight.copyWith(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12.sp,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBlob({
    double? top,
    double? left,
    double? bottom,
    double? right,
    required double size,
    required Color color,
  }) {
    return Positioned(
      top: top,
      left: left,
      bottom: bottom,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 50,
              spreadRadius: 20,
            ),
          ],
        ),
      ),
    );
  }
}
