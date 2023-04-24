import 'package:flutter/material.dart';
import 'package:prava_vrecica/providers/ai_model_provider.dart';
import 'package:provider/provider.dart';

import '../providers/categorization_provider.dart';

class RecognitionWidget extends StatelessWidget {
  final Recognition recognition;
  final num factor;
  final bool selected;

  const RecognitionWidget(
      {Key? key,
      required this.recognition,
      required this.factor,
      required this.selected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return selectedWidget(selected, context);
  }

  Widget selectedWidget(bool selected, BuildContext context) {
    final categorizationProvider =
        Provider.of<CategorizationProvider>(context, listen: false);
    return Positioned(
      left: recognition.renderLocation.left * factor,
      top: recognition.renderLocation.top * factor,
      width: recognition.renderLocation.width * factor,
      height: recognition.renderLocation.height * factor,
      child: Center(
        child: AnimatedContainer(
          curve: Curves.ease,
          duration: const Duration(milliseconds: 300),
          width: selected ? recognition.renderLocation.width * factor : 20,
          height: selected ? recognition.renderLocation.height * factor : 20,
          decoration: BoxDecoration(
            color: selected ? Colors.white24 : Colors.transparent,
            border: selected
                ? Border.all(
                    color: categorizationProvider
                        .getCategoryByLabel(recognition.label)!
                        .getColor(),
                    width: 5)
                : Border.all(
                    color: Theme.of(context).colorScheme.surfaceVariant),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: AnimatedContainer(
            margin: const EdgeInsets.all(3),
            duration: const Duration(milliseconds: 300),
            child: Text(
              recognition.score.toStringAsFixed(2),
              style: TextStyle(
                color: selected
                    ? categorizationProvider
                        .getCategoryByLabel(recognition.label)!
                        .getColor()
                    : Colors.transparent,
                fontSize: 12,
                shadows: selected
                    ? const <Shadow>[
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(1, 1),
                        ),
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(1, 1),
                        ),
                      ]
                    : <Shadow>[],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
