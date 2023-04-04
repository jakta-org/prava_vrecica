import 'package:flutter/material.dart';
import 'package:prava_vrecica/providers/user_provider.dart';
import 'package:prava_vrecica/screens/account_mode_screen.dart';
import 'package:prava_vrecica/screens/main_screen.dart';
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

    Widget child;

    if (userProvider.userId == -2) {
      child = const AccountModeScreen();
    } else {
      child = const MainScreen();
    }

    return Scaffold(
      body: child,
    );
  }
}