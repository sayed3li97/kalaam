import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:kalaam/theme.dart';
import 'package:kalaam/features/session/catalog/kalaam_actions.dart';

final dialogueBubbleItem = CatalogItem(
  name: 'DialogueBubble',
  dataSchema: S.object(
    properties: {
      'characterName': A2uiSchemas.stringReference(
        description: 'Name of speaking character',
      ),
      'characterLine': A2uiSchemas.stringReference(
        description: 'Character line in target language',
      ),
      'characterLineTranslation': A2uiSchemas.stringReference(
        description: 'Character line English translation',
      ),
      'userOptions': S.list(
        description: 'Response options for user',
        minItems: 2,
        maxItems: 3,
        items: S.object(
          properties: {
            'id': S.string(description: 'Option ID (e.g. A, B, C)'),
            'text': S.string(description: 'Option text in target language'),
            'register': S.string(
              description: 'Speech register: polite, neutral, or rude',
            ),
          },
          required: ['id', 'text', 'register'],
        ),
      ),
      'selectedOptionId': A2uiSchemas.stringReference(
        description: 'DataModel-bound chosen option ID',
      ),
      'showTranslation': S.boolean(
        description: 'DataModel-bound visibility toggle for translation',
      ),
    },
    required: [
      'characterName',
      'characterLine',
      'characterLineTranslation',
      'userOptions',
    ],
  ),
  exampleData: [
    () => '''
[
  {
    "id": "root",
    "component": "DialogueBubble",
    "characterName": "Barista",
    "characterLine": "أَهْلًا! مَاذَا تُرِيدُ؟",
    "characterLineTranslation": "Welcome! What would you like?",
    "userOptions": [
      {"id": "A", "text": "أُرِيدُ قَهْوَةً مِنْ فَضْلِكَ", "register": "polite"},
      {"id": "B", "text": "قَهْوَة", "register": "rude"},
      {"id": "C", "text": "لَحْظَة مِنْ فَضْلِكَ", "register": "neutral"}
    ],
    "selectedOptionId": "",
    "showTranslation": false
  }
]
''',
  ],
  widgetBuilder: (ctx) {
    final data = ctx.data as Map<String, Object?>;
    final name = data['characterName'] as String? ?? '';
    final line = data['characterLine'] as String? ?? '';
    final translation = data['characterLineTranslation'] as String? ?? '';
    final optionsList = data['userOptions'] as List<dynamic>? ?? [];
    final selectedIdVal = data['selectedOptionId'];
    final showTranslationVal = data['showTranslation'];

    Widget buildWithTranslation(String selectedId) {
      if (showTranslationVal is Map && showTranslationVal.containsKey('path')) {
        return BoundBool(
          dataContext: ctx.dataContext,
          value: showTranslationVal,
          builder: (context, showTranslationValue) {
            return _DialogueBubbleWidget(
              characterName: name,
              characterLine: line,
              characterLineTranslation: translation,
              options: optionsList,
              selectedOptionId: selectedId,
              showTranslation: showTranslationValue ?? false,
              context: ctx,
              rawData: data,
            );
          },
        );
      } else {
        final initialShow = showTranslationVal is bool
            ? showTranslationVal
            : false;
        return _DialogueBubbleWidget(
          characterName: name,
          characterLine: line,
          characterLineTranslation: translation,
          options: optionsList,
          selectedOptionId: selectedId,
          showTranslation: initialShow,
          context: ctx,
          rawData: data,
        );
      }
    }

    if (selectedIdVal is Map && selectedIdVal.containsKey('path')) {
      return BoundString(
        dataContext: ctx.dataContext,
        value: selectedIdVal,
        builder: (context, selectedIdValue) {
          return buildWithTranslation(selectedIdValue ?? '');
        },
      );
    } else {
      final initialVal = selectedIdVal is String ? selectedIdVal : '';
      return buildWithTranslation(initialVal);
    }
  },
);

class _DialogueBubbleWidget extends StatefulWidget {
  final String characterName;
  final String characterLine;
  final String characterLineTranslation;
  final List<dynamic> options;
  final String selectedOptionId;
  final bool showTranslation;
  final CatalogItemContext context;
  final Map<String, Object?> rawData;

  const _DialogueBubbleWidget({
    required this.characterName,
    required this.characterLine,
    required this.characterLineTranslation,
    required this.options,
    required this.selectedOptionId,
    required this.showTranslation,
    required this.context,
    required this.rawData,
  });

