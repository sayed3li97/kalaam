import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:kalaam/theme.dart';
import 'package:kalaam/features/session/catalog/kalaam_actions.dart';
import 'package:kalaam/shared/services/tts_service.dart';

final vocabCardItem = CatalogItem(
  name: 'VocabCard',
  dataSchema: S.object(
    properties: {
      'word': A2uiSchemas.stringReference(
        description: 'Target language word with full harakat',
      ),
      'transliteration': A2uiSchemas.stringReference(
        description: 'Romanised pronunciation',
      ),
      'ipa': A2uiSchemas.stringReference(
        description: 'IPA notation, always include',
      ),
      'translation': A2uiSchemas.stringReference(
        description: 'English translation',
      ),
      'exampleSentence': A2uiSchemas.stringReference(
        description: 'Example in target language',
      ),
      'exampleTranslation': A2uiSchemas.stringReference(
        description: 'English translation of example',
      ),
      'partOfSpeech': S.string(
        description: 'Part of speech, e.g. noun, verb, phrase, particle',
      ),
      'isFlipped': S.boolean(description: 'DataModel-bound, false initially'),
    },
    required: [
      'word',
      'transliteration',
      'ipa',
      'translation',
      'exampleSentence',
      'exampleTranslation',
      'partOfSpeech',
    ],
  ),
  exampleData: [
    () => '''
[
  {
    "id": "root",
    "component": "VocabCard",
    "word": "قَهْوَة",
    "transliteration": "qahwa",
    "ipa": "/ˈqah.wa/",
    "translation": "coffee",
    "exampleSentence": "أُرِيدُ قَهْوَةً مِنْ فَضْلِكَ",
    "exampleTranslation": "I would like a coffee please.",
    "partOfSpeech": "noun",
    "isFlipped": false
  }
]
''',
  ],
  widgetBuilder: (ctx) {
    final data = ctx.data as Map<String, Object?>;
    final word = data['word'] as String? ?? '';
    final translit = data['transliteration'] as String? ?? '';
    final ipa = data['ipa'] as String? ?? '';
    final translation = data['translation'] as String? ?? '';
    final sentence = data['exampleSentence'] as String? ?? '';
    final sentenceTranslation = data['exampleTranslation'] as String? ?? '';
    final partOfSpeech = data['partOfSpeech'] as String? ?? '';

    return _VocabCardFlipWidget(
      word: word,
      transliteration: translit,
      ipa: ipa,
      translation: translation,
      exampleSentence: sentence,
      exampleTranslation: sentenceTranslation,
      partOfSpeech: partOfSpeech,
      ctx: ctx,
    );
  },
);

class _VocabCardFlipWidget extends StatefulWidget {
  const _VocabCardFlipWidget({
    required this.word,
    required this.transliteration,
    required this.ipa,
    required this.translation,
    required this.exampleSentence,
    required this.exampleTranslation,
    required this.partOfSpeech,
    required this.ctx,
  });

  final String word;
  final String transliteration;
  final String ipa;
  final String translation;
  final String exampleSentence;
  final String exampleTranslation;
  final String partOfSpeech;
  final CatalogItemContext ctx;

  @override
  State<_VocabCardFlipWidget> createState() => _VocabCardFlipWidgetState();
}

class _VocabCardFlipWidgetState extends State<_VocabCardFlipWidget> {
  bool _isFlipped = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => setState(() => _isFlipped = !_isFlipped),
          child: AnimatedSwitcher(
            duration: 400.ms,
            transitionBuilder: (child, animation) {
              final rotate = Tween<double>(
                begin: 3.14,
                end: 0.0,
              ).animate(animation);
              return AnimatedBuilder(
                animation: rotate,
                builder: (context, widget) {
                  final angle = rotate.value;
                  final isBack = child.key == const ValueKey('back');
                  var tilt = 0.002;
                  if (angle > 1.57) {
                    tilt = -tilt;
                  }
                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, tilt)
                      ..rotateY(angle),
                    alignment: Alignment.center,
                    child: Transform(
                      transform: Matrix4.identity()..rotateY(isBack ? 3.14 : 0),
                      alignment: Alignment.center,
                      child: child,
                    ),
                  );
                },
              );
            },
            layoutBuilder: (currentChild, previousChildren) => Stack(
              children: [
                if (currentChild != null) currentChild,
                ...previousChildren,
              ],
            ),
            child: _isFlipped
                ? Card(
                    key: const ValueKey('back'),
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      padding: const EdgeInsetsDirectional.all(20),
                      decoration: BoxDecoration(
                        color: KalaamColors.surfaceVar,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: KalaamColors.primary.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.ipa,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const Gap(8),
                          Text(
                            widget.translation,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: KalaamColors.primary,
                                  fontSize: 22,
                                ),
                          ),
                          const Gap(16),
                          Text(
                            widget.exampleSentence,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontFamily: 'Amiri', fontSize: 18),
                          ),
                          const Gap(4),
                          Text(
                            widget.exampleTranslation,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  )
                : Card(
                    key: const ValueKey('front'),
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      padding: const EdgeInsetsDirectional.all(20),
                      decoration: BoxDecoration(
                        color: KalaamColors.surfaceVar,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: KalaamColors.primary.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: Chip(
                              label: Text(widget.partOfSpeech),
                              backgroundColor: KalaamColors.surfaceTrim,
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.word,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge
                                      ?.copyWith(
                                        color: KalaamColors.primary,
                                        fontSize: 48,
                                      ),
                                ),
                                const Gap(8),
                                Text(
                                  widget.transliteration,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: KalaamColors.onSurfaceDim,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: IconButton(
                              icon: const Icon(
                                Icons.volume_up,
                                color: KalaamColors.primary,
                              ),
                              onPressed: () => KalaamTts.speak(widget.word),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
        const Gap(12),
        KalaamContinueButton(ctx: widget.ctx, label: 'Next'),
      ],
    );
  }
}
