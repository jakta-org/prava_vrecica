import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

Widget barChart(BuildContext context, List<ChartData> chartData) {
  double maxY = chartData.map((e) => e.value).reduce(max);
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
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          toY: chartData[i].value,
          width: 50,
          color: chartData[i].color,
        ),
      ],
    );
    chartGroupsData.add(currentGroupData);
  }

  double chartWidth = chartGroupsData.length * 60;

  Widget getTitleData(double d, TitleMeta m) {
    int i = d.toInt();
    return Container(
      width: 50,
      height: 15,
      margin: const EdgeInsetsDirectional.only(top: 5, bottom: 10),
      decoration: BoxDecoration(
        color: chartData[i].color,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
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
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
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

Decoration childDecoration(BuildContext context) {
  return BoxDecoration(
    borderRadius: const BorderRadius.all(Radius.circular(10)),
    color: Theme.of(context).colorScheme.surface,
    boxShadow: const <BoxShadow>[],
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
