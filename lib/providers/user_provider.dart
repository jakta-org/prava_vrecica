import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  User? get user {
    return _user;
  }

  UserProvider(User? user) {
    _user = user;
  }

  Future<void> setUser(User user) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    _user = user;
    sharedPreferences.setString('user', jsonEncode(user));
    notifyListeners();

    if (kDebugMode) {
      print("User set called!");
    }
  }

  void clearUser(BuildContext context) {
    _user = null;
    notifyListeners();

    Navigator.pushNamed(
      context,
      'Account',
    );
  }
}