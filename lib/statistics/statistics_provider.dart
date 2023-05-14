import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prava_vrecica/database/database_provider.dart';
import 'package:prava_vrecica/providers/categorization_provider.dart';
import 'stats_models.dart';

class StatisticsProvider extends ChangeNotifier {
  CategorizationProvider categorizationProvider;
  DatabaseProvider databaseProvider;
  int userId = -2;
  int initializedUser = -3;
  Directory appDirectory;

  late File userStatsFile;
  late List<ObjectStatsWithTime> objectStatsEntries;
  late Map<String, ObjectStats> allTimeObjectStats;
  late List<CategoryStats> allTimeCategoriesStats;

  StatisticsProvider(this.userId, this.categorizationProvider, this.databaseProvider, this.appDirectory);

  Future<void> init() async {
    if (initializedUser == userId) {
      return;
    }
    userStatsFile = File('${appDirectory.path}/stats_$userId.json');
    final fileExists = await userStatsFile.exists();
    if (!fileExists) {
      await userStatsFile.create();
      if (userId < 0) {
        await userStatsFile.writeAsString(jsonEncode([]));
      } else {
        await userStatsFile.writeAsString(await databaseProvider.getUserData(userId) ?? jsonEncode([]));
      }
    }
    print("awaiting");
    objectStatsEntries = await getStatsFromFile();
    print("awaited");
    calculateAllTimeObjectStats();
    calculateAllTimeCategoriesStats();
    initializedUser = userId;
  }

  Future<bool> appropriateFile(int userId) async {
    final directory = await getApplicationDocumentsDirectory();
    userStatsFile = File('${directory.path}/stats_-1.json');
    final fileExists = await userStatsFile.exists();
    if (fileExists) {
      userStatsFile = await userStatsFile.rename('${directory.path}/stats_$userId.json');
    }
    this.userId = userId;
    return true;
  }

  Future<List<ObjectStatsWithTime>> getStatsFromFile() async {
    print("gsff");
    final stats = await userStatsFile.readAsString();
    print("gsff: " + stats.toString());
    if (stats == '') {
      return [];
    }
    return (jsonDecode(stats) as List<dynamic>).map((e) => ObjectStatsWithTime.fromJson(e)).toList();
  }

  Map<String, ObjectStats> getFilteredObjectStats({Function? entryFilter, Function? objectFilter}) {
    final filteredStats = <String, ObjectStats>{};
    for (var entry in objectStatsEntries) {
      if (entryFilter != null && !entryFilter(entry)) {
        continue;
      }
      for (var object in entry.stats.entries) {
        if (objectFilter != null && objectFilter(object)) {
          continue;
        }
        if (filteredStats.containsKey(object.key)) {
          filteredStats[object.key]!.recycledCount += object.value.recycledCount;
          filteredStats[object.key]!.recycledCountFromPhoto += object.value.recycledCountFromPhoto;
        } else {
          filteredStats[object.key] = object.value;
        }
      }
    }
    return filteredStats;
  }

  List<CategoryStats> getFilteredCategoryStats({Function? entryFilter, Function? objectFilter, Function? categoryFilter}) {
    var filteredStats = <CategoryStats>[];
    var objectStats = <String, ObjectStats>{};
    if (entryFilter != null || objectFilter != null) {
      objectStats = getFilteredObjectStats(entryFilter: entryFilter, objectFilter: objectFilter);
    } else {
      objectStats = allTimeObjectStats;
    }
    filteredStats = allTimeCategoriesStats;
    for (var category in filteredStats) {
      category.recycledCount = 0;
      category.recycledCountFromPhoto = 0;
    }
    for (var object in objectStats.entries) {
      final category = getCategoryName(object.key);
      if (category != null) {
        final categoryStats = allTimeCategoriesStats.firstWhere((element) => element.categoryName == category);
        categoryStats.recycledCount += object.value.recycledCount;
        categoryStats.recycledCountFromPhoto += object.value.recycledCountFromPhoto;
      }
    }
    if (categoryFilter != null) {
      filteredStats = filteredStats.where((element) => categoryFilter(element)).toList();
    }
    return filteredStats;
  }

