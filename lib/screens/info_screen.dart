import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:prava_vrecica/json_models/object_list_model.dart';
import 'package:prava_vrecica/json_models/rules_structure_model.dart';
import 'package:prava_vrecica/providers/categorization_provider.dart';
import 'package:provider/provider.dart';

import '../helping_classes.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => InfoScreenState();
}

class InfoScreenState extends State<InfoScreen> {
  List<double> scrollHeights = [];
  double objectsOpen = 0;

  List<Widget> _createChildren(BuildContext context) {
    List<Widget> widgetList = <Widget>[];

    widgetList.add(authorInfoOverview());
    widgetList.add(objectsOverview());

    return widgetList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
        child: ListView(
          children: _createChildren(context),
        ),
      ),
    );
  }

  Widget info(ObjectType currentObject, SortingCategory currentCategory, int index) {
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
      height: scrollHeights[index],
      child: Container(
        margin: const EdgeInsetsDirectional.all(2),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListView(
          children: wrapWidgets(),
        ),
      ),
    );
  }

  Widget objectsOverview() {
    final categorizationProvider = Provider.of<CategorizationProvider>(context, listen: false);

    List<Widget> wrapObjects() {
      List<Widget> wList = [];
      var objects = categorizationProvider.objectsList.objects;

      for (int i = 0; i < objects.length; i++) {
        var currentCategory = categorizationProvider.rulesStructure.getCategoryByLabel(objects[i].label)!;
        scrollHeights.add(0);
        wList.add(FractionallySizedBox(
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
                      scrollHeights[i] = (scrollHeights[i] == 400) ? 0 : 400;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${objects[i].name}: ",
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
                info(objects[i], currentCategory, i),
              ],
            ),
          ),
        ));
      }

      return wList;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.surfaceTint,
      ),
      margin: const EdgeInsetsDirectional.symmetric(vertical: 10),
      child: Column(
        children: [
          TextButton(
            onPressed: () {
              setState(() {
                objectsOpen = (objectsOpen == 0) ? 600: 0;
              });
            },
            child: Text(
              AppLocalizations.of(context)!.objects_info_list,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
          ),
          AnimatedContainer(
            curve: Curves.easeIn,
            duration: const Duration(milliseconds: 500),
            height: objectsOpen,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsetsDirectional.only(start: 5, end: 5, bottom: 5),
            child: ListView(
              children: wrapObjects(),
            ),
          ),
        ],
      ),
    );
  }

  Widget authorInfoOverview() {
    final categorizationProvider = Provider.of<CategorizationProvider>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceTint,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsetsDirectional.all(10),
      margin: const EdgeInsetsDirectional.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: Text(
              categorizationProvider.rulesStructure.name,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: Text(
              "- ${categorizationProvider.rulesStructure.author}",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ] +
        parseInfo(
          categorizationProvider.rulesStructure.authorInfo,
          TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
          0,
        ),
      ),
    );
  }
}