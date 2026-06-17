import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import 'package:kalaam/theme.dart';
import 'package:kalaam/features/session/catalog/kalaam_actions.dart';

/// The Unicode combining marks for each harakah.
const Map<String, String> _markChars = {
  'fatha': 'َ', // َ
  'damma': 'ُ', // ُ
  'kasra': 'ِ', // ِ
  'sukun': 'ْ', // ْ
  'shadda': 'ّ', // ّ
};

const Map<String, String> _markLabels = {
  'fatha': 'fatḥa',
  'damma': 'ḍamma',
  'kasra': 'kasra',
  'sukun': 'sukūn',
  'shadda': 'shadda',
};

/// HarakatBuilder — vocalise an Arabic consonant skeleton.
///
/// The learner taps a letter, then taps a harakah from the palette; the word
/// re-renders live with the diacritic applied. "Check" validates against the
/// target vocalisation. Teaches the writing system in a way only a dynamic UI
/// can — and showcases genui local interactive state + dispatch-back.
final harakatBuilderItem = CatalogItem(
  name: 'HarakatBuilder',
  dataSchema: S.object(
    properties: {
      'instruction': A2uiSchemas.stringReference(
        description: 'What to build, e.g. "Vocalise the word for coffee"',
      ),
      'letters': S.list(
        description: 'Ordered base (consonant) letters WITHOUT harakat',
        minItems: 2,
        maxItems: 8,
        items: S.string(),
      ),
      'target': S.list(
        description:
            'The correct harakah for each letter, same length/order '
            'as letters. One of: fatha, damma, kasra, sukun, shadda, none',
        items: S.string(),
      ),
      'transliteration': A2uiSchemas.stringReference(
        description: 'Romanised pronunciation of the finished word',
      ),
      'translation': A2uiSchemas.stringReference(
        description: 'English translation of the finished word',
      ),
    },
    required: [
      'instruction',
      'letters',
      'target',
      'transliteration',
      'translation',
    ],
  ),
  exampleData: [
    () => '''
[
  {
    "id": "root",
    "component": "HarakatBuilder",
    "instruction": "Add the vowels to spell qahwa (coffee)",
    "letters": ["ق", "ه", "و", "ة"],
    "target": ["fatha", "sukun", "fatha", "none"],
    "transliteration": "qahwa",
    "translation": "coffee"
  }
]
''',
  ],
  widgetBuilder: (ctx) {
    final data = ctx.data as Map<String, Object?>;
    final instruction = data['instruction'] as String? ?? '';
    final letters = List<String>.from(data['letters'] as List? ?? const []);
    final target = List<String>.from(data['target'] as List? ?? const []);
    final translit = data['transliteration'] as String? ?? '';
    final translation = data['translation'] as String? ?? '';

    return _HarakatBuilderWidget(
      instruction: instruction,
      letters: letters,
      target: target,
      transliteration: translit,
      translation: translation,
      ctx: ctx,
    );
  },
);

class _HarakatBuilderWidget extends StatefulWidget {
  const _HarakatBuilderWidget({
    required this.instruction,
    required this.letters,
    required this.target,
    required this.transliteration,
    required this.translation,
    required this.ctx,
  });

  final String instruction;
  final List<String> letters;
  final List<String> target;
  final String transliteration;
  final String translation;
  final CatalogItemContext ctx;

  @override
  State<_HarakatBuilderWidget> createState() => _HarakatBuilderWidgetState();
}

class _HarakatBuilderWidgetState extends State<_HarakatBuilderWidget> {
  late final List<String?> _chosen = List<String?>.filled(
    widget.letters.length,
    null,
  );
  int? _selected;
  bool _solved = false;
  bool _wrong = false;
  bool _shake = false;

  String _norm(String? v) => (v == null || v == 'none') ? 'none' : v;

  void _applyMark(String mark) {
    if (_solved || _selected == null) return;
    setState(() {
      _chosen[_selected!] = _chosen[_selected!] == mark ? null : mark;
      _wrong = false;
    });
  }

  void _check() {
    var correct = true;
    for (var i = 0; i < widget.letters.length; i++) {
      final want = i < widget.target.length ? widget.target[i] : 'none';
      if (_norm(_chosen[i]) != _norm(want)) {
        correct = false;
        break;
      }
    }
    if (correct) {
      setState(() {
        _solved = true;
        _wrong = false;
        _selected = null;
      });
    } else {
      setState(() {
        _wrong = true;
        _shake = true;
      });
    }
  }

