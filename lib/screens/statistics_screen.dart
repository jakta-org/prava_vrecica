import 'package:flutter/material.dart';
import 'package:prava_vrecica/widgets/normal_appbar.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => StatisticsScreenState();
}

class StatisticsScreenState extends State<StatisticsScreen> {
  List<Widget> _createChildren(BuildContext context) {
    List<Widget> widgetList = <Widget>[];

    for (int i = 0; i < 15; i++) {
      widgetList.add(materialStats(context));
    }

    return widgetList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: normalAppBar(context),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Stack(
          children: [
            SafeArea(
              child: Container(
                padding: const EdgeInsetsDirectional.all(10),
                child: ListView(
                  children: _createChildren(context),
                ),
              ),
            ),
          ],
        ));
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

  Decoration childDecoration() {
    return BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      color: Theme.of(context).colorScheme.surface,
      boxShadow: const <BoxShadow>[],
    );
  }
}