  @override
  State<_DialogueBubbleWidget> createState() => _DialogueBubbleWidgetState();
}

class _DialogueBubbleWidgetState extends State<_DialogueBubbleWidget> {
  String _localSelectedOptionId = '';
  bool _localShowTranslation = false;

  @override
  void initState() {
    super.initState();
    _localSelectedOptionId = widget.selectedOptionId;
    _localShowTranslation = widget.showTranslation;
  }

  @override
  void didUpdateWidget(_DialogueBubbleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedOptionId != oldWidget.selectedOptionId) {
      _localSelectedOptionId = widget.selectedOptionId;
    }
    if (widget.showTranslation != oldWidget.showTranslation) {
      _localShowTranslation = widget.showTranslation;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedOptionId = widget.selectedOptionId.isNotEmpty
        ? widget.selectedOptionId
        : _localSelectedOptionId;
    final showTranslation = widget.showTranslation || _localShowTranslation;
    final hasSelection = selectedOptionId.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Character speech bubble
        GestureDetector(
          onTap: () {
            final showTranslationPathMap = widget.rawData['showTranslation'];
            if (showTranslationPathMap is Map &&
                showTranslationPathMap.containsKey('path')) {
              widget.context.dataContext.update(
                DataPath(showTranslationPathMap['path'] as String),
                true,
              );
            } else {
              setState(() {
                _localShowTranslation = true;
              });
            }
          },
          child: Card(
            color: KalaamColors.surfaceVar,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.characterName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: KalaamColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(6),
                  Text(
                    widget.characterLine,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 22,
                      height: 1.4,
                    ),
                  ),
                  if (showTranslation) ...[
                    const Gap(8),
                    Text(
                      widget.characterLineTranslation,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: KalaamColors.onSurfaceDim,
                      ),
                    ).animate().fadeIn(duration: 250.ms),
                  ] else ...[
                    const Gap(8),
                    Text(
                      'Tap bubble to translate',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 9,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        const Gap(12),

        // User options cards
        Column(
          children: widget.options.map((opt) {
            final optMap = opt as Map<String, Object?>;
            final optId = optMap['id'] as String? ?? '';
            final text = optMap['text'] as String? ?? '';
            final register = optMap['register'] as String? ?? 'neutral';

            final isSelected = selectedOptionId == optId;
            final isWrongSelected = hasSelection && !isSelected;

            final registerIcon = switch (register) {
              'polite' => Icons.sentiment_very_satisfied_rounded,
              'rude' => Icons.sentiment_very_dissatisfied_rounded,
              _ => Icons.sentiment_neutral_rounded,
            };

            final registerColor = switch (register) {
              'polite' => KalaamColors.success,
              'rude' => KalaamColors.error,
              _ => KalaamColors.primary,
            };

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Opacity(
                opacity: isWrongSelected ? 0.5 : 1.0,
                child: InkWell(
                  onTap: hasSelection
                      ? null
                      : () {
                          final pathMap = widget.rawData['selectedOptionId'];
                          if (pathMap is Map && pathMap.containsKey('path')) {
                            widget.context.dataContext.update(
                              DataPath(pathMap['path'] as String),
                              optId,
                            );
                          } else {
                            setState(() {
                              _localSelectedOptionId = optId;
                            });
                          }
                        },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? registerColor.withValues(alpha: 0.15)
                          : KalaamColors.surfaceTrim,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? registerColor
                            : KalaamColors.primary.withValues(alpha: 0.1),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? registerColor
                                : KalaamColors.surfaceTrim,
                            border: Border.all(
                              color: KalaamColors.primary.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              optId,
                              style: TextStyle(
                                color: isSelected
                                    ? KalaamColors.onPrimary
                                    : KalaamColors.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const Gap(16),
                        Expanded(
                          child: Text(
                            text,
                            style: const TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const Gap(8),
                        Icon(registerIcon, color: registerColor, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ).animate().fadeIn(delay: 200.ms, duration: 300.ms),

        if (hasSelection) ...[
          const Gap(16),
          KalaamContinueButton(
            ctx: widget.context,
            label: 'Continue',
            action: 'replied',
            payload: {
              'selectedOptionId': selectedOptionId,
              'register':
                  (widget.options.firstWhere(
                        (o) => (o as Map)['id'] == selectedOptionId,
                        orElse: () => {'register': 'neutral'},
                      )
                      as Map)['register'],
            },
          ),
        ],
      ],
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }
}
