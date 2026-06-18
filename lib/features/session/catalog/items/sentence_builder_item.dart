import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:kalaam/theme.dart';
import 'package:kalaam/features/session/catalog/kalaam_actions.dart';

final sentenceBuilderItem = CatalogItem(
  name: 'SentenceBuilder',
  dataSchema: S.object(
    properties: {
      'instruction': A2uiSchemas.stringReference(
        description: 'What to build in English',
      ),
      'targetSentence': A2uiSchemas.stringReference(
        description: 'Correct target sentence in Arabic',
      ),
      'wordTiles': S.list(
        description:
            'Word tiles list, containing correct words and distractors',
        minItems: 4,
        maxItems: 10,
        items: S.string(),
      ),
      'hint': A2uiSchemas.stringReference(
        description: 'Hint to reveal after 2 wrong attempts',
      ),
      'isCorrect': S.boolean(description: 'DataModel-bound correctness flag'),
      'attemptCount': S.integer(description: 'DataModel-bound attempt counter'),
    },
    required: ['instruction', 'targetSentence', 'wordTiles', 'hint'],
  ),
  exampleData: [
    () => '''
[
  {
    "id": "root",
    "component": "SentenceBuilder",
    "instruction": "Build: I would like a coffee please.",
    "targetSentence": "أُرِيدُ قَهْوَةً مِنْ فَضْلِكَ",
    "wordTiles": ["أُرِيدُ", "قَهْوَةً", "مِنْ", "فَضْلِكَ", "شُكْرًا", "صَبَاحَ"],
    "hint": "Start with I want — أُرِيدُ",
    "isCorrect": false,
    "attemptCount": 0
  }
]
''',
  ],
  widgetBuilder: (ctx) {
    final data = ctx.data as Map<String, Object?>;
    final instruction = data['instruction'] as String? ?? '';
    final targetSentence = data['targetSentence'] as String? ?? '';
    final tiles = List<String>.from(data['wordTiles'] as List? ?? []);
    final hint = data['hint'] as String? ?? '';

    return BoundBool(
      dataContext: ctx.dataContext,
      value: data['isCorrect'],
      builder: (context, isCorrectValue) {
        final isCorrect = isCorrectValue ?? false;

        return BoundNumber(
          dataContext: ctx.dataContext,
          value: data['attemptCount'],
          builder: (context, attemptCountValue) {
            final attemptCount = (attemptCountValue ?? 0).toInt();

            return _SentenceBuilderWidget(
              instruction: instruction,
              targetSentence: targetSentence,
              tiles: tiles,
              hint: hint,
              isCorrect: isCorrect,
              attemptCount: attemptCount,
              context: ctx,
              rawData: data,
            );
          },
        );
      },
    );
  },
);

class _SentenceBuilderWidget extends StatefulWidget {
  final String instruction;
  final String targetSentence;
  final List<String> tiles;
  final String hint;
  final bool isCorrect;
  final int attemptCount;
  final CatalogItemContext context;
  final Map<String, Object?> rawData;

  const _SentenceBuilderWidget({
    required this.instruction,
    required this.targetSentence,
    required this.tiles,
    required this.hint,
    required this.isCorrect,
    required this.attemptCount,
    required this.context,
    required this.rawData,
  });

  @override
  State<_SentenceBuilderWidget> createState() => _SentenceBuilderWidgetState();
}

class _SentenceBuilderWidgetState extends State<_SentenceBuilderWidget> {
  final List<String> _selectedTiles = [];
  late List<String> _trayTiles;
  bool _shake = false;

  @override
  void initState() {
    super.initState();
    _trayTiles = List.from(widget.tiles);
  }

