import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/features/content_download/presentation/cubit/content_download_cubit.dart';
import 'package:yusr_app/features/content_download/presentation/cubit/content_download_state.dart';
import 'package:yusr_app/features/content_download/presentation/formatters/content_download_formatters.dart';

class ContentDownloadStatusChip extends StatelessWidget {
  const ContentDownloadStatusChip({this.bottomSpacing = 0, super.key});

  final double bottomSpacing;

  @override
  Widget build(BuildContext context) {
    ContentDownloadCubit cubit;
    try {
      cubit = BlocProvider.of<ContentDownloadCubit>(context);
    } catch (_) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<ContentDownloadCubit, ContentDownloadState>(
      bloc: cubit,
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.downloadedBytes != current.downloadedBytes ||
          previous.totalBytes != current.totalBytes ||
          previous.bytesPerSecond != current.bytesPerSecond,
      builder: (context, state) {
        if (!state.isPreparing && !state.isDownloading && !state.isPaused) {
          return const SizedBox.shrink();
        }

        final progressPercent = (state.progress * 100).toStringAsFixed(0);
        final speed = formatContentBytes(state.bytesPerSecond);
        final subtitle = state.isPaused
            ? 'التنزيل متوقف مؤقتًا. اضغط للاستكمال.'
            : 'اكتمل $progressPercent% • السرعة $speed/ث';

        return Padding(
          padding: EdgeInsets.only(bottom: bottomSpacing),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.pushNamed(context, '/content-download'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.45),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.downloading_rounded,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.isPaused
                              ? 'تنزيل المحتوى متوقف'
                              : 'تنزيل المحتوى جارٍ في الخلفية',
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.textSecondary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
