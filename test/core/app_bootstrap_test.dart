import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yusr_app/core/services/app_bootstrap.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences bootstrapPrefs;
  late Completer<SharedPreferences> sharedPreferencesCompleter;
  late Completer<void> storageHiveGate;
  late Completer<void> supabaseGate;
  final callLog = <String>[];

  setUp(() async {
    AppBootstrap.instance.resetForTesting();
    AppBootstrap.resetTestHooks();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    bootstrapPrefs = await SharedPreferences.getInstance();
    sharedPreferencesCompleter = Completer<SharedPreferences>();
    storageHiveGate = Completer<void>();
    supabaseGate = Completer<void>();
    callLog.clear();

    AppBootstrap.sharedPreferencesLoader = () {
      callLog.add('sharedPreferencesLoader');
      return sharedPreferencesCompleter.future;
    };
    AppBootstrap.storageHiveInitializer = (prefs) async {
      callLog.add('storageHiveInitializer');
      expect(prefs, same(bootstrapPrefs));
      await storageHiveGate.future;
    };
    AppBootstrap.supabaseInitializer = () async {
      callLog.add('supabaseInitializer');
      await supabaseGate.future;
    };
    AppBootstrap.dependenciesInitializer =
        ({required SharedPreferences sharedPreferences}) async {
          callLog.add('dependenciesInitializer');
          expect(sharedPreferences, same(bootstrapPrefs));
        };
  });

  tearDown(() {
    AppBootstrap.instance.resetForTesting();
    AppBootstrap.resetTestHooks();
  });

  test('runs startup steps in order before reporting ready', () async {
    final startFuture = AppBootstrap.instance.start();

    await Future<void>.delayed(Duration.zero);
    expect(
      callLog,
      equals(<String>['sharedPreferencesLoader', 'supabaseInitializer']),
    );
    expect(AppBootstrap.instance.status.value, AppBootstrapStatus.running);

    sharedPreferencesCompleter.complete(bootstrapPrefs);
    await Future<void>.delayed(Duration.zero);
    expect(
      callLog,
      equals(<String>[
        'sharedPreferencesLoader',
        'supabaseInitializer',
        'storageHiveInitializer',
      ]),
    );
    expect(AppBootstrap.instance.status.value, AppBootstrapStatus.running);

    storageHiveGate.complete();
    await Future<void>.delayed(Duration.zero);
    expect(
      callLog,
      equals(<String>[
        'sharedPreferencesLoader',
        'supabaseInitializer',
        'storageHiveInitializer',
      ]),
    );
    expect(AppBootstrap.instance.status.value, AppBootstrapStatus.running);

    supabaseGate.complete();
    await startFuture;

    expect(
      callLog,
      equals(<String>[
        'sharedPreferencesLoader',
        'supabaseInitializer',
        'storageHiveInitializer',
        'dependenciesInitializer',
      ]),
    );
    expect(AppBootstrap.instance.status.value, AppBootstrapStatus.ready);
  });
}
