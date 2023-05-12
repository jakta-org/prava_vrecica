import 'dart:io';
import 'package:flutter/material.dart';
import 'package:prava_vrecica/documents/document_model.dart';
import 'package:prava_vrecica/documents/document_preview_screen.dart';
import 'package:prava_vrecica/documents/document_provider.dart';
import 'package:prava_vrecica/providers/ai_model_provider.dart';
import 'package:prava_vrecica/providers/categorization_provider.dart';
import 'package:prava_vrecica/widgets/preview_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../feedback/detection_entry_queue_provider.dart';
import '../widgets/recognition_widget.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  int selected = 0;
  double iconSize = 50;
  double h = 50;
  //TODO: this value should be set using the group's settings
  bool canGenerateTicket = true;
  late DetectionEntryQueueProvider detectionEntryQueueProvider;
  late DocumentProvider documentProvider;
  late AppLocalizations localizations;
  late pw.MemoryImage memoryImage;

  @override
  Widget build(BuildContext context) {
    final categorizationProvider = Provider.of<CategorizationProvider>(context, listen: false);
    detectionEntryQueueProvider = Provider.of<DetectionEntryQueueProvider>(context, listen: false);
    documentProvider = Provider.of<DocumentProvider>(context, listen: false);
    localizations = AppLocalizations.of(context)!;
    final categorizationProvider =
        Provider.of<CategorizationProvider>(context, listen: false);
    detectionEntryQueueProvider =
        Provider.of<DetectionEntryQueueProvider>(context, listen: false);
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
          createTicketButton(),
        ],
      ),
    );
  }

  Widget createTicketButton() {
    return !canGenerateTicket ? const SizedBox.shrink() : Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsetsDirectional.only(top: 35, end: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                showDialog (context: context, builder: (context) {
                  String ticketTitle = '';
                  String ticketDescription = '';

                  return AlertDialog(
                    title: Text(localizations.create_ticket_text),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextField(
                          decoration: InputDecoration(
                            hintText: localizations.ticket_title_prompt,
                            label: Text(localizations.ticket_title),
                          ),
                          onChanged: (value) {
                            ticketTitle = value;
                          },
                          maxLength: 30,
                        ),
                        TextField(
                          decoration: InputDecoration(
                            hintText: localizations.ticket_description_prompt,
                            label: Text(localizations.ticket_description),
                          ),
                          onChanged: (value) {
                            ticketDescription = value;
                          },
                          maxLines: 5,
                          maxLength: 500,
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text(localizations.cancel),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      ElevatedButton(onPressed: () {
                        _generateTicketPreview(ticketTitle, ticketDescription);
                      }, child: Text(localizations.create_ticket))
                    ],
                  );
                }
                );
              },
              child: Text(localizations.create_ticket),
            ),
          ],
        ),
      ),
    );
  }

  void _generateTicketPreview(String title, String description) {
    final document = CustomDocument(
      type: CustomDocumentType.ticket,
      title: title,
      image: memoryImage,
      dateTime: widget.dateTime,
      detectedObjects: widget.recognitions,
      description: description,
    );
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DocumentPreviewScreen(document: document))
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
        DetectionsEntry(widget.imagePath, widget.dateTime, validRecognitions);
    detectionEntryQueueProvider.updateEntryOrAdd(updatedEntry);
  }

  @override
  void dispose() {
    detectionEntryQueueProvider.processEntries();
    super.dispose();
  }
}
