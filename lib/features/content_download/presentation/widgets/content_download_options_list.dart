import 'package:flutter/material.dart';
import 'package:yusr_app/features/content_download/domain/entities/content_download_option.dart';
import 'package:yusr_app/features/content_download/presentation/widgets/content_download_option_card.dart';

class ContentDownloadOptionsList extends StatelessWidget {
  const ContentDownloadOptionsList({
    required this.options,
    required this.selectedOption,
    required this.lockSelection,
    required this.onOptionSelected,
    super.key,
  });

  final List<ContentDownloadOption> options;
  final ContentDownloadOption? selectedOption;
  final bool lockSelection;
  final ValueChanged<ContentDownloadOption> onOptionSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options
          .map(
            (option) => ContentDownloadOptionCard(
              option: option,
              selected: selectedOption == option,
              onTap: lockSelection ? null : () => onOptionSelected(option),
            ),
          )
          .toList(),
    );
  }
}
