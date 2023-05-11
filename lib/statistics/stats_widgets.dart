import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:prava_vrecica/statistics/stats_models.dart';
import 'package:provider/provider.dart';

import '../providers/categorization_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../providers/categorization_provider.dart';

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

class ObjectEntryWidget extends StatefulWidget {
  final Map<String, ObjectStats> objectEntries;
  final Function saveButtonFunction;

  const ObjectEntryWidget({Key? key, required this.objectEntries, required this.saveButtonFunction}) : super(key: key);

  @override
  State<ObjectEntryWidget> createState() => _ObjectEntryWidgetState();
}

class _ObjectEntryWidgetState extends State<ObjectEntryWidget> {
  late Map<String, ObjectStats> _objectEntries;

  @override
  void initState() {
    super.initState();
    _objectEntries = widget.objectEntries;
  }

  @override
  Widget build(BuildContext context) {
    final categorizationProvider = Provider.of<CategorizationProvider>(context, listen: false);

    final categorizationProvider = Provider.of<CategorizationProvider>(context);

    return Container(
        decoration: childDecoration(context),
        height: 600,
        padding: const EdgeInsetsDirectional.only(top: 20, end: 20, start: 20),
        child: Column(
          children: [
            Text(AppLocalizations.of(context)!.object_entry, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Column(
            children: _objectEntries.keys.map((String key) {
              final name = categorizationProvider.objectsList.objects.firstWhere((element) => element.label == key).name;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(categorizationProvider.getObjectByLabel(key)!.name),
                  Text(name),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _objectEntries[key]?.recycledCount = max((_objectEntries[key]!.recycledCount - 1), 0);
                          });
                        },
                        icon: const Icon(Icons.remove),
                      ),
                      Text('${_objectEntries[key]?.recycledCount}'),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _objectEntries[key]?.recycledCount = (_objectEntries[key]!.recycledCount + 1);
                          });
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              );
            }).toList(),
          ), IconButton(onPressed: () {
            var newStats = <String, ObjectStats>{};
            for (var object in _objectEntries.entries) {
              if (object.value.recycledCount == 0 && object.value.recycledCountFromPhoto == 0) {
                continue;
              }
              newStats[object.key] = ObjectStats(recycledCount: object.value.recycledCount, recycledCountFromPhoto: object.value.recycledCountFromPhoto);
            }
            widget.saveButtonFunction(newStats);
            for (String key in _objectEntries.keys) {
              setState(() {
                _objectEntries[key]?.recycledCount = 0;
              });
            }
         }, icon: const Icon(Icons.save, color: Colors.green, size: 40), tooltip: AppLocalizations.of(context)!.entry_save_tooltip,)]
    ));
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


