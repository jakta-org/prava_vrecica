import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:prava_vrecica/statistics/statistics_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  int userId = -2;
  StatisticsProvider statisticsProvider;

  UserProvider(this.userId, this.statisticsProvider);

  Future<void> setUser(int userId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    this.userId = userId;
    sharedPreferences.setInt('user_id', userId);

    statisticsProvider.userId = userId;
    statisticsProvider.init();

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