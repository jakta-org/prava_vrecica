import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:prava_vrecica/json_models/object_list_model.dart';
import 'package:prava_vrecica/json_models/rules_structure_model.dart';

class CategorizationProvider extends ChangeNotifier {
  late Map<String, ObjectList> objectsLists;
  late ObjectList objectsList;
  late RulesStructure rulesStructure;

  CategorizationProvider(objectsListsSrc, rulesSrc, locale) {
    objectsLists = {};
    for (String objectsListJson in objectsListsSrc) {
      ObjectList cObjectList = ObjectList.fromJson(json.decode(objectsListJson));
      objectsLists[cObjectList.language] = cObjectList;
    }
    objectsList = objectsLists[locale]!;
    rulesStructure = RulesStructure.fromJson(json.decode(rulesSrc));
  }

  void setObjectsList(locale) {
    objectsList = objectsLists[locale]!;
  }

  SortingCategory? getCategoryByLabel(label) {
    for (ObjectCategory objectCategory in rulesStructure.categories) {
      for (CategoryObjectType categoryObjectType in objectCategory.objects) {
        if (categoryObjectType.label == label) {
          return objectCategory;
        }
      }
    }
    for (SpecialObjectType specialObjectType in rulesStructure.special) {
      if (specialObjectType.label == label) {
        return specialObjectType;
      }
    }
    return null;
  }

  ObjectType? getObjectByLabel(String label) {
    return objectsList.objects.firstWhere((element) => element.label == label);
  }
}