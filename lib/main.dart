import 'dart:developer' as dev;

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genui/genui.dart';
import 'package:logging/logging.dart' as log_pkg;

import 'package:kalaam/core/config/app_config.dart';
import 'package:kalaam/firebase_options.dart';
import 'package:kalaam/router.dart';
import 'package:kalaam/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _configureLogging();

  // Demo Mode never touches Firebase, so it runs with zero configuration.
  final firebaseReady = AppConfig.demoMode ? true : await _initFirebase();

  runApp(
    ProviderScope(
      overrides: [firebaseReadyProvider.overrideWithValue(firebaseReady)],
      child: const KalaamApp(),
    ),
  );
}

void _configureLogging() {
  configureLogging(
    logCallback: (level, msg) => dev.log(msg, name: 'genui.$level'),
  );
  log_pkg.Logger.root.level = log_pkg.Level.INFO;
  log_pkg.Logger.root.onRecord.listen(
    (r) => dev.log(r.message, name: r.loggerName),
  );
}

Future<bool> _initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // App Check protects the billable Gemini endpoint. Non-fatal: a missing
    // registration must not block the app, only weaken protection.
    try {
      await FirebaseAppCheck.instance.activate(
        androidProvider: kDebugMode
            ? AndroidProvider.debug
            : AndroidProvider.playIntegrity,
        appleProvider: kDebugMode
            ? AppleProvider.debug
            : AppleProvider.deviceCheck,
      );
    } catch (e, st) {
      dev.log(
        'App Check not activated (continuing): $e',
        name: 'main',
        error: e,
        stackTrace: st,
      );
    }
    return true;
  } catch (e, st) {
    dev.log(
      'Firebase init failed — live mode unavailable. Run `flutterfire configure` '
      'or use --dart-define=KALAAM_DEMO=true.',
      name: 'main',
      error: e,
      stackTrace: st,
    );
    return false;
  }
}

class KalaamApp extends ConsumerWidget {
  const KalaamApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Kalaam كلام',
      debugShowCheckedModeBanner: false,
      theme: KalaamTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: ref.watch(routerProvider),
      // Arabic-first → right-to-left across the whole app.
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
