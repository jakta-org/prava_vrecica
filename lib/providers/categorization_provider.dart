import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:prava_vrecica/json_models/object_list_model.dart';
import 'package:prava_vrecica/json_models/rules_structure_model.dart';

class CategorizationProvider extends ChangeNotifier {
  late ObjectList objectsList;
  late RulesStructure rulesStructure;

  CategorizationProvider(objectsSrc, rulesSrc) {
    objectsList = ObjectList.fromJson(json.decode(objectsSrc));
    rulesStructure = RulesStructure.fromJson(json.decode(rulesSrc));
  }

  String getNameByLabel(label) {
    return objectsList.objects.firstWhere((element) => element.label == label).name;
  }

  String getCategoryByLabel(label) {
    for (ObjectCategory objectCategory in rulesStructure.categories) {
      for (CategoryObjectType categoryObjectType in objectCategory.objects) {
        if (categoryObjectType.label == label) {
          return objectCategory.name;
        }
      }
    }
    for (SpecialObjectType specialObjectType in rulesStructure.special) {
      if (specialObjectType.label == label) {
        return "Specijalni otpad";
      }
    }
    return "Potražite dodatne informacije";
  }
}