import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yusr_app/core/bloc/settings_cubit.dart';
import 'package:yusr_app/core/services/storage_service.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/app_radial_background.dart';
import 'package:yusr_app/features/quran/presentation/cubit/quran_cubit.dart';
import 'package:yusr_app/features/quran/presentation/cubit/quran_state.dart';

import 'package:yusr_app/features/quran/presentation/screens/quran_page_viewer_screen.dart';
import 'package:yusr_app/features/quran/presentation/screens/quran_reader_screen.dart';
import 'package:yusr_app/features/quran/presentation/widgets/quran_juz_tab.dart';
import 'package:yusr_app/features/quran/presentation/widgets/quran_bookmarks_sheet.dart';
import 'package:yusr_app/features/quran/presentation/widgets/quran_khatma_tab.dart';
import 'package:yusr_app/features/quran/presentation/widgets/quran_pages_tab.dart';
import 'package:yusr_app/features/quran/presentation/widgets/quran_quick_jump_sheet.dart';
import 'package:yusr_app/features/quran/presentation/widgets/quran_surah_tab.dart';

part 'quran_screen_navigation.dart';
part 'quran_screen_ui.dart';
part 'quran_screen_app_bar.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _daysController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _daysController = TextEditingController(text: '30');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final cubit = context.read<QuranCubit>();
      if (cubit.state.status != QuranStatus.loaded ||
          cubit.state.surahs.isEmpty) {
        cubit.loadData();
      }
    });
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

    return BlocBuilder<QuranCubit, QuranState>(
      builder: (context, state) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: buildQuranAppBar(readAsText, state),
          body: AppRadialBackground(
            child: buildQuranBody(readAsText, isArabic: isArabic, state: state),
          ),
        );
      },
    );
  }
}
