import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/app_radial_background.dart';
import 'package:yusr_app/features/home/presentation/widgets/home_header.dart';
import 'package:yusr_app/features/home/presentation/widgets/daily_content_card.dart';
import 'package:yusr_app/features/home/presentation/widgets/service_card.dart';
import 'package:yusr_app/features/home/presentation/widgets/next_prayer_card.dart';
import 'package:yusr_app/core/localization/app_localizations.dart';
import 'package:yusr_app/core/localization/app_translations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.1,
                ),
                delegate: SliverChildListDelegate([
                  ServiceCard(
                    title: AppStrings.quran.tr,
                    icon: Icons.menu_book,
                    route: '/quran',
                  ),
                  ServiceCard(
                    title: AppStrings.adhkar.tr,
                    icon: Icons.auto_awesome,
                    route: '/adhkar',
                  ),
                  ServiceCard(
                    title: AppStrings.reminders.tr,
                    icon: Icons.notifications_active,
                    route: '/reminders',
                  ),
                  ServiceCard(
                    title: AppStrings.prayerTimes.tr,
                    icon: Icons.access_time,
                    route: '/prayer',
                  ),
                ]),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}
