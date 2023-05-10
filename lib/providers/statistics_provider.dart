import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/object_stats_model.dart';

class StatisticsProvider extends ChangeNotifier {
  late Map<String, ObjectStats> stats;
  late SharedPreferences _prefs;
  int userId = -2;
  bool test = false;

  StatisticsProvider(List<String> labels, this.userId) {
    initPrefs(labels);
  }

  Future<void> initPrefs(List<String> labels) async {
    _prefs = await SharedPreferences.getInstance();
    final prefStats = _prefs.getString('stats_$userId');
    if (prefStats == null) {
      Map<String, ObjectStats> setStats = {};
      for (String label in labels) {
        setStats[label] = ObjectStats(recycledCount: 0, recycledCountFromPhoto: 0);
      }
      saveStats(setStats);
    } else {
      stats = (jsonDecode(prefStats) as Map<String, dynamic>).map((key, value) => MapEntry(key, ObjectStats.fromJson(value)));
    }
  }

  Future<void> saveStats(Map<String, ObjectStats> stats) async {
    this.stats = stats;
    await _prefs.setString('stats_$userId', jsonEncode(stats));
    notifyListeners();
  }

  Future<void> updateStats(Map<String, ObjectStats> additionalStats) async {
    final oldStats = stats;
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

  Map<String, ObjectStats> getStats() {
    return stats;
  }

  Future<void> clearStats(int userId) async {
    stats = {};
    await _prefs.remove('stats_$userId');
    notifyListeners();
  }
}