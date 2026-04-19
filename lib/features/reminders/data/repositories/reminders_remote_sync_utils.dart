import 'package:yusr_app/core/localization/app_translations.dart';

import '../models/reminder_model.dart';

int nextAvailableReminderId(Set<int> used) {
  var next = 1;
  while (used.contains(next)) {
    next++;
  }
  return next;
}

(int, int) parseReminderSqlTime(String? time) {
  if (time == null || time.isEmpty) return (8, 0);
  final parts = time.split(':');
  if (parts.length < 2) return (8, 0);
  final hour = int.tryParse(parts[0]) ?? 8;
  final minute = int.tryParse(parts[1]) ?? 0;
  return (hour.clamp(0, 23), minute.clamp(0, 59));
}

String toReminderSqlTime(int hour, int minute) {
  final h = hour.toString().padLeft(2, '0');
  final m = minute.toString().padLeft(2, '0');
  return '$h:$m:00';
}

ReminderModel mapReminderFromRemote(
  Map<String, dynamic> map,
  Set<int> usedIds,
) {
  final sourceId = map['source_id']?.toString() ?? '';
  int id = int.tryParse(sourceId) ?? nextAvailableReminderId(usedIds);
  while (usedIds.contains(id)) {
    id = nextAvailableReminderId(usedIds);
  }
  usedIds.add(id);

  final time = parseReminderSqlTime(map['time_of_day']?.toString());
  final frequency = map['frequency']?.toString();
  final subtitle = map['subtitle']?.toString();

  return ReminderModel(
    id: id.toString(),
    titleKey: map['title']?.toString() ?? '',
    subtitleKey: frequency == 'weekly_friday'
        ? AppStrings.weeklyFriday
        : (subtitle?.isNotEmpty == true ? subtitle! : AppStrings.daily),
    hour: time.$1,
    minute: time.$2,
    enabled: map['enabled'] == true,
    iconCodeInfo: (map['icon_code_point'] as int?) ?? 0xe7f4,
  );
}
