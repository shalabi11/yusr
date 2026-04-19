import 'package:flutter/material.dart';
import 'package:yusr_app/features/quran/data/models/quran_models.dart';
import 'package:yusr_app/features/quran/data/repositories/quran_repository.dart';

import 'quran_quick_jump_form.dart';
import 'quran_quick_jump_nav.dart';

class QuranQuickJumpSheet extends StatefulWidget {
  const QuranQuickJumpSheet({
    required this.parentContext,
    required this.surahs,
    required this.readAsText,
    required this.repo,
    required this.onReload,
    super.key,
  });

  final BuildContext parentContext;
  final List<QuranSurah> surahs;
  final bool readAsText;
  final QuranRepository repo;
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
        repo: widget.repo,
        onReload: widget.onReload,
        input: _surahController.text,
      ),
      onGoToJuz: () => goToJuzJump(
        sheetContext: context,
        parentContext: widget.parentContext,
        repo: widget.repo,
        onReload: widget.onReload,
        input: _juzController.text,
      ),
      onGoToPage: () => goToPageJump(
        sheetContext: context,
        parentContext: widget.parentContext,
        onReload: widget.onReload,
        input: _pageController.text,
      ),
    );
  }
}
