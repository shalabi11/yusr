import 'package:get_it/get_it.dart';
import 'package:yusr_app/core/services/storage_service.dart';
import 'package:yusr_app/injection/adhkar_injection.dart';
import 'package:yusr_app/injection/assistant_injection.dart';
import 'package:yusr_app/injection/content_download_injection.dart';
import 'package:yusr_app/injection/core_injection.dart';
import 'package:yusr_app/injection/cubits_injection.dart';
import 'package:yusr_app/injection/home_injection.dart';
import 'package:yusr_app/injection/prayer_times_injection.dart';
import 'package:yusr_app/injection/quran_injection.dart';
import 'package:yusr_app/injection/reminders_injection.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  const assistantWebhookUrl = String.fromEnvironment(
    'N8N_ASSISTANT_WEBHOOK_URL',
    defaultValue:
        'https://nonfenestrated-unreplevined-obdulia.ngrok-free.dev/webhook-test/yusr-assistant-split',
  );
  final prefs = await SharedPreferences.getInstance();

  registerCoreServices(sl, prefs);
  registerContentDownloadDependencies(sl);
  registerAssistantDependencies(sl, webhookUrl: assistantWebhookUrl);
  registerPrayerTimesDependencies(sl);
  registerQuranDependencies(sl);
  registerRemindersDependencies(sl);
  registerAdhkarDependencies(sl);
  registerHomeDependencies(sl);
  StorageService.bind(sl());
  registerCubits(sl);
}
