import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';

class ProfileUserNameText extends StatelessWidget {
  const ProfileUserNameText({
    super.key,
    required this.isAnonymous,
    required this.username,
    required this.email,
  });

  final bool isAnonymous;
  final String? username;
  final String? email;

  @override
  Widget build(BuildContext context) {
    final normalizedUsername = username?.trim();
    final hasUsername =
        normalizedUsername != null && normalizedUsername.isNotEmpty;

    return Text(
      isAnonymous
          ? 'مستخدم زائر'
          : (hasUsername ? normalizedUsername : (email ?? 'مستخدم مسجل')),
      style: const TextStyle(
        color: AppColors.textWhite,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }
}
