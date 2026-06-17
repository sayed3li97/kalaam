// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SessionResultImpl _$$SessionResultImplFromJson(Map<String, dynamic> json) =>
    _$SessionResultImpl(
      id: json['id'] as String,
      languageCode: json['languageCode'] as String,
      scenarioTitle: json['scenarioTitle'] as String,
      masteryPercent: (json['masteryPercent'] as num).toInt(),
      wordsLearned: (json['wordsLearned'] as num).toInt(),
      completedAt: DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$$SessionResultImplToJson(_$SessionResultImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'languageCode': instance.languageCode,
      'scenarioTitle': instance.scenarioTitle,
      'masteryPercent': instance.masteryPercent,
      'wordsLearned': instance.wordsLearned,
      'completedAt': instance.completedAt.toIso8601String(),
    };
