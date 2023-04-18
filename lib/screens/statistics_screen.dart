import 'package:flutter/material.dart';
import 'package:prava_vrecica/json_models/rules_structure_model.dart';
import 'package:prava_vrecica/providers/statistics_provider.dart';
import 'package:provider/provider.dart';
import '../providers/categorization_provider.dart';
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
}