  @override
  Widget build(BuildContext context) {
    final showHint = widget.attemptCount >= 2 && !widget.isCorrect;

    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: KalaamColors.surfaceVar,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isCorrect
                ? KalaamColors.success
                : widget.attemptCount > 0
                ? KalaamColors.error.withValues(alpha: 0.5)
                : KalaamColors.primary.withValues(alpha: 0.15),
            width: widget.isCorrect ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.instruction,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Gap(16),

            // Answer Zone
            Container(
                  constraints: const BoxConstraints(minHeight: 60),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: KalaamColors.surfaceTrim,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _selectedTiles.isEmpty
                      ? Center(
                          child: Text(
                            'Tap tiles to build answer',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        )
                      : Wrap(
                          textDirection: TextDirection.rtl,
                          spacing: 8,
                          runSpacing: 8,
                          children: _selectedTiles.map((tile) {
                            return ActionChip(
                              label: Text(
                                tile,
                                style: const TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onPressed: widget.isCorrect
                                  ? null
                                  : () {
                                      setState(() {
                                        _selectedTiles.remove(tile);
                                        _trayTiles.add(tile);
                                      });
                                    },
                              backgroundColor: KalaamColors.primaryDim
                                  .withValues(alpha: 0.3),
                              side: const BorderSide(
                                color: KalaamColors.primary,
                              ),
                            );
                          }).toList(),
                        ),
                )
                .animate(target: _shake ? 1.0 : 0.0)
                .shake(duration: 400.ms)
                .callback(callback: (_) => setState(() => _shake = false)),

            const Gap(16),

            // Tray Zone
            if (!widget.isCorrect) ...[
              Wrap(
                textDirection: TextDirection.rtl,
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: _trayTiles.map((tile) {
                  return ActionChip(
                    label: Text(
                      tile,
                      style: const TextStyle(fontFamily: 'Amiri', fontSize: 16),
                    ),
                    onPressed: () {
                      setState(() {
                        _trayTiles.remove(tile);
                        _selectedTiles.add(tile);
                      });
                    },
                    backgroundColor: KalaamColors.surfaceTrim,
                  );
                }).toList(),
              ),
              const Gap(16),
            ],

            // Hint Opacity
            if (showHint)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: AnimatedOpacity(
                  opacity: showHint ? 1.0 : 0.0,
                  duration: 300.ms,
                  child: Text(
                    '💡 Hint: ${widget.hint}',
                    style: const TextStyle(
                      color: KalaamColors.primary,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),

            // Control Button
            if (!widget.isCorrect) ...[
              ElevatedButton(
                onPressed: _selectedTiles.isEmpty ? null : _checkAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: KalaamColors.primary,
                  foregroundColor: KalaamColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Check Answer'),
              ),
              const Gap(8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedTiles.clear();
                        _selectedTiles.addAll(widget.targetSentence.split(' '));
                        _trayTiles.clear();
                      });
                      _checkAnswer();
                    },
                    icon: const Icon(
                      Icons.visibility_rounded,
                      size: 16,
                      color: KalaamColors.primary,
                    ),
                    label: const Text(
                      'Show Answer',
                      style: TextStyle(color: KalaamColors.primary),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      sendKalaamAction(widget.context, 'completed', {
                        'isCorrect': false,
                        'skipped': true,
                      });
                    },
                    icon: const Icon(
                      Icons.skip_next_rounded,
                      size: 16,
                      color: KalaamColors.onSurfaceDim,
                    ),
                    label: const Text(
                      'Skip',
                      style: TextStyle(color: KalaamColors.onSurfaceDim),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: KalaamColors.success,
                    size: 24,
                  ).animate().scale(duration: 300.ms, curve: Curves.elasticOut),
                  const Gap(8),
                  Text(
                    'Correct! 🎉',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: KalaamColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Gap(16),
              KalaamContinueButton(
                ctx: widget.context,
                label: 'Continue',
                action: 'completed',
                payload: {
                  'isCorrect': true,
                  'attemptCount': widget.attemptCount,
                },
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }

  void _checkAnswer() {
    final assembled = _selectedTiles.join(' ').trim();
    final isCorrect =
        _stripHarakat(assembled) == _stripHarakat(widget.targetSentence.trim());

    final attemptPathMap = widget.rawData['attemptCount'];
    final isCorrectPathMap = widget.rawData['isCorrect'];

    if (attemptPathMap is Map && attemptPathMap.containsKey('path')) {
      widget.context.dataContext.update(
        DataPath(attemptPathMap['path'] as String),
        widget.attemptCount + 1,
      );
    }

    if (isCorrect) {
      if (isCorrectPathMap is Map && isCorrectPathMap.containsKey('path')) {
        widget.context.dataContext.update(
          DataPath(isCorrectPathMap['path'] as String),
          true,
        );
      }
    } else {
      setState(() {
        _shake = true;
      });
    }
  }

  /// Remove diacritics for comparison — same approach as FillInTheBlank.
  String _stripHarakat(String str) {
    final RegExp arabicHarakat = RegExp(r'[\u064B-\u0652\u0670\u0653-\u065F]');
    return str.replaceAll(arabicHarakat, '').trim();
  }
}
