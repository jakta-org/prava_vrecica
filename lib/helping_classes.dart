class ObjectCount {
  late int totalCount;
  late int validCount;

  int get notValidCount => totalCount - validCount;

  ObjectCount(this.totalCount, this.validCount);

  factory ObjectCount.fromJson(Map<String, dynamic> json) {
    return ObjectCount(
      json['totalCount'] as int,
      json['validCount'] as int,
    );
  }
}