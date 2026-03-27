import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';

class AppRadialBackground extends StatelessWidget {
  const AppRadialBackground({
    required this.child,
    this.useSafeArea = true,
    super.key,
  });

  final Widget child;
  final bool useSafeArea;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 2.0,
          colors: [AppColors.primaryDark, AppColors.background],
        ),
      ),
      child: useSafeArea ? SafeArea(child: child) : child,
    );
  }
}
