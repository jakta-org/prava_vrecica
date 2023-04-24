import 'package:prava_vrecica/json_models/rules_structure_model.dart';
import '../helping_classes.dart';
import '../json_models/object_list_model.dart';
import '../models/user_model.dart';

abstract class DatabaseInterface {
  int getNewUserId();

  User? getUserById(int id);
  int authenticateUser(String mail, int passwordHash);

  bool updateUserInfo(int id, User user);
  bool updateUserStats(int id, Map<int, ObjectCount> objectCountList);

  List<ObjectType> getObjectTypes();

  List<RulesStructure> getRulesStructures();
}