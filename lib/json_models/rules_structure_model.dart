import 'package:flutter/material.dart';
import 'package:prava_vrecica/providers/categorization_provider.dart';
import 'package:provider/provider.dart';
import '../helping_classes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'object_list_model.dart';

class RulesStructure {
  final int id;
  final String language;
  final String name;
  final String author;
  final Map<String, dynamic> authorInfo;

  final List<RuleInfo> infoList;

  final List<ObjectCategory> categories;

  final List<SpecialObjectType> special;

  final List<AttributeType> attributes;

  RulesStructure({
    required this.id,
    required this.language,
    required this.name,
    required this.author,
    required this.authorInfo,
    required this.infoList,
    required this.categories,
    required this.special,
    required this.attributes,
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
      attributes: (json["attribute-info"] as List).map<AttributeType>((json) => AttributeType.fromJson(json)).toList(),
    );
  }

  SortingCategory? getCategoryByLabel(String label) {
    if(categories.any((category) => category.objects.any((object) => object.label == label))) {
      return categories.firstWhere((category) => category.objects.any((object) => object.label == label));
    } else if (special.any((specialCategory) => specialCategory.label == label)) {
      return special.firstWhere((specialCategory) => specialCategory.label == label);
    } else {
      return null;
    }
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

abstract class SortingCategory {

  String getName(BuildContext context);
  Color getColor();
  List<Widget> getDisplayable(TextStyle style, BuildContext context, String label);
  List<AttributeType> objectAttributes(RulesStructure rulesStructure, String label);
}

class ObjectCategory implements SortingCategory {
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

  @override
  Color getColor() {
    return color;
  }

  @override
  List<Widget> getDisplayable(TextStyle style, BuildContext context, String label) {
    final categorizationProvider = Provider.of<CategorizationProvider>(context, listen: false);

    List<Widget> wList = <Widget>[];
    wList.add(
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[Text(AppLocalizations.of(context)!.recycle_where, style: style.copyWith(fontWeight: FontWeight.bold))] + parseInfo(where, style, 0),
      ),
    );

    wList.add(
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[Text(AppLocalizations.of(context)!.object_info_title, style: style.copyWith(fontWeight: FontWeight.bold)), Text(categorizationProvider.getObjectByLabel(label)!.desc, textAlign: TextAlign.justify ,style: style)],
      ),
    );

    Map<String, dynamic> mergeMap = {};
    mergeMap.addAll(objects.firstWhere((obj) => obj.label == label).attributes);
    mergeMap.addAll(categorizationProvider.objectsList.objects.firstWhere((obj) => obj.label == label).attributes);
    List<AttributeType> displayAttributes = categorizationProvider.objectsList.attributes.where((attr) => mergeMap.keys.contains(attr.name)).toList() + categorizationProvider.rulesStructure.attributes.where((attr) => mergeMap.keys.contains(attr.name)).toList();
    if (displayAttributes.isNotEmpty) {
      wList.add(
          Column(
            children: <Widget>[
              Text(AppLocalizations.of(context)!.attributes_title,
                  style: style.copyWith(fontWeight: FontWeight.bold))
            ] + displayAttributes.map((attr) =>
                attr.getDisplayable(context, style, mergeMap[attr.name])).toList(),
          )
      );
    }

    return wList;
  }

  @override
  String getName(BuildContext context) {
    return name;
  }

  @override
  List<AttributeType> objectAttributes(RulesStructure rulesStructure, String label) {
    return rulesStructure.attributes.where((attr) => objects.firstWhere((obj) => obj.label == label).attributes.keys.contains(attr.name)).toList();
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
      attributes: json["attributes"] == null ? {} : json["attributes"] as Map<String, dynamic>,
    );
  }
}

class SpecialObjectType implements SortingCategory {
  final String label;
  final Color color;
  final Map<String, dynamic> info;
  final Map<String, dynamic> where;
  final Map<String, dynamic> attributes;

  SpecialObjectType({
    required this.label,
    required this.color,
    required this.info,
    required this.where,
    required this.attributes,
  });

  factory SpecialObjectType.fromJson(Map<String, dynamic> json) {
    return SpecialObjectType(
      label: json["label"] as String,
      color: Color(int.parse(json["color"])),
      info: json["info"] as Map<String, dynamic>,
      where: json["where"] as Map<String, dynamic>,
      attributes: json["attributes"] == null ? {} : json["attributes"] as Map<String, dynamic>,
    );
  }

  @override
  Color getColor() {
    return color;
  }

  @override
  List<Widget> getDisplayable(TextStyle style, BuildContext context, String label) {
    final categorizationProvider = Provider.of<CategorizationProvider>(context, listen: false);

    List<Widget> wList = <Widget>[];
    wList.add(
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[Text(AppLocalizations.of(context)!.recycle_where, style: style.copyWith(fontWeight: FontWeight.bold))] + parseInfo(where, style, 0),
      ),
    );

    wList.add(
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[Text(AppLocalizations.of(context)!.object_info_title, style: style.copyWith(fontWeight: FontWeight.bold)), Text(categorizationProvider.getObjectByLabel(label)!.desc, textAlign: TextAlign.justify, style: style)],
      ),
    );

    Map<String, dynamic> mergeMap = {};
    mergeMap.addAll(attributes);
    mergeMap.addAll(categorizationProvider.objectsList.objects.firstWhere((obj) => obj.label == label).attributes);
    List<AttributeType> displayAttributes = categorizationProvider.objectsList.attributes.where((attr) => mergeMap.keys.contains(attr.name)).toList() + categorizationProvider.rulesStructure.attributes.where((attr) => mergeMap.keys.contains(attr.name)).toList();
    if (displayAttributes.isNotEmpty) {
      wList.add(
          Column(
            children: <Widget>[
              Text(AppLocalizations.of(context)!.attributes_title,
                  style: style.copyWith(fontWeight: FontWeight.bold))
            ] + displayAttributes.map((attr) =>
                attr.getDisplayable(context, style, mergeMap[attr.name])).toList(),
          )
      );
    }

    return wList;
  }

  @override
  String getName(BuildContext context) {
    final categorizationProvider = Provider.of<CategorizationProvider>(context, listen: false);
    return categorizationProvider.objectsList.objects.firstWhere((obj) => obj.label == label).name;
  }

  @override
  List<AttributeType> objectAttributes(RulesStructure rulesStructure, String label) {
    return <AttributeType>[];
  }
}