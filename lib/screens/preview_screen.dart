import 'dart:io';
import 'package:flutter/material.dart';
import 'package:prava_vrecica/providers/ai_model_provider.dart';
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
  List <Recognition> recognitions = [];
  int selected = 0;
  double iconSize = 50;

  @override
  Widget build(BuildContext context) {
    final aiModelProvider = Provider.of<AiModelProvider>(context, listen: false);
    final classifier = aiModelProvider.classifier;
    List<int> imageBytes = File(widget.imagePath).readAsBytesSync();
    final image = img.decodeImage(imageBytes);
    recognitions = classifier.predict(image!);
    recognitions.sort((a, b) => a.location.left.compareTo(b.location.left));
    final factor = MediaQuery.of(context).size.width / image.width;

    return Scaffold(
      appBar: normalAppBar(context),
      body: Stack(children: <Widget> [
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
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: recognitions
              .map((recognition) => GestureDetector(
            onTap: () {
              changeSelected(recognitions.indexOf(recognition));
            },
            child: Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: recognitions.indexOf(recognition) == selected
                    ? Colors.white
                    : Colors.white.withOpacity(0.4),
              ),
            ),
          )).toList(),
        ),
      ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 150,
                height: 50,
                margin: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Add functionality for red button here
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Wrong detection'),
                ),
              ),
              Container(
                width: 150,
                height: 50,
                margin: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Add functionality for green button here
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Recycle'),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  void changeSelected(int index) {
    setState(() {
      selected = index;
    });
    print(selected);
  }
}

Widget boundingBoxes(List<Recognition> recognitions, num factor, int selected) {
  return Stack(
    children: recognitions
        .map((recognition) => RecognitionWidget(recognition: recognition, factor: factor, selected: recognition == recognitions[selected],)
    ).toList(),
  );
}
