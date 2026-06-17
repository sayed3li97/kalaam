import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:kalaam/theme.dart';
import 'package:kalaam/features/session/catalog/kalaam_actions.dart';

final culturalNoteItem = CatalogItem(
  name: 'CulturalNote',
  dataSchema: S.object(
    properties: {
      'title': A2uiSchemas.stringReference(
        description: 'Title of cultural note',
      ),
      'body': A2uiSchemas.stringReference(
        description: 'Explanatory text (2-3 sentences)',
      ),
      'doThis': A2uiSchemas.stringReference(
        description: 'Recommended behavior or greeting',
      ),
      'avoidThis': A2uiSchemas.stringReference(
        description: 'Behavior to avoid or common pitfall',
      ),
      'icon': A2uiSchemas.stringReference(
        description: 'Single emoji representing the note topic',
      ),
    },
    required: ['title', 'body', 'doThis', 'avoidThis', 'icon'],
  ),
  exampleData: [
    () => '''
[
  {
    "id": "root",
    "component": "CulturalNote",
    "title": "Ordering in an Ahwa",
    "body": "Egyptian coffee shops (ahawi) are social institutions. The garson (waiter) remembers regulars. Sitting implies you will stay.",
    "doThis": "Greet with أَهْلًا and make eye contact",
    "avoidThis": "Snapping fingers or waving — considered rude",
    "icon": "🫖"
  }
]
''',
  ],
  widgetBuilder: (ctx) {
    final data = ctx.data as Map<String, Object?>;
    final title = data['title'] as String? ?? '';
    final body = data['body'] as String? ?? '';
    final doThis = data['doThis'] as String? ?? '';
    final avoidThis = data['avoidThis'] as String? ?? '';
    final icon = data['icon'] as String? ?? '💡';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: const BoxDecoration(
          color: KalaamColors.surfaceVar,
          border: Border(
            left: BorderSide(color: KalaamColors.primary, width: 4),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 24)),
                const Gap(10),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(ctx.buildContext).textTheme.titleMedium
                        ?.copyWith(
                          color: KalaamColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const Gap(12),
            Text(body, style: Theme.of(ctx.buildContext).textTheme.bodyLarge),
            const Gap(16),

            // Do This pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: KalaamColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: KalaamColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: KalaamColors.success,
                    size: 16,
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      'DO: $doThis',
                      style: const TextStyle(
                        color: KalaamColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(8),

            // Avoid This pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: KalaamColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: KalaamColors.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.cancel_outlined,
                    color: KalaamColors.error,
                    size: 16,
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      'AVOID: $avoidThis',
                      style: const TextStyle(
                        color: KalaamColors.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(16),
            KalaamContinueButton(ctx: ctx, label: 'Got it'),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.05, end: 0);
  },
);
