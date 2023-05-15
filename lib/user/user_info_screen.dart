import 'package:flutter/material.dart';
import 'package:prava_vrecica/user/user_provider.dart';
import 'package:prava_vrecica/user/account_mode_screen.dart';
import 'package:provider/provider.dart';
import 'user_model.dart';
import 'theme_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../statistics/statistics_provider.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => UserInfoScreenState();
}

class UserInfoScreenState extends State<UserInfoScreen> {
  late UserProvider userProvider;

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: userInfoAppBar(),
      body: SafeArea(
        child: ListView(
          children: getUserInfo(userProvider.user) + [
            clearStatsButton(),
          ],
        ),
      ),
    );
  }

  List<ListTile> getUserInfo(User? user) {
    List<ListTile> rList = [];

    if (user == null) {
      rList.add(
        ListTile(
          leading: const Icon(Icons.account_circle),
          title: Text(AppLocalizations.of(context)!.guestmode_name),
        ),
      );
    } else {
      rList.addAll([
        ListTile(
          leading: const Icon(Icons.mail),
          title: Text(AppLocalizations.of(context)!.email),
          trailing: Text(user.email),
        ),
        ListTile(
          leading: const Icon(Icons.account_circle),
          title: Text(AppLocalizations.of(context)!.username),
          trailing: Text(notSet(user.username) ? AppLocalizations.of(context)!.not_set : user.username!),
        ),
        ListTile(
          leading: const Icon(Icons.abc),
          title: Text(AppLocalizations.of(context)!.first_name),
          trailing: Text(notSet(user.firstName) ? AppLocalizations.of(context)!.not_set : user.firstName!),
        ),
        ListTile(
          leading: const Icon(Icons.perm_identity),
          title: Text(AppLocalizations.of(context)!.last_name),
          trailing: Text(notSet(user.lastName) ? AppLocalizations.of(context)!.not_set : user.lastName!),
        ),
        ListTile(
          leading: const Icon(Icons.phone),
          title: Text(AppLocalizations.of(context)!.phone_number),
          trailing: Text(notSet(user.phoneNumber) ? AppLocalizations.of(context)!.not_set : user.phoneNumber!),
        ),
      ]);
    }

    return rList;
  }

  bool notSet(String? string) {
    if (string == null || string == "") {
      return true;
    } else {
      return false;
    }
  }

  Widget logoutButton() {
    return Container(
      alignment: Alignment.center,
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
            userProvider.userId == -1 ? Icons.supervisor_account_sharp : Icons.logout,
            color: Theme.of(context).colorScheme.onBackground,
          ),
          TextButton(
            onPressed: () async {
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
              await userProvider.clearUser();
              themeProvider.updateSystemUI(false);

              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountModeScreen(),
                  ),
                );
              }
            },
            child: Text(
                userProvider.userId == -1 ? AppLocalizations.of(context)!.return_accounts : AppLocalizations.of(context)!.logout,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  ListTile clearStatsButton() {
    return ListTile(
      leading: const Icon(Icons.bar_chart),
      title: Text(AppLocalizations.of(context)!.clear_statistics),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(AppLocalizations.of(context)!.clear_statistics),
                content: Text(AppLocalizations.of(context)!.clear_statistics_text),
                actions: [
                  TextButton(
                    child: Text(AppLocalizations.of(context)!.cancel),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                      onPressed: () {
                        Provider.of<StatisticsProvider>(context, listen: false).clearStats();
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: Text(AppLocalizations.of(context)!.clear),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  AppBar userInfoAppBar() {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
              AppLocalizations.of(context)!.user_screen,
              style: TextStyle(color: Theme.of(context).colorScheme.onBackground)),
          logoutButton()
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      iconTheme: IconThemeData(
        color: Theme.of(context).colorScheme.onBackground,
      ),
      shadowColor: Colors.transparent,
      shape: const Border(bottom: BorderSide(color: Colors.grey, width: 0.1)),
    );
  }
}
