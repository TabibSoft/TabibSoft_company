import 'package:flutter/material.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_app_bar_widget.dart';

class CustomNavBar extends StatelessWidget {
  final List<Widget> items;
  final MainAxisAlignment alignment;
  final double height;
  final EdgeInsetsGeometry padding;

  const CustomNavBar({
    Key? key,
    required this.items,                   // ← your icons/widgets here
    this.alignment = MainAxisAlignment.spaceBetween,
    this.height = 60,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
  }) : super(key: key);

  static const Color primaryColor = CustomAppBar.primaryColor;
  static const Color secondaryColor = CustomAppBar.secondaryColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [secondaryColor, primaryColor],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      padding: padding,
      child: Row(
        mainAxisAlignment: alignment,
        children: items,
      ),
    );
  }
}
