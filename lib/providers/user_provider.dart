import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  int _userId = -1;
  int get userId {
    return _userId;
  }

  UserProvider(int userId) {
    _userId = userId;
  }

  Future<void> setUser(int userId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    _userId = userId;
    sharedPreferences.setInt('user_id', userId);

    notifyListeners();
  }

  void clearUser() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    _userId = -1;
    sharedPreferences.setInt('user_id', -1);

    notifyListeners();
  }
}