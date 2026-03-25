import 'package:flutter/material.dart';
import '../models/reminder_model.dart';
import '../../../../core/localization/app_translations.dart';

List<ReminderModel> getDummyReminders() {
  return [
    ReminderModel(
      id: '1',
      titleKey: AppStrings.suratAlMulk,
      subtitleKey: AppStrings.daily,
      hour: 21,
      minute: 30, // 9:30 PM
      enabled: true,
      iconCodeInfo: Icons.nightlight_round.codePoint,
    ),
    ReminderModel(
      id: '2',
      titleKey: AppStrings.suratAlKahf,
      subtitleKey: AppStrings.weeklyFriday,
      hour: 8,
      minute: 0, // 8:00 AM
      enabled: true,
      iconCodeInfo: Icons.wb_sunny_outlined.codePoint,
    ),
    ReminderModel(
      id: '3',
      titleKey: AppStrings.morningAdhkar,
      subtitleKey: AppStrings.daily,
      hour: 6,
      minute: 0, // 6:00 AM
      enabled: false,
      iconCodeInfo: Icons.brightness_high.codePoint,
    ),
    ReminderModel(
      id: '4',
      titleKey: AppStrings.eveningAdhkar,
      subtitleKey: AppStrings.daily,
      hour: 16,
      minute: 30, // 4:30 PM
      enabled: true,
      iconCodeInfo: Icons.brightness_4.codePoint,
    ),
  ];
}
