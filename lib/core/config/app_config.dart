import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Build-time configuration for Kalaam.
abstract final class AppConfig {
  /// When true, the app replays curated A2UI transcripts offline instead of
  /// calling Gemini — no Firebase or API key required. Enable with:
  ///
  ///     flutter run --dart-define=KALAAM_DEMO=true
  ///
  /// Live mode (the default) uses the Gemini Developer API via `firebase_ai`.
  static const bool demoMode = bool.fromEnvironment('KALAAM_DEMO');

  /// The Gemini model used in live mode.
  static const String geminiModel = 'gemini-2.5-flash';
}

/// Whether Firebase initialised successfully this launch.
///
/// Always `true` in demo mode (Firebase is never touched). In live mode the
/// real result is injected via a [ProviderScope] override in `main()`, so the
/// UI can fail fast with an actionable message instead of an opaque AI error.
final firebaseReadyProvider = Provider<bool>((ref) => true);
