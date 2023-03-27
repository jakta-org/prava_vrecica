import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:prava_vrecica/screens/camera_screen.dart';
import 'package:prava_vrecica/screens/info_screen.dart';
import 'package:prava_vrecica/screens/statistics_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key}) : super();

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int pageIndex = 1;
  int oldPageIndex = -1;
  List<Widget> pageList = [
    const StatisticsScreen(),
    const CameraScreen(),
    const InfoScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 700),
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
      items: const [
        BottomNavigationBarItem(
          label: 'Statistics',
          icon: Icon(
            Icons.bar_chart,
          ),
        ),
        BottomNavigationBarItem(
          label: 'Camera',
          icon: Icon(
            Icons.camera_alt,
          ),
        ),
        BottomNavigationBarItem(
          label: 'Info',
          icon: Icon(
            Icons.info,
          ),
        ),
      ],
    );
  }
}
