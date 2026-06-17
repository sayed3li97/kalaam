import 'package:flutter/widgets.dart';
import 'package:kalaam/shared/models/language.dart';

abstract final class KalaamLanguages {
  static const arabic = Language(
    code: 'ar',
    name: 'Arabic',
    nativeName: 'العربية',
    flag: '🇸🇦',
    textDirection: TextDirection.rtl,
  );
  static const french = Language(
    code: 'fr',
    name: 'French',
    nativeName: 'Français',
    flag: '🇫🇷',
  );
  static const japanese = Language(
    code: 'ja',
    name: 'Japanese',
    nativeName: '日本語',
    flag: '🇯🇵',
  );
  static const spanish = Language(
    code: 'es',
    name: 'Spanish',
    nativeName: 'Español',
    flag: '🇪🇸',
  );
  static const all = [arabic, french, japanese, spanish];
  static Language? byCode(String code) =>
      all.where((l) => l.code == code).firstOrNull;
}
