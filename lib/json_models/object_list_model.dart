import '../models/object_type_model.dart';

class ObjectList {
  final int id;
  final String language;
  final List<ObjectType> objects;

  ObjectList({required this.id, required this.language, required this.objects});

  factory ObjectList.fromJson(Map<String, dynamic> json) {
    return ObjectList(
      id: json["id"] as int,
      language: json["language"] as String,
      objects: (json["objects"] as List).map<ObjectType>((json) => ObjectType.fromJson(json)).toList(),
    );
  }
}