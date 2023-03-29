import 'package:flutter/material.dart';
import 'package:prava_vrecica/providers/ai_model_provider.dart';

class RecognitionWidget extends StatelessWidget {
  final Recognition recognition;
  final num factor;

  const RecognitionWidget({Key? key, required this.recognition, required this.factor}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Color color = Colors.primaries[
    (recognition.label.length + recognition.label.codeUnitAt(0) + recognition.id) %
        Colors.primaries.length];

    return Positioned(
      left: recognition.renderLocation.left * factor,
      top: recognition.renderLocation.top * factor,
      width: recognition.renderLocation.width * factor,
      height: recognition.renderLocation.height * factor,
      child: Container(
        width: recognition.renderLocation.width * factor,
        height: recognition.renderLocation.height * factor,
        decoration: BoxDecoration(
            border: Border.all(color: color, width: 3),
            borderRadius: const BorderRadius.all(Radius.circular(2))),
        child: Align(
          alignment: Alignment.topLeft,
          child: FittedBox(
            child: Container(
              color: color,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(recognition.label),
                  Text(" ${recognition.score.toStringAsFixed(2)}"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}