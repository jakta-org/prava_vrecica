import 'package:flutter/material.dart';
import 'package:prava_vrecica/providers/database_provider.dart';
import 'package:prava_vrecica/providers/user_provider.dart';
import 'package:prava_vrecica/screens/main_screen.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  String? mail;
  int? passwordHash;
  final loginFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.toggleNavigationBar(false);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                loginForm(),
                loginButton(),
                const Divider(
                  thickness: 2,
                  height: 40,
                  indent: 40,
                  endIndent: 40,
                ),
                guestModeButton(),
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
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 40),
      margin: const EdgeInsetsDirectional.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(50)),
      ),
      child: Form(
        key: loginFormKey,
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(
                icon: const Icon(Icons.mail),
                focusColor: Theme.of(context).primaryColor,
                hintText: 'Your e-mail address',
                labelText: 'Mail',
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
                hintText: 'Your password',
                labelText: 'Password',
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
          ],
        ),
      ),
    );
  }

  Widget loginButton() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final db = Provider.of<DatabaseProvider>(context, listen: false).database;

    return TextButton(
      onPressed: () {
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
      },
      child: Container(
        alignment: Alignment.center,
        width: 300,
        height: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: const BorderRadius.all(Radius.circular(50)),
        ),
        child: Text(
          'Sign in',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  Widget guestModeButton() {
    return TextButton(
      onPressed: () {},
      child: Container(
        alignment: Alignment.center,
        width: 300,
        height: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: const BorderRadius.all(Radius.circular(50)),
        ),
        child: Text(
          'Continue as guest',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
