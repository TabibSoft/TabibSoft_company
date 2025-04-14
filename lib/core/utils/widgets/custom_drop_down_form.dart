import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tabib_soft_company/core/utils/constant/app_color.dart';
import 'package:tabib_soft_company/core/utils/constant/app_style.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_animated_drop_down_form_field.dart';

class AnimatedDropDownFormFieldWidget extends StatelessWidget {
  const AnimatedDropDownFormFieldWidget({
    super.key,
    this.image,
    required this.controller,
    this.onChangeListState,
    required this.text,
    required this.items,
    required this.listHeight,
    this.onChangeSelectedIndex,
    required this.label,
    this.labelColor,
    this.onTapButton,
    this.actionWidget,
  });
  final String? image;
  final AnimatedDropDownFormFieldController controller;
  final void Function(bool)? onChangeListState;
  final String text;
  final List<Widget> items;
  final double listHeight;
  final Function(int)? onChangeSelectedIndex;
  final String label;
  final Color? labelColor;
  final void Function()? onTapButton;
  final Widget? actionWidget;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0.h),
          child: Row(
            children: [
              Text(
                label,
                style: AppStyle.font14_400Weight.copyWith(
                  color: AppColor.titleColor,
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
        ),
        AnimatedDropDownFormField(
          controller: controller,
          errorBorder: Border.all(),
          defultTextStyle: AppStyle.font14_700Weight.copyWith(
            color: AppColor.titleColor,
            fontWeight: FontWeight.w400,
          ),
          buttonPadding: EdgeInsetsDirectional.symmetric(
            vertical: 18.5.h,
            horizontal: 16.w,
          ),
          buttonDecoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColor.titleColor),
            borderRadius: const BorderRadiusDirectional.all(
              Radius.circular(10),
            ),
          ),
          selectedItemIcon: const Icon(
            Icons.check_rounded,
            color: AppColor.primaryColor,
          ),
          items: items,
          actionWidget: actionWidget ?? const SizedBox(),
          placeHolder: Row(
            children: [
              image != null ? Image.asset(image!) : const SizedBox(),
              Text(text),
            ],
          ),
          onTapButton: onTapButton,
          listHeight: listHeight,
          listBackgroundDecoration: BoxDecoration(
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                color: AppColor.titleColor,
                blurRadius: 3,
                spreadRadius: 0,
              )
            ],
            borderRadius: BorderRadius.circular(8.r),
          ),
          listPadding: const EdgeInsetsDirectional.all(15),
          listScrollPhysics: const BouncingScrollPhysics(),
          onChangeListState: onChangeListState,
          onChangeSelectedIndex: onChangeSelectedIndex,
          dropDownAnimationParameters: const SizingDropDownAnimationParameters(
            duration: Duration(milliseconds: 200),
            reversDuration: Duration(milliseconds: 200),
          ),
        ),
      ],
    );
  }
}
