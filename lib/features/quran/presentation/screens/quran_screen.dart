import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yusr_app/core/bloc/settings_cubit.dart';
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
import 'package:yusr_app/injection_container.dart';

part 'quran_screen_actions.dart';
part 'quran_screen_navigation.dart';
part 'quran_screen_ui.dart';
part 'quran_screen_app_bar.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => QuranScreenState();
}

class QuranScreenState extends State<QuranScreen>
    with SingleTickerProviderStateMixin {
  final QuranRepository _repo = sl<QuranRepository>();
  late final TabController _tabController;
  late final TextEditingController _daysController;
  late final TextEditingController _searchController;
  List<QuranSurah> _surahs = const [];
  String _search = '';
  bool _loading = true;
  QuranLastRead? _lastRead;
  KhatmaPlan? _khatmaPlan;

  void _applyLoadedData(List<QuranSurah> surahs, QuranLastRead? lastRead) {
    if (!mounted) return;
    setState(() {
      _surahs = surahs;
      _lastRead = lastRead;
      _loading = false;
      _khatmaPlan = _repo.calculateKhatmaPlan(30);
    });
  }

  void _applyKhatmaPlan(int days) {
    if (!mounted) return;
    setState(() {
      _khatmaPlan = _repo.calculateKhatmaPlan(days);
    });
  }

  void _updateSearch(String value) {
    if (!mounted) return;
    setState(() => _search = value.trim());
  }

  void _clearSearch() {
    _searchController.clear();
    if (!mounted) return;
    setState(() => _search = '');
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
