import 'package:flutter/material.dart';
import 'package:prava_vrecica/database/database_provider.dart';
import 'package:prava_vrecica/mode_status.dart';
import 'package:prava_vrecica/providers/user_provider.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  String? mail;
  int? passwordHash;
  final loginFormKey = GlobalKey<FormState>();
  bool loginAccess = true;

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
                /*
                orDivider(context),
                userButton(
                    const LoginScreen(),
                    AppLocalizations.of(context)!.continue_google,
                    Theme.of(context).colorScheme.surface,
                    Icons.g_mobiledata,
                    Colors.black),
                userButton(
                    const LoginScreen(),
                    AppLocalizations.of(context)!.continue_apple,
                    Theme.of(context).colorScheme.surface,
                    Icons.apple,
                    Colors.black),

                 */
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
                  return AppLocalizations.of(context)!.field_empty;
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
                  return AppLocalizations.of(context)!.field_empty;
                }
                return null;
              },
            ),
            loginButton(),
          ],
        ),
      ),
    );
  }

  Widget loginButton() {
    return Container(
      alignment: Alignment.center,
      width: 300,
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
      ),
      margin: const EdgeInsetsDirectional.symmetric(vertical: 30),
      child: GestureDetector(
        onTap: () async {
          if (!loginAccess) {
            return;
          } else {
            setState(() {
              loginAccess = false;
            });
          }
          final databaseProvider =
              Provider.of<DatabaseProvider>(context, listen: false);
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);

          if (loginFormKey.currentState!.validate()) {
            loginFormKey.currentState!.save();
          } else {
            return;
          }

          int? userValid = await databaseProvider.authenticateUser(
              null, mail, passwordHash.toString());
          if (userValid == null) {
            if (context.mounted) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(
                content: Text(AppLocalizations.of(context)!.field_wrong),
              ));
            }
          } else {
            await userProvider.setUser(userValid);

            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ModeStatus(),
                ),
              );
            }
          }

          setState(() {
            loginAccess = false;
          });
        },
        child: Text(
          AppLocalizations.of(context)!.login,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget userButton(Widget route, String text, Color backgroundColor,
      IconData iconData, Color iconColor) {
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
