import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/localization/app_translations.dart';
import 'package:yusr_app/core/services/storage_service.dart';
import 'package:yusr_app/features/intro/presentation/widgets/intro_footer.dart';
import 'package:yusr_app/features/intro/presentation/widgets/intro_page_card.dart';

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

  Future<void> _continue() async {
    if (_currentPage == _pages.length - 1) {
      await StorageService.setIntroSeen(true);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/onboarding-auth');
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
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
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
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
              IntroFooter(
                pagesCount: _pages.length,
                currentPage: _currentPage,
                onPressed: _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
