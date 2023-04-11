import 'package:flutter/material.dart';
import 'package:prava_vrecica/providers/ai_model_provider.dart';

class RecognitionWidget extends StatelessWidget {
  final Recognition recognition;
  final num factor;
  final bool selected;
  final VoidCallback func;

  const RecognitionWidget(
      {Key? key,
      required this.recognition,
      required this.factor,
      required this.selected,
      required this.func})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return selectedWidget(selected, context, func);
  }

  Widget selectedWidget(
      bool selected, BuildContext context, VoidCallback func) {
    return Positioned(
      left: recognition.renderLocation.left * factor,
      top: recognition.renderLocation.top * factor,
      width: recognition.renderLocation.width * factor,
      height: recognition.renderLocation.height * factor,
      child: Container(
        width: recognition.renderLocation.width * factor,
        height: recognition.renderLocation.height * factor,
        decoration: BoxDecoration(
            border: selected
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary, width: 5)
                : const Border(
                    top: BorderSide.none,
                    bottom: BorderSide.none,
                    left: BorderSide.none,
                    right: BorderSide.none,
                  ),
            borderRadius: const BorderRadius.all(Radius.circular(5))),
        child: Stack(
          children: [
            GestureDetector(
              onTap: func,
              child: Center(
                child: Icon(
                  Icons.circle_outlined,
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceVariant,
                ),
              ),
            ),
            selected
                ? Align(
                    alignment: Alignment.topLeft,
                    child: FittedBox(
                      child: Container(
                        color: Theme.of(context).colorScheme.primary,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(recognition.label),
                            Text(" ${recognition.score.toStringAsFixed(2)}"),
                          ],
                        ),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
