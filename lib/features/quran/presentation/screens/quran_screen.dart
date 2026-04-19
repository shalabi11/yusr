import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yusr_app/core/bloc/settings_cubit.dart';
import 'package:yusr_app/core/utils/app_logger.dart';
import 'package:yusr_app/core/services/notification_service.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/app_radial_background.dart';
import 'package:yusr_app/features/quran/data/models/quran_models.dart';
import 'package:yusr_app/features/quran/data/repositories/quran_repository.dart';
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
  const QuranScreen({required this.repo, super.key});

  final QuranRepository repo;

  @override
  State<QuranScreen> createState() => QuranScreenState();
}

class QuranScreenState extends State<QuranScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _daysController;
  late final TextEditingController _searchController;
  List<QuranSurah> _surahs = const [];
  List<QuranSurah> _filteredSurahs = const [];
  final Map<int, String> _searchableTextBySurah = <int, String>{};
  final Map<int, String> _matchedPreviewBySurah = <int, String>{};
  String _search = '';
  bool _loading = true;
  QuranLastRead? _lastRead;
  KhatmaPlan? _khatmaPlan;
  Timer? _searchDebounce;

  static const Duration _searchDebounceDuration = Duration(milliseconds: 220);

  void _applyLoadedData(List<QuranSurah> surahs, QuranLastRead? lastRead) {
    _rebuildSearchIndexes(surahs);
    _applySearchFilter('');
    if (!mounted) return;
    setState(() {
      _surahs = surahs;
      _filteredSurahs = surahs;
      _lastRead = lastRead;
      _loading = false;
      _khatmaPlan = widget.repo.calculateKhatmaPlan(30);
    });
  }

  void _applyKhatmaPlan(int days) {
    if (!mounted) return;
    setState(() {
      _khatmaPlan = widget.repo.calculateKhatmaPlan(days);
    });
  }

  void _updateSearch(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(_searchDebounceDuration, () {
      if (!mounted) return;
      _applySearchFilter(value);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _searchDebounce?.cancel();
    if (!mounted) return;
    _applySearchFilter('');
  }

  void _rebuildSearchIndexes(List<QuranSurah> surahs) {
    _searchableTextBySurah
      ..clear()
      ..addEntries(
        surahs.map(
          (surah) => MapEntry(
            surah.number,
            [
              surah.nameAr,
              surah.nameEn.toLowerCase(),
              surah.number.toString(),
              ...surah.verses.map((verse) => verse.textAr),
            ].join(' '),
          ),
        ),
      );
  }

  void _applySearchFilter(String rawQuery) {
    final query = rawQuery.trim();
    if (query.isEmpty) {
      setState(() {
        _search = '';
        _matchedPreviewBySurah.clear();
        _filteredSurahs = _surahs;
      });
      return;
    }

    final lower = query.toLowerCase();
    final filtered = <QuranSurah>[];
    final previews = <int, String>{};

    for (final surah in _surahs) {
      final searchableText = _searchableTextBySurah[surah.number] ?? '';
      if (!searchableText.contains(query) && !searchableText.contains(lower)) {
        continue;
      }

      final verseMatch = surah.verses.firstWhere(
        (verse) =>
            verse.textAr.contains(query) ||
            verse.textAr.toLowerCase().contains(lower),
        orElse: () => const QuranVerse(number: 0, textAr: '', juz: 0, page: 0),
      );
      if (verseMatch.number != 0 && verseMatch.textAr.isNotEmpty) {
        final preview = verseMatch.textAr;
        previews[surah.number] = preview.length > 45
            ? '${preview.substring(0, 45)}...'
            : preview;
      }

      filtered.add(surah);
    }

    setState(() {
      _search = query;
      _filteredSurahs = filtered;
      _matchedPreviewBySurah
        ..clear()
        ..addAll(previews);
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _daysController = TextEditingController(text: '30');
    _searchController = TextEditingController();
    loadData();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _tabController.dispose();
    _daysController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final readAsText = context.watch<SettingsCubit>().state.quranReadAsText;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: buildQuranAppBar(readAsText),
      body: AppRadialBackground(child: buildQuranBody(readAsText)),
    );
  }
}
