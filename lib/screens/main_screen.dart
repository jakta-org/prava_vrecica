import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:prava_vrecica/screens/camera_screen.dart';
import 'package:prava_vrecica/screens/info_screen.dart';
import 'package:prava_vrecica/statistics/statistics_screen.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key}) : super();

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int pageIndex = 1;
  int oldPageIndex = -1;
  int pageSensitivity = 5; // how many pixels to move to change page
  List<Widget> pageList = [
    const StatisticsScreen(),
    const CameraScreen(),
    const InfoScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.updateSystemUI(true);

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx > pageSensitivity) {
          // swipe right
          if (pageIndex > 0 && oldPageIndex == -1) {
            setState(() {
              oldPageIndex = pageIndex;
              pageIndex--;
            });
          }
        } else if (details.delta.dx < -pageSensitivity) {
          // swipe left
          if (pageIndex < pageList.length - 1 && oldPageIndex == -1) {
            setState(() {
              oldPageIndex = pageIndex;
              pageIndex++;
            });
          }
        }
      },
      onHorizontalDragEnd: (_) {
        oldPageIndex = -1;
      },
      child: Scaffold(
        body: PageTransitionSwitcher(
          duration: const Duration(milliseconds: 300),
          reverse: transitionOrientation(oldPageIndex, pageIndex),
          transitionBuilder: (child, primaryAnimation, secondaryAnimation) =>
              SharedAxisTransition(
                animation: primaryAnimation,
                secondaryAnimation: secondaryAnimation,
                transitionType: SharedAxisTransitionType.horizontal,
                child: child,
              ),
          child: pageList[pageIndex],
        ),
        bottomNavigationBar: navbar(context, pageIndex),
      ),
    );
  }

  bool transitionOrientation(int oldIndex, int newIndex) {
    if (oldIndex == 0 && newIndex == pageList.length - 1) {
      return true;
    } else if (oldIndex == pageList.length - 1 && newIndex == 0) {
      return false;
    } else if (oldIndex < newIndex) {
      return false;
    } else {
      return true;
    }
  }

  Widget navbar(BuildContext context, int currentIndex) {
    return BottomNavigationBar(
      showSelectedLabels: true,
      showUnselectedLabels: false,
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedIconTheme: IconThemeData(
        color: Theme.of(context).colorScheme.primary,
      ),
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedIconTheme: IconThemeData(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      unselectedItemColor: Theme.of(context).colorScheme.onSurface,
      backgroundColor: Theme.of(context).colorScheme.surface,
      onTap: (value) {
        setState(() {
          oldPageIndex = pageIndex;
          pageIndex = value;
        });
      },
      items: [
        BottomNavigationBarItem(
          label: AppLocalizations.of(context)!.statistics_screen,
          icon: const Icon(
            Icons.bar_chart,
          ),
        ),
        BottomNavigationBarItem(
          label: AppLocalizations.of(context)!.camera_screen,
          icon: const Icon(
            Icons.camera_alt,
          ),
        ),
        BottomNavigationBarItem(
          label: AppLocalizations.of(context)!.statistics_screen,
          icon: const Icon(
            Icons.info,
          ),
        ),
      ],
    );
  }
}
