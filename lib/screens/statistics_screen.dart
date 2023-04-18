import 'package:flutter/material.dart';
import 'package:prava_vrecica/json_models/rules_structure_model.dart';
import 'package:prava_vrecica/providers/statistics_provider.dart';
import 'package:prava_vrecica/providers/categorization_provider.dart';
import 'package:provider/provider.dart';
import '../providers/categorization_provider.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/stats_widgets.dart';

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
  List<ChartData> categoriesCount = [];
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
    await statisticsProvider.initPrefs();
    var objectCounts = await statisticsProvider.getStats();
    categoriesCount = categories.map((category) {
      return ChartData(
        category.name,
        0.0,
        category.color,
      );
    }).toList();
    categoriesCount.add(ChartData(
      "Specijalni otpad",
      0.0,
      special.first.color,
    ));
    for (var object in objectCounts.entries) {
      categoriesCount.firstWhere((category) => category.name == categorizationProvider.getCategoryByLabel(object.key)).value += object.value.recycledCount;
    }
  }

  List<Widget> _createChildren(BuildContext context) {
    List<Widget> widgetList = <Widget>[];

    widgetList.add(barChart(context, categoriesCount));

    return widgetList;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    User user;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
        child: FutureBuilder<void>(
          future: _setCategoriesCountFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return ListView(
                children: _createChildren(context),
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

  Widget categoriesMassChart() {
    final categorizationProvider =
        Provider.of<CategorizationProvider>(context, listen: false);
    // test data
    List<String> categories = categorizationProvider.rulesStructure.categories
            .map((c) => c.name)
            .toList() +
        categorizationProvider.rulesStructure.special
            .map((s) => categorizationProvider.objectsList.objects
                .firstWhere((obj) => obj.label == s.label)
                .name)
            .toList();
    List<Color> colors = categorizationProvider.rulesStructure.categories
            .map((c) => c.getColor())
            .toList() +
        categorizationProvider.rulesStructure.special
            .map((s) => s.color)
            .toList();
    var totalMass = <double>[
      5.613,
      4.189,
      2.056,
      1.379,
      0.405,
      0.632,
      0.101,
      0.052,
      0,
      0
    ];

    double chartWidth = categories.length * 58;

    var chartGroupsData = <BarChartGroupData>[];
    for (int i = 0; i < categories.length; i++) {
      BarChartGroupData currentGroupData = BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              color: Theme.of(context).colorScheme.surfaceTint,
              fromY: 0,
              toY: totalMass[0],
            ),
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            toY: totalMass[i],
            width: 50,
            color: colors[i],
          ),
        ],
      );
      chartGroupsData.add(currentGroupData);
    }

    Widget getTitleData(double d, TitleMeta m) {
      int i = d.toInt();
      return Container(
        width: 50,
        height: 15,
        margin: const EdgeInsetsDirectional.only(top: 5, bottom: 10),
        decoration: BoxDecoration(
          color: colors[i],
          borderRadius: const BorderRadius.all(Radius.circular(5)),
        ),
        child: Center(
          child: Text(
            categories[i],
            style: TextStyle(
              color: Theme.of(context).colorScheme.surface,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Container(
      decoration: childDecoration(),
      height: 250,
      padding: const EdgeInsetsDirectional.only(top: 20, end: 40),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          SizedBox(
            height: 200,
            width: chartWidth,
            child: BarChart(
              BarChartData(
                groupsSpace: 10,
                backgroundColor: Colors.transparent,
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      reservedSize: 40,
                      showTitles: true,
                      getTitlesWidget: getTitleData,
                    ),
                  ),
                  topTitles: AxisTitles(
                      sideTitles: SideTitles(
                          reservedSize: 5,
                          showTitles: true,
                          getTitlesWidget: (double d, TitleMeta tm) {
                            return const SizedBox();
                          })),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: true, reservedSize: 40)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: chartGroupsData,
                gridData: FlGridData(show: false),
                alignment: BarChartAlignment.spaceBetween,
                maxY: totalMass[0],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
