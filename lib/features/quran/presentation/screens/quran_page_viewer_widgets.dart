import 'package:flutter/material.dart';
import 'dart:io';
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

Widget buildQuranPageImage(
  BuildContext context,
  int page, {
  String? localImagePath,
  String? remoteImageUrl,
}) {
  final screenWidth = MediaQuery.sizeOf(context).width;
  final dpr = MediaQuery.devicePixelRatioOf(context);
  final targetCacheWidth = (screenWidth * dpr).round().clamp(720, 2200);

  Widget buildMissingImageMessage() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 22),
      child: Text(
        'تعذر تحميل صفحة القرآن. تأكد من تنزيل بيانات القرآن من شاشة تنزيل المحتوى.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  final hasLocal = localImagePath != null && localImagePath.isNotEmpty;
  final hasRemote = remoteImageUrl != null && remoteImageUrl.isNotEmpty;

  return InteractiveViewer(
    minScale: 1,
    maxScale: 4,
    child: Center(
      child: hasLocal
          ? Image.file(
              File(localImagePath),
              fit: BoxFit.contain,
              cacheWidth: targetCacheWidth,
              filterQuality: FilterQuality.medium,
              errorBuilder: (_, __, ___) {
                if (!hasRemote) return buildMissingImageMessage();
                return Image.network(
                  remoteImageUrl,
                  fit: BoxFit.contain,
                  cacheWidth: targetCacheWidth,
                  filterQuality: FilterQuality.medium,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const CircularProgressIndicator();
                  },
                  errorBuilder: (_, __, ___) => buildMissingImageMessage(),
                );
              },
            )
          : hasRemote
          ? Image.network(
              remoteImageUrl,
              fit: BoxFit.contain,
              cacheWidth: targetCacheWidth,
              filterQuality: FilterQuality.medium,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const CircularProgressIndicator();
              },
              errorBuilder: (_, __, ___) => buildMissingImageMessage(),
            )
          : buildMissingImageMessage(),
    ),
  );
}
