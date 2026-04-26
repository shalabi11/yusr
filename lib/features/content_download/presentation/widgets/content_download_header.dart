import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';

class ContentDownloadHeader extends StatelessWidget {
  const ContentDownloadHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تهيئة محتوى التطبيق',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'اختر ما تريد تنزيله الآن. يمكنك إكمال أي محتوى لاحقًا من الإعدادات.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
