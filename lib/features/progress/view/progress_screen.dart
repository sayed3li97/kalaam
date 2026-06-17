import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:kalaam/shared/models/session_result.dart';
import 'package:kalaam/shared/repositories/progress_repository.dart';
import 'package:kalaam/theme.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(progressRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Learning Journey',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: KalaamColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: KalaamColors.surface,
        elevation: 0,
      ),
      body: progressAsync.when(
        data: (results) {
          if (results.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.insights_rounded,
                      size: 80,
                      color: KalaamColors.onSurfaceDim,
                    ).animate().scale(
                      duration: 400.ms,
                      curve: Curves.elasticOut,
                    ),
                    const Gap(24),
                    Text(
                      'No completed sessions yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Gap(8),
                    Text(
                      'Complete your first AI learning session to start tracking progress.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            );
          }

          final totalCompleted = results.length;
          final totalWords = results.fold<int>(
            0,
            (sum, r) => sum + r.wordsLearned,
          );
          final avgMastery =
              (results.fold<int>(0, (sum, r) => sum + r.masteryPercent) /
                      totalCompleted)
                  .round();

          // Calculate actual streak from session completion dates
          final streak = _calculateStreak(results);

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            children: [
              // Stats Cards Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _StatCard(
                    title: 'Sessions',
                    value: '$totalCompleted',
                    icon: Icons.done_all_rounded,
                    color: KalaamColors.success,
                  ),
                  _StatCard(
                    title: 'Words Learned',
                    value: '$totalWords',
                    icon: Icons.auto_stories_rounded,
                    color: KalaamColors.primary,
                  ),
                  _StatCard(
                    title: 'Avg. Mastery',
                    value: '$avgMastery%',
                    icon: Icons.local_activity_rounded,
                    color: KalaamColors.secondary,
                  ),
                  _StatCard(
                    title: 'Day Streak',
                    value: '$streak',
                    icon: Icons.local_fire_department_rounded,
                    color: KalaamColors.error,
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms),
              const Gap(32),
              Text(
                'Recent Achievements',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Gap(12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final r =
                      results[results.length -
                          1 -
                          index]; // reverse chronological
                  final formattedDate = DateFormat(
                    'MMM dd, yyyy · hh:mm a',
                  ).format(r.completedAt);
                  return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: KalaamColors.primary.withValues(
                                alpha: 0.1,
                              ),
                              child: const Text(
                                '🎓',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                            title: Text(
                              r.scenarioTitle,
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(fontSize: 16),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Gap(4),
                                Text(
                                  'Learned ${r.wordsLearned} words',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const Gap(2),
                                Text(
                                  formattedDate,
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: KalaamColors.primary.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${r.masteryPercent}%',
                                style: const TextStyle(
                                  color: KalaamColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'IBMPlexMono',
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: (index * 50).ms)
                      .slideX(begin: 0.05, end: 0);
                },
              ),
              const Gap(80),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: KalaamColors.primary),
        ),
        error: (e, _) => Center(child: Text('Error loading stats: $e')),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodySmall),
                Icon(icon, color: color, size: 20),
              ],
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: KalaamColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Calculates the current day streak by checking consecutive days
/// with at least one session completed, counting backwards from today.
int _calculateStreak(List<SessionResult> results) {
  if (results.isEmpty) return 0;

  final completionDays =
      results
          .map(
            (r) => DateTime(
              r.completedAt.year,
              r.completedAt.month,
              r.completedAt.day,
            ),
          )
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a)); // newest first

  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);

  // The most recent session must be today or yesterday to have an active streak.
  final diff = todayDate.difference(completionDays.first).inDays;
  if (diff > 1) return 0;

  var streak = 1;
  for (var i = 1; i < completionDays.length; i++) {
    final gap = completionDays[i - 1].difference(completionDays[i]).inDays;
    if (gap == 1) {
      streak++;
    } else {
      break;
    }
  }
  return streak;
}
