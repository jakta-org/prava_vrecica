import 'package:flutter/cupertino.dart';
import 'package:prava_vrecica/interfaces/database_interface.dart';
import 'package:prava_vrecica/testData.dart';

class DatabaseProvider extends ChangeNotifier {
  late final DatabaseInterface _database = Database.testDb;

  DatabaseInterface get database {
    if (_database == null) return Database.testDb;
    return _database;
  }

  DatabaseInterface _initDatabase() {
    return Database.testDb;
  }
}