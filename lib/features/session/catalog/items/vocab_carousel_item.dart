import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:kalaam/theme.dart';
import 'package:kalaam/features/session/catalog/kalaam_actions.dart';
import 'package:kalaam/shared/services/tts_service.dart';

final vocabCarouselItem = CatalogItem(
  name: 'VocabCarousel',
  dataSchema: S.object(
    properties: {
      'sectionTitle': A2uiSchemas.stringReference(
        description: 'e.g. Words for this scene',
      ),
      'items': S.list(
        description: 'Array of vocabulary items',
        minItems: 2,
        maxItems: 6,
        items: S.object(
          properties: {
            'word': S.string(description: 'Word in target language'),
            'transliteration': S.string(
              description: 'Pronunciation transliteration',
            ),
            'ipa': S.string(description: 'IPA pronunciation guide'),
            'translation': S.string(description: 'English translation'),
            'exampleSentence': S.string(
              description: 'Target language example sentence',
            ),
            'exampleTranslation': S.string(
              description: 'English example translation',
            ),
            'partOfSpeech': S.string(
              description: 'Part of speech, e.g. noun, verb, phrase, particle',
            ),
            'isFlipped': S.boolean(description: 'Dynamic flipping flag'),
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
      ),
    },
    required: ['sectionTitle', 'items'],
  ),
  exampleData: [
    () => '''
[
  {
    "id": "root",
    "component": "VocabCarousel",
    "sectionTitle": "Words for this scene",
    "items": [
      {
        "word": "قَهْوَة",
        "transliteration": "qahwa",
        "ipa": "/ˈqah.wa/",
        "translation": "coffee",
        "exampleSentence": "أُرِيدُ قَهْوَةً",
        "exampleTranslation": "I want coffee",
        "partOfSpeech": "noun",
        "isFlipped": false
      },
      {
        "word": "مِنْ فَضْلِكَ",
        "transliteration": "min fadlak",
        "ipa": "/mɪn ˈfaðlak/",
        "translation": "please",
        "exampleSentence": "قَهْوَةً مِنْ فَضْلِكَ",
        "exampleTranslation": "A coffee please",
        "partOfSpeech": "phrase",
        "isFlipped": false
      }
    ]
  }
]
''',
  ],
  widgetBuilder: (ctx) {
    final data = ctx.data as Map<String, Object?>;
    final title = data['sectionTitle'] as String? ?? 'Words for this scene';
    final itemsList = data['items'] as List<dynamic>? ?? [];

    return _VocabCarouselWidget(title: title, items: itemsList, context: ctx);
  },
);

class _VocabCarouselWidget extends StatefulWidget {
  final String title;
  final List<dynamic> items;
  final CatalogItemContext context;

  const _VocabCarouselWidget({
    required this.title,
    required this.items,
    required this.context,
  });

  @override
  State<_VocabCarouselWidget> createState() => _VocabCarouselWidgetState();
}

class _VocabCarouselWidgetState extends State<_VocabCarouselWidget> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  final Set<int> _flippedIndices = {};

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            widget.title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: KalaamColors.primary),
          ),
        ),
        const Gap(12),
        SizedBox(
          height: 220,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                onPressed: _currentIndex > 0
                    ? () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    final item = widget.items[index] as Map<String, Object?>;
                    final word = item['word'] as String? ?? '';
                    final translit = item['transliteration'] as String? ?? '';
                    final ipa = item['ipa'] as String? ?? '';
                    final translation = item['translation'] as String? ?? '';
                    final sentence = item['exampleSentence'] as String? ?? '';
                    final sentenceTranslation =
                        item['exampleTranslation'] as String? ?? '';
                    final partOfSpeech = item['partOfSpeech'] as String? ?? '';
                    final isFlipped = _flippedIndices.contains(index);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isFlipped) {
                            _flippedIndices.remove(index);
                          } else {
                            _flippedIndices.add(index);
                          }
                        });
                      },
                      child: AnimatedSwitcher(
                        duration: 300.ms,
                        child: isFlipped
                            ? Card(
                                key: ValueKey('back_$index'),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: KalaamColors.surfaceVar,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: KalaamColors.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        ipa,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelSmall,
                                      ),
                                      const Gap(6),
                                      Text(
                                        translation,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: KalaamColors.primary,
                                              fontSize: 20,
                                            ),
                                      ),
                                      const Gap(12),
                                      Text(
                                        sentence,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              fontFamily: 'Amiri',
                                              fontSize: 18,
                                            ),
                                      ),
                                      const Gap(2),
                                      Text(
                                        sentenceTranslation,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Card(
                                key: ValueKey('front_$index'),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: KalaamColors.surfaceVar,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: KalaamColors.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Chip(
                                          label: Text(partOfSpeech),
                                          backgroundColor:
                                              KalaamColors.surfaceTrim,
                                        ),
                                      ),
                                      Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              word,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displayLarge
                                                  ?.copyWith(
                                                    color: KalaamColors.primary,
                                                    fontSize: 36,
                                                  ),
                                            ),
                                            const Gap(6),
                                            Text(
                                              translit,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.copyWith(
                                                    color: KalaamColors
                                                        .onSurfaceDim,
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
                                            size: 20,
                                          ),
                                          onPressed: () =>
                                              KalaamTts.speak(word),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
                onPressed: _currentIndex < widget.items.length - 1
                    ? () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
              ),
            ],
          ),
        ),
        const Gap(10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.items.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: _currentIndex == index ? 24 : 8,
              decoration: BoxDecoration(
                color: _currentIndex == index
                    ? KalaamColors.primary
                    : KalaamColors.surfaceTrim,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const Gap(16),
        KalaamContinueButton(ctx: widget.context, label: 'Next'),
      ],
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }
}
