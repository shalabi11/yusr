import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yusr_app/features/content_download/domain/entities/content_download_option.dart';
import 'package:yusr_app/features/content_download/presentation/cubit/content_download_cubit.dart';
import 'package:yusr_app/features/content_download/presentation/cubit/content_download_state.dart';
import 'package:yusr_app/features/content_download/presentation/widgets/content_progress_widget.dart';

class ContentDownloadScreen extends StatelessWidget {
  const ContentDownloadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContentDownloadCubit, ContentDownloadState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == ContentDownloadStatus.completed,
      listener: (context, state) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      },
      child: const _ContentDownloadView(),
    );
  }
}

class _ContentDownloadView extends StatefulWidget {
  const _ContentDownloadView();

  @override
  State<_ContentDownloadView> createState() => _ContentDownloadViewState();
}

class _ContentDownloadViewState extends State<_ContentDownloadView> {
  ContentDownloadOption? _selectedOption;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B1220), Color(0xFF0F172A), Color(0xFF111827)],
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<ContentDownloadCubit, ContentDownloadState>(
            builder: (context, state) {
              const options = ContentDownloadOption.values;
              _selectedOption ??= _defaultOption(options);
              final lockSelection = state.isPreparing || state.isDownloading;

              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'تهيئة محتوى التطبيق',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'اختر ما تريد تنزيله الآن. يمكنك إكمال أي محتوى لاحقًا من الإعدادات.',
                      style: TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ...options.map((option) {
                      return _OptionCard(
                        option: option,
                        selected: _selectedOption == option,
                        onTap: lockSelection
                            ? null
                            : () => setState(() => _selectedOption = option),
                      );
                    }),
                    const SizedBox(height: 16),
                    if (state.isPreparing ||
                        state.isDownloading ||
                        state.isPaused)
                      ContentProgressWidget(
                        progress: state.progress,
                        downloadedBytes: state.downloadedBytes,
                        totalBytes: state.totalBytes,
                        currentFileName: state.currentFileName,
                        completedFiles: state.completedFiles,
                        totalFiles: state.totalFiles,
                      ),
                    if (state.errorMessage != null &&
                        state.errorMessage!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        state.errorMessage!,
                        style: const TextStyle(color: Color(0xFFFCA5A5)),
                      ),
                    ],
                    const Spacer(),
                    _ActionButtons(
                      state: state,
                      hasSelection: _selectedOption != null,
                      onStart: () {
                        final selectedOption = _selectedOption;
                        if (selectedOption == null) return;
                        context.read<ContentDownloadCubit>().startDownload(
                          selectedOption,
                        );
                      },
                      onPause: () =>
                          context.read<ContentDownloadCubit>().pauseDownload(),
                      onResume: () =>
                          context.read<ContentDownloadCubit>().resumeDownload(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  ContentDownloadOption? _defaultOption(List<ContentDownloadOption> options) {
    if (options.isEmpty) return null;
    if (options.contains(ContentDownloadOption.all)) {
      return ContentDownloadOption.all;
    }
    return options.first;
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final ContentDownloadOption option;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: selected
                  ? const Color(0xFF1D4ED8).withValues(alpha: 0.25)
                  : const Color(0xFF0B1220),
              border: Border.all(
                color: selected
                    ? const Color(0xFF60A5FA)
                    : const Color(0xFF334155),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        option.description,
                        style: const TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  selected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: selected
                      ? const Color(0xFF93C5FD)
                      : const Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.state,
    required this.hasSelection,
    required this.onStart,
    required this.onPause,
    required this.onResume,
  });

  final ContentDownloadState state;
  final bool hasSelection;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    if (state.isDownloading) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onPause,
          icon: const Icon(Icons.pause_circle_outline),
          label: const Text('إيقاف مؤقت'),
        ),
      );
    }

    if (state.isPaused) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onResume,
          icon: const Icon(Icons.play_arrow),
          label: const Text('استكمال التنزيل'),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: hasSelection ? onStart : null,
        child: const Text('بدء التنزيل'),
      ),
    );
  }
}
