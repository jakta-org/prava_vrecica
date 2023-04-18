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