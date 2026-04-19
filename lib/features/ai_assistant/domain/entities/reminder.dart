import 'package:equatable/equatable.dart';

class Reminder extends Equatable {
  const Reminder({
    required this.title,
    required this.type,
    required this.hour,
    required this.minute,
    required this.repeat,
    this.id,
    this.enabled = true,
  });

  /// The Supabase UUID of this reminder, if known.
  /// When present, n8n uses the preferred update/delete-by-id strategy.
  final String? id;
  final String title;
  final String type;
  final int hour;
  final int minute;
  final String repeat;
  final bool enabled;

  @override
  List<Object?> get props => [id, title, type, hour, minute, repeat, enabled];
}
