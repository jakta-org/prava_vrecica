import 'package:prava_vrecica/enums.dart';
import '../helping_classes.dart';

class User {
  int id;
  int score;
  AccountType accountType;
  DateTime timeJoined;

  Map<int, ObjectCount> objectCountList;

  int? passwordHash;
  String? username;
  String? mail;

  User(this.id, this.score, this.accountType, this.timeJoined, this.username, this.mail, this.passwordHash, this.objectCountList);

  factory User.fromJson(Map<String, dynamic> json) {
    final objectCountListJson = json['objectCountList'] as Map<String, dynamic>;
    final objectCountList = objectCountListJson.map(
          (key, value) => MapEntry(
        int.parse(key),
        ObjectCount.fromJson(value as Map<String, dynamic>),
      ),
    );

    return User(
      json['id'] as int,
      json['score'] as int,
      AccountType.values[json['accountType'] as int],
      DateTime.parse(json['timeJoined'] as String),
      json['username'] as String?,
      json['mail'] as String?,
      json['passwordHash'] as int?,
      objectCountList,
    );
  }
}