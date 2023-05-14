import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prava_vrecica/fun/fun_models.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../providers/localization_provider.dart';
import '../statistics/stats_widgets.dart';

class FunFactsWidget extends StatefulWidget {
  const FunFactsWidget({Key? key}) : super(key: key);

  @override
  _FunFactsWidgetState createState() => _FunFactsWidgetState();
}

class _FunFactsWidgetState extends State<FunFactsWidget> {
  late List<FunFact> _funFacts;
  int _currentFunFactIndex = 0;
  final AssetImage image = const AssetImage('assets/images/V_logo_s.png');
  late Future<void> funFactFuture;

  _FunFactsWidgetState() {
    funFactFuture = rootBundle.loadString('assets/fun_facts.json').then((value) {
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
    final localizationProvider = Provider.of<LocalizationProvider>(context, listen: false);

    return FutureBuilder<void>(future: funFactFuture, builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        return Container(
          decoration: childDecoration(context),
          width: MediaQuery.of(context).size.width,
          height: 150,
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    getRandomFunFact();
                  });
                },
                child:
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
                      Text(AppLocalizations.of(context)!.click_me),
                    ]
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width - 120,
                child: Center(
                  child: Text(
                    _funFacts[_currentFunFactIndex].getFact(localizationProvider.locale),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ],
          )
        );
      } else {
        return Container(
            decoration: childDecoration(context),
            width: MediaQuery.of(context).size.width,
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
                      Text("Click me!")
                    ]
                ),
                Container(
                  width: MediaQuery.of(context).size.width - 120,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            )
        );
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