import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:kalaam/theme.dart';
import 'package:kalaam/features/session/catalog/kalaam_actions.dart';

final quickChoiceItem = CatalogItem(
  name: 'QuickChoice',
  dataSchema: S.object(
    properties: {
      'question': A2uiSchemas.stringReference(
        description: 'The multiple choice question',
      ),
      'options': S.list(
        description: 'Array of 4 options',
        minItems: 4,
        maxItems: 4,
        items: S.object(
          properties: {
            'id': S.string(description: 'Option identifier (A, B, C, or D)'),
            'text': S.string(description: 'Option content text'),
          },
          required: ['id', 'text'],
        ),
      ),
      'correctId': S.string(description: 'The correct option ID'),
      'selectedId': A2uiSchemas.stringReference(
        description: 'DataModel-bound chosen option ID',
      ),
      'explanationOnWrong': A2uiSchemas.stringReference(
        description: 'Explanation shown if user chooses wrong answer',
      ),
    },
    required: ['question', 'options', 'correctId', 'explanationOnWrong'],
  ),
  exampleData: [
    () => '''
[
  {
    "id": "root",
    "component": "QuickChoice",
    "question": "What does قَهْوَة mean?",
    "options": [
      {"id": "A", "text": "Tea"},
      {"id": "B", "text": "Coffee"},
      {"id": "C", "text": "Water"},
      {"id": "D", "text": "Juice"}
    ],
    "correctId": "B",
    "selectedId": "",
    "explanationOnWrong": "قَهْوَة (qahwa) is coffee — central to Arab hospitality."
  }
]
''',
  ],
  widgetBuilder: (ctx) {
    final data = ctx.data as Map<String, Object?>;
    final question = data['question'] as String? ?? '';
    final optionsList = data['options'] as List<dynamic>? ?? [];
    final correctId = data['correctId'] as String? ?? '';
    final explanation = data['explanationOnWrong'] as String? ?? '';

    final selectedIdVal = data['selectedId'];
    if (selectedIdVal is Map && selectedIdVal.containsKey('path')) {
      return BoundString(
        dataContext: ctx.dataContext,
        value: selectedIdVal,
        builder: (context, selectedIdValue) {
          return _QuickChoiceWidget(
            question: question,
            options: optionsList,
            correctId: correctId,
            selectedId: selectedIdValue ?? '',
            explanationOnWrong: explanation,
            context: ctx,
            rawData: data,
          );
        },
      );
    } else {
      final initialVal = selectedIdVal is String ? selectedIdVal : '';
      return _QuickChoiceWidget(
        question: question,
        options: optionsList,
        correctId: correctId,
        selectedId: initialVal,
        explanationOnWrong: explanation,
        context: ctx,
        rawData: data,
      );
    }
  },
);

class _QuickChoiceWidget extends StatefulWidget {
  final String question;
  final List<dynamic> options;
  final String correctId;
  final String selectedId;
  final String explanationOnWrong;
  final CatalogItemContext context;
  final Map<String, Object?> rawData;

  const _QuickChoiceWidget({
    required this.question,
    required this.options,
    required this.correctId,
    required this.selectedId,
    required this.explanationOnWrong,
    required this.context,
    required this.rawData,
  });

  @override
  State<_QuickChoiceWidget> createState() => _QuickChoiceWidgetState();
}

class _QuickChoiceWidgetState extends State<_QuickChoiceWidget> {
  String _localSelectedId = '';
  // Whether the learner revealed the answer rather than choosing it. Reported
  // to the model in the single Continue dispatch so it can reinforce gently.
  bool _showedAnswer = false;
  // One-shot guard for the Skip path, which dispatches directly (it has no
  // self-locking Continue button). Prevents a double-tap from advancing twice.
  bool _skipped = false;

  @override
  void initState() {
    super.initState();
    _localSelectedId = widget.selectedId;
  }

  @override
  void didUpdateWidget(_QuickChoiceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedId != oldWidget.selectedId) {
      _localSelectedId = widget.selectedId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedId = widget.selectedId.isNotEmpty
        ? widget.selectedId
        : _localSelectedId;
    final hasSelection = selectedId.isNotEmpty;
    final isWrong = hasSelection && selectedId != widget.correctId;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.question,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Gap(16),

            // 2x2 grid of options
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: widget.options.map((opt) {
                final optMap = opt as Map<String, Object?>;
                final optId = optMap['id'] as String? ?? '';
                final text = optMap['text'] as String? ?? '';
                final isSelected = selectedId == optId;

                Color cardColor = KalaamColors.surfaceTrim;
                Color borderColor = KalaamColors.primary.withValues(alpha: 0.1);
                Color textColor = KalaamColors.onSurface;

                if (hasSelection) {
                  if (optId == widget.correctId) {
                    cardColor = KalaamColors.success.withValues(alpha: 0.15);
                    borderColor = KalaamColors.success;
                    textColor = KalaamColors.success;
                  } else if (isSelected) {
                    cardColor = KalaamColors.error.withValues(alpha: 0.15);
                    borderColor = KalaamColors.error;
                    textColor = KalaamColors.error;
                  }
                }

                return InkWell(
                  onTap: hasSelection
                      ? null
                      : () {
                          final pathMap = widget.rawData['selectedId'];
                          if (pathMap is Map && pathMap.containsKey('path')) {
                            widget.context.dataContext.update(
                              DataPath(pathMap['path'] as String),
                              optId,
                            );
                          } else {
                            setState(() {
                              _localSelectedId = optId;
                            });
                          }
                        },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: borderColor,
                        width:
                            isSelected ||
                                (hasSelection && optId == widget.correctId)
                            ? 2
                            : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            if (!hasSelection) ...[
              const Gap(12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    // Reveal only — do NOT dispatch here. Revealing makes the
                    // single Continue button appear, which is the sole place the
                    // 'answered' action is sent (avoids a double dispatch that
                    // would advance the lesson twice).
                    onPressed: () {
                      _showedAnswer = true;
                      final pathMap = widget.rawData['selectedId'];
                      if (pathMap is Map && pathMap.containsKey('path')) {
                        widget.context.dataContext.update(
                          DataPath(pathMap['path'] as String),
                          widget.correctId,
                        );
                      } else {
                        setState(() {
                          _localSelectedId = widget.correctId;
                        });
                      }
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
                    // One-shot: disabled after the first tap so a double-tap
                    // can't dispatch 'answered' twice and advance the lesson
                    // twice.
                    onPressed: _skipped
                        ? null
                        : () {
                            setState(() => _skipped = true);
                            sendKalaamAction(widget.context, 'answered', {
                              'selectedId': '',
                              'correctId': widget.correctId,
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
            ],

            // Explanation shown on wrong selection
            if (isWrong) ...[
              const Gap(16),
              AnimatedOpacity(
                opacity: isWrong ? 1.0 : 0.0,
                duration: 300.ms,
                child: Text(
                  '💡 ${widget.explanationOnWrong}',
                  style: TextStyle(
                    color: KalaamColors.error.withValues(alpha: 0.8),
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],

            if (hasSelection) ...[
              const Gap(16),
              KalaamContinueButton(
                ctx: widget.context,
                label: 'Continue',
                action: 'answered',
                payload: {
                  'selectedId': selectedId,
                  'correctId': widget.correctId,
                  // If the learner revealed the answer, they didn't truly know
                  // it — report isCorrect:false so the model can reinforce.
                  'isCorrect': !_showedAnswer && selectedId == widget.correctId,
                  'showedAnswer': _showedAnswer,
                },
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }
}
