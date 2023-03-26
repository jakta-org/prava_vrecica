import 'package:flutter/cupertino.dart';

import 'object_type_model.dart';

@immutable
class RulesStructure {
  final int id;
  final String name;
  final String? description;

  final List<ObjectCategory> categories;


  const RulesStructure(this.id, this.name, this.description, this.categories);
}

class ObjectCategory {
  final String name;
  final String? description;

  final List<ObjectType> objectTypes;

  ObjectCategory(this.name, this.description, this.objectTypes);
}