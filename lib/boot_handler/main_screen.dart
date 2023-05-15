import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:prava_vrecica/ai/camera_screen.dart';
import 'package:prava_vrecica/info/info_screen.dart';
import 'package:prava_vrecica/user/settings_screen.dart';
import 'package:prava_vrecica/statistics/statistics_screen.dart';
import 'package:prava_vrecica/user/user_info_screen.dart';
import 'package:provider/provider.dart';
import '../group_profile/group_model.dart';
import '../user/theme_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../user/user_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key}) : super();

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int pageIndex = 1;
  int oldPageIndex = -1;
  late UserProvider userProvider;
  int pageSensitivity = 5; // how m

  bool groupsEnabled = false;

  List<StatefulWidget> pageList = [
    const StatisticsScreen(),
    const CameraScreen(),
    const InfoScreen(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.updateSystemUI(true);

    userProvider = Provider.of<UserProvider>(context, listen: true);

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
        floatingActionButton: Container(
          margin: const EdgeInsetsDirectional.only(top: 10, start: 10, end: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              userProvider.userId < 0 ? Container(height: 30) : AnimatedContainer(
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Theme.of(context).colorScheme.surfaceTint,
                        blurRadius: 15.0)
                  ],
                ),
                margin: const EdgeInsetsDirectional.symmetric(horizontal: 13),
                padding: EdgeInsets.zero,
                duration: const Duration(milliseconds: 300),
                child: DropdownButtonHideUnderline(
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButton<Group>(
                      value: userProvider.setGroup,
                      borderRadius: BorderRadius.circular(15),
                      iconEnabledColor: Theme.of(context).colorScheme.shadow,
                      iconDisabledColor: Theme.of(context).colorScheme.shadow,
                      iconSize: 30,
                      dropdownColor: Theme.of(context).colorScheme.surfaceVariant,
                      elevation: 0,
                      items: createGroupProfiles(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            userProvider.setNewGroup(value);
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  OpenContainer(
                    closedElevation: 0,
                    openElevation: 0,
                    transitionType: ContainerTransitionType.fadeThrough,
                    closedColor: Colors.transparent,
                    transitionDuration: const Duration(milliseconds: 300),
                    routeSettings: const RouteSettings(name: 'User'),
                    openBuilder: (context, action) => const UserInfoScreen(),
                    closedBuilder: (context, VoidCallback openContainer) =>
                        IconButton(
                      onPressed: openContainer,
                      padding: EdgeInsets.zero,
                      iconSize: 35,
                      icon: Icon(
                        Icons.account_circle,
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        shadows: <Shadow>[
                          Shadow(
                              color: Theme.of(context).colorScheme.surfaceTint,
                              blurRadius: 15.0)
                        ],
                      ),
                    ),
                  ),
                  OpenContainer(
                    closedElevation: 0,
                    openElevation: 0,
                    transitionType: ContainerTransitionType.fadeThrough,
                    closedColor: Colors.transparent,
                    transitionDuration: const Duration(milliseconds: 300),
                    routeSettings: const RouteSettings(name: 'Settings'),
                    openBuilder: (context, action) => const SettingsScreen(),
                    closedBuilder: (context, VoidCallback openContainer) =>
                        IconButton(
                      onPressed: openContainer,
                      padding: EdgeInsets.zero,
                      iconSize: 35,
                      icon: Icon(
                        Icons.settings,
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        shadows: <Shadow>[
                          Shadow(
                              color: Theme.of(context).colorScheme.surfaceTint,
                              blurRadius: 15.0)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
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

  List<DropdownMenuItem<Group>> createGroupProfiles() {
    DropdownMenuItem<Group> createSingle(Group value, {String? override}) {
      return DropdownMenuItem<Group>(
        value: value,
        alignment: AlignmentDirectional.centerStart,
        child: Wrap(
          direction: Axis.horizontal,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              margin: const EdgeInsetsDirectional.only(end: 10),
              child: Icon(
                value.settings.iconData,
                color: value.settings.iconColor,
              ),
            ),
            Text(
              override ?? value.settings.name,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.shadow,
              ),
            ),
          ],
        ),
      );
    }

    List<DropdownMenuItem<Group>> rList = [];

    rList.add(createSingle(Group.personal(),
        override: AppLocalizations.of(context)!.personal));

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    for (Group group in userProvider.groups) {
      rList.add(createSingle(group));
    }

    return rList;
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
            Icons.widgets,
          ),
        ),
        BottomNavigationBarItem(
          label: AppLocalizations.of(context)!.camera_screen,
          icon: const Icon(
            Icons.camera_alt,
          ),
        ),
        BottomNavigationBarItem(
          label: AppLocalizations.of(context)!.info_screen,
          icon: const Icon(
            Icons.info,
          ),
        ),
      ],
    );
  }
}
