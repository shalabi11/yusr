import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';

AppBar buildQuranPageAppBar({
  required BuildContext context,
  required int currentPage,
  required bool showPageTitle,
  required Set<int> savedPages,
  required VoidCallback onBookmark,
  required VoidCallback onToggleReverse,
}) {
  final isSaved = savedPages.contains(currentPage);
  return AppBar(
    title: showPageTitle ? Text('الصفحة $currentPage') : null,
    iconTheme: const IconThemeData(color: AppColors.primaryDark),
    actionsIconTheme: const IconThemeData(color: AppColors.primaryDark),
    actions: [
      IconButton(
        onPressed: onBookmark,
        icon: Icon(
          isSaved ? Icons.bookmark_added : Icons.bookmark_add_outlined,
          color: isSaved ? Colors.green.shade700 : AppColors.primaryDark,
        ),
        tooltip: 'حفظ مرجعية القراءة',
      ),
      IconButton(
        onPressed: onToggleReverse,
        icon: const Icon(Icons.swap_horiz),
        tooltip: 'تبديل اتجاه التقليب',
      ),
    ],
  );
}

Widget buildQuranPageImage(int page) {
  return InteractiveViewer(
    minScale: 1,
    maxScale: 4,
    child: Center(
      child: Image.asset(
        'assets/quran_images/$page.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Text(
          'تعذر تحميل الصورة',
          style: TextStyle(color: Colors.white),
        ),
      ),
    ),
  );
}
