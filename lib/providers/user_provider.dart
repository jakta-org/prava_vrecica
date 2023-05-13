import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:prava_vrecica/statistics/statistics_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../feedback/detection_entry_queue_provider.dart';

class UserProvider extends ChangeNotifier {
  int userId = -2;
  bool wasIntroScreenShown = false;
  StatisticsProvider statisticsProvider;
  DetectionEntryQueueProvider detectionEntryQueueProvider;

  UserProvider(this.userId, this.statisticsProvider, this.detectionEntryQueueProvider, this.wasIntroScreenShown);

  Future<void> setUser(int userId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    this.userId = userId;
    sharedPreferences.setInt('user_id', userId);

    statisticsProvider.userId = userId;
    statisticsProvider.init();

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

  void clearUser() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    sharedPreferences.clear();

    userId = -2;
    sharedPreferences.setInt('user_id', userId);

    notifyListeners();
  }
}