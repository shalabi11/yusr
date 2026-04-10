import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/glass_container.dart';

class QuranQuickJumpForm extends StatelessWidget {
  const QuranQuickJumpForm({
    required this.surahController,
    required this.juzController,
    required this.pageController,
    required this.onGoToSurah,
    required this.onGoToJuz,
    required this.onGoToPage,
    super.key,
  });

  final TextEditingController surahController;
  final TextEditingController juzController;
  final TextEditingController pageController;
  final VoidCallback onGoToSurah;
  final VoidCallback onGoToJuz;
  final VoidCallback onGoToPage;

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
              controller: surahController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'رقم السورة (1-114)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: juzController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'رقم الجزء (1-30)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: pageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'رقم الصفحة (1-604)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onGoToSurah,
              icon: const Icon(Icons.menu_book),
              label: const Text('اذهب إلى السورة'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: onGoToJuz,
              icon: const Icon(Icons.auto_stories),
              label: const Text('اذهب إلى الجزء'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: onGoToPage,
              icon: const Icon(Icons.find_in_page_outlined),
              label: const Text('اذهب إلى الصفحة'),
            ),
          ],
        ),
      ),
    );
  }
}
