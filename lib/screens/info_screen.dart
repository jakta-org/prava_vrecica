import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../widgets/modular_widgets.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => InfoScreenState();
}

class InfoScreenState extends State<InfoScreen> {
  late UserProvider userProvider;
  List<double> scrollHeights = [];
  double objectsOpen = 0;

  List<Widget> _createChildren(BuildContext context) {
    List<Widget> widgetList = <Widget>[];

    widgetList.addAll(ModularWidgets.getWidgetList(WidgetType.info, this, userProvider.setGroup.settings.widgets));

    return widgetList;
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: ListView(
        padding: const EdgeInsetsDirectional.only(top: 100, start: 10, end: 10),
        children: _createChildren(context),
      ),
    );
  }
}
