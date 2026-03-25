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

  IconData get icon => IconData(iconCodeInfo, fontFamily: 'MaterialIcons');
  TimeOfDay get timeOfDay => TimeOfDay(hour: hour, minute: minute);

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
    iconCodeInfo: json['iconCodeInfo'] ?? Icons.notifications.codePoint,
  );
}
