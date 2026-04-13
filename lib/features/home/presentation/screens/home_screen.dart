import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/app_radial_background.dart';
import 'package:yusr_app/features/home/presentation/widgets/home_header.dart';
import 'package:yusr_app/features/home/presentation/widgets/daily_content_card.dart';
import 'package:yusr_app/features/home/presentation/widgets/home_services_carousel.dart';
import 'package:yusr_app/features/home/presentation/widgets/next_prayer_card.dart';
import 'package:yusr_app/core/localization/app_localizations.dart';
import 'package:yusr_app/core/localization/app_translations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = <ServiceItem>[
      ServiceItem(
        title: AppStrings.quran.tr,
        icon: Icons.menu_book,
        route: '/quran',
      ),
      ServiceItem(
        title: AppStrings.adhkar.tr,
        icon: Icons.auto_awesome,
        route: '/adhkar',
      ),
      ServiceItem(
        title: AppStrings.reminders.tr,
        icon: Icons.notifications_active,
        route: '/reminders',
      ),
      ServiceItem(
        title: AppStrings.prayerTimes.tr,
        icon: Icons.access_time,
        route: '/prayer',
      ),
    ];

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/assistant'),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.primaryDark,
        icon: const Icon(Icons.smart_toy_outlined),
        label: Text(AppStrings.aiAssistant.tr),
      ),
      body: AppRadialBackground(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HomeHeader(),
                    const SizedBox(height: 25),
                    const NextPrayerCard(),
                    const SizedBox(height: 25),
                    const DailyContentCard(),
                    const SizedBox(height: 30),
                    Text(
                      AppStrings.basicServices.tr,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: HomeServicesCarousel(services: services)),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }
}
