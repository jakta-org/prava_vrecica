class ObjectType {
  final String label;
  final String name;
  final String desc;
  final Map<String, dynamic> attributes;

  ObjectType({required this.label, required this.name, required this.desc, required this.attributes});

  factory ObjectType.fromJson(Map<String, dynamic> json) {
    return ObjectType(
      label: json["label"] as String,
      name: json["name"] as String,
      desc: json["desc"] as String,
      attributes: json["attributes"] as Map<String, dynamic>,
    );
  }
}