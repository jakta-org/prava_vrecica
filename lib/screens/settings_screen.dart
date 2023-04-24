import 'package:flutter/material.dart';
import 'package:prava_vrecica/providers/ai_model_provider.dart';
import 'package:prava_vrecica/providers/categorization_provider.dart';
import 'package:prava_vrecica/providers/localization_provider.dart';
import 'package:prava_vrecica/widgets/normal_appbar.dart';
import 'package:prava_vrecica/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: normalAppBar(context, AppLocalizations.of(context)!.settings_screen),
      body: SafeArea(
        child: ListView(
          children: [
            modeSwitch(),
            thresholdSlider(),
            languageMenu(),
          ],
        ),
      ),
    );
  }

  Widget modeSwitch() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    Icon modeIcon = themeProvider.isDarkMode
        ? const Icon(Icons.dark_mode)
        : const Icon(Icons.light_mode);
    Text modeText = themeProvider.isDarkMode
        ? Text(AppLocalizations.of(context)!.dark_mode)
        : Text(AppLocalizations.of(context)!.light_mode);

    return ListTile(
      leading: modeIcon,
      title: modeText,
      trailing: Switch.adaptive(
        activeTrackColor: Theme.of(context).colorScheme.primary,
        thumbColor:
            MaterialStatePropertyAll(Theme.of(context).colorScheme.surface),
        inactiveTrackColor: Theme.of(context).colorScheme.surfaceTint,
        value: themeProvider.isDarkMode,
        onChanged: (value) {
          themeProvider.toggleTheme(value);
        },
      ),
    );
  }

  Widget thresholdSlider() {
    final aiModelProvider =
        Provider.of<AiModelProvider>(context, listen: false);
    double localThreshold = aiModelProvider.threshold;

    return ListTile(
      leading: const Icon(Icons.percent),
      title: Text(AppLocalizations.of(context)!.detection_sensitivity),
      trailing: SizedBox(
        width: 180,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 150,
              child: Slider(
                activeColor: Theme.of(context).colorScheme.primary,
                inactiveColor: Theme.of(context).colorScheme.surfaceTint,
                thumbColor: Theme.of(context).colorScheme.surface,
                value: localThreshold,
                onChanged: (value) {
                  setState(() => localThreshold = value);
                  aiModelProvider.setThreshold(value);
                },
                min: 0.0,
                max: 1.0,
                divisions: 20,
              ),
            ),
            Text(localThreshold.toString()),
          ],
        ),
      ),
    );
  }

  Widget languageMenu() {
    final localizationProvider =
        Provider.of<LocalizationProvider>(context, listen: false);
    Language selectedLang = localizationProvider.language;
    Text displayLang = Text("${selectedLang.flag}  ${selectedLang.name}");
    final categorizationProvider =
        Provider.of<CategorizationProvider>(context, listen: false);

    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(AppLocalizations.of(context)!.language),
      trailing: DropdownButton<Language>(
        underline: Container(),
        hint: displayLang,
        dropdownColor: Theme.of(context).colorScheme.surface,
        elevation: 2,
        items: Language.languageList()
            .map(
              (lang) => DropdownMenuItem(
                value: lang,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${lang.flag}  ${lang.name}",
                    ),
                  ],
                ),
              ),
            )
            .toList(),
        onChanged: (Language? value) {
          if (value != null) {
            localizationProvider.setLocale(value.languageCode);
            categorizationProvider.setObjectsList(value.languageCode);
          }
        },
      ),
    );
  }
}
