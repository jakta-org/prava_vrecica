import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prava_vrecica/providers/categorization_provider.dart';

import 'stats_models.dart';

class StatisticsProvider extends ChangeNotifier {
  CategorizationProvider categorizationProvider;
  int userId = -2;
  int initializedUser = -3;
  bool started = false;

  late File userStatsFile;
  late List<ObjectStatsWithTime> objectStatsEntries;
  late Map<String, ObjectStats> allTimeObjectStats;
  late List<CategoryStats> allTimeCategoriesStats;

  StatisticsProvider(this.userId, this.categorizationProvider) {
    init();
  }

  Future<void> init() async {
    if (initializedUser == userId) {
      return;
    }
    if (started) {
      while (initializedUser != userId) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return;
    }
    started = true;
    final directory = await getApplicationDocumentsDirectory();
    userStatsFile = File('${directory.path}/stats_$userId.json');
    final fileExists = await userStatsFile.exists();
    if (!fileExists) {
      await userStatsFile.create();
      await userStatsFile.writeAsString(jsonEncode([]));
    }
    objectStatsEntries = await getStatsFromFile();
    calculateAllTimeObjectStats();
    calculateAllTimeCategoriesStats();
    initializedUser = userId;
    started = false;
  }

  Future<List<ObjectStatsWithTime>> getStatsFromFile() async {
    final stats = await userStatsFile.readAsString();
    if (stats == '') {
      return [];
    }
    return (jsonDecode(stats) as List<dynamic>).map((e) => ObjectStatsWithTime.fromJson(e)).toList();
  }

  Map<String, ObjectStats> getFilteredObjectStats({Function? entryFilter, Function? objectFilter}) {
    final filteredStats = <String, ObjectStats>{};
    for (var entry in objectStatsEntries) {
      if (entryFilter != null && entryFilter(entry)) {
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