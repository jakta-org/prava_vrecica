class FunFact {
  Map<String, String> fact;
  String? source;

  FunFact({required this.fact, this.source});

  String getFact(String language) {
    return fact[language]!;
  }

  String? getSource() {
    return source;
  }

  factory FunFact.fromJson(Map<String, dynamic> json) {
    return FunFact(
      fact: Map.from(json['fact']),
      source: json['source'],
    );
  }
}