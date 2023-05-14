import 'package:flutter/material.dart';
import 'package:prava_vrecica/intro_screen/intro_page.dart';
import 'package:prava_vrecica/mode_status.dart';
import 'package:prava_vrecica/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/user_provider.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  IntroScreenState createState() => IntroScreenState();
}

class IntroScreenState extends State<IntroScreen> {
  final PageController _controller = PageController();
  final int _numPages = 3;
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final localizations = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.updateSystemUI(false);

    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: PageView(
              controller: _controller,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                IntroPage(image: const Image(
                    image: AssetImage('assets/images/onboard_1.jpg')),
                    text: AppLocalizations.of(context)!.intro_1,
                    index: 0),
                IntroPage(image: const Image(
                    image: AssetImage('assets/images/onboard_2.jpg')),
                    text: AppLocalizations.of(context)!.intro_2,
                    index: 1),
                IntroPage(image: const Image(
                    image: AssetImage('assets/images/onboard_3.jpg')),
                    text: AppLocalizations.of(context)!.intro_3,
                    index: 2),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SmoothPageIndicator(
                      controller: _controller,
                      count: _numPages,
                      effect: ExpandingDotsEffect(
                        dotColor: Theme
                            .of(context)
                            .colorScheme
                            .surfaceTint,
                        activeDotColor: Theme
                            .of(context)
                            .colorScheme
                            .primary,
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
                    child: Container(
                      margin: const EdgeInsetsDirectional.symmetric(horizontal: 20),
                      child: TextButton(
                        onPressed: () {
                          userProvider.setWasIntroScreenShown(true);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ModeStatus()));
                        },
                        child: Text(
                          localizations.skip,
                          style: TextStyle(
                            color: Theme
                                .of(context)
                                .colorScheme
                                .onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                    visible: _currentPage != _numPages - 1,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        margin: const EdgeInsetsDirectional.symmetric(
                            vertical: 4, horizontal: 20),
                        child: IconButton(
                          onPressed: () {
                            _controller.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeIn);
                          },
                          icon: Icon(
                            Icons.arrow_right_alt,
                            color: Theme
                                .of(context)
                                .colorScheme
                                .onSurface,
                            size: 40,
                          ),
                        ),
                      ),
                    )),
                Visibility(
                  visible: _currentPage == _numPages - 1,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      margin: const EdgeInsetsDirectional.symmetric(horizontal: 20),
                      child: TextButton(
                        onPressed: () {
                          userProvider.setWasIntroScreenShown(true);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ModeStatus()));
                        },
                        child: Text(
                          localizations.start,
                          style: TextStyle(
                            color: Theme
                                .of(context)
                                .colorScheme
                                .onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
