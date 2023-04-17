import 'dart:ui';

class ObjectStats {
  int recycledCount;
  int recycledCountFromPhoto;

  ObjectStats({required this.recycledCount, required this.recycledCountFromPhoto});

  factory ObjectStats.fromJson(Map<String, dynamic> json) {
    return ObjectStats(
      recycledCount: json['recycledCount'] as int,
      recycledCountFromPhoto: json['recycledCountFromPhoto'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recycledCount': recycledCount,
      'recycledCountFromPhoto': recycledCountFromPhoto,
    };
  }

  @override
  String toString() {
    return 'ObjectStats{recycledCount: $recycledCount, recycledCountFromPhoto: $recycledCountFromPhoto}';
  }
}

class ObjectStatsWithTime {
  DateTime time;
  Map<String, ObjectStats> stats;

  ObjectStatsWithTime({required this.time, required this.stats});

  factory ObjectStatsWithTime.fromJson(Map<String, dynamic> json) {
    return ObjectStatsWithTime(
      time: DateTime.parse(json['time'] as String),
      stats: (json['stats'] as Map<String, dynamic>).map((key, value) => MapEntry(key, ObjectStats.fromJson(value))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time.toIso8601String(),
      'stats': stats.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  @override
  String toString() {
    return 'ObjectStatsWithTime{time: $time, stats: $stats}';
  }
}

class CategoryStats {
  String categoryName;
  Color categoryColor;
  int recycledCount;
  int recycledCountFromPhoto;

  CategoryStats({
    required this.categoryName,
    required this.categoryColor,
    required this.recycledCount,
    required this.recycledCountFromPhoto,
  });

  @override
  String toString() {
    return 'CategoryStats{categoryName: $categoryName, categoryColor: $categoryColor, recycledCount: $recycledCount, recycledCountFromPhoto: $recycledCountFromPhoto}';
  }
}