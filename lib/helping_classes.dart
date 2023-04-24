import 'package:flutter/cupertino.dart';

class ObjectCount {
  late int totalCount;
  late int validCount;

  int get notValidCount => totalCount - validCount;

  ObjectCount(this.totalCount, this.validCount);

  factory ObjectCount.fromJson(Map<String, dynamic> json) {
    return ObjectCount(
      json['totalCount'] as int,
      json['validCount'] as int,
    );
  }
}

List<Widget> parseInfo(Map<String, dynamic> info, TextStyle style, int lvl) {
  Map<String, dynamic> currentSettings = info["settings"];
  bool showKey = currentSettings["showKey"] as bool;
  String prefix = currentSettings["prefix"];
  String separator = currentSettings["separator"];

  List<Widget> wList = <Widget>[];

  for (String key in info.keys) {
    if (key != "settings" && key != "data" && key != "final") {
      Map<String, dynamic> levelElement = info[key];
      bool finalEl = levelElement["final"] as bool;
      if (finalEl == true) {
        String displayText = showKey == true ? key + separator + levelElement["data"] : levelElement["data"] as String;
        displayText = prefix*lvl + displayText;
        wList.add(Text(
          displayText,
          style: style,
          textAlign: TextAlign.start,
        ));
      } else {
        String displayText = showKey == true ? key + separator + levelElement["data"] : levelElement["data"] as String;
        displayText = prefix*lvl + displayText;
        wList.add(
            Container(
              padding: const EdgeInsetsDirectional.symmetric(vertical: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[Text(displayText, style: style, textAlign: TextAlign.start)] + parseInfo(info[key], style, lvl+1),
            ),
        ));
      }
    }
  }

  return wList;
}