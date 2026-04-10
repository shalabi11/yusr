String formatPrayerCountdown(Duration remaining) {
  final safe = remaining.isNegative ? Duration.zero : remaining;
  final hours = safe.inHours.toString().padLeft(2, '0');
  final minutes = (safe.inMinutes % 60).toString().padLeft(2, '0');
  final seconds = (safe.inSeconds % 60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}

String formatPrayerHoursMinutes(Duration remaining) {
  final safe = remaining.isNegative ? Duration.zero : remaining;
  final totalMinutes = safe.inMinutes;
  final hours = (totalMinutes ~/ 60).toString().padLeft(2, '0');
  final minutes = (totalMinutes % 60).toString().padLeft(2, '0');
  return '$hours:$minutes';
}
