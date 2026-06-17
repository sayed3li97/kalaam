import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:kalaam/theme.dart';
import 'package:kalaam/features/session/catalog/kalaam_actions.dart';
import 'package:kalaam/shared/services/tts_service.dart';

final phonemeCardItem = CatalogItem(
  name: 'PhonemeCard',
  dataSchema: S.object(
    properties: {
      'phoneme': A2uiSchemas.stringReference(
        description: 'The character or sound, e.g. ع',
      ),
      'ipaNotation': A2uiSchemas.stringReference(
        description: 'IPA phonetic notation',
      ),
      'mouthPositionDescription': A2uiSchemas.stringReference(
        description: 'Instruction on articulation',
      ),
      'nativeExample': A2uiSchemas.stringReference(
        description: 'Example word using the phoneme',
      ),
      'nativeExampleTranslation': A2uiSchemas.stringReference(
        description: 'English translation of example',
      ),
      'challengeCount': S.integer(
        description: 'DataModel-bound attempt counter',
      ),
      'masteryThreshold': S.integer(
        description: 'Number of repetitions to achieve mastery',
      ),
    },
    required: [
      'phoneme',
      'ipaNotation',
      'mouthPositionDescription',
      'nativeExample',
      'nativeExampleTranslation',
      'challengeCount',
      'masteryThreshold',
    ],
  ),
  exampleData: [
    () => '''
[
  {
    "id": "root",
    "component": "PhonemeCard",
    "phoneme": "ع",
    "ipaNotation": "/ʕ/",
    "mouthPositionDescription": "Pharyngeal constriction — like fogging a mirror from deep in the throat. No English equivalent.",
    "nativeExample": "عَيْن",
    "nativeExampleTranslation": "eye / water spring",
    "challengeCount": 0,
    "masteryThreshold": 3
  }
]
''',
  ],
  widgetBuilder: (ctx) {
    final data = ctx.data as Map<String, Object?>;
    final phoneme = data['phoneme'] as String? ?? '';
    final ipa = data['ipaNotation'] as String? ?? '';
    final desc = data['mouthPositionDescription'] as String? ?? '';
    final example = data['nativeExample'] as String? ?? '';
    final translation = data['nativeExampleTranslation'] as String? ?? '';
    final threshold = data['masteryThreshold'] as int? ?? 3;

    return BoundNumber(
      dataContext: ctx.dataContext,
      value: data['challengeCount'],
      builder: (context, val) {
        final count = (val ?? 0).toInt();

        return _PhonemeCardWidget(
          phoneme: phoneme,
          ipa: ipa,
          description: desc,
          example: example,
          translation: translation,
          challengeCount: count,
          masteryThreshold: threshold,
          context: ctx,
          rawData: data,
        );
      },
    );
  },
);

class _PhonemeCardWidget extends StatelessWidget {
  final String phoneme;
  final String ipa;
  final String description;
  final String example;
  final String translation;
  final int challengeCount;
  final int masteryThreshold;
  final CatalogItemContext context;
  final Map<String, Object?> rawData;

  const _PhonemeCardWidget({
    required this.phoneme,
    required this.ipa,
    required this.description,
    required this.example,
    required this.translation,
    required this.challengeCount,
    required this.masteryThreshold,
    required this.context,
    required this.rawData,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (challengeCount / masteryThreshold).clamp(0.0, 1.0);
    final isMastered = challengeCount >= masteryThreshold;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pronunciation Focus',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: KalaamColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                const Gap(16),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: KalaamColors.surfaceTrim,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: KalaamColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          phoneme,
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 48,
                            color: KalaamColors.primary,
                            height: 1.0,
                          ),
                        ),
                        Text(
                          ipa,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Gap(20),

            // Example Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: KalaamColors.surfaceTrim,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.volume_up,
                      color: KalaamColors.primary,
                    ),
                    onPressed: () => KalaamTts.speak(example),
                  ),
                  const Gap(12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        example,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 22,
                          color: KalaamColors.onSurface,
                        ),
                      ),
                      Text(
                        translation,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Gap(20),

            // Progress Bar and Reps
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mastery Progress',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '$challengeCount / $masteryThreshold',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: KalaamColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Gap(8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: KalaamColors.surfaceTrim,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  KalaamColors.primary,
                ),
                minHeight: 8,
              ),
            ),
            const Gap(16),

            // Interactive Button or Completion Badge
            if (!isMastered)
              ElevatedButton.icon(
                icon: const Icon(Icons.check_rounded),
                label: const Text('I\'ve practiced this'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: KalaamColors.primary,
                  foregroundColor: KalaamColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final newCount = challengeCount + 1;
                  final pathMap = rawData['challengeCount'];
                  if (pathMap is Map && pathMap.containsKey('path')) {
                    this.context.dataContext.update(
                      DataPath(pathMap['path'] as String),
                      newCount,
                    );
                  }
                  // Once mastered, advance the lesson.
                  if (newCount >= masteryThreshold) {
                    sendKalaamAction(this.context, 'mastered', {
                      'challengeCount': newCount,
                      'mastered': true,
                    });
                  }
                },
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: KalaamColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: KalaamColors.success),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      color: KalaamColors.success,
                      size: 20,
                    ),
                    const Gap(8),
                    Text(
                      'Mastered! 🎉',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: KalaamColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }
}
