String formatPrayerCountdown(Duration remaining) {
  final safe = remaining.isNegative ? Duration.zero : remaining;
  final totalMinutes = safe.inMinutes;
  final hours = (totalMinutes ~/ 60).toString().padLeft(2, '0');
  final minutes = (totalMinutes % 60).toString().padLeft(2, '0');
  return '$hours:$minutes';
}

String formatPrayerHoursMinutes(Duration remaining) {
  final safe = remaining.isNegative ? Duration.zero : remaining;
  final totalMinutes = safe.inMinutes;
  final hours = (totalMinutes ~/ 60).toString().padLeft(2, '0');
  final minutes = (totalMinutes % 60).toString().padLeft(2, '0');
  return '$hours:$minutes';
}
