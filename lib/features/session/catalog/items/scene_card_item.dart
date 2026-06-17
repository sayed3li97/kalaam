import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:kalaam/theme.dart';
import 'package:kalaam/features/session/catalog/kalaam_actions.dart';

final sceneCardItem = CatalogItem(
  name: 'SceneCard',
  dataSchema: S.object(
    properties: {
      'scenarioTitle': A2uiSchemas.stringReference(
        description: 'Title of the scenario',
      ),
      'settingDescription': A2uiSchemas.stringReference(
        description: 'A detailed, evocative description of the environment',
      ),
      'targetLanguage': A2uiSchemas.stringReference(
        description: 'The language being learned',
      ),
      'difficultyLevel': A2uiSchemas.stringReference(
        description: 'Difficulty level (Beginner, Intermediate, Advanced)',
      ),
      'emoji': A2uiSchemas.stringReference(
        description: 'Single emoji representing the scene',
      ),
    },
    required: [
      'scenarioTitle',
      'settingDescription',
      'targetLanguage',
      'difficultyLevel',
      'emoji',
    ],
  ),
  exampleData: [
    () => '''
[
  {
    "id": "root",
    "component": "SceneCard",
    "scenarioTitle": "Ordering Coffee in Cairo",
    "settingDescription": "A bustling ahwa in downtown Cairo. Cardamom coffee smell, al-Ahly match on TV.",
    "targetLanguage": "Arabic",
    "difficultyLevel": "Beginner",
    "emoji": "☕"
  }
]
''',
  ],
  widgetBuilder: (ctx) {
    final data = ctx.data as Map<String, Object?>;
    final title = data['scenarioTitle'] as String? ?? '';
    final description = data['settingDescription'] as String? ?? '';
    final lang = data['targetLanguage'] as String? ?? '';
    final difficulty = data['difficultyLevel'] as String? ?? '';
    final emoji = data['emoji'] as String? ?? '🗺️';

    return Card(
          clipBehavior: Clip.antiAlias,
          child: Container(
            decoration: const BoxDecoration(
              color: KalaamColors.surfaceVar,
              border: Border(
                left: BorderSide(color: KalaamColors.primary, width: 4),
              ),
            ),
            padding: const EdgeInsetsDirectional.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 32)),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(ctx.buildContext)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontSize: 20,
                                  color: KalaamColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const Gap(6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsetsDirectional.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: KalaamColors.surfaceTrim,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  lang,
                                  style: Theme.of(ctx.buildContext)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(color: KalaamColors.secondary),
                                ),
                              ),
                              const Gap(8),
                              Container(
                                padding: const EdgeInsetsDirectional.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: KalaamColors.surfaceTrim,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  difficulty,
                                  style: Theme.of(ctx.buildContext)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(color: KalaamColors.primary),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Gap(16),
                Text(
                  description,
                  style: Theme.of(
                    ctx.buildContext,
                  ).textTheme.bodyLarge?.copyWith(height: 1.5),
                ),
                const Gap(20),
                KalaamContinueButton(ctx: ctx, label: 'Begin lesson'),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
  },
);
