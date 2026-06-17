import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:kalaam/theme.dart';
import 'package:kalaam/features/session/catalog/kalaam_actions.dart';

final fillInBlankItem = CatalogItem(
  name: 'FillInTheBlank',
  dataSchema: S.object(
    properties: {
      'sentenceParts': S.list(
        description:
            'Sentence parts split around blank, blank is represented as __',
        items: S.string(),
      ),
      'blankIndex': S.integer(description: 'Index of __ in sentenceParts'),
      'correctAnswer': A2uiSchemas.stringReference(
        description: 'The correct word to fill in the blank',
      ),
      'userInput': A2uiSchemas.stringReference(
        description: 'DataModel-bound user-entered string',
      ),
      'validationState': S.string(
        description:
            'DataModel-bound validation state: idle, correct, or incorrect',
      ),
      'hint': A2uiSchemas.stringReference(
        description: 'Hint shown on first incorrect attempt',
      ),
    },
    required: ['sentenceParts', 'blankIndex', 'correctAnswer', 'hint'],
  ),
  exampleData: [
    () => '''
[
  {
    "id": "root",
    "component": "FillInTheBlank",
    "sentenceParts": ["أُرِيدُ", "__", "مِنْ فَضْلِكَ"],
    "blankIndex": 1,
    "correctAnswer": "قَهْوَةً",
    "userInput": "",
    "validationState": "idle",
    "hint": "Coffee with tanwin — قَهْوَةً"
  }
]
''',
  ],
  widgetBuilder: (ctx) {
    final data = ctx.data as Map<String, Object?>;
    final sentenceParts = List<String>.from(
      data['sentenceParts'] as List? ?? [],
    );
    final blankIndex = data['blankIndex'] as int? ?? 1;
    final correctAnswer = data['correctAnswer'] as String? ?? '';
    final hint = data['hint'] as String? ?? '';

    return BoundString(
      dataContext: ctx.dataContext,
      value: data['userInput'],
      builder: (context, userInputValue) {
        final userInput = userInputValue ?? '';

        return BoundString(
          dataContext: ctx.dataContext,
          value: data['validationState'],
          builder: (context, validationValue) {
            final validationState = validationValue ?? 'idle';

            return _FillInBlankWidget(
              sentenceParts: sentenceParts,
              blankIndex: blankIndex,
              correctAnswer: correctAnswer,
              hint: hint,
              userInput: userInput,
              validationState: validationState,
              context: ctx,
              rawData: data,
            );
          },
        );
      },
    );
  },
);

class _FillInBlankWidget extends StatefulWidget {
  final List<String> sentenceParts;
  final int blankIndex;
  final String correctAnswer;
  final String hint;
  final String userInput;
  final String validationState;
  final CatalogItemContext context;
  final Map<String, Object?> rawData;

  const _FillInBlankWidget({
    required this.sentenceParts,
    required this.blankIndex,
    required this.correctAnswer,
    required this.hint,
    required this.userInput,
    required this.validationState,
    required this.context,
    required this.rawData,
  });

  @override
  State<_FillInBlankWidget> createState() => _FillInBlankWidgetState();
}

class _FillInBlankWidgetState extends State<_FillInBlankWidget> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.userInput);
  }

  @override
  void didUpdateWidget(_FillInBlankWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userInput != oldWidget.userInput &&
        _textController.text != widget.userInput) {
      _textController.text = widget.userInput;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCorrect = widget.validationState == 'correct';
    final isIncorrect = widget.validationState == 'incorrect';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Fill in the blank:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: KalaamColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(16),

            // Sentence with inline text field
            Directionality(
              textDirection: TextDirection.rtl,
              child: Wrap(
                spacing: 8,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.center,
                children: List.generate(widget.sentenceParts.length, (index) {
                  if (index == widget.blankIndex) {
                    return SizedBox(
                      width: 120,
                      height: 40,
                      child: TextField(
                        controller: _textController,
                        enabled: !isCorrect,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 18,
                          color: KalaamColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          filled: true,
                          fillColor: KalaamColors.surfaceTrim,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isCorrect
                                  ? KalaamColors.success
                                  : isIncorrect
                                  ? KalaamColors.error
                                  : KalaamColors.primary,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isCorrect
                                  ? KalaamColors.success
                                  : isIncorrect
                                  ? KalaamColors.error
                                  : KalaamColors.primary.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        onChanged: (val) {
                          final pathMap = widget.rawData['userInput'];
                          if (pathMap is Map && pathMap.containsKey('path')) {
                            widget.context.dataContext.update(
                              DataPath(pathMap['path'] as String),
                              val,
                            );
                          }
                        },
                      ),
                    );
                  }

                  return Text(
                    widget.sentenceParts[index],
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }),
              ),
            ),

            const Gap(20),

            // Hint panel
            if (isIncorrect)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  '💡 Hint: ${widget.hint}',
                  style: const TextStyle(
                    color: KalaamColors.primary,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ).animate().fadeIn(duration: 250.ms),
              ),

            // Check button
            if (!isCorrect) ...[
              ListenableBuilder(
                listenable: _textController,
                builder: (context, _) => ElevatedButton(
                  onPressed: _textController.text.trim().isEmpty
                      ? null
                      : _validate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KalaamColors.primary,
                    foregroundColor: KalaamColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Check Answer'),
                ),
              ),
              const Gap(8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      _textController.text = widget.correctAnswer;
                      final pathMap = widget.rawData['userInput'];
                      if (pathMap is Map && pathMap.containsKey('path')) {
                        widget.context.dataContext.update(
                          DataPath(pathMap['path'] as String),
                          widget.correctAnswer,
                        );
                      }
                      _validate();
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
                        'validationState': 'skipped',
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
                    'Well Done! 🎉',
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
                payload: const {'validationState': 'correct'},
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }

  // Remove diacritics for comparison
  String _stripHarakat(String str) {
    final RegExp arabicHarakat = RegExp(r'[\u064B-\u0652\u0670\u0653-\u065F]');
    return str.replaceAll(arabicHarakat, '').trim();
  }

  void _validate() {
    final inputClean = _stripHarakat(_textController.text);
    final correctClean = _stripHarakat(widget.correctAnswer);
    final isMatch = inputClean == correctClean;

    final valPathMap = widget.rawData['validationState'];
    if (valPathMap is Map && valPathMap.containsKey('path')) {
      widget.context.dataContext.update(
        DataPath(valPathMap['path'] as String),
        isMatch ? 'correct' : 'incorrect',
      );
    }

    // Only advance the lesson once the blank is right; a wrong try stays local
    // so the learner can use the hint and retry.
  }
}
