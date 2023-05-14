import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../json_models/object_list_model.dart';
import '../json_models/rules_structure_model.dart';
import 'ai_model_provider.dart';
import 'categorization_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PreviewSheet extends StatefulWidget {
  final Recognition recognition;
  final Function() notify;

  const PreviewSheet(BuildContext context, this.recognition, this.notify,
      {super.key});

  @override
  PreviewStateSheet createState() => PreviewStateSheet();
}

class PreviewStateSheet extends State<PreviewSheet> {
  int state = 0;
  double infoScrollHeight = 0;
  double objectScrollHeight = 0;
  final scrollControllerInfo = ScrollController(keepScrollOffset: false);
  final scrollControllerObjects = ScrollController(keepScrollOffset: false);

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FractionallySizedBox(
            alignment: Alignment.center,
            widthFactor: 0.9,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  widget.recognition.valid = true;
                  state = (state == 1) ? 0 : 1;
                  infoScrollHeight = (state == 1) ? 400 : 0;
                  objectScrollHeight = 0;
                });
                widget.notify();
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 1, color: Theme.of(context).colorScheme.surfaceTint),
                  color: Theme.of(context).colorScheme.surface,
                ),
                margin: const EdgeInsetsDirectional.only(top: 16, bottom: 8),
                child: Column(
                  children: [
                    Container(
                      padding:
                          const EdgeInsetsDirectional.symmetric(vertical: 15),
                      child: Stack(
                        children: [
                          Align(
                            alignment: AlignmentDirectional.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${currentObject.name}: ",
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  currentCategory.isSpecial() ? AppLocalizations.of(context)!.special_category : currentCategory.getName(context),
                                  style: const TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: AnimatedContainer(
                              width: 15,
                              height: 15,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: currentCategory.getColor(),
                              ),
                              duration: const Duration(milliseconds: 300),
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
          ),
          FractionallySizedBox(
            alignment: Alignment.center,
            widthFactor: 0.9,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  state = (state == 2) ? 0 : 2;
                  objectScrollHeight = (state == 2) ? 400 : 0;
                  infoScrollHeight = 0;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.red,
                  ),
                ),
                margin: const EdgeInsetsDirectional.only(top: 8, bottom: 16),
                width: 80,
                child: Column(
                  children: [
                    Container(
                      padding:
                          const EdgeInsetsDirectional.symmetric(vertical: 15),
                      child: Stack(
                        children: [
                          Align(
                            alignment: AlignmentDirectional.center,
                            child: Text(
                              AppLocalizations.of(context)!.wrong_object,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: Container(
                              alignment: Alignment.center,
                              width: 15,
                              height: 15,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red,
                              ),
                              child: Center(
                                child: Icon(
                                  state == 2
                                      ? Icons.arrow_drop_up
                                      : Icons.arrow_drop_down,
                                  color: Theme.of(context).colorScheme.surface,
                                  size: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    objects(categorizationProvider.objectsList),
                  ],
                ),
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
      List<Widget> displayable = currentCategory.getDisplayable(
          TextStyle(
            fontSize: 15,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          context,
          currentObject.label);
      for (Widget widget in displayable) {
        wList.add(
          FractionallySizedBox(
            alignment: Alignment.center,
            widthFactor: 0.9,
            child: Container(
              padding: const EdgeInsets.all(5),
              margin: const EdgeInsetsDirectional.symmetric(vertical: 10),
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
        margin:
            const EdgeInsetsDirectional.only(bottom: 10, start: 5, end: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: RawScrollbar(
          thumbVisibility: true,
          trackVisibility: true,
          controller: scrollControllerInfo,
          radius: const Radius.circular(10),
          trackRadius: const Radius.circular(10),
          thumbColor: Theme.of(context).colorScheme.surfaceTint,
          child: ListView(
            controller: scrollControllerInfo,
            children: wrapWidgets(),
          ),
        ),
      ),
    );
  }

  Widget objects(ObjectList objectList) {
    List<Widget> wrapObjects() {
      List<Widget> wList = <Widget>[];
      for (ObjectType objectType in objectList.objects) {
        if (objectType.label != widget.recognition.label) {
          wList.add(Material(
            child: InkWell(
              highlightColor: Colors.transparent,
              splashColor: Colors.red.withOpacity(0.5),
              onTap: () {
                setState(() {
                  widget.recognition.label = objectType.label;
                  widget.recognition.valid = true;
                  state = (state == 2) ? 0 : 2;
                  objectScrollHeight = (state == 2) ? 400 : 0;
                  infoScrollHeight = 0;
                });
                widget.notify();
              },
              child: Ink(
                child: Center(
                    child: Container(
                      padding: const EdgeInsetsDirectional.symmetric(vertical: 20),
                      child: Text(
                        objectType.name,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 15),
                  ),
                    ),
                ),
              ),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          border: BorderDirectional(
            top: BorderSide(color: Colors.red.withOpacity(state == 2 ? 1 : 0)),
          ),
        ),
        child: Container(
          margin: const EdgeInsetsDirectional.symmetric(vertical: 10, horizontal: 5),
          child: RawScrollbar(
            thumbVisibility: true,
            trackVisibility: true,
            controller: scrollControllerObjects,
            radius: const Radius.circular(10),
            trackRadius: const Radius.circular(10),
            thumbColor: Theme.of(context).colorScheme.surfaceTint,
            child: ListView(
              controller: scrollControllerObjects,
              children: wrapObjects(),
            ),
          ),
        ),
      ),
    );
  }
}
