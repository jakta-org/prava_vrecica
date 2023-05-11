import 'package:flutter/material.dart';
import 'package:prava_vrecica/json_models/rules_structure_model.dart';
import 'package:prava_vrecica/statistics/statistics_provider.dart';
import 'package:prava_vrecica/statistics/stats_models.dart';
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
  late Future<void> _setCategoriesCountFuture;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    categorizationProvider = Provider.of<CategorizationProvider>(context, listen: false);
    statisticsProvider = Provider.of<StatisticsProvider>(context, listen: false);
    categories = categorizationProvider.rulesStructure.categories;
    special = categorizationProvider.rulesStructure.special;
    _setCategoriesCountFuture = _setCategoriesCount();
  }

  Future<void> _setCategoriesCount() async{
    await statisticsProvider.init();
    categoriesCount = statisticsProvider.allTimeCategoriesStats
        .map((category) => ChartData(
              category.categoryName,
              category.recycledCount.toDouble(),
              category.categoryColor
    )).toList();
    objectStats = statisticsProvider.allTimeObjectStats;
    addObjectEntries = objectStats.map((key, value) => MapEntry(key, ObjectStats(recycledCount: 0, recycledCountFromPhoto: 0)));
  }

  List<Widget> _createChildren(BuildContext context) {
    List<Widget> widgetList = <Widget>[];

    widgetList.add(barChart(context, categoriesCount));
    widgetList.add(ObjectEntryWidget(objectEntries: addObjectEntries, saveButtonFunction: updateStats));
    return widgetList;
  }

  void updateStats(Map<String, ObjectStats> objectEntries) {
    statisticsProvider.updateStats(objectEntries);
    setState(() {
      _setCategoriesCountFuture = _setCategoriesCount();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
        child: FutureBuilder<void>(
          future: _setCategoriesCountFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return ListView(
                children: _createChildren(context)
                    .map((child) =>
                      Container(
                        margin: const EdgeInsetsDirectional.symmetric(vertical: 5),
                        decoration: childDecoration(context),
                        child: child,
                      )
                    ).toList()
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
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
