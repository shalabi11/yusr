import 'package:flutter/material.dart';
import 'package:yusr_app/features/quran/data/models/quran_models.dart';
import 'package:yusr_app/features/quran/domain/usecases/quran_use_cases.dart';

import 'quran_quick_jump_form.dart';
import 'quran_quick_jump_nav.dart';

class QuranQuickJumpSheet extends StatefulWidget {
  const QuranQuickJumpSheet({
    required this.parentContext,
    required this.surahs,
    required this.readAsText,
    required this.useCases,
    required this.onReload,
    super.key,
  });

  final BuildContext parentContext;
  final List<QuranSurah> surahs;
  final bool readAsText;
  final QuranUseCases useCases;
  final Future<void> Function() onReload;

  @override
  State<QuranQuickJumpSheet> createState() => _QuranQuickJumpSheetState();
}

class _QuranQuickJumpSheetState extends State<QuranQuickJumpSheet> {
  late final TextEditingController _surahController;
  late final TextEditingController _juzController;
  late final TextEditingController _pageController;

  @override
  void initState() {
    super.initState();
    _surahController = TextEditingController();
    _juzController = TextEditingController();
    _pageController = TextEditingController();
  }

  @override
  void dispose() {
    _surahController.dispose();
    _juzController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return QuranQuickJumpForm(
      surahController: _surahController,
      juzController: _juzController,
      pageController: _pageController,
      onGoToSurah: () => goToSurahJump(
        sheetContext: context,
        parentContext: widget.parentContext,
        surahs: widget.surahs,
        readAsText: widget.readAsText,
        useCases: widget.useCases,
        onReload: widget.onReload,
        input: _surahController.text,
      ),
      onGoToJuz: () => goToJuzJump(
        sheetContext: context,
        parentContext: widget.parentContext,
        useCases: widget.useCases,
        onReload: widget.onReload,
        input: _juzController.text,
      ),
      onGoToPage: () => goToPageJump(
        sheetContext: context,
        parentContext: widget.parentContext,
        useCases: widget.useCases,
        onReload: widget.onReload,
        input: _pageController.text,
      ),
    );
  }
}
