import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/localization/app_localizations.dart';
import 'package:yusr_app/core/localization/app_translations.dart';
import 'package:yusr_app/core/services/storage_service.dart';
import 'package:yusr_app/features/intro/presentation/widgets/intro_page_card.dart';
import 'package:yusr_app/features/intro/presentation/widgets/intro_page_dots.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'titleKey': AppStrings.welcome,
      'descKey': AppStrings.introDesc1,
      'icon': 'mosque',
    },
    {
      'titleKey': AppStrings.smartReminders,
      'descKey': AppStrings.introDesc2,
      'icon': 'notifications',
    },
    {
      'titleKey': AppStrings.simplicity,
      'descKey': AppStrings.introDesc3,
      'icon': 'book',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryDark, AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return IntroPageCard(
                      titleKey: _pages[index]['titleKey']!,
                      descKey: _pages[index]['descKey']!,
                      iconName: _pages[index]['icon']!,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 40,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IntroPageDots(
                      pagesCount: _pages.length,
                      currentPage: _currentPage,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.primaryDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                      ),
                      onPressed: () async {
                        if (_currentPage == _pages.length - 1) {
                          await StorageService.setIntroSeen(true);
                          if (!mounted) return;
                          Navigator.pushReplacementNamed(context, '/home');
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        }
                      },
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? AppStrings.startNow.tr
                            : AppStrings.next.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
