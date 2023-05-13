import 'package:flutter/material.dart';
import 'package:prava_vrecica/intro_screen/intro_page_1.dart';
import 'package:prava_vrecica/intro_screen/intro_page_4.dart';
import 'package:prava_vrecica/mode_status.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../providers/user_provider.dart';
import 'intro_page_2.dart';
import 'intro_page_3.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _controller = PageController();
  final int _numPages = 4;
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: const [
              IntroPage1(),
              IntroPage2(),
              IntroPage3(),
              IntroPage4(),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SmoothPageIndicator(
                controller: _controller,
                count: _numPages,
                effect: const ExpandingDotsEffect(
                  dotColor: Colors.grey,
                  activeDotColor: Colors.white,
                  dotHeight: 16,
                  dotWidth: 16,
                  spacing: 4,
                  expansionFactor: 2,
                ),
              ),
            ),
          ),
          Visibility(
            visible: _currentPage != _numPages - 1,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: ElevatedButton(
                  onPressed: () {
                    userProvider.setWasIntroScreenShown(true);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ModeStatus()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    textStyle: const TextStyle(
                      fontSize: 24.0,
                    ),
                  ),
                  child: Text(localizations.skip)
              ),
            ),
          ),
          Visibility(
            visible: _currentPage != _numPages - 1,
            child: Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                  onPressed: () {
                    _controller.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeIn);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    textStyle: const TextStyle(
                      fontSize: 24.0,
                    ),
                  ),
                  child: Text(localizations.next),
              ),
            )
          ),
          Visibility(
              visible: _currentPage == _numPages - 1,
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                      onPressed: () {
                        userProvider.setWasIntroScreenShown(true);
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ModeStatus()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        textStyle: const TextStyle(
                          fontSize: 30.0,
                        ),
                      ),
                      child: Text(localizations.start),
                  ),
                ),
              )
          )
        ],
      )
    );
  }
}