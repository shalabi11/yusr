class HijriDate {
  final int year;
  final int month;
  final int day;

  const HijriDate({required this.year, required this.month, required this.day});

  bool get isWhiteDay => day >= 13 && day <= 15;

  String get monthNameAr {
    const names = <String>[
      'محرم',
      'صفر',
      'ربيع الأول',
      'ربيع الآخر',
      'جمادى الأولى',
      'جمادى الآخرة',
      'رجب',
      'شعبان',
      'رمضان',
      'شوال',
      'ذو القعدة',
      'ذو الحجة',
    ];
    final idx = month - 1;
    if (idx < 0 || idx >= names.length) return 'غير معروف';
    return names[idx];
  }

  String get formattedAr => '$day $monthNameAr $year هـ';
}

class HijriUtils {
  static const int _civilEpoch = 1948440;

  static HijriDate fromGregorian(DateTime date) {
    final jd = _julianDay(date.year, date.month, date.day);
    final l = jd - _civilEpoch + 10632;
    final n = (l - 1) ~/ 10631;
    final l2 = l - 10631 * n + 354;
    final j =
        ((10985 - l2) ~/ 5316) * ((50 * l2) ~/ 17719) +
        (l2 ~/ 5670) * ((43 * l2) ~/ 15238);
    final l3 =
        l2 -
        ((30 - j) ~/ 15) * ((17719 * j) ~/ 50) -
        (j ~/ 16) * ((15238 * j) ~/ 43) +
        29;
    final month = (24 * l3) ~/ 709;
    final day = l3 - (709 * month) ~/ 24;
    final year = 30 * n + j - 30;

    return HijriDate(year: year, month: month, day: day);
  }

  static int _julianDay(int year, int month, int day) {
    final a = (14 - month) ~/ 12;
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;
    return day +
        (153 * m + 2) ~/ 5 +
        365 * y +
        y ~/ 4 -
        y ~/ 100 +
        y ~/ 400 -
        32045;
  }
}
