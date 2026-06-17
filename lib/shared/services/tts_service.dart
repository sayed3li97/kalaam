import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Shared [FlutterTts] instance to avoid leaking native resources.
///
/// A single TTS engine is configured once and reused across all widgets
/// (instantiating `FlutterTts()` per tap leaks a native synthesizer). It also
/// verifies an Arabic voice is actually installed before speaking — otherwise
/// the platform would either stay silent or mangle the pronunciation, which is
/// worse than nothing for a language tutor.
abstract final class KalaamTts {
  static final FlutterTts _tts = FlutterTts();
  static bool _configured = false;
  static bool _arabicAvailable = false;

  static Future<void> _ensureConfigured() async {
    if (_configured) return;
    _configured = true;
    try {
      // Prefer a regional Arabic voice, fall back to the generic tag.
      final hasRegional = await _tts.isLanguageAvailable('ar-SA') == true;
      final lang = hasRegional ? 'ar-SA' : 'ar';
      _arabicAvailable =
          hasRegional || await _tts.isLanguageAvailable('ar') == true;
      if (_arabicAvailable) {
        await _tts.setLanguage(lang);
        await _tts.setSpeechRate(0.45);
        await _tts.setPitch(1.0);
      }
    } catch (_) {
      // Some platforms/emulators have no TTS engine at all.
      _arabicAvailable = false;
    }
  }

  /// Whether the device has an Arabic voice installed.
  static bool get arabicAvailable => _arabicAvailable;

  /// Speak [text] in Arabic. Safe to call repeatedly. Always gives a light
  /// haptic so the tap registers even when no Arabic voice is available.
  static Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    await _ensureConfigured();
    await HapticFeedback.selectionClick();
    if (!_arabicAvailable) return; // No Arabic voice — stay silent.
    await _tts.stop();
    await _tts.speak(text);
  }
}
