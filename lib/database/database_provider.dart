import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseProvider extends ChangeNotifier {
  final String root = "karlo13.pythonanywhere.com";
  late String token;

  DatabaseProvider(this.token);

  Future<void> setToken(token) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('token', token);
    this.token = token;
  }

  Future<int?> authenticateUser(String? username, String? email, String hash) async {
    var url = Uri.https(root, "accounts/token/");
    Response response;
    if (username == null && email == null) {
      return null;
    } else if (email == null) {
      response = await post(url, body: {'username': username, 'password': hash});
    } else {
      response = await post(url, body: {'email': email, 'password': hash});
    }
    if (response.statusCode == 200) {
      setToken(jsonDecode(response.body)["token"]);
      return jsonDecode(response.body)["user"]["id"];
    } else {
      return null;
    }
  }

  Future<bool> createUser(String email, String hash, String? username, String? entranceCode) async {
    var url = Uri.https(root, "accounts/user/");
    Response response;
    if (username == null && entranceCode == null) {
      response = await post(url, body: {'email': email, 'password': hash});
    } else if (username == null) {
      response = await post(url, body: {'email': email, 'password': hash, 'entranceCode': entranceCode});
    } else if (entranceCode == null) {
      response = await post(url, body: {'email': email, 'password': hash, 'username': username});
    } else {
      response = await post(url, body: {'email': email, 'password': hash, 'username': username, 'entranceCode': entranceCode});
    }

    if (response.statusCode == 201) {
      token = jsonDecode(response.body)["token"];
      return true;
    } else {
      return false;
    }
  }
  Future<String?> getUserInfo(userId) async {
    var url = Uri.https(root, "accounts/user/$userId/");
    Response response;
    response = await get(url, headers: {'Authorization': 'Token $token'});

    print(token);
    print(response.body);

    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  }

  Future<String?> getUserData(userId) async {
    var url = Uri.https(root, "accounts/user/$userId/meta-data/");
    Response response;
    response = await get(url, headers: {'Authorization': 'Token $token'});

    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  }

  Future<bool> updateUserData(userId, String data) async {
    var url = Uri.https(root, "accounts/user/$userId/meta-data");
    Response response;
    response = await post(url, headers: {'Authorization': 'Token $token'}, body: {'meta_data': data});

    print(response.body);

    return response.statusCode == 200;
  }

  Future<bool> sendFeedback(String image, String fileName, String objectsData, String? message, bool isTrusted) async {
    var url = Uri.https(root, "feedback/feedback/");
    Response response;

    print("create response");
    response = await post(
        url,
        headers: {'Authorization': 'Token $token'},
        body: {
          'image': image,
          'file_name': fileName,
          'objects_data': objectsData,
          'message': message ?? '',
          'is_trusted': isTrusted.toString(),
        },
    );

    print(response.statusCode);
    print(response.body);

    return (response.statusCode == 200);
  }
}