  Future<void> updateStats(Map<String, ObjectStats> additionalStats) async {
    print('Updating stats with $additionalStats');
    await init();
    final statsEntry = ObjectStatsWithTime(time: DateTime.now(), stats: additionalStats);
    objectStatsEntries.add(statsEntry);
    for (var object in additionalStats.entries) {
      if (allTimeObjectStats.containsKey(object.key)) {
        allTimeObjectStats[object.key]!.recycledCount += object.value.recycledCount;
        allTimeObjectStats[object.key]!.recycledCountFromPhoto += object.value.recycledCountFromPhoto;
      } else {
        allTimeObjectStats[object.key] = object.value;
      }
      final category = getCategoryName(object.key);
      if (category != null) {
        final categoryStats = allTimeCategoriesStats.firstWhere((element) => element.categoryName == category);
        categoryStats.recycledCount += object.value.recycledCount;
        categoryStats.recycledCountFromPhoto += object.value.recycledCountFromPhoto;
      }
    }
    saveStatsToFile();
  }

  Future<void> saveStatsToFile() async {
    await userStatsFile.writeAsString(jsonEncode(objectStatsEntries));
    notifyListeners();
  }

  Future<void> clearStats() async {
    try {
      await userStatsFile.writeAsString(jsonEncode([]));
    } catch (e) {
      print(e);
    }
    objectStatsEntries = [];
    calculateAllTimeObjectStats();
    calculateAllTimeCategoriesStats();
    notifyListeners();
  }

  void calculateAllTimeObjectStats() {
    allTimeObjectStats = {};
    for (var object in categorizationProvider.objectsList.objects) {
      allTimeObjectStats[object.label] = ObjectStats(
        recycledCount: 0,
        recycledCountFromPhoto: 0,
      );
    }
    for (var entry in objectStatsEntries) {
      for (var object in entry.stats.entries) {
        if (allTimeObjectStats.containsKey(object.key)) {
          allTimeObjectStats[object.key]!.recycledCount += object.value.recycledCount;
          allTimeObjectStats[object.key]!.recycledCountFromPhoto += object.value.recycledCountFromPhoto;
        } else {
          allTimeObjectStats[object.key] = object.value;
        }
      }
    }
  }

  void calculateAllTimeCategoriesStats() {
    allTimeCategoriesStats = [];
    for (var category in categorizationProvider.rulesStructure.categories) {
      var categoryStats = CategoryStats(
        categoryName: category.name,
        recycledCount: 0,
        recycledCountFromPhoto: 0,
        categoryColor: category.color,
      );
      for (var object in category.objects) {
        if (allTimeObjectStats.containsKey(object.label)) {
          categoryStats.recycledCount += allTimeObjectStats[object.label]!.recycledCount;
          categoryStats.recycledCountFromPhoto += allTimeObjectStats[object.label]!.recycledCountFromPhoto;
        }
      }
      allTimeCategoriesStats.add(categoryStats);
    }
    for (var specialCategory in categorizationProvider.rulesStructure.special) {
      var categoryStats = CategoryStats(
        categoryName: specialCategory.label,
        recycledCount: allTimeObjectStats.containsKey(specialCategory.label)
            ? allTimeObjectStats[specialCategory.label]!.recycledCount : 0,
        recycledCountFromPhoto: allTimeObjectStats.containsKey(specialCategory.label)
            ? allTimeObjectStats[specialCategory.label]!.recycledCountFromPhoto : 0,
        categoryColor: specialCategory.color,
      );
      allTimeCategoriesStats.add(categoryStats);
    }
  }

  String? getCategoryName(String objectName) {
    for (var category in categorizationProvider.rulesStructure.categories) {
      for (var object in category.objects) {
        if (object.label == objectName) {
          return category.name;
        }
      }
    }
    for (var specialCategory in categorizationProvider.rulesStructure.special) {
      if (specialCategory.label == objectName) {
        return specialCategory.label;
      }
    }
    return null;
  }
}