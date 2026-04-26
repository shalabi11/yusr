import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yusr_app/features/content_download/domain/entities/content_download_option.dart';
import 'package:yusr_app/features/content_download/presentation/cubit/content_download_cubit.dart';
import 'package:yusr_app/features/content_download/presentation/cubit/content_download_state.dart';
import 'package:yusr_app/features/content_download/presentation/widgets/content_download_action_buttons.dart';
import 'package:yusr_app/features/content_download/presentation/widgets/content_download_error_text.dart';
import 'package:yusr_app/features/content_download/presentation/widgets/content_download_header.dart';
import 'package:yusr_app/features/content_download/presentation/widgets/content_download_options_list.dart';
import 'package:yusr_app/features/content_download/presentation/widgets/content_download_progress_section.dart';

class ContentDownloadView extends StatefulWidget {
  const ContentDownloadView({required this.initialOption, super.key});

  final ContentDownloadOption? initialOption;

  @override
  State<ContentDownloadView> createState() => _ContentDownloadViewState();
}

class _ContentDownloadViewState extends State<ContentDownloadView> {
  ContentDownloadOption? _selectedOption;

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.initialOption;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContentDownloadCubit, ContentDownloadState>(
      buildWhen: (previous, current) {
        return previous.status != current.status ||
            previous.errorMessage != current.errorMessage;
      },
      builder: (context, state) {
        const options = ContentDownloadOption.values;
        _selectedOption ??= _defaultOption(options);

        return Scaffold(
          body: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0B1220),
                  Color(0xFF0F172A),
                  Color(0xFF111827),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const ContentDownloadHeader(),
                    const SizedBox(height: 24),
                    ContentDownloadOptionsList(
                      options: options,
                      selectedOption: _selectedOption,
                      lockSelection: state.isPreparing || state.isDownloading,
                      onOptionSelected: (option) {
                        setState(() => _selectedOption = option);
                      },
                    ),
                    const SizedBox(height: 16),
                    const ContentDownloadProgressSection(),
                    if (state.errorMessage != null &&
                        state.errorMessage!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ContentDownloadErrorText(message: state.errorMessage!),
                    ],
                    const Spacer(),
                    ContentDownloadActionButtons(
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
              ),
            ),
          ),
        );
      },
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
