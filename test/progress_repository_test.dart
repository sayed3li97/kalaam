import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kalaam/shared/models/session_result.dart';
import 'package:kalaam/shared/repositories/progress_repository.dart';

SessionResult _result(String id, int mastery) => SessionResult(
  id: id,
  languageCode: 'ar',
  scenarioTitle: 'Scenario $id',
  masteryPercent: mastery,
  wordsLearned: 5,
  completedAt: DateTime(2026, 1, int.parse(id)),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('addResult preserves prior results even when the notifier is freshly '
      'loading (regression: would clobber history)', () async {
    // One result already persisted from a previous session.
    SharedPreferences.setMockInitialValues({
      'kalaam_session_results': jsonEncode([_result('1', 70).toJson()]),
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Call addResult on the just-created (auto-dispose) notifier BEFORE its
    // async build() has resolved — exactly the 2nd-session timing that used to
    // read a null state and overwrite the stored history.
    await container
        .read(progressRepositoryProvider.notifier)
        .addResult(_result('2', 80));

    final results = await container.read(progressRepositoryProvider.future);
    expect(
      results.map((r) => r.id).toSet(),
      {'1', '2'},
      reason: 'the previously-saved result must survive the new save',
    );
  });
}
