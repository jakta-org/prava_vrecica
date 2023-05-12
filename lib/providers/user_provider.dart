import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:prava_vrecica/database/database_provider.dart';
import 'package:prava_vrecica/statistics/statistics_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../feedback/detection_entry_queue_provider.dart';

import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  int userId = -2;
  bool wasIntroScreenShown = false;
  StatisticsProvider statisticsProvider;
  DatabaseProvider databaseProvider;
  DetectionEntryQueueProvider detectionEntryQueueProvider;
  late User? user;

  UserProvider(this.userId, this.statisticsProvider, this.databaseProvider, this.detectionEntryQueueProvider) {
    init();
  }

  UserProvider(this.userId, this.statisticsProvider, this.detectionEntryQueueProvider, this.wasIntroScreenShown);
  Future<void> init() async {
    String? userJson = await databaseProvider.getUserInfo(userId);
    print("$userId userJson: " + (userJson ?? 'null'));

    if (userJson != null) {
      user = User.fromJson(jsonDecode(userJson));
    } else {
      user = null;
    }
  }

  Future<void> setUser(int userId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    this.userId = userId;
    sharedPreferences.setInt('user_id', userId);
    await init();

    statisticsProvider.userId = userId;
    detectionEntryQueueProvider.userId = userId;
    detectionEntryQueueProvider.init();

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
}