  String _composed() {
    final buffer = StringBuffer();
    for (var i = 0; i < widget.letters.length; i++) {
      buffer.write(widget.letters[i]);
      final mark = _chosen[i];
      if (mark != null && _markChars.containsKey(mark)) {
        buffer.write(_markChars[mark]);
      }
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.spellcheck_rounded,
                  color: KalaamColors.primary,
                  size: 16,
                ),
                const Gap(8),
                Expanded(
                  child: Text(
                    widget.instruction,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const Gap(20),

            // The word being vocalised — RTL, tappable letters.
            Directionality(
                  textDirection: TextDirection.rtl,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 6,
                    children: List.generate(widget.letters.length, (i) {
                      final isSel = _selected == i;
                      final mark = _chosen[i];
                      final glyph =
                          widget.letters[i] +
                          (mark != null ? (_markChars[mark] ?? '') : '');
                      return GestureDetector(
                        onTap: _solved
                            ? null
                            : () =>
                                  setState(() => _selected = isSel ? null : i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 52,
                          height: 64,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSel
                                ? KalaamColors.primaryDim.withValues(
                                    alpha: 0.25,
                                  )
                                : KalaamColors.surfaceTrim,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _solved
                                  ? KalaamColors.success
                                  : isSel
                                  ? KalaamColors.primary
                                  : KalaamColors.primary.withValues(
                                      alpha: 0.15,
                                    ),
                              width: isSel || _solved ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            glyph,
                            style: const TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 34,
                              color: KalaamColors.onSurface,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                )
                .animate(target: _shake ? 1 : 0)
                .shake(duration: 380.ms)
                .callback(callback: (_) => setState(() => _shake = false)),

            const Gap(20),

            if (!_solved) ...[
              Text(
                _selected == null
                    ? 'Tap a letter, then choose its vowel'
                    : 'Choose a vowel for the highlighted letter',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Gap(10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: _markChars.keys.map((m) {
                  return _HarakahChip(
                    mark: m,
                    enabled: _selected != null,
                    onTap: () => _applyMark(m),
                  );
                }).toList(),
              ),
              const Gap(16),
              if (_wrong)
                Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 12),
                  child: const Text(
                    '💡 Not quite — check each vowel and try again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: KalaamColors.primary,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ).animate().fadeIn(duration: 250.ms),
                ),
              ElevatedButton(
                onPressed: _chosen.any((c) => c != null) ? _check : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: KalaamColors.primary,
                  foregroundColor: KalaamColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Check'),
              ),
              const Gap(8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        for (var i = 0; i < widget.letters.length; i++) {
                          _chosen[i] = i < widget.target.length
                              ? widget.target[i]
                              : 'none';
                        }
                      });
                      _check();
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
                      sendKalaamAction(widget.ctx, 'completed', {
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
              _SolvedBanner(
                transliteration: widget.transliteration,
                translation: widget.translation,
              ),
              const Gap(12),
              KalaamContinueButton(
                ctx: widget.ctx,
                label: 'Continue',
                action: 'completed',
                payload: {'isCorrect': true, 'word': _composed()},
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }
}

class _HarakahChip extends StatelessWidget {
  const _HarakahChip({
    required this.mark,
    required this.enabled,
    required this.onTap,
  });

  final String mark;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Render the mark on a dotted-circle carrier (ـ) so it's visible alone.
    final preview = 'ـ${_markChars[mark]}';
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 64,
          padding: const EdgeInsetsDirectional.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: KalaamColors.surfaceTrim,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: KalaamColors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Text(
                preview,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 24,
                  color: KalaamColors.primary,
                ),
              ),
              Text(
                _markLabels[mark] ?? mark,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(fontSize: 9),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SolvedBanner extends StatelessWidget {
  const _SolvedBanner({
    required this.transliteration,
    required this.translation,
  });
  final String transliteration;
  final String translation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.all(12),
      decoration: BoxDecoration(
        color: KalaamColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KalaamColors.success),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: KalaamColors.success,
                size: 22,
              ).animate().scale(duration: 300.ms, curve: Curves.elasticOut),
              const Gap(8),
              Text(
                'Vocalised!  $transliteration',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: KalaamColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(translation, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
