import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/object_stats_model.dart';

class StatisticsProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  int userId = -2;
  bool test = false;

  StatisticsProvider() {
    initPrefs();
  }

  Future<void> initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveStats(Map<String, ObjectStats> stats) async {
    await _prefs.setString('stats_$userId', jsonEncode(stats));
    notifyListeners();
  }

  Future<void> updateStats(Map<String, ObjectStats> additionalStats) async {
    final oldStats = await getStats();
    final newStats = oldStats.map((key, value) {
      if (additionalStats.containsKey(key)) {
        return MapEntry(
            key,
            ObjectStats(recycledCount: value.recycledCount + additionalStats[key]!.recycledCount,
            recycledCountFromPhoto: value.recycledCountFromPhoto + additionalStats[key]!.recycledCountFromPhoto)
        );
      } else {
        return MapEntry(key, value);
      }
    });
    await saveStats(newStats);
  }

  Future<Map<String, ObjectStats>> getStats() async {
    final stats = _prefs.getString('stats_$userId');
    if (stats == null) {
      return {};
    }
    return (jsonDecode(stats) as Map<String, dynamic>).map((key, value) => MapEntry(key, ObjectStats.fromJson(value)));
  }

  Future<void> clearStats(int userId) async {
    await _prefs.remove('stats_$userId');
    notifyListeners();
  }
}