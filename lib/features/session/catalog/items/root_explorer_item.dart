import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import 'package:kalaam/theme.dart';
import 'package:kalaam/features/session/catalog/kalaam_actions.dart';

/// RootExplorer — the Arabic triliteral-root visualiser.
///
/// Derived words radiate from the shared root. Tapping a node expands it to
/// reveal its morphological pattern (وزن / wazn) with the root letters slotted
/// into ف-ع-ل, and an "Explore" affordance that asks the AI to dive deeper into
/// that specific word — turning a static diagram into a branch point.
final rootExplorerItem = CatalogItem(
  name: 'RootExplorer',
  dataSchema: S.object(
    properties: {
      'rootWord': S.string(
        description:
            'The triliteral root, letters joined by dashes, e.g. ك-ت-ب',
      ),
      'rootMeaning': S.string(
        description: 'Core meaning of the root in English',
      ),
      'family': S.list(
        description: 'Derived words that share this root',
        minItems: 3,
        maxItems: 7,
        items: S.object(
          properties: {
            'word': S.string(description: 'Derived word with full harakat'),
            'transliteration': S.string(description: 'Romanised pronunciation'),
            'meaning': S.string(description: 'English meaning'),
            'partOfSpeech': S.string(
              description: 'Part of speech, e.g. noun, verb, phrase, particle',
            ),
            'pattern': S.string(
              description:
                  'Morphological pattern (wazn), e.g. فَعَلَ, مَفْعَل, فَاعِل',
            ),
            'isExpanded': S.boolean(
              description: 'DataModel-bound, false initially',
            ),
          },
          required: ['word', 'transliteration', 'meaning'],
        ),
      ),
    },
    required: ['rootWord', 'rootMeaning', 'family'],
  ),
  exampleData: [
    () => '''
[
  {
    "id": "root",
    "component": "RootExplorer",
    "rootWord": "ك-ت-ب",
    "rootMeaning": "to write",
    "family": [
      {"word": "كَتَبَ", "transliteration": "kataba", "meaning": "he wrote", "partOfSpeech": "verb", "pattern": "فَعَلَ", "isExpanded": false},
      {"word": "كِتَاب", "transliteration": "kitāb", "meaning": "book", "partOfSpeech": "noun", "pattern": "فِعَال", "isExpanded": false},
      {"word": "كَاتِب", "transliteration": "kātib", "meaning": "writer", "partOfSpeech": "noun", "pattern": "فَاعِل", "isExpanded": false},
      {"word": "مَكْتَب", "transliteration": "maktab", "meaning": "office/desk", "partOfSpeech": "noun", "pattern": "مَفْعَل", "isExpanded": false},
      {"word": "مَكْتُوب", "transliteration": "maktūb", "meaning": "written/letter", "partOfSpeech": "adjective", "pattern": "مَفْعُول", "isExpanded": false}
    ]
  }
]
''',
  ],
  widgetBuilder: (ctx) {
    final data = ctx.data as Map<String, Object?>;
    final rootWord = data['rootWord'] as String? ?? '';
    final rootMeaning = data['rootMeaning'] as String? ?? '';
    final family = data['family'] as List<dynamic>? ?? [];

    return _RootExplorerWidget(
      rootWord: rootWord,
      rootMeaning: rootMeaning,
      family: family,
      ctx: ctx,
    );
  },
);

class _RootExplorerWidget extends StatelessWidget {
  const _RootExplorerWidget({
    required this.rootWord,
    required this.rootMeaning,
    required this.family,
    required this.ctx,
  });

  final String rootWord;
  final String rootMeaning;
  final List<dynamic> family;
  final CatalogItemContext ctx;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.hub_outlined,
                  color: KalaamColors.primary,
                  size: 16,
                ),
                const Gap(8),
                Text(
                  'Root System  ·  نظام الجذر',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: KalaamColors.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const Gap(8),
            LayoutBuilder(
              builder: (context, constraints) {
                final double size = math.min(constraints.maxWidth, 360);
                final double center = size / 2;
                final double radius = size * 0.34;

                return SizedBox(
                  width: size,
                  height: size,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      _GuideRing(radius: radius),
                      _RootCore(rootWord: rootWord, rootMeaning: rootMeaning),
                      ...List.generate(family.length, (i) {
                        final item = family[i] as Map<String, Object?>;
                        final angle =
                            (2 * math.pi / family.length) * i - math.pi / 2;
                        final x = center + radius * math.cos(angle);
                        final y = center + radius * math.sin(angle);
                        return _FamilyNode(
                          item: item,
                          rootWord: rootWord,
                          x: x,
                          y: y,
                          index: i,
                          ctx: ctx,
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
            const Gap(8),
            Text(
              'Tap a word to reveal its pattern (وزن)',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const Gap(14),
            KalaamContinueButton(ctx: ctx, label: 'Continue'),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0);
  }
}

class _GuideRing extends StatelessWidget {
  const _GuideRing({required this.radius});
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: KalaamColors.primary.withValues(alpha: 0.12),
          width: 1.5,
        ),
      ),
    );
  }
}

class _RootCore extends StatelessWidget {
  const _RootCore({required this.rootWord, required this.rootMeaning});
  final String rootWord;
  final String rootMeaning;

  @override
  Widget build(BuildContext context) {
    return Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: KalaamColors.surfaceTrim,
            shape: BoxShape.circle,
            border: Border.all(color: KalaamColors.primary, width: 2),
            boxShadow: [
              BoxShadow(
                color: KalaamColors.primary.withValues(alpha: 0.25),
                blurRadius: 16,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                rootWord,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: KalaamColors.primary,
                ),
              ),
              Text(
                rootMeaning,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(fontSize: 8),
              ),
            ],
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
          duration: 1600.ms,
          curve: Curves.easeInOut,
        );
  }
}

