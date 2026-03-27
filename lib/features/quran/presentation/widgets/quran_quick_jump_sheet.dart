import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/glass_container.dart';
import 'package:yusr_app/features/quran/data/models/quran_models.dart';
import 'package:yusr_app/features/quran/data/repositories/quran_repository.dart';
import 'package:yusr_app/features/quran/presentation/screens/quran_page_viewer_screen.dart';
import 'package:yusr_app/features/quran/presentation/screens/quran_reader_screen.dart';

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
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: GlassContainer(
        borderRadius: 20,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'انتقال مباشر',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _surahController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'رقم السورة (1-114)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _juzController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'رقم الجزء (1-30)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _pageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'رقم الصفحة (1-604)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _goToSurah,
              icon: const Icon(Icons.menu_book),
              label: const Text('اذهب إلى السورة'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _goToJuz,
              icon: const Icon(Icons.auto_stories),
              label: const Text('اذهب إلى الجزء'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _goToPage,
              icon: const Icon(Icons.find_in_page_outlined),
              label: const Text('اذهب إلى الصفحة'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _goToSurah() async {
    final surahNumber = int.tryParse(_surahController.text.trim());
    if (surahNumber == null || surahNumber < 1 || surahNumber > 114) {
      _showMessage('رقم السورة غير صالح');
      return;
    }

    Navigator.of(context).pop();
    if (!widget.parentContext.mounted) return;

    final surah = widget.surahs.firstWhere(
      (s) => s.number == surahNumber,
      orElse: () => widget.surahs.first,
    );

    if (widget.readAsText) {
      await Navigator.of(widget.parentContext).push(
        MaterialPageRoute(builder: (_) => QuranReaderScreen(surah: surah)),
      );
    } else {
      final pages = await widget.repo.pagesForSurah(surahNumber);
      if (!widget.parentContext.mounted || pages.isEmpty) return;
      await Navigator.of(widget.parentContext).push(
        MaterialPageRoute(
          builder: (_) => QuranPageViewerScreen(
            initialPage: pages.first,
            showPageTitle: false,
          ),
        ),
      );
    }

    if (!widget.parentContext.mounted) return;
    await widget.onReload();
  }

  Future<void> _goToJuz() async {
    final juz = int.tryParse(_juzController.text.trim());
    if (juz == null || juz < 1 || juz > 30) {
      _showMessage('رقم الجزء غير صالح');
      return;
    }

    final pages = await widget.repo.pagesForJuz(juz);
    if (!context.mounted || pages.isEmpty) return;

    Navigator.of(context).pop();
    if (!widget.parentContext.mounted) return;

    await Navigator.of(widget.parentContext).push(
      MaterialPageRoute(
        builder: (_) => QuranPageViewerScreen(
          initialPage: pages.first,
          showPageTitle: false,
        ),
      ),
    );

    if (!widget.parentContext.mounted) return;
    await widget.onReload();
  }

  Future<void> _goToPage() async {
    final page = int.tryParse(_pageController.text.trim());
    if (page == null || page < 1 || page > 604) {
      _showMessage('رقم الصفحة غير صالح');
      return;
    }

    Navigator.of(context).pop();
    if (!widget.parentContext.mounted) return;

    await Navigator.of(widget.parentContext).push(
      MaterialPageRoute(
        builder: (_) => QuranPageViewerScreen(
          initialPage: page,
          showPageTitle: false,
        ),
      ),
    );

    if (!widget.parentContext.mounted) return;
    await widget.onReload();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
