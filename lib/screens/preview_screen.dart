import 'dart:io';
import 'package:flutter/material.dart';
import 'package:prava_vrecica/providers/ai_model_provider.dart';
import 'package:prava_vrecica/providers/categorization_provider.dart';
import 'package:prava_vrecica/widgets/preview_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../feedback/detection_entry_queue_provider.dart';
import '../widgets/recognition_widget.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key, required this.imagePath, required this.recognitions, required this.factor, required this.dateTime}) : super();

  final String imagePath;
  final List<Recognition> recognitions;
  final double factor;
  final DateTime dateTime;

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  int selected = 0;
  double iconSize = 50;
  double h = 50;
  late DetectionEntryQueueProvider detectionEntryQueueProvider;

  @override
  Widget build(BuildContext context) {
    final categorizationProvider = Provider.of<CategorizationProvider>(context, listen: false);
    detectionEntryQueueProvider = Provider.of<DetectionEntryQueueProvider>(context, listen: false);
    updateDetectionQueue();

    return Scaffold(
      bottomSheet: PreviewSheet(context, widget.recognitions[selected], refreshState),
      body: Stack(
        children: <Widget>[
          Image.file(File(widget.imagePath)),
          boundingBoxes(widget.recognitions, widget.factor, selected),
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.chevron_left),
              color: Theme.of(context).colorScheme.surfaceVariant,
              onPressed: () {
                changeSelected((selected - 1) % widget.recognitions.length);
              },
              iconSize: iconSize,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.chevron_right),
              color: Theme.of(context).colorScheme.surfaceVariant,
              onPressed: () {
                changeSelected((selected + 1) % widget.recognitions.length);
              },
              iconSize: iconSize,
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsetsDirectional.only(top: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.recognitions
                    .map((recognition) => GestureDetector(
                          onTap: () {
                            changeSelected(widget.recognitions.indexOf(recognition));
                          },
                          child: AnimatedContainer(
                            width: 15,
                            height: 15,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.recognitions.indexOf(recognition) ==
                                      selected
                                  ? categorizationProvider.getCategoryByLabel(recognition.label)!.getColor()
                                  : Theme.of(context).colorScheme.surfaceTint,
                              border: recognition.valid ? (recognition.label == recognition.recognizedLabel ? Border.all(color: Theme.of(context).colorScheme.primary) : Border.all(color: Colors.red)) : Border.all(color: Theme.of(context).colorScheme.surfaceVariant),
                            ),
                            duration: const Duration(milliseconds: 300),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void changeSelected(int index) {
    setState(() {
      selected = index;
    });
  }

  void refreshState() {
    setState(() {});
  }

  Widget boundingBoxes(
      List<Recognition> recognitions, num factor, int selected) {
    return Stack(
      children: recognitions
          .map((recognition) => RecognitionWidget(
                recognition: recognition,
                factor: factor,
                selected: recognition == recognitions[selected],
              ))
          .toList(),
    );
  }

  void updateDetectionQueue (){
    final validRecognitions = widget.recognitions.where((recognition) => recognition.valid).toList();
    final updatedEntry = DetectionsEntry(widget.imagePath, widget.dateTime, validRecognitions);
    detectionEntryQueueProvider.updateEntryOrAdd(updatedEntry);
  }

  @override
  void dispose() {
    detectionEntryQueueProvider.processEntries();
    super.dispose();
  }
}
