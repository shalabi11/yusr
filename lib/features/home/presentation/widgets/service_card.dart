import 'package:flutter/material.dart';
import 'package:yusr_app/core/services/storage_service.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/glass_container.dart';
import 'package:yusr_app/features/content_download/domain/entities/content_download_option.dart';

class ServiceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String route;

  const ServiceCard({
    super.key,
    required this.title,
    required this.icon,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (route == '/quran' && !StorageService.quranContentDownloaded) {
          _showIncompleteContentMessage(
            context,
            message: 'تنزيل القرآن غير مكتمل. ابدأ التنزيل للمتابعة.',
            option: ContentDownloadOption.quranOnly,
            successRoute: '/quran',
          );
          return;
        }

        if (route == '/adhkar' && !StorageService.adhkarContentDownloaded) {
          _showIncompleteContentMessage(
            context,
            message: 'تنزيل الأذكار غير مكتمل. ابدأ التنزيل للمتابعة.',
            option: ContentDownloadOption.adhkarOnly,
            successRoute: '/adhkar',
          );
          return;
        }

        if (route.isNotEmpty) {
          Navigator.pushNamed(context, route);
        }
      },
      borderRadius: BorderRadius.circular(24),
      child: GlassContainer(
        borderRadius: 24,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: AppColors.accent),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showIncompleteContentMessage(
    BuildContext context, {
    required String message,
    required ContentDownloadOption option,
    required String successRoute,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'ابدأ التنزيل',
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/content-download',
              arguments: <String, dynamic>{
                'initialOption': option,
                'autoProceedOnComplete': true,
                'successRoute': successRoute,
              },
            );
          },
        ),
      ),
    );
  }
}
