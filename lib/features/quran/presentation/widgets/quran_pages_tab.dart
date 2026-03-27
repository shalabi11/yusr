import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/features/quran/presentation/screens/quran_page_viewer_screen.dart';

class QuranPagesTab extends StatelessWidget {
  const QuranPagesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      cacheExtent: 1200,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.4,
      ),
      itemCount: 604,
      itemBuilder: (_, index) {
        final page = index + 1;
        return InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuranPageViewerScreen(
                  initialPage: page,
                  showPageTitle: false,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.22),
              ),
            ),
            child: Center(
              child: Text(
                '$page',
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
