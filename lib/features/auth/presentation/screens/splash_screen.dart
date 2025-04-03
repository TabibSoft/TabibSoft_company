import 'package:flutter/material.dart';
import 'package:tabib_soft_company/features/auth/presentation/screens/login/login_screen.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topRight,
            colors: [
              Color(0xFF88C8F3),
              Color(0xFF90F398),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -70,
              left: -200,
              child: Transform.rotate(
                angle: 65.44 * (3.141592653589793 / 180),
                child: Opacity(
                  opacity: 0.5,
                  child: Container(
                    width: 500,
                    height: 380,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1BBCFC),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      width: 150,
                      height: 150,
                      child: Image.asset(
                        'assets/images/pngs/tabibLogo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                const Text(
                  'All Rights Reserved © TabibSoft 2025',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
