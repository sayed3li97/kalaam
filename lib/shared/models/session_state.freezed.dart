// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SessionState {
  String get languageCode => throw _privateConstructorUsedError;
  String get scenarioId => throw _privateConstructorUsedError;
  String get scenarioTitle => throw _privateConstructorUsedError;
  SessionStatus get status => throw _privateConstructorUsedError;
  int get exercisesCompleted => throw _privateConstructorUsedError;
  int get correctAnswers => throw _privateConstructorUsedError;
  List<String> get wordsEncountered => throw _privateConstructorUsedError;
  bool get isAiThinking => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of SessionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SessionStateCopyWith<SessionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionStateCopyWith<$Res> {
  factory $SessionStateCopyWith(
    SessionState value,
    $Res Function(SessionState) then,
  ) = _$SessionStateCopyWithImpl<$Res, SessionState>;
  @useResult
  $Res call({
    String languageCode,
    String scenarioId,
    String scenarioTitle,
    SessionStatus status,
    int exercisesCompleted,
    int correctAnswers,
    List<String> wordsEncountered,
    bool isAiThinking,
    String? errorMessage,
  });
}

/// @nodoc
class _$SessionStateCopyWithImpl<$Res, $Val extends SessionState>
    implements $SessionStateCopyWith<$Res> {
  _$SessionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SessionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? languageCode = null,
    Object? scenarioId = null,
    Object? scenarioTitle = null,
    Object? status = null,
    Object? exercisesCompleted = null,
    Object? correctAnswers = null,
    Object? wordsEncountered = null,
    Object? isAiThinking = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            languageCode: null == languageCode
                ? _value.languageCode
                : languageCode // ignore: cast_nullable_to_non_nullable
                      as String,
            scenarioId: null == scenarioId
                ? _value.scenarioId
                : scenarioId // ignore: cast_nullable_to_non_nullable
                      as String,
            scenarioTitle: null == scenarioTitle
                ? _value.scenarioTitle
                : scenarioTitle // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as SessionStatus,
            exercisesCompleted: null == exercisesCompleted
                ? _value.exercisesCompleted
                : exercisesCompleted // ignore: cast_nullable_to_non_nullable
                      as int,
            correctAnswers: null == correctAnswers
                ? _value.correctAnswers
                : correctAnswers // ignore: cast_nullable_to_non_nullable
                      as int,
            wordsEncountered: null == wordsEncountered
                ? _value.wordsEncountered
                : wordsEncountered // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            isAiThinking: null == isAiThinking
                ? _value.isAiThinking
                : isAiThinking // ignore: cast_nullable_to_non_nullable
                      as bool,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SessionStateImplCopyWith<$Res>
    implements $SessionStateCopyWith<$Res> {
  factory _$$SessionStateImplCopyWith(
    _$SessionStateImpl value,
    $Res Function(_$SessionStateImpl) then,
  ) = __$$SessionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String languageCode,
    String scenarioId,
    String scenarioTitle,
    SessionStatus status,
    int exercisesCompleted,
    int correctAnswers,
    List<String> wordsEncountered,
    bool isAiThinking,
    String? errorMessage,
  });
}

