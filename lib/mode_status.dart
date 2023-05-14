import 'package:flutter/material.dart';
import 'package:prava_vrecica/feedback/detection_entry_queue_provider.dart';
import 'package:prava_vrecica/providers/theme_provider.dart';
import 'package:prava_vrecica/providers/user_provider.dart';
import 'package:prava_vrecica/screens/account_mode_screen.dart';
import 'package:prava_vrecica/screens/loading_screen.dart';
import 'package:prava_vrecica/screens/main_screen.dart';
import 'package:prava_vrecica/statistics/statistics_provider.dart';
import 'package:provider/provider.dart';

class ModeStatus extends StatefulWidget {
  const ModeStatus({super.key});

  @override
  ModeStatusState createState() => ModeStatusState();
}

class ModeStatusState extends State<ModeStatus> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.updateSystemUI(false);

    Widget child;

    if (userProvider.userId == -2) {
      child = const AccountModeScreen();
    } else {
      child = MainScreen();
    }

    return FutureBuilder(
      future: providersInit(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        }

        return child;
      },
    );
  }

  Future<void> providersInit() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final statisticsProvider = Provider.of<StatisticsProvider>(context, listen: false);
    final detectionEntryQueueProvider = Provider.of<DetectionEntryQueueProvider>(context, listen: false);
    await userProvider.init();
    await statisticsProvider.init();
    await detectionEntryQueueProvider.init();
  }
}