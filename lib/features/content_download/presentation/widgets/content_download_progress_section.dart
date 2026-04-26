import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yusr_app/features/content_download/presentation/cubit/content_download_cubit.dart';
import 'package:yusr_app/features/content_download/presentation/cubit/content_download_state.dart';
import 'package:yusr_app/features/content_download/presentation/widgets/content_progress_widget.dart';

class ContentDownloadProgressSection extends StatelessWidget {
  const ContentDownloadProgressSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContentDownloadCubit, ContentDownloadState>(
      buildWhen: (previous, current) {
        return previous.status != current.status ||
            previous.progress != current.progress ||
            previous.downloadedBytes != current.downloadedBytes ||
            previous.totalBytes != current.totalBytes ||
            previous.remainingBytes != current.remainingBytes ||
            previous.bytesPerSecond != current.bytesPerSecond ||
            previous.completedFiles != current.completedFiles ||
            previous.totalFiles != current.totalFiles;
      },
      builder: (context, state) {
        if (!state.isPreparing && !state.isDownloading && !state.isPaused) {
          return const SizedBox.shrink();
        }

        return ContentProgressWidget(
          progress: state.progress,
          downloadedBytes: state.downloadedBytes,
          totalBytes: state.totalBytes,
          remainingBytes: state.remainingBytes,
          bytesPerSecond: state.bytesPerSecond,
          completedFiles: state.completedFiles,
          totalFiles: state.totalFiles,
        );
      },
    );
  }
}