/// @nodoc
class __$$SessionStateImplCopyWithImpl<$Res>
    extends _$SessionStateCopyWithImpl<$Res, _$SessionStateImpl>
    implements _$$SessionStateImplCopyWith<$Res> {
  __$$SessionStateImplCopyWithImpl(
    _$SessionStateImpl _value,
    $Res Function(_$SessionStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SessionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? languageCode = null,
    Object? scenarioId = null,
    Object? scenarioTitle = null,
    Object? status = null,
    Object? exercisesCompleted = null,
    Object? correctAnswers = null,
    Object? wordsEncountered = null,
    Object? isAiThinking = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$SessionStateImpl(
        languageCode: null == languageCode
            ? _value.languageCode
            : languageCode // ignore: cast_nullable_to_non_nullable
                  as String,
        scenarioId: null == scenarioId
            ? _value.scenarioId
            : scenarioId // ignore: cast_nullable_to_non_nullable
                  as String,
        scenarioTitle: null == scenarioTitle
            ? _value.scenarioTitle
            : scenarioTitle // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as SessionStatus,
        exercisesCompleted: null == exercisesCompleted
            ? _value.exercisesCompleted
            : exercisesCompleted // ignore: cast_nullable_to_non_nullable
                  as int,
        correctAnswers: null == correctAnswers
            ? _value.correctAnswers
            : correctAnswers // ignore: cast_nullable_to_non_nullable
                  as int,
        wordsEncountered: null == wordsEncountered
            ? _value._wordsEncountered
            : wordsEncountered // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        isAiThinking: null == isAiThinking
            ? _value.isAiThinking
            : isAiThinking // ignore: cast_nullable_to_non_nullable
                  as bool,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$SessionStateImpl implements _SessionState {
  const _$SessionStateImpl({
    required this.languageCode,
    required this.scenarioId,
    required this.scenarioTitle,
    this.status = SessionStatus.initialising,
    this.exercisesCompleted = 0,
    this.correctAnswers = 0,
    final List<String> wordsEncountered = const [],
    this.isAiThinking = false,
    this.errorMessage,
  }) : _wordsEncountered = wordsEncountered;

  @override
  final String languageCode;
  @override
  final String scenarioId;
  @override
  final String scenarioTitle;
  @override
  @JsonKey()
  final SessionStatus status;
  @override
  @JsonKey()
  final int exercisesCompleted;
  @override
  @JsonKey()
  final int correctAnswers;
  final List<String> _wordsEncountered;
  @override
  @JsonKey()
  List<String> get wordsEncountered {
    if (_wordsEncountered is EqualUnmodifiableListView)
      return _wordsEncountered;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_wordsEncountered);
  }

  @override
  @JsonKey()
  final bool isAiThinking;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'SessionState(languageCode: $languageCode, scenarioId: $scenarioId, scenarioTitle: $scenarioTitle, status: $status, exercisesCompleted: $exercisesCompleted, correctAnswers: $correctAnswers, wordsEncountered: $wordsEncountered, isAiThinking: $isAiThinking, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionStateImpl &&
            (identical(other.languageCode, languageCode) ||
                other.languageCode == languageCode) &&
            (identical(other.scenarioId, scenarioId) ||
                other.scenarioId == scenarioId) &&
            (identical(other.scenarioTitle, scenarioTitle) ||
                other.scenarioTitle == scenarioTitle) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.exercisesCompleted, exercisesCompleted) ||
                other.exercisesCompleted == exercisesCompleted) &&
            (identical(other.correctAnswers, correctAnswers) ||
                other.correctAnswers == correctAnswers) &&
            const DeepCollectionEquality().equals(
              other._wordsEncountered,
              _wordsEncountered,
            ) &&
            (identical(other.isAiThinking, isAiThinking) ||
                other.isAiThinking == isAiThinking) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    languageCode,
    scenarioId,
    scenarioTitle,
    status,
    exercisesCompleted,
    correctAnswers,
    const DeepCollectionEquality().hash(_wordsEncountered),
    isAiThinking,
    errorMessage,
  );

  /// Create a copy of SessionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionStateImplCopyWith<_$SessionStateImpl> get copyWith =>
      __$$SessionStateImplCopyWithImpl<_$SessionStateImpl>(this, _$identity);
}

abstract class _SessionState implements SessionState {
  const factory _SessionState({
    required final String languageCode,
    required final String scenarioId,
    required final String scenarioTitle,
    final SessionStatus status,
    final int exercisesCompleted,
    final int correctAnswers,
    final List<String> wordsEncountered,
    final bool isAiThinking,
    final String? errorMessage,
  }) = _$SessionStateImpl;

  @override
  String get languageCode;
  @override
  String get scenarioId;
  @override
  String get scenarioTitle;
  @override
  SessionStatus get status;
  @override
  int get exercisesCompleted;
  @override
  int get correctAnswers;
  @override
  List<String> get wordsEncountered;
  @override
  bool get isAiThinking;
  @override
  String? get errorMessage;

  /// Create a copy of SessionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionStateImplCopyWith<_$SessionStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
