import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';

class ProfileGuestActions extends StatelessWidget {
  const ProfileGuestActions({super.key, required this.onSignIn});

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'قم بتسجيل الدخول للاستمتاع بجميع الميزات',
          style: TextStyle(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: onSignIn,
            icon: const Icon(Icons.login),
            label: const Text('تسجيل الدخول'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.primaryDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
