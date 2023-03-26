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

  void toggleNavigationBar(bool value) {
    ThemeData theme = isDarkMode ? Themes.darkTheme : Themes.lightTheme;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: value ? theme.colorScheme.surface : theme.colorScheme.background,
    ));
  }

  void updateSystemUI() {
    ThemeData theme = isDarkMode ? Themes.darkTheme : Themes.lightTheme;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: theme.colorScheme.surface,
      systemNavigationBarIconBrightness: Brightness.light,
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
    colorScheme: ColorScheme.light(
      primary: Colors.blue,
      surface: Colors.white,
      background: Colors.grey.shade200,
    ),
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
    colorScheme: ColorScheme.dark(
      primary: Colors.blue,
      surface: Colors.grey.shade800,
      background: Colors.grey.shade900,
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Colors.white,
    ),
    splashColor: Colors.blue,
    secondaryHeaderColor: Colors.blue,
  );
}