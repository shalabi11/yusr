import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/app_radial_background.dart';
import 'package:yusr_app/core/widgets/glass_container.dart';
import 'package:yusr_app/features/content_download/domain/entities/content_download_option.dart';

class ContentDownloadRequiredScreen extends StatelessWidget {
  const ContentDownloadRequiredScreen({
    required this.title,
    required this.description,
    required this.requiredOption,
    required this.targetRoute,
    super.key,
  });

  final String title;
  final String description;
  final ContentDownloadOption requiredOption;
  final String targetRoute;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppRadialBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: GlassContainer(
                borderRadius: 24,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_download_outlined,
                      size: 48,
                      color: AppColors.accent,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      description,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/content-download',
                            arguments: <String, dynamic>{
                              'initialOption': requiredOption,
                              'autoProceedOnComplete': true,
                              'successRoute': targetRoute,
                            },
                          );
                        },
                        icon: const Icon(Icons.download_rounded),
                        label: const Text('بدء تنزيل المحتوى الآن'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('الرجوع'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
