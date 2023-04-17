import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/object_stats_model.dart';

Widget categoriesCountChart(List<ObjectCategory> categories, List<ObjectWithCategoryStats> objects) {
  // test data
  var chartGroupsData = <BarChartGroupData>[];
  for (int i = 0; i < categoriesData.length; i++) {
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
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          toY: totalMass[i],
          width: 50,
          color: colors[i],
        ),
      ],
    );
    chartGroupsData.add(currentGroupData);
  }

  return Container(
    decoration: childDecoration(),
    height: 250,
    padding: const EdgeInsetsDirectional.only(top: 20, end: 40),
    child: BarChart(
      BarChartData(
        groupsSpace: 10,
        backgroundColor: Colors.transparent,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              reservedSize: 30,
              showTitles: true,
              getTitlesWidget: getTitleData,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: chartGroupsData,
        gridData: FlGridData(show: false),
        alignment: BarChartAlignment.spaceBetween,
        maxY: totalMass[0],
      ),
    ),
  );
}


