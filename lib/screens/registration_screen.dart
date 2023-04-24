import 'package:flutter/material.dart';
import 'package:prava_vrecica/providers/database_provider.dart';
import 'package:prava_vrecica/providers/user_provider.dart';
import 'package:prava_vrecica/widgets/or_divider.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => RegistrationScreenState();
}

class RegistrationScreenState extends State<RegistrationScreen> {
  String? mail;
  int? passwordHash;
  final loginFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.updateSystemUI(false);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                loginForm(),
                orDivider(context),
                userButton(
                    const RegistrationScreen(),
                    AppLocalizations.of(context)!.continue_google,
                    Theme.of(context).colorScheme.surface,
                    Icons.g_mobiledata,
                    Colors.black),
                userButton(
                    const RegistrationScreen(),
                    AppLocalizations.of(context)!.continue_apple,
                    Theme.of(context).colorScheme.surface,
                    Icons.apple,
                    Colors.black),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget loginForm() {
    return Container(
      width: 300,
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 0),
      margin: const EdgeInsetsDirectional.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
      ),
      child: Form(
        key: loginFormKey,
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(
                icon: const Icon(Icons.perm_identity),
                focusColor: Theme.of(context).primaryColor,
                hintText: AppLocalizations.of(context)!.valid_prompt,
                labelText: AppLocalizations.of(context)!.valid_var,
              ),
              onSaved: (String? value) {
                mail = value;
              },
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return "This field cannot be empty!";
                }
                return null;
              },
            ),
            TextFormField(
              obscureText: true,
              decoration: InputDecoration(
                icon: const Icon(Icons.password),
                focusedBorder: UnderlineInputBorder(
                    borderSide:
                    BorderSide(color: Theme.of(context).primaryColor)),
                hintText: AppLocalizations.of(context)!.password_prompt,
                labelText: AppLocalizations.of(context)!.password,
              ),
              onSaved: (String? value) {
                passwordHash = value.hashCode;
              },
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return "This field cannot be empty!";
                }
                return null;
              },
            ),
            TextFormField(
              decoration: InputDecoration(
                icon: const Icon(Icons.lock),
                focusColor: Theme.of(context).primaryColor,
                hintText: AppLocalizations.of(context)!.confirm_pass_prompt,
                labelText: AppLocalizations.of(context)!.confirm_pass,
              ),
              onSaved: (String? value) {
                mail = value;
              },
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return "This field cannot be empty!";
                }
                return null;
              },
            ),
            TextFormField(
              obscureText: true,
              decoration: InputDecoration(
                icon: const Icon(Icons.key),
                focusedBorder: UnderlineInputBorder(
                    borderSide:
                    BorderSide(color: Theme.of(context).primaryColor)),
                hintText: AppLocalizations.of(context)!.entr_key_prompt,
                labelText: AppLocalizations.of(context)!.entrance_key,
              ),
              onSaved: (String? value) {
                passwordHash = value.hashCode;
              },
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return "This field cannot be empty!";
                }
                return null;
              },
            ),
            registerButton(),
          ],
        ),
      ),
    );
  }

  Widget registerButton() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final db = Provider.of<DatabaseProvider>(context, listen: false).database;

    return Container(
      alignment: Alignment.center,
      width: 300,
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
      ),
      margin: const EdgeInsetsDirectional.symmetric(vertical: 30),
      child: TextButton(
        onPressed: () {
          /*
          if (loginFormKey.currentState!.validate()) {
            loginFormKey.currentState!.save();
          } else {
            return;
          }

          int userId = db.authenticateUser(mail!, passwordHash!);
          if (userId == -1) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Mail or password not right."),
            ));
          } else {
            userProvider.setUser(userId);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MainScreen(),
                settings: const RouteSettings(name: 'Main'),
              ),
            );
          }
           */
        },
        child: Text(
          AppLocalizations.of(context)!.register,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget userButton(Widget route, String text,
      Color backgroundColor, IconData iconData, Color iconColor) {
    return Container(
      alignment: Alignment.center,
      width: 300,
      height: 60,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
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
              /*
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => route,
                ),
              );
              */
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
}
