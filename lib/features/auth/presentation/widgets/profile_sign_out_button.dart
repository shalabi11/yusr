import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';

class ProfileSignOutButton extends StatelessWidget {
  const ProfileSignOutButton({
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
      child: OutlinedButton.icon(
        onPressed: loading ? null : onPressed,
        icon: loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColors.textWhite,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.logout, color: AppColors.textWhite),
        label: const Text(
          'تسجيل الخروج',
          style: TextStyle(color: AppColors.textWhite),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
