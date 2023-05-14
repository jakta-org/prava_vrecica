import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:prava_vrecica/database/database_provider.dart';
import 'package:prava_vrecica/statistics/statistics_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../feedback/detection_entry_queue_provider.dart';
import '../models/group_model.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  int userId = -2;
  bool wasIntroScreenShown = false;
  StatisticsProvider statisticsProvider;
  DatabaseProvider databaseProvider;
  DetectionEntryQueueProvider detectionEntryQueueProvider;
  late User? user;
  late List<Group> groups;
  Group setGroup = Group.personal();

  UserProvider(this.userId, this.statisticsProvider, this.databaseProvider, this.detectionEntryQueueProvider, this.wasIntroScreenShown);
  
  Future<void> init() async {
    groups = [];
    if (userId < 0) {
      user = null;
      return;
    }

    String? userJson = await databaseProvider.getUserInfo(userId);
    print("$userId userJson: ${userJson ?? 'null'}");

    if (userJson != null) {
      user = User.fromJson(jsonDecode(userJson));
    } else {
      user = null;
    }

    String? groupsIdJson = await databaseProvider.getUserGroups(userId);
    if (groupsIdJson == null) {
      groups = [];
    } else {
      List<int> groupsIdList = (jsonDecode(groupsIdJson) as List<dynamic>).map((e) => e['id'] as int).toList();
      for (int groupId in groupsIdList) {
        String? newGroupJson = await databaseProvider.getGroupData(groupId);

        if (newGroupJson != null) {
          Group newGroup = Group.fromJson(jsonDecode(newGroupJson));
          groups.add(newGroup);
        }

        print(newGroupJson);
      }
    }
  }

  Future<void> setUser(int userId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    this.userId = userId;
    sharedPreferences.setInt('user_id', userId);

    statisticsProvider.userId = userId;
    detectionEntryQueueProvider.userId = userId;

    notifyListeners();
  }

  Future<void> setWasIntroScreenShown(bool wasIntroScreenShown) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    this.wasIntroScreenShown = wasIntroScreenShown;
    sharedPreferences.setBool('was_intro_screen_shown', wasIntroScreenShown);

    notifyListeners();
  }

  Future<void> clearUser() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    int? saveInitializedUser = sharedPreferences.getInt('user_init');
    sharedPreferences.clear();

    userId = -2;
    sharedPreferences.setInt('user_id', userId);
    if (saveInitializedUser != null) sharedPreferences.setInt('user_init', saveInitializedUser);


    notifyListeners();
  }

  void setNewGroup(Group newGroup) {
    if(newGroup == setGroup) {
      return;
    }

    setGroup = newGroup;

    notifyListeners();
  }
}