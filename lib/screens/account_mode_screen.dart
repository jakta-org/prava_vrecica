import 'package:flutter/material.dart';
import 'package:prava_vrecica/providers/theme_provider.dart';
import 'package:prava_vrecica/screens/login_screen.dart';
import 'package:prava_vrecica/widgets/or_divider.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import 'main_screen.dart';

class AccountModeScreen extends StatefulWidget {
  const AccountModeScreen({super.key});

  @override
  State<AccountModeScreen> createState() => AccountModeScreenState();
}

class AccountModeScreenState extends State<AccountModeScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    themeProvider.toggleNavigationBar(false);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                userButton(
                    const AccountModeScreen(),
                    'Account',
                    'Register',
                    Theme.of(context).colorScheme.primary,
                    Icons.account_circle,
                    Colors.black),
                userButton(
                    const LoginScreen(),
                    'Login',
                    'Sign in',
                    Theme.of(context).colorScheme.primary,
                    Icons.login,
                    Colors.black),
                orDivider(context),
                guestModeButton(
                  const MainScreen(),
                  'Main',
                  'Continue as Guest',
                  Theme.of(context).colorScheme.surface,
                  Icons.no_accounts,
                  Colors.black,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget userButton(Widget route, String routeName, String text,
      Color backgroundColor, IconData iconData, Color iconColor) {
    return Container(
      alignment: Alignment.center,
      width: 300,
      height: 60,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(50)),
      ),
      margin: const EdgeInsetsDirectional.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData,
            color: iconColor,
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => route,
                  settings: RouteSettings(name: routeName),
                ),
              );
            },
            child: Text(
              text,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget guestModeButton(Widget route, String routeName, String text,
      Color backgroundColor, IconData iconData, Color iconColor) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Container(
      alignment: Alignment.center,
      width: 300,
      height: 60,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(50)),
      ),
      margin: const EdgeInsetsDirectional.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData,
            color: iconColor,
          ),
          TextButton(
            onPressed: () {
              userProvider.setUser(-1);

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => route,
                  settings: RouteSettings(name: routeName),
                ),
              );
            },
            child: Text(
              text,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
