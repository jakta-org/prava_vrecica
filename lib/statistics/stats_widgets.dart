import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:prava_vrecica/statistics/statistics_screen.dart';
import 'package:prava_vrecica/statistics/stats_models.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../fun/fun_models.dart';
import '../ai/categorization_provider.dart';

Widget barChart(BuildContext context, List<ChartData> chartData) {
  double maxY = chartData.map((e) => e.value).reduce(max);
  var chartWidth = 58.0 * chartData.length;
  var chartGroupsData = <BarChartGroupData>[];
  for (int i = 0; i < chartData.length; i++) {
    BarChartGroupData currentGroupData = BarChartGroupData(
      x: i,
      barRods: [
        BarChartRodData(
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            color: Theme.of(context).colorScheme.surfaceTint,
            fromY: 0,
            toY: maxY,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          toY: chartData[i].value,
          width: 50,
          color: chartData[i].color,
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
        color: chartData[i].color,
        borderRadius: const BorderRadius.all(Radius.circular(5)),
      ),
      child: Center(
        child: Text(
          chartData[i].name,
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
    decoration: childDecoration(context),
    height: 250,
    padding: const EdgeInsetsDirectional.only(top: 20, end: 40),
    margin: const EdgeInsetsDirectional.symmetric(vertical: 10),
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
              maxY: maxY,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget barChartUser(StatisticsScreenState state) {
  BuildContext context = state.context;
  List<ChartData> chartData = state.categoriesCount;
  if (kDebugMode) {
    print(chartData.toString());
  }

  return barChart(context, chartData);
}

class ObjectEntryWidget extends StatefulWidget {
  final StatisticsScreenState state;

  const ObjectEntryWidget({Key? key, required this.state}) : super(key: key);

  @override
  State<ObjectEntryWidget> createState() => _ObjectEntryWidgetState();
}

class _ObjectEntryWidgetState extends State<ObjectEntryWidget> {
  late Map<String, ObjectStats> objectEntries;
  late Function saveButtonFunction;

  @override
  void initState() {
    super.initState();
    objectEntries = widget.state.addObjectEntries;
    saveButtonFunction = (objectEntries) => widget.state.updateScreen(objectEntries);
  }

  @override
  Widget build(BuildContext context) {
    final categorizationProvider = Provider.of<CategorizationProvider>(context, listen: false);

    return Container(
        decoration: childDecoration(context),
        height: 600,
        padding: const EdgeInsetsDirectional.only(top: 20, end: 20, start: 20),
        margin: const EdgeInsetsDirectional.symmetric(vertical: 10),
        child: Column(
          children: [Column(
            children: objectEntries.keys.map((String key) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(categorizationProvider.getObjectByLabel(key)!.name),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            objectEntries[key]?.recycledCount = max((objectEntries[key]!.recycledCount - 1), 0);
                          });
                        },
                        icon: const Icon(Icons.remove),
                      ),
                      Text('${objectEntries[key]?.recycledCount}'),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            objectEntries[key]?.recycledCount = (objectEntries[key]!.recycledCount + 1);
                          });
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              );
            }).toList(),
          ), IconButton(color: Theme.of(context).colorScheme.primary, onPressed: () {
            var newStats = <String, ObjectStats>{};
            for (var object in objectEntries.entries) {
              if (object.value.recycledCount == 0 && object.value.recycledCountFromPhoto == 0) {
                continue;
              }
              newStats[object.key] = ObjectStats(recycledCount: object.value.recycledCount, recycledCountFromPhoto: object.value.recycledCountFromPhoto);
            }
            saveButtonFunction(newStats);
            for (String key in objectEntries.keys) {
              setState(() {
                objectEntries[key]?.recycledCount = 0;
              });
            }
         }, icon: const Icon(Icons.save, color: Colors.blue, size: 40), tooltip: AppLocalizations.of(context)!.entry_save_tooltip,)]
    ));
  }
}

class LeaderboardWidget extends StatefulWidget {
  final StatisticsScreenState state;

  const LeaderboardWidget({Key? key, required this.state}) : super(key: key);

  @override
  State<LeaderboardWidget> createState() => _LeaderboardWidgetState();
}

class _LeaderboardWidgetState extends State<LeaderboardWidget> {
  late final List<Score> scores;
  late final int userScoreIndex;
  late final List<Score> topScores;

  @override
  void initState() {
    super.initState();
    scores = widget.state.scores;
    scores.sort((a, b) => b.score.compareTo(a.score));
    userScoreIndex = scores.indexWhere((element) => element.id == widget.state.userProvider.userId);
    topScores = scores.sublist(0, min(5, scores.length));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: childDecoration(context),
        height: (userScoreIndex >= 5 ? 450 : topScores.length * 50 + 100),
        padding: const EdgeInsetsDirectional.only(top: 15, end: 20, start: 20),
        margin: const EdgeInsetsDirectional.symmetric(vertical: 10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(AppLocalizations.of(context)!.leaderboard, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            ),
            Column(
              children: topScores.map((value) {
                final index = topScores.indexOf(value);
                return getLeaderboardEntry(context, index);
              }).toList(),
            ),
            if (userScoreIndex >= 5) Column(
              children: [
                const Center(child: Text("...", style: TextStyle(fontSize: 40),)),
                getLeaderboardEntry(context, userScoreIndex),
              ],
            ),
          ]
    ));
  }

  Widget getLeaderboardEntry(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: index != userScoreIndex ? Theme.of(context).colorScheme.surfaceTint : Theme.of(context).colorScheme.primary,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                    width: 50,
                    child: Text((index + 1).toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
                ),
              ),
              Container(alignment: Alignment.center, child: Text(index != userScoreIndex ? scores[index].name : AppLocalizations.of(context)!.you, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
              Container(
                alignment: Alignment.centerRight,
                child: SizedBox(
                    width: 100,
                    child: Center(child: Text(scores[index].score.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)))
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


Decoration childDecoration(BuildContext context) {
  return BoxDecoration(
    borderRadius: const BorderRadius.all(Radius.circular(10)),
    color: Theme.of(context).colorScheme.surface,
    boxShadow: <BoxShadow>[
      BoxShadow(
          color: Theme.of(context).colorScheme.surfaceTint,
          blurRadius: 5.0)
    ],
  );
}

class ChartData {
  String name;
  double value;
  Color color;

  ChartData(this.name, this.value, this.color);

  @override
  String toString() {
    return 'ChartData{name: $name, value: $value, color: $color}';
  }
}


