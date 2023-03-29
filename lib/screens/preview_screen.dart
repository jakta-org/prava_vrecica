import 'dart:io';
import 'package:flutter/material.dart';
import 'package:prava_vrecica/providers/ai_model_provider.dart';
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
  @override
  Widget build(BuildContext context) {
    final aiModelProvider = Provider.of<AiModelProvider>(context, listen: false);
    final classifier = aiModelProvider.classifier;
    List<int> imageBytes = File(widget.imagePath).readAsBytesSync();
    final image = img.decodeImage(imageBytes);
    List <Recognition> recognitions = classifier.predict(image!);

    final factor = MediaQuery.of(context).size.width / image.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview'),
      ),
      body: Stack(children: <Widget> [
        Image.file(File(widget.imagePath)),
        boundingBoxes(recognitions, factor),
      ]),
    );
  }
}

Widget boundingBoxes(List<Recognition> recognitions, num factor) {
  return Stack(
    children: recognitions
        .map((recognition) => RecognitionWidget(recognition: recognition, factor: factor)
    ).toList(),
  );
}
