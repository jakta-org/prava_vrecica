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
      print("da");
      response = await post(url, body: {'email': email, 'password': hash, 'entrance_code': entranceCode});
    } else if (entranceCode == null) {
      response = await post(url, body: {'email': email, 'password': hash, 'username': username});
    } else {
      response = await post(url, body: {'email': email, 'password': hash, 'username': username, 'entrance_code': entranceCode});
    }
    print(entranceCode);
    print(jsonDecode(response.body));

    if (response.statusCode == 201) {
      print("${jsonDecode(response.body)["token"]} $hash");
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
      return utf8.decode(response.bodyBytes);
    } else {
      return null;
    }
  }

  Future<String?> getUserData(userId) async {
    var url = Uri.https(root, "accounts/user/$userId/meta_data/");
    Response response;
    response = await get(url, headers: {'Authorization': 'Token $token'});

    print(response.body.toString());

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['meta_data'];
    } else {
      return null;
    }
  }

  Future<bool> updateUserData(userId, String data) async {
    var url = Uri.https(root, "accounts/user/$userId/meta_data/");
    Response response;
    response = await post(url, headers: {'Authorization': 'Token $token'}, body: {'meta_data': data});

    print(data);
    print("update user data!");
    print(response.body);

    return response.statusCode == 200;
  }

  Future<bool> sendFeedback(String image, String fileName, String objectsData, String? message, bool isTrusted) async {
    var url = Uri.https(root, "feedback/feedback/");
    Response response;

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
    print("feedback: ${response.statusCode}");

    return (response.statusCode == 200);
  }

  Future<String?> getUserGroups(userId) async {
    var url = Uri.https(root, "accounts/user/$userId/group/");
    Response response;

    response = await get(url, headers: {'Authorization': 'Token $token'});

    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  }

  Future<String?> getGroupData(groupId) async {
    var url = Uri.https(root, "accounts/group/$groupId/");
    Response response;

    response = await get(url, headers: {'Authorization': 'Token $token'});

    if (response.statusCode == 200) {
      return utf8.decode(response.bodyBytes);
    } else {
      return null;
    }
  }

  Future<String?> getGroupUsers(groupId) async {
    var url = Uri.https(root, "accounts/group/$groupId/user/");
    Response response;

    response = await get(url, headers: {'Authorization': 'Token $token'});

    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  }

  Future<int?> createGroup(String type, String? settings, String? metaData) async {
    var url = Uri.https(root, "accounts/group/");
    Response response;

    response = await post(url, headers: {'Authorization': 'Token $token'}, body: {'type': type, 'settings': settings, 'meta_data': metaData});

    if (response.statusCode == 200) {
      return int.parse(jsonDecode(response.body)['group_id']);
    } else {
      return null;
    }
  }

  Future<void> updateGroupScore(userId, groupId, score) async {
    var url = Uri.https(root, "accounts/group/$groupId/user/$userId/");
    Response response;

    response = await patch(url, headers: {'Authorization': 'Token $token'}, body: {'score': score.toString()});

    if (response.statusCode == 200) {
      return;
    } else {
      return;
    }
  }

  Future<bool> updateGroupData(groupId, String type, String? settings, String? metaData) async {
    var url = Uri.https(root, "accounts/group/$groupId/");
    Response response;

    response = await put(url, headers: {'Authorization': 'Token $token'}, body: {'type': type, 'settings': settings, 'meta_data': metaData});

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}