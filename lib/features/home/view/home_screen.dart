import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kalaam/core/constants/scenarios.dart';
import 'package:kalaam/shared/models/scenario.dart';
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
            expandedHeight: 180,
            pinned: true,
            backgroundColor: KalaamColors.surface,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(
                start: 24,
                bottom: 16,
              ),
              title: Text(
                'Kalaam كلام',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: KalaamColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [KalaamColors.surface, KalaamColors.surfaceVar],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Opacity(
                    opacity: 0.05,
                    child: Text(
                      'العربية',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 120,
                        color: KalaamColors.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
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
                'Or start from a scene',
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
            'Tell Kalaam what you want — Gemini composes the whole lesson live.',
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
            child: ElevatedButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.school_rounded, size: 18),
              label: const Text('Teach me'),
              style: ElevatedButton.styleFrom(
                backgroundColor: KalaamColors.primary,
                foregroundColor: KalaamColors.onPrimary,
                padding: const EdgeInsetsDirectional.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fixed height emoji header
            Container(
              height: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    KalaamColors.primaryDim.withValues(alpha: 0.40),
                    KalaamColors.secondary.withValues(alpha: 0.40),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(
                  scenario.emoji,
                  style: const TextStyle(fontSize: 36),
                ),
              ),
            ),
            // Fixed height text section (no Expanded to prevent unbounded constraints)
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              color: KalaamColors.surfaceTrim,
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
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: chipColor.withValues(alpha: 0.5),
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
          ],
        ),
      ),
    );
  }
}
