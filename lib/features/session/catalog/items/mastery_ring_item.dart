import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:genui/genui.dart';
import 'package:go_router/go_router.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:kalaam/shared/models/session_result.dart';
import 'package:kalaam/shared/repositories/progress_repository.dart';
import 'package:kalaam/core/constants/scenarios.dart';
import 'package:kalaam/theme.dart';

/// The session finale. Its `masteryPercent` is a **bound number reference**, so
/// the model can `createSurface` the ring at 0 and then push `updateDataModel`
/// ticks (e.g. 45 → 80) that animate the arc and the counter WITHOUT rebuilding
/// the surface. This is the headline GenUI capability: the model steering live
/// widget state through the data model, visible in the Live GenUI Inspector.
final masteryRingItem = CatalogItem(
  name: 'MasteryRing',
  dataSchema: S.object(
    properties: {
      'sessionTitle': A2uiSchemas.stringReference(
        description: 'Title of the scenario',
      ),
      'wordsEncountered': S.integer(description: 'Count of words encountered'),
      'exercisesCompleted': S.integer(
        description: 'Count of exercises completed',
      ),
      'correctAnswers': S.integer(description: 'Count of correct answers'),
      // A data-bound number: emit a literal (e.g. 80) for a static ring, OR a
      // {"path": "/progress/mastery"} binding and then push updateDataModel
      // values to animate it live.
      'masteryPercent': A2uiSchemas.numberReference(
        description:
            'Mastery percentage (0-100). Bind to a data path and push '
            'updateDataModel values to animate the ring live.',
      ),
      'streakDays': S.integer(description: 'Active streak in days'),
      'topWords': S.list(
        description: 'Selected top words learned',
        items: S.string(),
      ),
    },
    required: [
      'sessionTitle',
      'wordsEncountered',
      'exercisesCompleted',
      'correctAnswers',
      'masteryPercent',
      'streakDays',
      'topWords',
    ],
  ),
  exampleData: [
    () => '''
[
  {
    "id": "root",
    "component": "MasteryRing",
    "sessionTitle": "Ordering Coffee in Cairo",
    "wordsEncountered": 8,
    "exercisesCompleted": 5,
    "correctAnswers": 4,
    "masteryPercent": 80,
    "streakDays": 3,
    "topWords": ["قَهْوَة", "مِنْ فَضْلِكَ", "أُرِيدُ"]
  }
]
''',
  ],
  widgetBuilder: (ctx) {
    final data = ctx.data as Map<String, Object?>;
    final title = data['sessionTitle'] as String? ?? 'Ordering Coffee in Cairo';
    final wordsCount = data['wordsEncountered'] as int? ?? 8;
    final exercises = data['exercisesCompleted'] as int? ?? 5;
    final correct = data['correctAnswers'] as int? ?? 4;
    // Raw, unresolved: a literal num OR a {"path": ...} binding. BoundNumber
    // resolves and subscribes so updateDataModel ticks rebuild just the arc.
    final masteryValue = data['masteryPercent'];
    final streak = data['streakDays'] as int? ?? 3;
    final topWords = List<String>.from(data['topWords'] as List? ?? []);

    return _MasteryRingWidget(
      sessionTitle: title,
      wordsEncountered: wordsCount,
      exercisesCompleted: exercises,
      correctAnswers: correct,
      masteryValue: masteryValue,
      dataContext: ctx.dataContext,
      streakDays: streak,
      topWords: topWords,
    );
  },
);

class _MasteryRingWidget extends ConsumerStatefulWidget {
  final String sessionTitle;
  final int wordsEncountered;
  final int exercisesCompleted;
  final int correctAnswers;

  /// Raw mastery value: a literal `num` or a `{"path": ...}` data binding.
  final Object? masteryValue;
  final DataContext dataContext;
  final int streakDays;
  final List<String> topWords;

  const _MasteryRingWidget({
    required this.sessionTitle,
    required this.wordsEncountered,
    required this.exercisesCompleted,
    required this.correctAnswers,
    required this.masteryValue,
    required this.dataContext,
    required this.streakDays,
    required this.topWords,
  });

  @override
  ConsumerState<_MasteryRingWidget> createState() => _MasteryRingWidgetState();
}

