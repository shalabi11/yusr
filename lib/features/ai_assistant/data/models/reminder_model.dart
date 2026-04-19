import 'package:yusr_app/features/ai_assistant/domain/entities/reminder.dart';

class ReminderModel extends Reminder {
  const ReminderModel({
    required super.title,
    required super.type,
    required super.hour,
    required super.minute,
    required super.repeat,
    super.id,
    super.enabled,
  });

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id']?.toString(),
      title: map['title']?.toString() ?? '',
      type: map['type']?.toString() ?? 'custom',
      hour: _toInt(map['hour']),
      minute: _toInt(map['minute']),
      repeat: map['repeat']?.toString() ?? 'daily',
      enabled: map['enabled'] is bool ? map['enabled'] as bool : true,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }
}
