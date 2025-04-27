// lib/features/auth/presentation/screens/login/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tabib_soft_company/core/helpers/space_helper.dart';
import 'package:tabib_soft_company/core/services/firebase/firebase_notification/notification.dart'
    show MessagingConfig;
import 'package:tabib_soft_company/core/services/locator/get_it_locator.dart';
import 'package:tabib_soft_company/core/utils/cache/cache_helper.dart';
import 'package:tabib_soft_company/core/utils/validator.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_loading_page_widget.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_text_form_field.dart';
import 'package:tabib_soft_company/features/auth/presentation/cubits/login_cubit.dart';
import 'package:tabib_soft_company/features/auth/presentation/cubits/login_state.dart';
import 'package:tabib_soft_company/features/home/presentation/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passController;
  late GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  String token = '';

  @override
  void initState() {
    super.initState();
    _emailController = context.read<LoginCubit>().emailController;
    _passController = context.read<LoginCubit>().passController;
    MessagingConfig.getDeviceToken().then((value) {
      print('Device token: $value');
      token = value;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) async {
          if (state.status == LoginStatus.loading) {
            showDialog(
              context: context,
              builder: (context) {
                return Transform.scale(
                  scale: 0.6,
                  child: Dialog(
                    backgroundColor: Colors.white,
                    child: SizedBox(
                      width: 200.w,
                      height: 150.h,
                      child: const CustomLoadingPageWidget(),
                    ),
                  ),
                );
              },
            );
          }
          if (state.status == LoginStatus.success) {
            // حفظ التوكن
            await CacheHelper.saveData(
              key: 'loginToken',
              value: state.data!.token,
            );
            // حفظ اسم المستخدم للإظهار لاحقاً
            await CacheHelper.saveData(
              key: 'userName',
              value: _emailController.text,
            );

            print('Token saved: ${state.data!.token}');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          } else if (state.status == LoginStatus.failure) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('الحساب او كلمة المرور غير صحيحة')),
            );
          }
        },
        builder: (context, state) {
          return Form(
            key: loginFormKey,
            child: Stack(
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/pngs/tabibLogo.png',
                        width: 100.w,
                        height: 100.h,
                      ),
                      verticalSpace(50),
                      Container(
                        padding: EdgeInsets.all(20.sp),
                        margin: EdgeInsets.symmetric(horizontal: 20.sp),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 155, 155, 155)
                              .withOpacity(0.3),
                          borderRadius: BorderRadius.circular(25.r),
                        ),
                        width: MediaQuery.sizeOf(context).width,
                        height: 450.h,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'تسجيل الدخول',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            verticalSpace(10),
                            const Text(
                              'معلومات شخصيه',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF178CBB),
                              ),
                            ),
                            verticalSpace(20),
                            CustomTextFormField(
                              height: 70.h,
                              controller: _emailController,
                              textInputType: TextInputType.emailAddress,
                              label: '',
                              prefixIcon: true,
                              prefixImage: 'assets/images/pngs/email.png',
                              hint: 'ادخل الاسم او الايميل',
                              validator: (value) =>
                                  Validator.emailValidator(value),
                            ),
                            verticalSpace(20),
                            CustomTextFormField(
                              height: 70.h,
                              controller: _passController,
                              textInputType: TextInputType.visiblePassword,
                              label: '',
                              prefixIcon: true,
                              prefixImage: 'assets/images/pngs/password.png',
                              hint: 'ادخل الباسوورد',
                              isPassword: true,
                              validator: (value) =>
                                  Validator.passwordValidator(value),
                            ),
                            verticalSpace(25),
                            ElevatedButton(
                              onPressed: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                if (loginFormKey.currentState!.validate()) {
                                  context
                                      .read<LoginCubit>()
                                      .login(dKey: token);
                                }
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
                              child: const Text(
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
              ],
            ),
          );
        },
      ),
    );
  }
}
