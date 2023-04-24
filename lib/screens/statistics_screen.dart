import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => StatisticsScreenState();
}

class StatisticsScreenState extends State<StatisticsScreen> {
  List<Widget> _createChildren(BuildContext context) {
    List<Widget> widgetList = <Widget>[];

    widgetList.add(categoriesMassChart());

    return widgetList;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    User user;

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

  Decoration childDecoration() {
    return BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      color: Theme.of(context).colorScheme.surface,
      boxShadow: const <BoxShadow>[],
    );
  }

  Widget materialStats(BuildContext context) {
    return Container(
      decoration: childDecoration(),
    );
  }

  Widget testWidget(BuildContext context) {
    return Container(
      decoration: childDecoration(),
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
    // test data
    var categories = <String>[
      "MIXED",
      "PLASTIC",
      "PAPER",
      "GLASS",
      "TEXTILE",
      //"BATTERIES"
    ];
    var colors = <Color>[
      Colors.blueGrey.shade300,
      Colors.yellow.shade700,
      Colors.blue,
      Colors.green,
      Colors.redAccent,
      //Colors.orangeAccent.shade400,
    ];
    var totalMass = <double>[5.613, 4.189, 2.056, 1.379, 0.405];

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
            borderRadius: const BorderRadius.all(Radius.circular(10)),
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
          borderRadius: const BorderRadius.all(Radius.circular(10)),
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
}
