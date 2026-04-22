import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yusr_app/core/bloc/settings_cubit.dart';
import 'package:yusr_app/core/utils/app_logger.dart';
import 'package:yusr_app/core/services/notification_service.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/app_radial_background.dart';
import 'package:yusr_app/features/quran/data/models/quran_models.dart';
import 'package:yusr_app/features/quran/domain/usecases/quran_use_cases.dart';
import 'package:yusr_app/features/quran/presentation/models/quran_offline_availability.dart';
import 'package:yusr_app/features/quran/presentation/screens/quran_page_viewer_screen.dart';
import 'package:yusr_app/features/quran/presentation/screens/quran_reader_screen.dart';
import 'package:yusr_app/features/quran/presentation/widgets/quran_juz_tab.dart';
import 'package:yusr_app/features/quran/presentation/widgets/quran_bookmarks_sheet.dart';
import 'package:yusr_app/features/quran/presentation/widgets/quran_khatma_tab.dart';
import 'package:yusr_app/features/quran/presentation/widgets/quran_pages_tab.dart';
import 'package:yusr_app/features/quran/presentation/widgets/quran_quick_jump_sheet.dart';
import 'package:yusr_app/features/quran/presentation/widgets/quran_surah_tab.dart';

part 'quran_screen_actions.dart';
part 'quran_screen_navigation.dart';
part 'quran_screen_ui.dart';
part 'quran_screen_app_bar.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({required this.useCases, super.key});

  final QuranUseCases useCases;

  @override
  State<QuranScreen> createState() => QuranScreenState();
}

class QuranScreenState extends State<QuranScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _daysController;
  List<QuranSurah> _surahs = const [];
  List<QuranSurah> _filteredSurahs = const [];
  final Map<int, String> _matchedPreviewBySurah = <int, String>{};
  Map<int, QuranOfflineAvailability> _offlineAvailabilityBySurah =
      const <int, QuranOfflineAvailability>{};
  String _search = '';
  bool _loading = true;
  QuranLastRead? _lastRead;
  KhatmaPlan? _khatmaPlan;

  void _applyLoadedData(
    List<QuranSurah> surahs,
    QuranLastRead? lastRead, {
    Map<int, String> localPageImagePaths = const <int, String>{},
  }) {
    final offlineAvailability = _buildOfflineAvailability(
      surahs,
      localPageImagePaths,
    );
    if (!mounted) return;
    setState(() {
      _surahs = surahs;
      _filteredSurahs = surahs;
      _lastRead = lastRead;
      _loading = false;
      _khatmaPlan = widget.useCases.calculateKhatmaPlan(30);
      _offlineAvailabilityBySurah = offlineAvailability;
      _search = '';
      _matchedPreviewBySurah.clear();
    });
  }

  void _applyKhatmaPlan(int days) {
    if (!mounted) return;
    setState(() {
      _khatmaPlan = widget.useCases.calculateKhatmaPlan(days);
    });
  }

  Map<int, QuranOfflineAvailability> _buildOfflineAvailability(
    List<QuranSurah> surahs,
    Map<int, String> localPageImagePaths,
  ) {
    final localPages = localPageImagePaths.entries
        .where((entry) => entry.value.isNotEmpty)
        .map((entry) => entry.key)
        .toSet();
    if (localPages.isEmpty || surahs.isEmpty) {
      return <int, QuranOfflineAvailability>{
        for (final surah in surahs) surah.number: QuranOfflineAvailability.none,
      };
    }

    final availabilityBySurah = <int, QuranOfflineAvailability>{};
    for (final surah in surahs) {
      final surahPages = surah.verses.map((verse) => verse.page).toSet();
      if (surahPages.isEmpty) {
        availabilityBySurah[surah.number] = QuranOfflineAvailability.none;
        continue;
      }

      final matchedPages = surahPages.where(localPages.contains).length;
      if (matchedPages == 0) {
        availabilityBySurah[surah.number] = QuranOfflineAvailability.none;
      } else if (matchedPages == surahPages.length) {
        availabilityBySurah[surah.number] = QuranOfflineAvailability.full;
      } else {
        availabilityBySurah[surah.number] = QuranOfflineAvailability.partial;
      }
    }
    return availabilityBySurah;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _daysController = TextEditingController(text: '30');
    loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    final readAsText = settings.quranReadAsText;
    final isArabic = settings.langCode == 'ar';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: buildQuranAppBar(readAsText),
      body: AppRadialBackground(
        child: buildQuranBody(readAsText, isArabic: isArabic),
      ),
    );
  }
}
