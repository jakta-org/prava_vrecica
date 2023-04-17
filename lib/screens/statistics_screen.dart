import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  List<Widget> _createChildren(BuildContext context) {
    List<Widget> widgetList = <Widget>[];

    widgetList.add(categoriesMassChart());

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
}
