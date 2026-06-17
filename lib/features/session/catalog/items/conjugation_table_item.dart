import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import 'package:kalaam/theme.dart';
import 'package:kalaam/features/session/catalog/kalaam_actions.dart';
import 'package:kalaam/shared/services/tts_service.dart';

final _arabic = RegExp(r'[؀-ۿ]');

/// ConjugationTable — a morphology grid the AI authors (verb conjugations,
/// pronoun tables, the ten verb forms…). Arabic cells are tappable: they speak
/// via TTS and ask the AI to explain that cell. Shows genui rendering real
/// structured, AI-generated data.
final conjugationTableItem = CatalogItem(
  name: 'ConjugationTable',
  dataSchema: S.object(
    properties: {
      'title': A2uiSchemas.stringReference(
        description: 'Table title, e.g. "Past tense — كَتَبَ (to write)"',
      ),
      'headers': S.list(
        description: 'Column headers (2-4), e.g. ["Pronoun","Arabic","Sound"]',
        minItems: 2,
        maxItems: 4,
        items: S.string(),
      ),
      'rows': S.list(
        description:
            'Data rows; each row.cells length must equal headers length',
        minItems: 1,
        maxItems: 12,
        items: S.object(
          properties: {
            'cells': S.list(
              items: S.string(),
              description: 'One string per column',
            ),
            'highlight': S.boolean(
              description: 'Emphasise this row (optional)',
            ),
          },
          required: ['cells'],
        ),
      ),
      'caption': A2uiSchemas.stringReference(
        description: 'Optional note under the table, e.g. the pattern (wazn)',
      ),
    },
    required: ['title', 'headers', 'rows'],
  ),
  exampleData: [
    () => '''
[
  {
    "id": "root",
    "component": "ConjugationTable",
    "title": "Past tense — كَتَبَ (to write)",
    "headers": ["Pronoun", "Arabic", "Sound"],
    "rows": [
      {"cells": ["I", "كَتَبْتُ", "katabtu"]},
      {"cells": ["you (m)", "كَتَبْتَ", "katabta"]},
      {"cells": ["he", "كَتَبَ", "kataba"], "highlight": true},
      {"cells": ["she", "كَتَبَتْ", "katabat"]},
      {"cells": ["we", "كَتَبْنَا", "katabnā"]}
    ],
    "caption": "Root ك-ت-ب on the فَعَلَ pattern"
  }
]
''',
  ],
  widgetBuilder: (ctx) {
    final data = ctx.data as Map<String, Object?>;
    final title = data['title'] as String? ?? '';
    final headers = List<String>.from(data['headers'] as List? ?? const []);
    final rows = (data['rows'] as List? ?? const [])
        .map((r) => r as Map<String, Object?>)
        .toList();
    final caption = data['caption'] as String? ?? '';

    return _ConjugationTableWidget(
      title: title,
      headers: headers,
      rows: rows,
      caption: caption,
      ctx: ctx,
    );
  },
);

class _ConjugationTableWidget extends StatelessWidget {
  const _ConjugationTableWidget({
    required this.title,
    required this.headers,
    required this.rows,
    required this.caption,
    required this.ctx,
  });

  final String title;
  final List<String> headers;
  final List<Map<String, Object?>> rows;
  final String caption;
  final CatalogItemContext ctx;

  Future<void> _speak(String text) => KalaamTts.speak(text);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: KalaamColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(16),
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: KalaamColors.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                children: [
                  // Header row
                  _Row(cells: headers, isHeader: true),
                  ...rows.asMap().entries.map((entry) {
                    final i = entry.key;
                    final row = entry.value;
                    final cells = List<String>.from(
                      row['cells'] as List? ?? const [],
                    );
                    final highlight = row['highlight'] as bool? ?? false;
                    return _Row(
                      cells: cells,
                      striped: i.isOdd,
                      highlight: highlight,
                      onTapArabic: (value) {
                        _speak(value);
                        sendKalaamAction(ctx, 'explain_cell', {'value': value});
                      },
                    );
                  }),
                ],
              ),
            ),
            if (caption.isNotEmpty) ...[
              const Gap(12),
              Text(
                caption,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
              ),
            ],
            const Gap(14),
            KalaamContinueButton(ctx: ctx, label: 'Continue'),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.cells,
    this.isHeader = false,
    this.striped = false,
    this.highlight = false,
    this.onTapArabic,
  });

  final List<String> cells;
  final bool isHeader;
  final bool striped;
  final bool highlight;
  final void Function(String value)? onTapArabic;

  @override
  Widget build(BuildContext context) {
    final Color bg = isHeader
        ? KalaamColors.primaryDim.withValues(alpha: 0.18)
        : highlight
        ? KalaamColors.primary.withValues(alpha: 0.10)
        : striped
        ? KalaamColors.surfaceTrim.withValues(alpha: 0.4)
        : Colors.transparent;

    return Container(
      color: bg,
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      child: Row(
        children: cells.map((cell) {
          final isAr = _arabic.hasMatch(cell);
          final style = isHeader
              ? Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: KalaamColors.primary,
                  fontWeight: FontWeight.bold,
                )
              : TextStyle(
                  fontFamily: isAr ? 'Amiri' : 'IBMPlexSansArabic',
                  fontSize: isAr ? 20 : 14,
                  color: highlight
                      ? KalaamColors.primary
                      : KalaamColors.onSurface,
                  fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
                );
          // Plain wrapping text (no per-cell FittedBox): every cell keeps the
          // same font size, so the table reads as a consistent grid instead of
          // each cell scaling to a different size.
          final text = Text(
            cell,
            style: style,
            textAlign: TextAlign.center,
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          );

          return Expanded(
            // Overlay the speaker affordance instead of placing it inline, so a
            // tappable Arabic cell gets the SAME text width as a plain cell
            // (an inline icon stole ~17px and made these cells ellipsize early).
            child: (!isHeader && isAr && onTapArabic != null)
                ? GestureDetector(
                    onTap: () => onTapArabic!(cell),
                    behavior: HitTestBehavior.opaque,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        text,
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Icon(
                            Icons.volume_up_rounded,
                            size: 11,
                            color: KalaamColors.primary.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  )
                : text,
          );
        }).toList(),
      ),
    );
  }
}
