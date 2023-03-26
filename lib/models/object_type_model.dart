import 'package:flutter/cupertino.dart';

@immutable
class ObjectType {
  final int id;
  final String name;
  final String? description;
  final Icon? icon;

  const ObjectType(this.id, this.name, this.description, this.icon);
}