import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:prava_vrecica/providers/database_provider.dart';
import 'package:prava_vrecica/providers/user_provider.dart';
import 'package:prava_vrecica/screens/account_mode_screen.dart';
import 'package:prava_vrecica/screens/login_screen.dart';
import 'package:prava_vrecica/screens/settings_screen.dart';
import 'package:prava_vrecica/screens/statistics_screen.dart';
import 'package:prava_vrecica/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/user_model.dart';
import 'screens/camera_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  final isDark = sharedPreferences.getBool('is_dark') ?? false;
  final userJson = sharedPreferences.getString('user');
  final user = userJson != null ? User.fromJson(json.decode(userJson)) : null;
  runApp(App(isDark: isDark, user: user));
}

class App extends StatelessWidget {
  final User? user;
  final bool isDark;

  const App({super.key, required this.isDark, required this.user});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider(user)),
        ChangeNotifierProvider(create: (context) => ThemeProvider(isDark)),
        ChangeNotifierProvider(create: (context) => DatabaseProvider()),
      ],
      builder: (context, _) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        themeProvider.updateSystemUI();

        return MaterialApp(
          title: 'Prava Vrećica',
          themeMode: themeProvider.themeMode,
          theme: Themes.lightTheme,
          darkTheme: Themes.darkTheme,
          home: const AccountModeScreen(),
          routes: {
            'Camera': (BuildContext context) => const CameraScreen(),
            'Settings': (BuildContext context) => const SettingsScreen(),
            'Statistics': (BuildContext context) => const StatisticsScreen(),
            'Account': (BuildContext context) => const AccountModeScreen(),
            'Login': (BuildContext context) => const LoginScreen(),
          },
        );
      },
    );
  }
}
