import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kalaam/core/constants/scenarios.dart';
import 'package:kalaam/shared/models/scenario.dart';
import 'package:kalaam/shared/widgets/duo_button.dart';
import 'package:kalaam/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _goalController = TextEditingController();

  static const _arabic = 'ar';

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  void _startGoal() {
    final goal = _goalController.text.trim();
    if (goal.isEmpty) return;
    context.push(
      '/session/$_arabic/custom?goal=${Uri.encodeQueryComponent(goal)}',
    );
  }

  void _startScenario(Scenario s) {
    context.push('/session/$_arabic/${s.id}');
  }

  @override
  Widget build(BuildContext context) {
    final scenarios = KalaamScenarios.byLanguage(_arabic);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 80,
            pinned: true,
            backgroundColor: KalaamColors.surface,
            elevation: 0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.language_rounded, color: KalaamColors.primary, size: 32),
                Row(
                  children: [
                    Row(
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 20)),
                        const Gap(4),
                        Text('12', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.orange, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Gap(16),
                    Row(
                      children: [
                        const Text('❤️', style: TextStyle(fontSize: 20)),
                        const Gap(4),
                        Text('5', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: KalaamColors.error, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 8),
            sliver: SliverToBoxAdapter(
              child: _GoalStarter(
                controller: _goalController,
                onStart: _startGoal,
              ),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsetsDirectional.fromSTEB(24, 16, 24, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Or choose a real-world scenario',
                style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: KalaamColors.onSurface,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsetsDirectional.fromSTEB(24, 8, 24, 0),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 800 ? 3 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: MediaQuery.of(context).size.width > 800
                    ? 1.9
                    : 0.75,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final s = scenarios[index];
                return _ScenarioCard(
                      scenario: s,
                      onTap: () => _startScenario(s),
                    )
                    .animate()
                    .fadeIn(delay: (index * 50).ms, duration: 300.ms)
                    .scale(
                      begin: const Offset(0.95, 0.95),
                      curve: Curves.easeOutBack,
                    );
              }, childCount: scenarios.length),
            ),
          ),
          const SliverGap(80),
        ],
      ),
    );
  }
}

class _GoalStarter extends StatelessWidget {
  const _GoalStarter({required this.controller, required this.onStart});

  final TextEditingController controller;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            KalaamColors.primaryDim.withValues(alpha: 0.30),
            KalaamColors.secondary.withValues(alpha: 0.18),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: KalaamColors.primary.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: KalaamColors.primary,
                size: 20,
              ),
              const Gap(8),
              Text(
                'Learn anything in Arabic',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: KalaamColors.primary),
              ),
            ],
          ),
          const Gap(4),
          Text(
            'Tell Kalaam what you want to learn — your AI tutor will create a custom lesson just for you.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Gap(14),
          TextField(
            controller: controller,
            textInputAction: TextInputAction.go,
            onSubmitted: (_) => onStart(),
            decoration: const InputDecoration(
              hintText: 'e.g. bargaining in a Cairo market',
              hintStyle: TextStyle(fontSize: 14),
            ),
          ),
          const Gap(12),
          SizedBox(
            width: double.infinity,
            child: DuoButton(
              onPressed: onStart,
              color: KalaamColors.primary,
              shadowColor: KalaamColors.primaryDim,
              padding: const EdgeInsetsDirectional.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.school_rounded, size: 18, color: Colors.white),
                  const Gap(8),
                  const Text('Start Learning', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  final Scenario scenario;
  final VoidCallback onTap;

  const _ScenarioCard({required this.scenario, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final chipColor = switch (scenario.difficulty) {
      'Intermediate' => KalaamColors.secondary,
      'Advanced' => KalaamColors.error,
      _ => KalaamColors.success,
    };

    return DuoButton(
      onPressed: onTap,
      color: KalaamColors.surfaceVar,
      shadowColor: KalaamColors.surfaceTrim,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Flexible height emoji header
            Expanded(
              flex: 5,
              child: Container(
                decoration: const BoxDecoration(
                  color: KalaamColors.surfaceTrim,
                ),
                child: Center(
                  child: Text(
                    scenario.emoji,
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
              ),
            ),
            // Flexible height text section
            Expanded(
              flex: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              color: KalaamColors.surfaceVar,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scenario.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        scenario.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: chipColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: chipColor.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      scenario.difficulty,
                      style: TextStyle(
                        color: chipColor,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }
}
