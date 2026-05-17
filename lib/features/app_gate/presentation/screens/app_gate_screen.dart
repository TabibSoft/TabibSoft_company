import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tabib_soft_company/core/export.dart';
import 'package:tabib_soft_company/core/helpers/extensions.dart';
import 'package:tabib_soft_company/features/app_gate/presentation/cubit/app_gate_cubit.dart';
import 'package:tabib_soft_company/features/app_gate/presentation/cubit/app_gate_state.dart';

class AppGateScreen extends StatefulWidget {
  const AppGateScreen({super.key});

  @override
  State<AppGateScreen> createState() => _AppGateScreenState();
}

class _AppGateScreenState extends State<AppGateScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AppGateCubit>().checkAppAccess();
  }

  void _navigateBasedOnLoginStatus() {
    final String token = CacheHelper.getString(key: 'loginToken');
    if (token.isNotEmpty) {
      context.pushReplacementNamed(homeScreen);
    } else {
      context.pushReplacementNamed(loginScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppGateCubit, AppGateState>(
      listener: (context, state) {
        switch (state.status) {
          case AppGateStatus.allowed:
            _navigateBasedOnLoginStatus();
            break;
          case AppGateStatus.blocked:
            context.pushReplacementNamed(appBlockedScreen);
            break;
          case AppGateStatus.initial:
          case AppGateStatus.checking:
          case AppGateStatus.error:
            // Stay on this screen, show loading
            break;
        }
      },
      child: Scaffold(
        backgroundColor: TechColors.primaryDark,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: TechColors.premiumGradient,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Loading Indicator
                SizedBox(
                  width: 50.w,
                  height: 50.w,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'جاري التحقق...',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white.withOpacity(0.8),
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
