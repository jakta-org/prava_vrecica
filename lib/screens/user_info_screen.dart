import 'package:flutter/material.dart';
import 'package:prava_vrecica/providers/user_provider.dart';
import 'package:prava_vrecica/screens/account_mode_screen.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/normal_appbar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
      appBar: normalAppBar(context, AppLocalizations.of(context)!.user_screen),
      body: SafeArea(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: Text(AppLocalizations.of(context)!.guestmode_name),
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
              themeProvider.updateSystemUI(false);

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccountModeScreen(),
                ),
              );
            },
            child: Text(
                AppLocalizations.of(context)!.logout,
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
