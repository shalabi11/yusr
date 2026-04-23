String formatContentBytes(int bytes) {
  if (bytes <= 0) {
    return '0 B';
  }

  const units = <String>['B', 'KB', 'MB', 'GB'];
  var value = bytes.toDouble();
  var unitIndex = 0;

  while (value >= 1024 && unitIndex < units.length - 1) {
    value /= 1024;
    unitIndex += 1;
  }

  return '${value.toStringAsFixed(unitIndex == 0 ? 0 : 1)} ${units[unitIndex]}';
}
