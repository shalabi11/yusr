import 'package:flutter/material.dart';
import 'package:yusr_app/core/services/storage_service.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/glass_container.dart';
import 'package:yusr_app/features/content_download/domain/entities/content_download_option.dart';

class ContentDownloadSettingsCard extends StatefulWidget {
  const ContentDownloadSettingsCard({super.key});

  @override
  State<ContentDownloadSettingsCard> createState() =>
      _ContentDownloadSettingsCardState();
}

class _ContentDownloadSettingsCardState
    extends State<ContentDownloadSettingsCard> {
  bool get _isQuranDone => StorageService.quranContentDownloaded;
  bool get _isAdhkarDone => StorageService.adhkarContentDownloaded;

  ContentDownloadOption _suggestedOption() {
    if (!_isQuranDone && _isAdhkarDone) {
      return ContentDownloadOption.quranOnly;
    }
    if (_isQuranDone && !_isAdhkarDone) {
      return ContentDownloadOption.adhkarOnly;
    }
    return ContentDownloadOption.all;
  }

  @override
  Widget build(BuildContext context) {
    final suggested = _suggestedOption();
    final allDone = _isQuranDone && _isAdhkarDone;

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.download_rounded, color: AppColors.accent),
              SizedBox(width: 10),
              Text(
                'تنزيل محتوى التطبيق',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            allDone
                ? 'تم تنزيل القرآن والأذكار بالكامل.'
                : 'يمكنك متابعة تنزيل المحتوى غير المكتمل في أي وقت.',
            style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 14),
          _StatusRow(label: 'القرآن', done: _isQuranDone),
          const SizedBox(height: 8),
          _StatusRow(label: 'الأذكار', done: _isAdhkarDone),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.pushNamed(
                  context,
                  '/content-download',
                  arguments: <String, dynamic>{
                    'initialOption': suggested,
                    'autoProceedOnComplete': false,
                  },
                );
                if (!mounted) {
                  return;
                }
                setState(() {});
              },
              icon: const Icon(Icons.sync_alt_rounded),
              label: Text(
                allDone
                    ? 'إعادة تنزيل / تحديث المحتوى'
                    : 'استكمال تنزيل المحتوى',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.done});

  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          done ? Icons.check_circle : Icons.error_outline,
          color: done ? const Color(0xFF34D399) : const Color(0xFFF59E0B),
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: AppColors.textWhite)),
        const Spacer(),
        Text(
          done ? 'مكتمل' : 'غير مكتمل',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
