part of '../notification_service.dart';

const int _contentDownloadNotificationId = 9200;

Future<void> _showContentDownloadProgress({
  required FlutterLocalNotificationsPlugin notificationsPlugin,
  required int progressPercent,
  required int downloadedBytes,
  required int totalBytes,
  required int bytesPerSecond,
  required bool paused,
}) async {
  final clampedProgress = progressPercent.clamp(0, 100);
  final title = paused
      ? 'تنزيل المحتوى متوقف مؤقتًا'
      : 'جاري تنزيل محتوى التطبيق';
  final body =
      '$clampedProgress% • ${_formatDownloadBytes(downloadedBytes)} / ${_formatDownloadBytes(totalBytes)}'
      '${paused ? '' : ' • ${_formatDownloadBytes(bytesPerSecond)}/ث'}';

  final details = NotificationDetails(
    android: AndroidNotificationDetails(
      'content_download_channel',
      'Content Download',
      channelDescription: 'Shows overall app content download progress',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      playSound: false,
      enableVibration: false,
      onlyAlertOnce: true,
      showProgress: true,
      maxProgress: 100,
      progress: clampedProgress,
    ),
    iOS: const DarwinNotificationDetails(presentSound: false),
  );

  try {
    await notificationsPlugin.show(
      id: _contentDownloadNotificationId,
      title: title,
      body: body,
      notificationDetails: details,
    );
  } catch (_) {
    // Ignore notification plugin errors to avoid breaking the download flow.
  }
}

Future<void> _clearContentDownloadProgress(
  FlutterLocalNotificationsPlugin notificationsPlugin,
) async {
  try {
    await notificationsPlugin.cancel(id: _contentDownloadNotificationId);
  } catch (_) {
    // Ignore notification plugin errors to avoid breaking the download flow.
  }
}

String _formatDownloadBytes(int bytes) {
  if (bytes <= 0) {
    return '0 B';
  }

  const units = <String>['B', 'KB', 'MB', 'GB'];
  var value = bytes.toDouble();
  var unitIndex = 0;
  while (value >= 1024 && unitIndex < units.length - 1) {
    value /= 1024;
    unitIndex++;
  }
  return '${value.toStringAsFixed(unitIndex == 0 ? 0 : 1)} ${units[unitIndex]}';
}
