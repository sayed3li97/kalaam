import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kalaam/features/home/view/home_screen.dart';
import 'package:kalaam/features/progress/view/progress_screen.dart';
import 'package:kalaam/features/session/view/session_screen.dart';
import 'package:kalaam/shared/widgets/main_shell.dart';

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) => GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (_, __, shell) => MainShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: '/', builder: (_, __) => const HomeScreen())],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/progress',
              builder: (_, __) => const ProgressScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/session/:languageCode/:scenarioId',
      builder: (_, state) => SessionScreen(
        languageCode: state.pathParameters['languageCode']!,
        scenarioId: state.pathParameters['scenarioId']!,
        goal: state.uri.queryParameters['goal'],
      ),
    ),
  ],
);
