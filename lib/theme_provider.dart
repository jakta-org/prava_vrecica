import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;

  bool get isDarkMode {
    return themeMode == ThemeMode.dark;
  }

  ThemeProvider(bool isDark) {
    themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme(bool value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    themeMode = value ? ThemeMode.dark : ThemeMode.light;
    sharedPreferences.setBool('is_dark', value);
    updateSystemUI();

    notifyListeners();
  }

  void updateSystemUI() {
    ThemeData theme = isDarkMode ? Themes.darkTheme : Themes.lightTheme;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: theme.colorScheme.background,
      systemNavigationBarIconBrightness: theme.colorScheme.brightness,
      systemNavigationBarDividerColor: Colors.transparent,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: theme.colorScheme.brightness,
    ));
  }
}

class Themes {
  static final lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    primaryColor: Colors.blue,
    colorScheme: const ColorScheme.light(),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: MaterialStateProperty.all(Colors.blue),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Colors.black,
    ),
    splashColor: Colors.blue,
    secondaryHeaderColor: Colors.blue,
  );
  static final darkTheme = ThemeData(
    primarySwatch: Colors.blue,
    primaryColor: Colors.blue,
    colorScheme: const ColorScheme.dark(
      onBackground: Colors.grey,
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Colors.white,
    ),
    splashColor: Colors.blue,
    secondaryHeaderColor: Colors.blue,
  );
}