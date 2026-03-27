import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/glass_container.dart';
import 'package:yusr_app/features/quran/data/repositories/quran_repository.dart';
import 'package:yusr_app/features/quran/presentation/screens/quran_page_viewer_screen.dart';

class QuranJuzTab extends StatelessWidget {
  const QuranJuzTab({required this.repo, required this.onReload, super.key});

  final QuranRepository repo;
  final Future<void> Function() onReload;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 30,
      itemBuilder: (_, index) {
        final juz = index + 1;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () async {
              final pages = await repo.pagesForJuz(juz);
              if (!context.mounted || pages.isEmpty) return;
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuranPageViewerScreen(
                    initialPage: pages.first,
                    showPageTitle: false,
                  ),
                ),
              );
              if (!context.mounted) return;
              await onReload();
            },
            borderRadius: BorderRadius.circular(16),
            child: GlassContainer(
              borderRadius: 16,
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.auto_stories, color: AppColors.accent),
                  const SizedBox(width: 10),
                  Text(
                    'الجزء $juz',
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.bold,
                    ),
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
