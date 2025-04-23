import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tabib_soft_company/core/export.dart';

class CustomLoadingPageWidget extends StatelessWidget {
  const CustomLoadingPageWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 30.h,
        width: 30.w,
        child: const CircularProgressIndicator(
          color: AppColor.primaryColor,
          strokeWidth: 1.5,
        ),
      ),
    );
  }
}
