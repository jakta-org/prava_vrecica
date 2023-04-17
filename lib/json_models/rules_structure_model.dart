import 'package:flutter/material.dart';

class RulesStructure {
  final int id;
  final String language;
  final String name;
  final String author;
  final Map<String, dynamic> authorInfo;

  final List<RuleInfo> infoList;

  final List<ObjectCategory> categories;

  final List<SpecialObjectType> special;

  RulesStructure({
    required this.id,
    required this.language,
    required this.name,
    required this.author,
    required this.authorInfo,
    required this.infoList,
    required this.categories,
    required this.special,
  });

  factory RulesStructure.fromJson(Map<String, dynamic> json) {
    return RulesStructure(
      id: json["id"] as int,
      language: json["language"] as String,
      name: json["name"] as String,
      author: json["author"] as String,
      authorInfo: json["author-info"] as Map<String, dynamic>,
      infoList: (json["info-list"] as List).map<RuleInfo>((json) => RuleInfo.fromJson(json)).toList(),
      categories: (json["categories-list"] as List).map<ObjectCategory>((json) => ObjectCategory.fromJson(json)).toList(),
      special: (json["special"] as List).map<SpecialObjectType>((json) => SpecialObjectType.fromJson(json)).toList(),
    );
  }
}

class RuleInfo {
  final String type;
  final Map<String, dynamic> meta;

  RuleInfo({
    required this.type,
    required this.meta,
  });

  factory RuleInfo.fromJson(Map<String, dynamic> json) {
    return RuleInfo(
      type: json["type"] as String,
      meta: json["meta"] as Map<String, dynamic>,
    );
  }
}

class ObjectCategory {
  final String name;
  final Color color;
  final Map<String, dynamic> info;
  final Map<String, dynamic> where;
  final List<CategoryObjectType> objects;

  ObjectCategory({
    required this.name,
    required this.color,
    required this.info,
    required this.where,
    required this.objects,
  });

  factory ObjectCategory.fromJson(Map<String, dynamic> json) {
    return ObjectCategory(
      name: json["name"] as String,
      color: Color(int.parse(json["color"])),
      info: json["info"] as Map<String, dynamic>,
      where: json["where"] as Map<String, dynamic>,
      objects: (json["objects"] as List).map<CategoryObjectType>((json) => CategoryObjectType.fromJson(json)).toList(),
    );
  }
}

class CategoryObjectType {
  final String label;
  final Map<String, dynamic> attributes;

  CategoryObjectType({
    required this.label,
    required this.attributes,
  });

  factory CategoryObjectType.fromJson(Map<String, dynamic> json) {
    return CategoryObjectType(
      label: json["label"] as String,
      attributes: json["attributes"] as Map<String, dynamic>,
    );
  }
}

class SpecialObjectType {
  final String label;
  final Color color;
  final Map<String, dynamic> info;
  final Map<String, dynamic> where;

  SpecialObjectType({
    required this.label,
    required this.color,
    required this.info,
    required this.where,
  });

  factory SpecialObjectType.fromJson(Map<String, dynamic> json) {
    return SpecialObjectType(
      label: json["label"] as String,
      color: Color(int.parse(json["color"])),
      info: json["info"] as Map<String, dynamic>,
      where: json["where"] as Map<String, dynamic>,
    );
  }
}