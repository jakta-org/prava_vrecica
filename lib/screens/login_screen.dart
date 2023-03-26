import 'package:flutter/material.dart';
import 'package:prava_vrecica/providers/database_provider.dart';
import 'package:prava_vrecica/providers/user_provider.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/theme_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  String? mail;
  int? passwordHash;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final db = Provider.of<DatabaseProvider>(context, listen: false).database;
    themeProvider.toggleNavigationBar(false);

    final loginFormKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 300,
                  height: 200,
                  padding: const EdgeInsetsDirectional.all(20),
                  margin: const EdgeInsetsDirectional.symmetric(vertical: 40),
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
                          decoration: InputDecoration(
                            icon: const Icon(Icons.password),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor)),
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
                ),
                TextButton(
                  onPressed: () {
                    if (loginFormKey.currentState!.validate()) {
                      loginFormKey.currentState!.save();
                    } else {
                      return;
                    }

                    User? user = db.authenticateUser(mail!, passwordHash!);
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Mail or password not right."),
                      ));
                    } else {
                      userProvider.setUser(user);

                      Navigator.pushNamed(
                        context,
                        'Camera',
                      );
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: 300,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
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
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
