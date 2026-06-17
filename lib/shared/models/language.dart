import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'language.freezed.dart';

@freezed
class Language with _$Language {
  const factory Language({
    required String code,
    required String name,
    required String nativeName,
    required String flag,
    @Default(TextDirection.ltr) TextDirection textDirection,
  }) = _Language;
}
