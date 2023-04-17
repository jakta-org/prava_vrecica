import 'dart:io';
import 'package:flutter/material.dart';
import 'package:prava_vrecica/providers/ai_model_provider.dart';
import 'package:prava_vrecica/providers/categorization_provider.dart';
import 'package:prava_vrecica/widgets/normal_appbar.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;
import '../widgets/recognition_widget.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key, required this.imagePath}) : super();

  final String imagePath;

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  List<Recognition> recognitions = [];
  int selected = 0;
  double iconSize = 50;
  double h = 50;

  @override
  Widget build(BuildContext context) {
    final aiModelProvider =
        Provider.of<AiModelProvider>(context, listen: false);
    final classifier = aiModelProvider.classifier;
    List<int> imageBytes = File(widget.imagePath).readAsBytesSync();
    final image = img.decodeImage(imageBytes);
    recognitions = classifier.predict(image!);
    recognitions.sort((a, b) => a.location.left.compareTo(b.location.left));
    final factor = MediaQuery.of(context).size.width / image.width;

    return Scaffold(
      appBar: normalAppBar(context),
      bottomSheet: previewSheet(context, recognitions[selected]),
      body: Stack(
        children: <Widget>[
          Image.file(File(widget.imagePath)),
          boundingBoxes(recognitions, factor, selected),
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                changeSelected((selected - 1) % recognitions.length);
              },
              iconSize: iconSize,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                changeSelected((selected + 1) % recognitions.length);
              },
              iconSize: iconSize,
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsetsDirectional.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: recognitions
                    .map((recognition) => GestureDetector(
                          onTap: () {
                            changeSelected(recognitions.indexOf(recognition));
                          },
                          child: Container(
                            width: 15,
                            height: 15,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: recognitions.indexOf(recognition) ==
                                      selected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.surfaceTint,
                            ),
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

  Widget boundingBoxes(
      List<Recognition> recognitions, num factor, int selected) {
    return Stack(
      children: recognitions
          .map((recognition) => RecognitionWidget(
                recognition: recognition,
                factor: factor,
                selected: recognition == recognitions[selected],
                func: () => changeSelected(selected),
              ))
          .toList(),
    );
  }

  Widget previewSheet(BuildContext context, Recognition recognition) {
    final categorizationProvider =
        Provider.of<CategorizationProvider>(context, listen: false);

    if (recognitions.isEmpty) {
      return Container();
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 100),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(categorizationProvider.getNameByLabel(recognition.label)),
              Text(categorizationProvider.getCategoryByLabel(recognition.label)),
            ],
          ),
        ],
      ),
    );
  }
}
