import 'package:freezed_annotation/freezed_annotation.dart';

part 'scenario.freezed.dart';

@freezed
class Scenario with _$Scenario {
  const factory Scenario({
    required String id,
    required String languageCode,
    required String title,
    required String description,
    required String emoji,
    @Default('Beginner') String difficulty,
  }) = _Scenario;
}