class _FamilyNode extends StatefulWidget {
  const _FamilyNode({
    required this.item,
    required this.rootWord,
    required this.x,
    required this.y,
    required this.index,
    required this.ctx,
  });

  final Map<String, Object?> item;
  final String rootWord;
  final double x;
  final double y;
  final int index;
  final CatalogItemContext ctx;

  @override
  State<_FamilyNode> createState() => _FamilyNodeState();
}

class _FamilyNodeState extends State<_FamilyNode> {
  bool _localExpanded = false;

  @override
  void initState() {
    super.initState();
    final val = widget.item['isExpanded'];
    if (val is bool) {
      _localExpanded = val;
    }
  }

  @override
  Widget build(BuildContext context) {
    final word = widget.item['word'] as String? ?? '';
    final translit = widget.item['transliteration'] as String? ?? '';
    final meaning = widget.item['meaning'] as String? ?? '';
    final pos = widget.item['partOfSpeech'] as String? ?? '';
    final pattern = widget.item['pattern'] as String? ?? '';

    final isExpandedVal = widget.item['isExpanded'];
    if (isExpandedVal is Map && isExpandedVal.containsKey('path')) {
      return BoundBool(
        dataContext: widget.ctx.dataContext,
        value: isExpandedVal,
        builder: (context, value) {
          final expanded = value ?? _localExpanded;
          return _buildNodeContent(
            context,
            expanded,
            word,
            translit,
            meaning,
            pos,
            pattern,
          );
        },
      );
    } else {
      return _buildNodeContent(
        context,
        _localExpanded,
        word,
        translit,
        meaning,
        pos,
        pattern,
      );
    }
  }

  Widget _buildNodeContent(
    BuildContext context,
    bool expanded,
    String word,
    String translit,
    String meaning,
    String pos,
    String pattern,
  ) {
    final double w = expanded ? 155 : 92;
    final double h = expanded ? 144 : 46;

    return Positioned(
      left: widget.x - w / 2,
      top: widget.y - h / 2,
      child: GestureDetector(
        onTap: () {
          final pathMap = widget.item['isExpanded'];
          if (pathMap is Map && pathMap.containsKey('path')) {
            widget.ctx.dataContext.update(
              DataPath(pathMap['path'] as String),
              !expanded,
            );
          } else {
            setState(() {
              _localExpanded = !expanded;
            });
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          width: w,
          height: h,
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 8,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: expanded
                ? KalaamColors.primaryDim.withValues(alpha: 0.18)
                : KalaamColors.surfaceTrim,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: expanded
                  ? KalaamColors.primary
                  : KalaamColors.primary.withValues(alpha: 0.2),
              width: expanded ? 2 : 1,
            ),
          ),
          child: expanded
              ? _ExpandedNode(
                  word: word,
                  translit: translit,
                  meaning: meaning,
                  pos: pos,
                  pattern: pattern,
                  onExplore: () => sendKalaamAction(
                    widget.ctx,
                    'explore_word',
                    {'word': word, 'root': widget.rootWord, 'meaning': meaning},
                  ),
                )
              : Center(
                  child: Text(
                    word,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: KalaamColors.onSurface,
                    ),
                  ),
                ),
        ),
      ),
    ).animate().scale(
      delay: (widget.index * 80).ms,
      duration: 350.ms,
      curve: Curves.easeOutBack,
    );
  }
}

class _ExpandedNode extends StatelessWidget {
  const _ExpandedNode({
    required this.word,
    required this.translit,
    required this.meaning,
    required this.pos,
    required this.pattern,
    required this.onExplore,
  });

  final String word;
  final String translit;
  final String meaning;
  final String pos;
  final String pattern;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          word,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: KalaamColors.primary,
          ),
        ),
        Text(
          '$translit · $meaning',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 9),
        ),
        const Gap(2),
        Container(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 6,
            vertical: 1,
          ),
          decoration: BoxDecoration(
            color: KalaamColors.surface,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'وزن $pattern',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 12,
              color: KalaamColors.secondary,
            ),
          ),
        ),
        const Gap(2),
        GestureDetector(
          onTap: onExplore,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Explore',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: KalaamColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 9,
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 11,
                color: KalaamColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
