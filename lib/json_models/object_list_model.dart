import 'package:flutter/material.dart';

class ObjectList {
  final int id;
  final String language;
  final List<ObjectType> objects;
  final List<AttributeType> attributes;

  ObjectList({required this.id, required this.language, required this.objects, required this.attributes});

  factory ObjectList.fromJson(Map<String, dynamic> json) {
    return ObjectList(
      id: json["id"] as int,
      language: json["language"] as String,
      objects: (json["objects"] as List).map<ObjectType>((json) => ObjectType.fromJson(json)).toList(),
      attributes: (json["attribute-info"] as List).map<AttributeType>((json) => AttributeType.fromJson(json)).toList(),
    );
  }
  
  List<AttributeType> objectAttributes(ObjectType object) {
    return attributes.where((attr) => objects.firstWhere((obj) => obj == object).attributes.keys.contains(attr.name)).toList();
  }
}

class AttributeType {
  final String name;
  final int importance;
  final String info;

  AttributeType({required this.importance, required this.name, required this.info});

  factory AttributeType.fromJson(Map<String, dynamic> json) {
    return AttributeType(
      name: json["name"] as String,
      importance: json["importance"] as int,
      info: json["info"] as String,
    );
  }

  String formatWithVars(Map<String, dynamic> vars) {
    String r = info;

    for (String V in vars.keys) {
      r = r.replaceFirst("%$V%", vars[V].toString());
    }

    return r;
  }

  Widget getDisplayable(BuildContext context, TextStyle style, Map<String, dynamic> vars) {
    List<Color> importanceColors = [Theme.of(context).colorScheme.primary, Colors.green, Colors.yellow, Colors.red];

    return Container(
      margin: const EdgeInsetsDirectional.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 50,
            child: Container(
              padding: EdgeInsetsDirectional.zero,
              child: Icon(
                Icons.info,
                color: importanceColors[importance],
                shadows: const <Shadow>[
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 220,
            child: Text(
              formatWithVars(vars),
              textAlign: TextAlign.justify,
              style: style,
            ),
          )
        ],
      ),
    );
  }
}

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