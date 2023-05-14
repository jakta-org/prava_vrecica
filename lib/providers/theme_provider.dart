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
    await sharedPreferences.setBool('is_dark', value);
    updateSystemUI(true);

    notifyListeners();
  }

  void updateSystemUI(bool value) {
    ThemeData theme = isDarkMode ? Themes.darkTheme : Themes.lightTheme;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: value ? theme.colorScheme.surface : theme.colorScheme.background,
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
    canvasColor: Colors.transparent,
    colorScheme: ColorScheme.light(
      primary: Colors.blue,
      surface: Colors.white,
      background: Colors.grey.shade200,
      surfaceTint: Colors.black12,
      surfaceVariant: Colors.white,
      onSurface: Colors.black,
      secondary: Colors.transparent,
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: MaterialStateProperty.all(Colors.blue),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Colors.black,
    ),
    splashColor: Colors.blue,
    secondaryHeaderColor: Colors.blue,
    highlightColor: Colors.transparent,
  );
  static final darkTheme = ThemeData(
    primarySwatch: Colors.blue,
    primaryColor: Colors.blue,
    canvasColor: Colors.transparent,
    colorScheme: ColorScheme.dark(
      primary: Colors.blue,
      surface: Colors.grey.shade800,
      background: Colors.grey.shade900,
      surfaceTint: Colors.white12,
      surfaceVariant: Colors.grey.shade300,
      onSurface: Colors.grey.shade300,
      secondary: Colors.transparent,
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Colors.white,
    ),
    splashColor: Colors.blue,
    secondaryHeaderColor: Colors.blue,
    highlightColor: Colors.transparent,
  );
}