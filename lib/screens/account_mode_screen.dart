import 'package:flutter/material.dart';
import 'package:prava_vrecica/providers/theme_provider.dart';
import 'package:prava_vrecica/screens/login_screen.dart';
import 'package:provider/provider.dart';

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
                userButton(const LoginScreen(), 'Login', 'Personal', Theme.of(context).colorScheme.primary),
                userButton(const AccountModeScreen(), 'Account', 'Education', Colors.teal.shade300),
                userButton(const AccountModeScreen(), 'Account', 'Business', Colors.blueGrey.shade300),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget userButton(Widget route, String routeName, String text, Color backgroundColor) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => route,
            settings: RouteSettings(name: routeName),
          ),
        );
      },
      child: Container(
        alignment: Alignment.center,
        width: 300,
        height: 60,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(50)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
