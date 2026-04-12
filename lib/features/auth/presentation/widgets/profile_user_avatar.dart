import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';

class ProfileUserAvatar extends StatelessWidget {
  const ProfileUserAvatar({
    super.key,
    required this.avatarUrl,
    required this.loading,
    required this.onTap,
  });

  final String? avatarUrl;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarUrl != null && avatarUrl!.trim().isNotEmpty;

    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.background.withValues(alpha: 0.5),
            backgroundImage: hasAvatar ? NetworkImage(avatarUrl!.trim()) : null,
            child: hasAvatar
                ? null
                : const Icon(
                    Icons.person,
                    size: 48,
                    color: AppColors.textWhite,
                  ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.accent,
              child: loading
                  ? const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryDark,
                      ),
                    )
                  : const Icon(
                      Icons.camera_alt_outlined,
                      size: 14,
                      color: AppColors.primaryDark,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
