import 'package:flutter/material.dart';
import 'package:prava_vrecica/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class AccountModeScreen extends StatefulWidget {
  const AccountModeScreen({super.key});

  @override
  State<AccountModeScreen> createState() => AccountModeScreenState();
}

class AccountModeScreenState extends State<AccountModeScreen> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.toggleNavigationBar(false);

    if (userProvider.user != null) {
      Navigator.pushNamed(
        context,
        'Camera',
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                userButton('Login', 'Personal',
                    Theme.of(context).colorScheme.surface),
                userButton(null, 'Education', Colors.teal.shade300),
                userButton(null, 'Business', Colors.blueGrey.shade300),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget userButton(String? routeName, String text, Color backgroundColor) {
    return TextButton(
      onPressed: () {
        Navigator.pushNamed(
          context,
          routeName ?? 'Account',
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
