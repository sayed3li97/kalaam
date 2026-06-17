import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_result.freezed.dart';
part 'session_result.g.dart';

@freezed
class SessionResult with _$SessionResult {
  const factory SessionResult({
    required String id,
    required String languageCode,
    required String scenarioTitle,
    required int masteryPercent,
    required int wordsLearned,
    required DateTime completedAt,
  }) = _SessionResult;

  factory SessionResult.fromJson(Map<String, dynamic> json) =>
      _$SessionResultFromJson(json);
}
