import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';

class AuthModeSwitchButton extends StatelessWidget {
  const AuthModeSwitchButton({
    super.key,
    required this.enabled,
    required this.label,
    required this.onPressed,
  });

  final bool enabled;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: enabled ? onPressed : null,
      style: TextButton.styleFrom(foregroundColor: AppColors.textWhite),
      child: Text(label),
    );
  }
}
