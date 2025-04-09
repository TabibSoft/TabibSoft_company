import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final String? logoAsset;
  final double height;
  final Widget? leading; // ← Added leading widget
  final List<Widget>? actions; // ← Renamed buttons to actions for clarity

  const CustomAppBar({
    Key? key,
    required this.title,
    this.subtitle,
    this.logoAsset,
    this.height = 280,
    this.leading, // ← New parameter
    this.actions, // ← Renamed from buttons
  }) : super(key: key);

  static const Color primaryColor = Color(0xFF56C7F1);
  static const Color secondaryColor = Color(0xFF75D6A9);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [primaryColor, secondaryColor],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),

          // Decorative circle
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

          // Logo + title
          Positioned(
            top: height * 0.25,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const SizedBox(height: 30),
                if (logoAsset != null) ...[
                  Image.asset(
                    logoAsset!,
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Leading widget in the top-left
          if (leading != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              child: leading!,
            ),

          // Action buttons in the top-right
          if (actions != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 16,
              child: Row(children: actions!),
            ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
