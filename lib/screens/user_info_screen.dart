import 'package:flutter/material.dart';
import 'package:prava_vrecica/providers/user_provider.dart';
import 'package:prava_vrecica/screens/account_mode_screen.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/normal_appbar.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => UserInfoScreenState();
}

class UserInfoScreenState extends State<UserInfoScreen> {
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: normalAppBar(context),
      body: SafeArea(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text("Guest"),
              trailing: logoutButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget logoutButton() {
    return Container(
      alignment: Alignment.center,
      width: 140,
      height: 40,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.all(Radius.circular(50)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.logout,
            color: Theme.of(context).colorScheme.onBackground,
          ),
          TextButton(
            onPressed: () {
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              userProvider.clearUser();

              final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
              themeProvider.toggleNavigationBar(false);

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccountModeScreen(),
                  settings: const RouteSettings(name: 'Account'),
                ),
              );
            },
            child: Text(
              "Sign out",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
