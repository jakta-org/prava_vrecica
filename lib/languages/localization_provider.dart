import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationProvider extends ChangeNotifier {
  String locale = "hr";
  late Language language;

  LocalizationProvider(this.locale) {
    language = Language.languageList().firstWhere((lang) => lang.languageCode == locale);
  }

  Future<void> setLocale(String locale) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    this.locale = locale;
    sharedPreferences.setString('locale', this.locale);

    language = Language.languageList().firstWhere((lang) => lang.languageCode == this.locale);

    notifyListeners();
  }
}

class Language {
  final int id;
  final String flag;
  final String name;
  final String languageCode;

  Language(this.id, this.flag, this.name, this.languageCode);

  static List<Language> languageList() {
    return <Language>[
      Language(0, "🇭🇷", "hrvatski", "hr"),
      Language(1, "🇬🇧", "English", "en"),
    ];
  }
}