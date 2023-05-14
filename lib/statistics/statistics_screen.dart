import 'package:flutter/material.dart';
import 'package:prava_vrecica/documents/document_widgets.dart';
import 'package:prava_vrecica/fun/fun_widgets.dart';
import 'package:prava_vrecica/json_models/rules_structure_model.dart';
import 'package:prava_vrecica/statistics/statistics_provider.dart';
import 'package:prava_vrecica/statistics/stats_models.dart';
import 'package:prava_vrecica/widgets/modular_widgets.dart';
import 'package:provider/provider.dart';
import '../providers/categorization_provider.dart';
import '../providers/user_provider.dart';
import 'stats_widgets.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => StatisticsScreenState();
}

class StatisticsScreenState extends State<StatisticsScreen> {
  late StatisticsProvider statisticsProvider;
  late UserProvider userProvider;
  late CategorizationProvider categorizationProvider;
  late List<ObjectCategory> categories;
  late List<SpecialObjectType> special;
  Map<String, ObjectStats> objectStats = {};
  List<ChartData> categoriesCount = [];
  Map<String, ObjectStats> addObjectEntries = {};

  Future<void> _setCategoriesCount() async {
    await statisticsProvider.init();
    categoriesCount = statisticsProvider.allTimeCategoriesStats
        .map((category) => ChartData(displayCategoryName(category.categoryName),
            category.recycledCount.toDouble(), category.categoryColor))
        .toList();
    objectStats = statisticsProvider.allTimeObjectStats;
    addObjectEntries = objectStats.map((key, value) => MapEntry(
        key, ObjectStats(recycledCount: 0, recycledCountFromPhoto: 0)));
  }

  String displayCategoryName(String label) {
    for (var category in categorizationProvider.rulesStructure.categories) {
      if (category.name == label) {
        return label;
      }
    }
    for (var special in categorizationProvider.rulesStructure.special) {
      if (special.label == label) {
        return special.getName(context);
      }
    }
    return label;
  }

  List<Widget> _createChildren(BuildContext context) {
    List<Widget> widgetList = <Widget>[];

    widgetList.addAll(ModularWidgets.getWidgetList(WidgetType.interactive, this, userProvider.setGroup.settings.widgets));

    return widgetList;
  }

  void updateScreen(dynamic objectEntries) {
    statisticsProvider.updateStats(objectEntries);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context, listen: true);
    categorizationProvider =
        Provider.of<CategorizationProvider>(context, listen: false);
    statisticsProvider =
        Provider.of<StatisticsProvider>(context, listen: false);
    categories = categorizationProvider.rulesStructure.categories;
    special = categorizationProvider.rulesStructure.special;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: FutureBuilder<void>(
        future: _setCategoriesCount(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView(
              padding: const EdgeInsetsDirectional.only(
                  top: 100, start: 10, end: 10),
              children: _createChildren(context),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Widget materialStats(BuildContext context) {
    return Container(
      decoration: childDecoration(context),
    );
  }

  Widget testWidget(BuildContext context) {
    return Container(
      decoration: childDecoration(context),
      height: 250,
      margin: const EdgeInsetsDirectional.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          Icon(
            Icons.abc,
            color: Colors.red,
          ),
          Icon(
            Icons.abc,
            color: Colors.blue,
          ),
          Icon(
            Icons.abc,
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}
