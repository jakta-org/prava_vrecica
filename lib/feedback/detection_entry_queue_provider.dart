import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:prava_vrecica/database/database_provider.dart';
import 'package:prava_vrecica/providers/ai_model_provider.dart';
import 'package:prava_vrecica/statistics/stats_models.dart';
import 'package:synchronized/synchronized.dart';
import '../statistics/statistics_provider.dart';

class DetectionEntryQueueProvider extends ChangeNotifier {
  late String _path;
  late File _file;
  List<DetectionsEntry> entriesQueue = [];
  final _lock = Lock();
  int userId = -2;
  int initializedUser = -3;
  StatisticsProvider statisticsProvider;
  DatabaseProvider databaseProvider;
  bool started = false;
  Directory appDirectory;

  DetectionEntryQueueProvider(this.userId, this.statisticsProvider, this.databaseProvider, this.appDirectory);

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
    _path = '${(appDirectory).path}/detections_queue_$userId.json';
    _file = File(_path);
    if (_file.existsSync()) {
      final content = _file.readAsStringSync();
      if (content.isNotEmpty) {
        final List<dynamic> jsonEntries = jsonDecode(content);
        for (var jsonEntry in jsonEntries) {
          entriesQueue.add(DetectionsEntry.fromJson(jsonEntry));
        }
      }
    } else {
      _file.createSync();
      _saveToFile();
    }
    initializedUser = userId;
    started = false;
  }

  void enqueue(DetectionsEntry entry) {
    entriesQueue.add(entry);
    _saveToFile();
  }

  DetectionsEntry? getFirst() {
    if (entriesQueue.isEmpty) {
      return null;
    }
    return entriesQueue.first;
  }

  void removeFirst() {
    if (entriesQueue.isEmpty) {
      return;
    }
    entriesQueue.removeAt(0);
    _saveToFile();
  }

  void updateEntryOrAdd(DetectionsEntry entry) {
    final index = entriesQueue.indexWhere((e) => e.imagePath == entry.imagePath);
    if (index != -1) {
      entriesQueue[index] = entry;
      _saveToFile();
    } else {
      enqueue(entry);
    }
  }

  void _saveToFile() {
    if (kDebugMode) {
      print ('Saving queue: $entriesQueue');
    }
    _lock.synchronized(() {
      final jsonEntries = entriesQueue.map((e) => e.toJson()).toList();
      _file.writeAsStringSync(jsonEncode(jsonEntries));
    });
  }

  void clear() {
    entriesQueue.clear();
    _saveToFile();
  }

  void processEntries() async{
    await init();
    while (entriesQueue.isNotEmpty) {
      final entry = getFirst();
      if (entry == null) {
        return;
      }
      await _sendFeedback(entry);
      await _addToStats(entry);
      removeFirst();
    }
  }

  Future<void> _sendFeedback(DetectionsEntry entry) async {
    try {
      File imageFile = File(entry.imagePath);
      String newImagePath = '${appDirectory.path}/feedback_${DateTime.now().millisecondsSinceEpoch}_$userId.jpg';
      imageFile.renameSync(newImagePath);
      File newImageFile = File(newImagePath);

      final image = base64Encode(newImageFile.readAsBytesSync());
      final fileName = newImageFile.path.split('/').last;
      final objectsData = jsonEncode(entry.detectedObjects.map((e) => e.toJson()).toList());

      print("before!");
      bool success = await databaseProvider.sendFeedback(image, fileName, objectsData, null, true);
      print("sent!");

      if (!success) {
        throw Exception('Error sending feedback!');
      } else {
        newImageFile.deleteSync();
      }

    } catch (e) {
      if (kDebugMode) {
        print('Error deleting image file: $e');
      }
    }
    if (kDebugMode) {
      print('Sending feedback for entry: $entry');
    }
    return;
  }

  Future<void> _addToStats(DetectionsEntry entry) async {
    Map<String, ObjectStats> stats = {};
    int score = 0;
    Random random = Random();
    int groupId = entry.groupId;
    for (var object in entry.detectedObjects) {
      score += random.nextInt(10);
      if (stats.containsKey(object.label)) {
        stats[object.label]!.recycledCount++;
        stats[object.label]!.recycledCountFromPhoto++;
      } else {
        stats[object.label] = ObjectStats(recycledCount: 1, recycledCountFromPhoto: 1);
        score += 5;
      }
    }
    await statisticsProvider.updateStats(stats);
    await databaseProvider.updateUserData(userId, jsonEncode(statisticsProvider.objectStatsEntries));
    await databaseProvider.updateGroupScore(userId, groupId, score);
    if (kDebugMode) {
      print('Updated stats: $stats');
    }
  }
}

class DetectionsEntry {
  final String imagePath;
  final DateTime dateTime;
  final List<Recognition> detectedObjects;
  final int groupId;

  DetectionsEntry(this.imagePath, this.dateTime, this.detectedObjects, this.groupId);

  factory DetectionsEntry.fromJson(Map<String, dynamic> json) {
    return DetectionsEntry(
      json['imagePath'],
      DateTime.parse(json['dateTime']),
      (json['detectedObjects'] as List<dynamic>).map((e) => Recognition.fromJson(e)).toList(),
      json['groupId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imagePath': imagePath,
      'dateTime': dateTime.toIso8601String(),
      'detectedObjects': detectedObjects.map((e) => e.toJson()).toList(),
      'groupId': groupId,
    };
  }

  @override
  String toString() {
    return "DetectionsEntry(imagePath: $imagePath, dateTime: $dateTime, detectedObjects: $detectedObjects, groupId: $groupId)";
  }
}