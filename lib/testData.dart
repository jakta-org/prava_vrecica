import 'package:flutter/cupertino.dart';
import 'package:prava_vrecica/helping_classes.dart';
import 'package:prava_vrecica/interfaces/database_interface.dart';
import 'package:prava_vrecica/json_models/rules_structure_model.dart';
import 'package:prava_vrecica/models/user_model.dart';

import 'json_models/object_list_model.dart';

class Database implements DatabaseInterface {
  List<ObjectType> objectTypes;

  List<User> usersTable;

  List<RulesStructure> rulesStructures;

  Database(this.objectTypes, this.usersTable, this.rulesStructures);

  @override
  int authenticateUser(String mail, int passwordHash) {
    for (User dbUser in usersTable) {
      if (dbUser.mail == mail && dbUser.passwordHash == passwordHash) {
        return dbUser.id;
      }
    }
    return -1;
  }

  @override
  int getNewUserId() {
    return usersTable.length + 1;
  }

  @override
  User? getUserById(int id) {
    for (User dbUser in usersTable) {
      if (dbUser.id == id) {
        return dbUser;
      }
    }
    return null;
  }

  @override
  bool updateUserInfo(int id, User user) {
    for (User dbUser in usersTable) {
      if (dbUser.id == id) {
        dbUser = user;
        return true;
      }
    }
    return false;
  }

  @override
  bool updateUserStats(int id, Map<int, ObjectCount> objectCountlist) {
    for (User dbUser in usersTable) {
      if (dbUser.id == id) {
        dbUser.objectCountList = objectCountlist;
        return true;
      }
    }
    throw UnimplementedError();
  }

  @override
  List<ObjectType> getObjectTypes() {
    return objectTypes;
  }

  @override
  List<RulesStructure> getRulesStructures() {
    return rulesStructures;
  }

  static Database testDb = Database(
    [TestObjectTypes().plasticnaBoca],
    [
      //User(0, 123, AccountType.guest, DateTime(2022, 11, 3), null, null, null, {TestObjectTypes().plasticnaBoca.label : ObjectCount(10, 3)}),
      //User(1, 1066, AccountType.personal, DateTime(2023, 1, 1), null, null, null, {TestObjectTypes().plasticnaBoca.label : ObjectCount(5, 1)}),
      //User(1, 1066, AccountType.personal, DateTime(2024, 1, 1), 'a', 'a', '1'.hashCode, {TestObjectTypes().plasticnaBoca.label : ObjectCount(5, 1)}),
    ],
    [
      //RulesStructure(0, "Grad Zagreb", "Pravila reciklaže u gradu Zagrebu", [ObjectCategory("Plastika", "Plastični otpad", [TestObjectTypes().plasticnaBoca])])
    ],
  );
}

@immutable
class TestObjectTypes {
  final ObjectType plasticnaBoca = ObjectType(label: "plasticna boca", name: "Plastična boca", desc: "Obična plastična boca", attributes: <String, dynamic>{});
}