class _MasteryRingWidgetState extends ConsumerState<_MasteryRingWidget> {
  /// Highest mastery value observed from the data model — used for persistence.
  /// Tracks the max (not the latest) so a settled ramp 0→45→80 records 80 even
  /// if the save fires mid-animation.
  num _maxObserved = 0;
  bool _saved = false;
  Timer? _saveTimer;

  @override
  void initState() {
    super.initState();
    // Seed from a literal value if present (live mode often emits one).
    if (widget.masteryValue is num) {
      _maxObserved = widget.masteryValue! as num;
    }
    // Fallback auto-save: fires once the data-model ticks have settled, so a
    // result is recorded even if the learner never taps "Back to Scenarios".
    _saveTimer = Timer(const Duration(seconds: 3), _saveSessionResult);
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    super.dispose();
  }

  Future<void> _saveSessionResult() async {
    if (_saved) return;
    _saved = true;
    _saveTimer?.cancel();

    // Find the correct languageCode from the scenarioTitle. For custom goals
    // (where sessionTitle won't match any scenario), default to 'ar' since the
    // app is Arabic-only, rather than attributing to the first scenario's data.
    final match = KalaamScenarios.all
        .where(
          (s) => s.title.toLowerCase() == widget.sessionTitle.toLowerCase(),
        )
        .firstOrNull;

    final result = SessionResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      languageCode: match?.languageCode ?? 'ar',
      scenarioTitle: widget.sessionTitle,
      masteryPercent: _maxObserved.round(),
      wordsLearned: widget.topWords.length,
      completedAt: DateTime.now(),
    );

    await ref.read(progressRepositoryProvider.notifier).addResult(result);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Scenario Completed! 🎓',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: KalaamColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(4),
                Text(
                  widget.sessionTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Gap(32),

                // The bound ring: resolves masteryValue against the data model and
                // rebuilds whenever the model pushes a new updateDataModel value.
                Center(
                  child: SizedBox(
                    width: 160,
                    height: 160,
                    child: BoundNumber(
                      dataContext: widget.dataContext,
                      value: widget.masteryValue,
                      builder: (context, num? bound) {
                        final pct = (bound ?? _maxObserved)
                            .clamp(0, 100)
                            .toDouble();
                        if (pct > _maxObserved) _maxObserved = pct;
                        // TweenAnimationBuilder eases from the current value to each
                        // new target, so successive ticks chain into one smooth ramp.
                        return TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: pct / 100),
                          duration: 900.ms,
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return CustomPaint(
                              painter: _RingPainter(value),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${(value * 100).round()}%',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayLarge
                                          ?.copyWith(
                                            color: KalaamColors.primary,
                                            fontSize: 36,
                                          ),
                                    ),
                                    Text(
                                      'MASTERY',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                const Gap(32),

                // Stat Cards
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _MiniStat(
                      label: 'Words',
                      value: '${widget.wordsEncountered}',
                      color: KalaamColors.secondary,
                    ),
                    _MiniStat(
                      label: 'Correct',
                      value:
                          '${widget.correctAnswers}/${widget.exercisesCompleted}',
                      color: KalaamColors.success,
                    ),
                    _MiniStat(
                      label: 'Streak',
                      value: '${widget.streakDays}d',
                      color: KalaamColors.error,
                    ),
                  ],
                ),
                const Gap(24),

                // Top Words
                Text(
                  'Key Words Learned:',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Gap(8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.topWords.map((word) {
                    return Chip(
                      label: Text(
                        word,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: KalaamColors.primary,
                        ),
                      ),
                      backgroundColor: KalaamColors.primaryDim.withValues(
                        alpha: 0.15,
                      ),
                    );
                  }).toList(),
                ),
                const Gap(32),

                // Start Another Scene
                ElevatedButton(
                  onPressed: () {
                    _saveSessionResult();
                    context.go('/');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KalaamColors.primary,
                    foregroundColor: KalaamColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Back to Scenarios'),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOutBack);
  }
}

class _RingPainter extends CustomPainter {
  final double progress;

  _RingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final bgPaint = Paint()
      ..color = KalaamColors.surfaceTrim
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    final progressPaint = Paint()
      ..color = KalaamColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final angle = 2 * 3.14159 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      angle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            fontFamily: 'IBMPlexMono',
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
