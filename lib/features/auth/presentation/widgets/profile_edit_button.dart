import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';

class ProfileEditButton extends StatelessWidget {
  const ProfileEditButton({
    super.key,
    required this.loading,
    required this.onPressed,
  });

  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: loading ? null : onPressed,
        icon: const Icon(Icons.edit_outlined),
        label: const Text('تعديل الملف الشخصي'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.primaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
