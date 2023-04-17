class StatisticService {

  Future<void> saveStats(Map<String, ObjectStats> stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('stats', jsonEncode(stats));
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
    final prefs = await SharedPreferences.getInstance();
    final stats = prefs.getString('stats');
    if (stats == null) {
      return {};
    }
    return (jsonDecode(stats) as Map<String, dynamic>).map((key, value) => MapEntry(key, ObjectStats.fromJson(value)));
  }
}