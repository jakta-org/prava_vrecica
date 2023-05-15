import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prava_vrecica/fun/fun_models.dart';
import 'package:provider/provider.dart';
import '../languages/localization_provider.dart';
import '../statistics/stats_widgets.dart';

class FunFactsWidget extends StatefulWidget {
  const FunFactsWidget({Key? key}) : super(key: key);

  @override
  FunFactsWidgetState createState() => FunFactsWidgetState();
}

class FunFactsWidgetState extends State<FunFactsWidget> {
  late List<FunFact> _funFacts;
  int _currentFunFactIndex = 0;
  final AssetImage image =
      const AssetImage('assets/images/mascot_demo_noback.png');
  late Future<void> funFactFuture;

  FunFactsWidgetState() {
    funFactFuture =
        rootBundle.loadString('assets/fun_facts.json').then((value) {
      List<dynamic> json = jsonDecode(value);
      List<FunFact> funFacts = [];
      for (var item in json) {
        funFacts.add(FunFact.fromJson(item));
      }
      _funFacts = funFacts;
      getRandomFunFact();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizationProvider =
        Provider.of<LocalizationProvider>(context, listen: false);

    return FutureBuilder<void>(
        future: funFactFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  getRandomFunFact();
                });
              },
              child: Container(
                  decoration: childDecoration(context),
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsetsDirectional.symmetric(vertical: 10),
                  height: 150,
                  child: Row(
                    children: [
                      Center(
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: image,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).colorScheme.surfaceTint,
                        ),
                        width: MediaQuery.of(context).size.width - 170,
                        margin:
                            const EdgeInsetsDirectional.symmetric(vertical: 20),
                        padding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                _funFacts[_currentFunFactIndex]
                                    .getFact(localizationProvider.locale),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                width: 20,
                                height: 20,
                                margin: const EdgeInsets.all(5),
                                child: Icon(
                                  Icons.keyboard_arrow_right_sharp,
                                  color: Theme.of(context).colorScheme.onSurface,
                                  size: 20,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  )),
            );
          } else {
            return Container(
                decoration: childDecoration(context),
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsetsDirectional.symmetric(vertical: 10),
                height: 150,
                child: Row(
                  children: [
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: image,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ]),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 120,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ],
                ));
          }
        });
  }

  void getRandomFunFact() {
    var newFunFactIndex = Random().nextInt(_funFacts.length);
    while (newFunFactIndex == _currentFunFactIndex) {
      newFunFactIndex = Random().nextInt(_funFacts.length);
    }
    _currentFunFactIndex = newFunFactIndex;
  }
}
