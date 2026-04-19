import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';

class AuthHeaderIcon extends StatelessWidget {
  const AuthHeaderIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.person_outline_rounded,
      size: 64,
      color: AppColors.accent,
    );
  }
}
