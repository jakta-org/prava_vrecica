import 'dart:convert';
import 'package:flutter/material.dart';

class Group {
  int id;
  String type;
  GroupSettings settings;
  String data;

  Group(this.id, this.type, this.settings, this.data);

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      json['id'] as int,
      json['type'] as String,
      GroupSettings.fromJson(json['settings'] as Map<String, dynamic>),
      jsonEncode(json['meta_data']),
    );
  }

  factory Group.personal() {
    return Group(-1, "personal", GroupSettings.personal(), "{}");
  }

  @override
  bool operator ==(Object other) {
    return other is Group && id == other.id;
  }

  @override
  int get hashCode => Object.hash(id, type, settings, data);

}

class GroupSettings {
  String name;
  String info;
  IconData iconData;
  Color iconColor;
  List<String> widgets;

  GroupSettings(this.name, this.info, this.iconData, this.iconColor, this.widgets);

  factory GroupSettings.fromJson(Map<String, dynamic> json) {

    return GroupSettings(
        json['name'] as String,
        json['info'] as String,
        IconData(json['icon_data'] as int, fontFamily: 'MaterialIcons'),
        Color(int.parse(json["icon_color"])),
        (json['widgets'] as List).map((s) => s as String).toList(),
    );
  }

  factory GroupSettings.personal() {
    return GroupSettings("", "", const IconData(58094, fontFamily: 'MaterialIcons'), Colors.blue, [
      "statistics_chart", "manual_add_statistics", "author_info", "objects_overview",
    ]);
  }
}