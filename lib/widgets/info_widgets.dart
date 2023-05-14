import 'package:flutter/material.dart';
import 'package:prava_vrecica/screens/info_screen.dart';
import 'package:provider/provider.dart';
import '../helping_classes.dart';
import '../json_models/object_list_model.dart';
import '../json_models/rules_structure_model.dart';
import '../providers/categorization_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Widget authorInfoOverview(InfoScreenState state) {
  BuildContext context = state.context;

  final categorizationProvider =
  Provider.of<CategorizationProvider>(context, listen: false);

  return Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(10),
      boxShadow: <BoxShadow>[
        BoxShadow(
            color: Theme.of(context).colorScheme.surfaceTint,
            blurRadius: 5.0)
      ],
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

Widget objectsOverview(InfoScreenState state) {
  BuildContext context = state.context;

  final categorizationProvider =
  Provider.of<CategorizationProvider>(context, listen: false);

  Widget info(
      ObjectType currentObject, SortingCategory currentCategory, int index) {
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
      height: state.scrollHeights[index],
      child: Container(
        margin: const EdgeInsetsDirectional.all(2),
        decoration: BoxDecoration(
          color: Theme.of(state.context).colorScheme.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListView(
          children: wrapWidgets(),
        ),
      ),
    );
  }

  List<Widget> wrapObjects() {
    List<Widget> wList = [];
    var objects = categorizationProvider.objectsList.objects;

    for (int i = 0; i < objects.length; i++) {
      var currentCategory = categorizationProvider.rulesStructure
          .getCategoryByLabel(objects[i].label)!;
      state.scrollHeights.add(0);
      wList.add(FractionallySizedBox(
        alignment: Alignment.center,
        widthFactor: 0.9,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.surface,
          ),
          margin: const EdgeInsetsDirectional.symmetric(vertical: 5),
          child: Column(
            children: [
              TextButton(
                onPressed: () {
                  state.setState(() {
                    state.scrollHeights[i] = (state.scrollHeights[i] == 400) ? 0 : 400;
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
                      currentCategory.getName(context),
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
      color: Theme.of(context).colorScheme.surface,
      boxShadow: <BoxShadow>[
        BoxShadow(
            color: Theme.of(context).colorScheme.surfaceTint,
            blurRadius: 5.0)
      ],
    ),
    margin: const EdgeInsetsDirectional.symmetric(vertical: 10),
    child: Column(
      children: [
        TextButton(
          onPressed: () {
            state.setState(() {
              state.objectsOpen = (state.objectsOpen == 0) ? 600 : 0;
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
          height: state.objectsOpen,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: BorderRadius.circular(10),
          ),
          margin:
          const EdgeInsetsDirectional.only(start: 5, end: 5, bottom: 5),
          child: ListView(
            children: wrapObjects(),
          ),
        ),
      ],
    ),
  );
}