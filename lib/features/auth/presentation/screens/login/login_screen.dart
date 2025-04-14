import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/core/networking/dio_factory.dart';
import 'package:tabib_soft_company/core/utils/cache/cache_helper.dart';
import 'package:tabib_soft_company/features/auth/data/repos/login_repo.dart';
import 'package:tabib_soft_company/features/auth/presentation/cubits/login_cubit.dart';
import 'package:tabib_soft_company/features/auth/presentation/cubits/login_state.dart';
import 'package:tabib_soft_company/features/home/presentation/screens/home_screen.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/screen/support_home/technical_support_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dio = DioFactory.getDio();
    final repo = LoginReposetory(dio);
    return BlocProvider(
      create: (_) => LoginCubit(repo),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  String? _dKey;
  bool _loadingKey = true;

  @override
  void initState() {
    super.initState();
    _initDeviceKey();
  }

  Future<void> _initDeviceKey() async {
    final deviceInfo = DeviceInfoPlugin();
    String key;
    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      key = info.id ?? 'unknown_android_id';
    } else if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      key = info.identifierForVendor ?? 'unknown_ios_id';
    } else {
      key = 'unsupported_platform';
    }
    setState(() {
      _dKey = key;
      _loadingKey = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loadingKey
          ? const Center(child: CircularProgressIndicator())
          : BlocConsumer<LoginCubit, LoginState>(
              listener: (context, state) async {
                if (state.status == LoginStatus.success) {
                  await CacheHelper.saveData(
                    key: 'loginToken',
                    value: state.data!.token,
                  );
                  await CacheHelper.saveData(
                    key: 'userName',
                    value: state.data!.user.name,
                  );
                  print('Token saved: ${state.data!.token}'); 
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                } else if (state.status == LoginStatus.failure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.error ?? 'حدث خطأ')),
                  );
                }
              },
              builder: (context, state) {
                return Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF86EFAC),
                            Color(0xFF7DD3FC),
                          ],
                          begin: Alignment.topRight,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
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
                    Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset('assets/images/pngs/tabibLogo.png',
                                width: 80),
                            const SizedBox(height: 50),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 155, 155, 155)
                                    .withOpacity(0.3),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              width: 300,
                              child: Column(
                                children: [
                                  const Text(
                                    'تسجيل الدخول',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'معلومات شخصيه',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF178CBB),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  _buildInputField(
                                    'ادخل الاسم او الايميل',
                                    'assets/images/pngs/email.png',
                                    controller: _emailCtrl,
                                  ),
                                  const SizedBox(height: 10),
                                  _buildInputField(
                                    'ادخل الباسوورد',
                                    'assets/images/pngs/password.png',
                                    isPassword: true,
                                    controller: _passCtrl,
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () {
                                      context.read<LoginCubit>().login(
                                            email: _emailCtrl.text.trim(),
                                            password: _passCtrl.text.trim(),
                                            dKey: _dKey!,
                                          );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF178CBB),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 50,
                                      ),
                                    ),
                                    child: state.status == LoginStatus.loading
                                        ? const CircularProgressIndicator(
                                            color: Colors.white)
                                        : const Text(
                                            'دخول',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildInputField(String hintText, String imagePath,
      {bool isPassword = false, TextEditingController? controller}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Image.asset(imagePath, width: 20, height: 20),
          ),
        ),
      ),
    );
  }
}
