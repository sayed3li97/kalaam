import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_state.freezed.dart';

enum SessionStatus { initialising, active, error, complete }

@freezed
class SessionState with _$SessionState {
  const factory SessionState({
    required String languageCode,
    required String scenarioId,
    required String scenarioTitle,
    @Default(SessionStatus.initialising) SessionStatus status,
    @Default(0) int exercisesCompleted,
    @Default(0) int correctAnswers,
    @Default([]) List<String> wordsEncountered,
    @Default(false) bool isAiThinking,
    String? errorMessage,
  }) = _SessionState;
}
