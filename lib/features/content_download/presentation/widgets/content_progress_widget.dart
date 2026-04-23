import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/features/content_download/presentation/formatters/content_download_formatters.dart';

class ContentProgressWidget extends StatelessWidget {
  const ContentProgressWidget({
    required this.progress,
    required this.downloadedBytes,
    required this.totalBytes,
    required this.remainingBytes,
    required this.bytesPerSecond,
    required this.completedFiles,
    required this.totalFiles,
    super.key,
  });

  final double progress;
  final int downloadedBytes;
  final int totalBytes;
  final int remainingBytes;
  final int bytesPerSecond;
  final int completedFiles;
  final int totalFiles;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryDark.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'جاري تنزيل المحتوى',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.textSecondary.withValues(alpha: 0.25),
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(height: 10),
          Text(
            '${(progress * 100).toStringAsFixed(1)}% • ${formatContentBytes(downloadedBytes)} / ${formatContentBytes(totalBytes)}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Text(
            'المتبقي: ${formatContentBytes(remainingBytes)}',
            style: const TextStyle(color: AppColors.textWhite),
          ),
          const SizedBox(height: 6),
          Text(
            'السرعة: ${formatContentBytes(bytesPerSecond)}/ث',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Text(
            'الملفات المكتملة: $completedFiles / $totalFiles',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
