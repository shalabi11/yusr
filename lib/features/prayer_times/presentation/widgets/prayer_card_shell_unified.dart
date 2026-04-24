import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/features/prayer_times/domain/entities/prayer_time.dart';

/// Unified Prayer Card Shell
/// Replaces both NextPrayerCard and NextPrayerSummaryCard with a single, flexible component.
/// 
/// **Why this is better:**
/// - Eliminates code duplication
/// - Easier to maintain and update styling
/// - Supports multiple display modes with a single component
/// - Follows DRY (Don't Repeat Yourself) principle
/// - Reduces bundle size
class PrayerCardShellUnified extends StatelessWidget {
  const PrayerCardShellUnified({
    required this.prayer,
    required this.timeUntilNext,
    this.displayMode = PrayerCardDisplayMode.full,
    this.onTap,
    super.key,
  });

  /// The prayer time data
  final PrayerTime prayer;

  /// Time remaining until next prayer (e.g., "2h 30m")
  final String timeUntilNext;

  /// Display mode: full card or summary
  final PrayerCardDisplayMode displayMode;

  /// Optional callback when card is tapped
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.9),
              AppColors.primary.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: displayMode == PrayerCardDisplayMode.full
            ? _buildFullCard()
            : _buildSummaryCard(),
      ),
    );
  }

  /// Full card layout: shows prayer name, time, and countdown
  Widget _buildFullCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          prayer.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textWhite,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              prayer.time,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.textWhite.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                timeUntilNext,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Summary card layout: compact version with prayer name and time only
  Widget _buildSummaryCard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              prayer.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textWhite,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              timeUntilNext,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textWhite.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        Text(
          prayer.time,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }
}

/// Display mode for prayer card
enum PrayerCardDisplayMode {
  /// Full card with all details
  full,

  /// Compact summary card
  summary,
}
