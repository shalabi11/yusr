import 'dart:io';

import 'package:supabase/supabase.dart';

import 'seeding/seed_adhkar.dart';
import 'seeding/seed_daily_content.dart';
import 'seeding/seed_quran.dart';

Future<void> main(List<String> args) async {
  final dryRun = args.contains('--dry-run');

  stdout.writeln('Starting seed process... dryRun=$dryRun');

  if (dryRun) {
    await seedQuran(null, dryRun: true);
    await seedAdhkar(null, dryRun: true);
    await seedDailyContent(null, dryRun: true);
    stdout.writeln('Dry-run finished successfully.');
    return;
  }

  final url = Platform.environment['SUPABASE_URL'] ?? '';
  final serviceRoleKey =
      Platform.environment['SUPABASE_SERVICE_ROLE_KEY'] ?? '';

  if (url.isEmpty || serviceRoleKey.isEmpty) {
    stderr.writeln('Missing required environment variables.');
    stderr.writeln(
      'Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY, then run again.',
    );
    stderr.writeln('Example:');
    stderr.writeln(
      r'$env:SUPABASE_URL="https://PROJECT_ID.supabase.co"; '
      r'$env:SUPABASE_SERVICE_ROLE_KEY="YOUR_SERVICE_ROLE"; '
      r'dart run tool/seed_supabase.dart',
    );
    exitCode = 64;
    return;
  }

  final client = SupabaseClient(url, serviceRoleKey);

  await seedQuran(client, dryRun: false);
  await seedAdhkar(client, dryRun: false);
  await seedDailyContent(client, dryRun: false);

  stdout.writeln('Seed process finished successfully.');
}
