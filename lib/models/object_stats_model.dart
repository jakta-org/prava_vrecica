class ObjectStats {
  final int recycledCount;
  final int recycledCountFromPhoto;

  ObjectStats({required this.recycledCount, required this.recycledCountFromPhoto});
}

class ObjectWithCategoryStats extends ObjectStats {
  final String category;

  ObjectWithCategoryStats(
      {required this.category,
        required int recycledCount,
        required int recycledCountFromPhoto})
      : super(
      recycledCount: recycledCount,
      recycledCountFromPhoto: recycledCountFromPhoto);
}