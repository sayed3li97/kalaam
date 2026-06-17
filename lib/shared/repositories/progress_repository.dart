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
    final current = state.value ?? [];
    final updated = [...current, result];
    state = AsyncValue.data(updated);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(updated.map((r) => r.toJson()).toList()),
    );
  }
}
