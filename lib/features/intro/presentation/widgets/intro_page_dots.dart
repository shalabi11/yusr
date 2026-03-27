import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';

class IntroPageDots extends StatelessWidget {
  const IntroPageDots({
    required this.pagesCount,
    required this.currentPage,
    super.key,
  });

  final int pagesCount;
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(pagesCount, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: currentPage == index ? 24 : 8,
          decoration: BoxDecoration(
            color: currentPage == index
                ? AppColors.accent
                : AppColors.textSecondary.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
