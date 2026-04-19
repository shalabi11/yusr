import 'download_content_type.dart';

enum ContentDownloadOption {
  all,
  quranOnly,
  adhkarOnly;

  Set<DownloadContentType> get targetTypes {
    switch (this) {
      case ContentDownloadOption.all:
        return {DownloadContentType.quran, DownloadContentType.adhkar};
      case ContentDownloadOption.quranOnly:
        return {DownloadContentType.quran};
      case ContentDownloadOption.adhkarOnly:
        return {DownloadContentType.adhkar};
    }
  }

  String get title {
    switch (this) {
      case ContentDownloadOption.all:
        return 'تنزيل كل المحتوى';
      case ContentDownloadOption.quranOnly:
        return 'تنزيل القرآن فقط';
      case ContentDownloadOption.adhkarOnly:
        return 'تنزيل الأذكار فقط';
    }
  }

  String get description {
    switch (this) {
      case ContentDownloadOption.all:
        return 'قرآن + أذكار للوصول السريع بدون إنترنت.';
      case ContentDownloadOption.quranOnly:
        return 'تنزيل ملف القرآن فقط لتقليل حجم التحميل.';
      case ContentDownloadOption.adhkarOnly:
        return 'تنزيل الأذكار الآن مع إمكانية تنزيل القرآن لاحقًا.';
    }
  }
}
