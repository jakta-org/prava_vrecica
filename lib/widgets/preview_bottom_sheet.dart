import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../json_models/object_list_model.dart';
import '../json_models/rules_structure_model.dart';
import '../providers/ai_model_provider.dart';
import '../providers/categorization_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PreviewSheet extends StatefulWidget {
  final Recognition recognition;
  final Function() notify;

  const PreviewSheet(BuildContext context, this.recognition, this.notify, {super.key});

  @override
  PreviewStateSheet createState() => PreviewStateSheet();
}

class PreviewStateSheet extends State<PreviewSheet> {
  int state = 0;
  double infoScrollHeight = 0;
  double objectScrollHeight = 0;

  @override
  Widget build(BuildContext context) {
    final categorizationProvider =
        Provider.of<CategorizationProvider>(context, listen: false);

    ObjectType currentObject =
        categorizationProvider.getObjectByLabel(widget.recognition.label)!;
    SortingCategory currentCategory =
        categorizationProvider.getCategoryByLabel(widget.recognition.label)!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      curve: Curves.fastLinearToSlowEaseIn,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        color: Theme.of(context).colorScheme.surface,
      ),
      padding: const EdgeInsetsDirectional.symmetric(vertical: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FractionallySizedBox(
            alignment: Alignment.center,
            widthFactor: 0.1,
            child: Divider(
                color: Theme.of(context).colorScheme.surfaceTint,
                thickness: 3,
            ),
          ),

          FractionallySizedBox(
            alignment: Alignment.center,
            widthFactor: 0.9,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.surfaceTint,
              ),
              margin: const EdgeInsetsDirectional.symmetric(vertical: 5),
              child: Column(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        widget.recognition.valid = true;
                        state = (state == 1) ? 0 : 1;
                        infoScrollHeight = (state == 1) ? 400 : 0;
                        objectScrollHeight = 0;
                      });
                      widget.notify();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${currentObject.name}: ",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          currentCategory.getName(),
                          style: TextStyle(
                            color: currentCategory.getColor(),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            shadows: const <Shadow>[
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  info(currentObject, currentCategory),
                ],
              ),
            ),
          ),
          FractionallySizedBox(
            alignment: Alignment.center,
            widthFactor: 0.9,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceTint,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.red,
                ),
              ),
              margin: const EdgeInsetsDirectional.symmetric(vertical: 5),
              width: 80,
              child: Column(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        state = (state == 2) ? 0 : 2;
                        objectScrollHeight = (state == 2) ? 400 : 0;
                        infoScrollHeight = 0;
                      });
                    },
                    child: Text(
                      AppLocalizations.of(context)!.wrong_object,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  objects(categorizationProvider.objectsList),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget info(ObjectType currentObject, SortingCategory currentCategory) {
    List<Widget> wrapWidgets() {
      List<Widget> wList = <Widget>[];
      List<Widget> displayable = currentCategory.getDisplayable(TextStyle(
        fontSize: 15,
        color: Theme.of(context).colorScheme.onSurface,
      ), context, currentObject.label);
      for (Widget widget in displayable) {
        wList.add(
          FractionallySizedBox(
            alignment: Alignment.center,
            widthFactor: 0.9,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceTint,
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsetsDirectional.symmetric(vertical: 5),
              child: widget,
            ),
          ),
        );
      }

      return wList;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      curve: Curves.fastLinearToSlowEaseIn,
      height: infoScrollHeight,
      child: Container(
        margin: const EdgeInsetsDirectional.all(2),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListView(
          children: wrapWidgets(),
        ),
      ),
    );
  }

  Widget objects(ObjectList objectList) {
    List<Widget> wrapObjects() {
      List<Widget> wList = <Widget>[];
      for (ObjectType objectType in objectList.objects) {
        if (objectType.label != widget.recognition.label) {
          wList.add(TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            onPressed: () {
              setState(() {
                widget.recognition.label = objectType.label;
                widget.recognition.valid = true;
                state = (state == 2) ? 0 : 2;
                objectScrollHeight = (state == 2) ? 400 : 0;
                infoScrollHeight = 0;
              });
              widget.notify();
            },
            child: Text(
              objectType.name,
              style: const TextStyle(color: Colors.red),
            ),
          ));
        }
      }
      return wList;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      curve: Curves.fastLinearToSlowEaseIn,
      height: objectScrollHeight,
      child: Container(
        margin: const EdgeInsetsDirectional.all(1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: ListView(
          children: wrapObjects(),
        ),
      ),
    );
  }
}
