// lib/features/auth/presentation/screens/login/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tabib_soft_company/core/services/firebase/firebase_notification/notification.dart';
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

  // password obscure toggle
  bool _isPasswordObscure = true;

  static const Color teal1 = Color(0xff104D9D);
  static const Color teal2 = Color(0xff20AAC9);

  @override
  void initState() {
    super.initState();
    _emailController = context.read<LoginCubit>().emailController;
    _passController = context.read<LoginCubit>().passController;
    MessagingConfig.getDeviceToken().then((value) {
      debugPrint('Device token: $value');
      token = value ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(430, 932),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) async {
          if (state.status == LoginStatus.loading) {
            // show loading dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return Transform.scale(
                  scale: 0.6,
                  child: Dialog(
                    backgroundColor: Colors.white10,
                    elevation: 0,
                    child: SizedBox(
                      width: 200.w,
                      height: 150.h,
                      child: const CustomLoadingPageWidget(),
                    ),
                  ),
                );
              },
            );
          } else {
            // whenever status is not loading, try to close any loading dialog shown earlier
            if (Navigator.canPop(context)) Navigator.pop(context);
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

            debugPrint('Token saved: ${state.data!.token}');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          } else if (state.status == LoginStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('الحساب او كلمة المرور غير صحيحة')),
            );
          }
        },
        builder: (context, state) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Stack(
              children: [
                // Full background gradient
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [teal1, teal2],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),

                // Top large logo / illustration area
                Positioned(
                  top: 100.h,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 160.h,
                        child: Image.asset(
                          'assets/images/pngs/TS_Logo0.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Image.asset('assets/images/pngs/TabibSoft CRM.png')
                    ],
                  ),
                ),

                // White rounded bottom card
                Positioned(
                  top: 400.h,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F8FA),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(48),
                        topRight: Radius.circular(48),
                      ),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 22.w, vertical: 26.h),
                        child: Form(
                          key: loginFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 6.h),
                              const Text(
                                'تسجيل الدخول',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0E3346),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              SizedBox(height: 18.h),

                              // Email field wrapped as white card
                              _fieldCard(
                                child: CustomTextFormField(
                                  height: 70.h,
                                  controller: _emailController,
                                  textInputType: TextInputType.emailAddress,
                                  label: '',
                                  prefixIcon: true,
                                  prefixImage: 'assets/images/pngs/email.png',
                                  hint: 'البريد الالكتروني',
                                  validator: (value) =>
                                      Validator.emailValidator(value),
                                ),
                              ),

                              SizedBox(height: 14.h),

                              // Password field wrapped as white card
                              // Using a native TextFormField here to ensure we can add the show/hide toggle easily.
                              _fieldCard(
                                child: SizedBox(
                                  height: 70.h,
                                  child: TextFormField(
                                    controller: _passController,
                                    keyboardType: TextInputType.visiblePassword,
                                    obscureText: _isPasswordObscure,
                                    validator: (value) =>
                                        Validator.passwordValidator(value),
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                    ),
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12.w, vertical: 18.h),
                                      hintText: 'كلمة المرور',
                                      hintStyle: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 16.sp,
                                      ),
                                      border: InputBorder.none,
                                      prefixIcon: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12.w),
                                        child: SizedBox(
                                          width: 30.w,
                                          height: 30.h,
                                          child: Image.asset(
                                            'assets/images/pngs/password.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      prefixIconConstraints: BoxConstraints(
                                        minWidth: 40.w,
                                        minHeight: 40.h,
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _isPasswordObscure =
                                                !_isPasswordObscure;
                                          });
                                        },
                                        icon: Icon(
                                          _isPasswordObscure
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 16.h),

                              // Remember row (kept simple)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(width: 8.w),
                                ],
                              ),

                              SizedBox(height: 18.h),

                              // Login button
                              SizedBox(
                                width: double.infinity,
                                height: 58.h,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    if (loginFormKey.currentState!.validate()) {
                                      context
                                          .read<LoginCubit>()
                                          .login(dKey: token);
                                    }
                                  },
                                  icon: const Icon(Icons.arrow_back_ios_new,
                                      color: Colors.white),
                                  label: const Text(
                                    'تسجيل الدخول',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: teal2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 14.h),

                              SizedBox(height: 18.h),
                              Container(height: 1.h, color: Colors.grey[300]),
                              SizedBox(height: 12.h),

                              SizedBox(height: 100.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _fieldCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(16, 152, 157, 0.06),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      child: child,
    );
  }
}
