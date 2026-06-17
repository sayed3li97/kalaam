import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kalaam/shared/models/session_result.dart';

part 'progress_repository.g.dart';

@riverpod
class ProgressRepository extends _$ProgressRepository {
  static const _key = 'kalaam_session_results';

  @override
  Future<List<SessionResult>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      return list
          .map((item) => SessionResult.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addResult(SessionResult result) async {
    // Await the loaded history before appending. This notifier is auto-dispose,
    // so on the 2nd+ session it's freshly created and still in its async
    // build() when addResult runs — reading `state.value ?? []` there would see
    // null and overwrite every previously saved result. `future` resolves to
    // the persisted list first, so prior sessions are preserved.
    final current = await future;
    final updated = [...current, result];
    state = AsyncValue.data(updated);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(updated.map((r) => r.toJson()).toList()),
    );
  }
}
