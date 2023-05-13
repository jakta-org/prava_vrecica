import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
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
  bool started = false;
  Directory appDirectory;

  DetectionEntryQueueProvider(this.userId, this.statisticsProvider, this.appDirectory) {
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
    _path = '${appDirectory.path}/detections_queue_$userId.json';
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
  /*
      final image = base64Encode(newImageFile.readAsBytesSync());
      final fileName = newImageFile.path.split('/').last;
      final objectsData = entry.detectedObjects.map((e) => e.toJson()).toList();

      final response = await http.post(
        Uri.parse('https://karlo13.pythonanywhere.com/feedback/feedback/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token xxxxxxxxxxxxxxxxxxxxxxxx'
        },
        body: jsonEncode({
          'image': image,
          'file_name': fileName,
          'objects_data': objectsData,
          'string': "Test post request"
        }),
      );

      print (response.body);

      if (response.statusCode != 200) {
        throw Exception('Error sending feedback: ${response.body}');
      }
*/
      newImageFile.deleteSync();
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
    for (var object in entry.detectedObjects) {
      if (stats.containsKey(object.label)) {
        stats[object.label]!.recycledCount++;
        stats[object.label]!.recycledCountFromPhoto++;
      } else {
        stats[object.label] = ObjectStats(recycledCount: 1, recycledCountFromPhoto: 1);
      }
    }
    await statisticsProvider.updateStats(stats);
    if (kDebugMode) {
      print('Updated stats: $stats');
    }
  }
}

class DetectionsEntry {
  final String imagePath;
  final DateTime dateTime;
  final List<Recognition> detectedObjects;

  DetectionsEntry(this.imagePath, this.dateTime, this.detectedObjects);

  factory DetectionsEntry.fromJson(Map<String, dynamic> json) {
    return DetectionsEntry(
      json['imagePath'],
      DateTime.parse(json['dateTime']),
      (json['detectedObjects'] as List<dynamic>).map((e) => Recognition.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imagePath': imagePath,
      'dateTime': dateTime.toIso8601String(),
      'detectedObjects': detectedObjects.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return "DetectionsEntry(imagePath: $imagePath, dateTime: $dateTime, detectedObjects: $detectedObjects)";
  }
}