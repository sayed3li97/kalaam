// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SessionResult _$SessionResultFromJson(Map<String, dynamic> json) {
  return _SessionResult.fromJson(json);
}

/// @nodoc
mixin _$SessionResult {
  String get id => throw _privateConstructorUsedError;
  String get languageCode => throw _privateConstructorUsedError;
  String get scenarioTitle => throw _privateConstructorUsedError;
  int get masteryPercent => throw _privateConstructorUsedError;
  int get wordsLearned => throw _privateConstructorUsedError;
  DateTime get completedAt => throw _privateConstructorUsedError;

  /// Serializes this SessionResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SessionResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SessionResultCopyWith<SessionResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionResultCopyWith<$Res> {
  factory $SessionResultCopyWith(
    SessionResult value,
    $Res Function(SessionResult) then,
  ) = _$SessionResultCopyWithImpl<$Res, SessionResult>;
  @useResult
  $Res call({
    String id,
    String languageCode,
    String scenarioTitle,
    int masteryPercent,
    int wordsLearned,
    DateTime completedAt,
  });
}

/// @nodoc
class _$SessionResultCopyWithImpl<$Res, $Val extends SessionResult>
    implements $SessionResultCopyWith<$Res> {
  _$SessionResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SessionResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? languageCode = null,
    Object? scenarioTitle = null,
    Object? masteryPercent = null,
    Object? wordsLearned = null,
    Object? completedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            languageCode: null == languageCode
                ? _value.languageCode
                : languageCode // ignore: cast_nullable_to_non_nullable
                      as String,
            scenarioTitle: null == scenarioTitle
                ? _value.scenarioTitle
                : scenarioTitle // ignore: cast_nullable_to_non_nullable
                      as String,
            masteryPercent: null == masteryPercent
                ? _value.masteryPercent
                : masteryPercent // ignore: cast_nullable_to_non_nullable
                      as int,
            wordsLearned: null == wordsLearned
                ? _value.wordsLearned
                : wordsLearned // ignore: cast_nullable_to_non_nullable
                      as int,
            completedAt: null == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SessionResultImplCopyWith<$Res>
    implements $SessionResultCopyWith<$Res> {
  factory _$$SessionResultImplCopyWith(
    _$SessionResultImpl value,
    $Res Function(_$SessionResultImpl) then,
  ) = __$$SessionResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String languageCode,
    String scenarioTitle,
    int masteryPercent,
    int wordsLearned,
    DateTime completedAt,
  });
}

/// @nodoc
class __$$SessionResultImplCopyWithImpl<$Res>
    extends _$SessionResultCopyWithImpl<$Res, _$SessionResultImpl>
    implements _$$SessionResultImplCopyWith<$Res> {
  __$$SessionResultImplCopyWithImpl(
    _$SessionResultImpl _value,
    $Res Function(_$SessionResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SessionResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? languageCode = null,
    Object? scenarioTitle = null,
    Object? masteryPercent = null,
    Object? wordsLearned = null,
    Object? completedAt = null,
  }) {
    return _then(
      _$SessionResultImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        languageCode: null == languageCode
            ? _value.languageCode
            : languageCode // ignore: cast_nullable_to_non_nullable
                  as String,
        scenarioTitle: null == scenarioTitle
            ? _value.scenarioTitle
            : scenarioTitle // ignore: cast_nullable_to_non_nullable
                  as String,
        masteryPercent: null == masteryPercent
            ? _value.masteryPercent
            : masteryPercent // ignore: cast_nullable_to_non_nullable
                  as int,
        wordsLearned: null == wordsLearned
            ? _value.wordsLearned
            : wordsLearned // ignore: cast_nullable_to_non_nullable
                  as int,
        completedAt: null == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SessionResultImpl implements _SessionResult {
  const _$SessionResultImpl({
    required this.id,
    required this.languageCode,
    required this.scenarioTitle,
    required this.masteryPercent,
    required this.wordsLearned,
    required this.completedAt,
  });

  factory _$SessionResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$SessionResultImplFromJson(json);

  @override
  final String id;
  @override
  final String languageCode;
  @override
  final String scenarioTitle;
  @override
  final int masteryPercent;
  @override
  final int wordsLearned;
  @override
  final DateTime completedAt;

  @override
  String toString() {
    return 'SessionResult(id: $id, languageCode: $languageCode, scenarioTitle: $scenarioTitle, masteryPercent: $masteryPercent, wordsLearned: $wordsLearned, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionResultImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.languageCode, languageCode) ||
                other.languageCode == languageCode) &&
            (identical(other.scenarioTitle, scenarioTitle) ||
                other.scenarioTitle == scenarioTitle) &&
            (identical(other.masteryPercent, masteryPercent) ||
                other.masteryPercent == masteryPercent) &&
            (identical(other.wordsLearned, wordsLearned) ||
                other.wordsLearned == wordsLearned) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    languageCode,
    scenarioTitle,
    masteryPercent,
    wordsLearned,
    completedAt,
  );

  /// Create a copy of SessionResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionResultImplCopyWith<_$SessionResultImpl> get copyWith =>
      __$$SessionResultImplCopyWithImpl<_$SessionResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SessionResultImplToJson(this);
  }
}

abstract class _SessionResult implements SessionResult {
  const factory _SessionResult({
    required final String id,
    required final String languageCode,
    required final String scenarioTitle,
    required final int masteryPercent,
    required final int wordsLearned,
    required final DateTime completedAt,
  }) = _$SessionResultImpl;

  factory _SessionResult.fromJson(Map<String, dynamic> json) =
      _$SessionResultImpl.fromJson;

  @override
  String get id;
  @override
  String get languageCode;
  @override
  String get scenarioTitle;
  @override
  int get masteryPercent;
  @override
  int get wordsLearned;
  @override
  DateTime get completedAt;

  /// Create a copy of SessionResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionResultImplCopyWith<_$SessionResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
