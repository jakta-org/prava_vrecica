import 'dart:io';
import 'package:flutter/material.dart';
import 'package:prava_vrecica/ai/ai_model_provider.dart';
import 'package:prava_vrecica/ai/categorization_provider.dart';
import 'package:prava_vrecica/user/user_provider.dart';
import 'package:prava_vrecica/ai/preview_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../feedback/detection_entry_queue_provider.dart';
import '../widget_handling/modular_widgets.dart';
import 'recognition_widget.dart';
import 'package:pdf/widgets.dart' as pw;


class PreviewScreen extends StatefulWidget {
  const PreviewScreen(
      {super.key,
      required this.imagePath,
      required this.recognitions,
      required this.factor,
      required this.dateTime})
      : super();

  final String imagePath;
  final List<Recognition> recognitions;
  final double factor;
  final DateTime dateTime;

  @override
  State<PreviewScreen> createState() => PreviewScreenState();
}

class PreviewScreenState extends State<PreviewScreen> {
  int selected = 0;
  double iconSize = 50;
  double h = 50;
  late Widget generateTicket;

  late DetectionEntryQueueProvider detectionEntryQueueProvider;
  late UserProvider userProvider;
  late pw.MemoryImage memoryImage;

  @override
  Widget build(BuildContext context) {
    final categorizationProvider =
        Provider.of<CategorizationProvider>(context, listen: false);
    detectionEntryQueueProvider =
        Provider.of<DetectionEntryQueueProvider>(context, listen: false);
    userProvider = Provider.of<UserProvider>(context, listen: true);
    generateTicket = userProvider.setGroup.settings.widgets.contains("generate_ticket") ? ModularWidgets.miscWidgets["generate_ticket"]!(this) : Container();
    updateDetectionQueue();
    final imageFile = File(widget.imagePath);
    memoryImage = pw.MemoryImage(imageFile.readAsBytesSync());

    return Scaffold(
      bottomSheet:
          PreviewSheet(context, widget.recognitions[selected], refreshState),
      body: Stack(
        children: <Widget>[
          Image.file(imageFile),
          boundingBoxes(widget.recognitions, widget.factor, selected),
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_circle_left_outlined),
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
              icon: const Icon(Icons.arrow_circle_right_outlined),
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
                            changeSelected(
                                widget.recognitions.indexOf(recognition));
                          },
                          child: AnimatedContainer(
                            width: 15,
                            height: 15,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.recognitions.indexOf(recognition) ==
                                      selected
                                  ? categorizationProvider
                                      .getCategoryByLabel(recognition.label)!
                                      .getColor()
                                  : Theme.of(context).colorScheme.surfaceTint,
                              border: recognition.valid
                                  ? (recognition.label ==
                                          recognition.recognizedLabel
                                      ? Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary)
                                      : Border.all(color: Colors.red))
                                  : Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceVariant),
                            ),
                            duration: const Duration(milliseconds: 300),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              margin: const EdgeInsetsDirectional.only(bottom: 150),
              child: IconButton(
                icon: const Icon(Icons.check_circle_outline),
                color: Theme.of(context).colorScheme.surfaceVariant,
                onPressed: () {
                  widget.recognitions[selected].valid = true;
                  changeSelected((selected + 1) % widget.recognitions.length);
                },
                iconSize: iconSize,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: generateTicket,
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
    int index = -1;
    return Stack(
      children: recognitions.map((recognition) {
        index++;
        return RecognitionWidget(
          recognition: recognition,
          factor: factor,
          selected: recognition == recognitions[selected],
          index: index,
          func: changeSelected,
        );
      }).toList(),
    );
  }

  void updateDetectionQueue() {
    final validRecognitions =
        widget.recognitions.where((recognition) => recognition.valid).toList();
    final updatedEntry =
        DetectionsEntry(widget.imagePath, widget.dateTime, validRecognitions, userProvider.setGroup.id);
    detectionEntryQueueProvider.updateEntryOrAdd(updatedEntry);
  }

  @override
  void dispose() {
    detectionEntryQueueProvider.processEntries();
    super.dispose();
  }
}
