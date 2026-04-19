import 'package:flutter/material.dart';

class ReminderModel {
  final String id;
  final String titleKey;
  final String subtitleKey;
  int hour;
  int minute;
  bool enabled;
  final int iconCodeInfo;

  ReminderModel({
    required this.id,
    required this.titleKey,
    required this.subtitleKey,
    required this.hour,
    required this.minute,
    required this.enabled,
    required this.iconCodeInfo,
  });

  IconData get icon => _iconFromCodePoint(iconCodeInfo);
  TimeOfDay get timeOfDay => TimeOfDay(hour: hour, minute: minute);

  static IconData _iconFromCodePoint(int codePoint) {
    if (codePoint == Icons.nightlight_round.codePoint) {
      return Icons.nightlight_round;
    }
    if (codePoint == Icons.wb_sunny_outlined.codePoint) {
      return Icons.wb_sunny_outlined;
    }
    if (codePoint == Icons.brightness_high.codePoint) {
      return Icons.brightness_high;
    }
    if (codePoint == Icons.brightness_4.codePoint) {
      return Icons.brightness_4;
    }
    if (codePoint == Icons.auto_awesome.codePoint) {
      return Icons.auto_awesome;
    }
    return Icons.notifications;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'titleKey': titleKey,
    'subtitleKey': subtitleKey,
    'hour': hour,
    'minute': minute,
    'enabled': enabled,
    'iconCodeInfo': iconCodeInfo,
  };

  factory ReminderModel.fromJson(Map<String, dynamic> json) => ReminderModel(
    id: json['id'] ?? '0',
    titleKey: json['titleKey'] ?? '',
    subtitleKey: json['subtitleKey'] ?? '',
    hour: json['hour'] ?? 12,
    minute: json['minute'] ?? 0,
    enabled: json['enabled'] ?? true,
    iconCodeInfo: json['iconCodeInfo'] is int
        ? json['iconCodeInfo'] as int
        : int.tryParse(json['iconCodeInfo']?.toString() ?? '') ??
              Icons.notifications.codePoint,
  );
}
