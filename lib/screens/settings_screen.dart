import 'package:flutter/material.dart';
import 'package:prava_vrecica/providers/ai_model_provider.dart';
import 'package:prava_vrecica/widgets/normal_appbar.dart';
import 'package:prava_vrecica/providers/theme_provider.dart';
import 'package:provider/provider.dart';

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
      appBar: normalAppBar(context),
      body: SafeArea(
        child: ListView(
          children: [
            modeSwitch(),
            thresholdSlider(),
          ],
        ),
      ),
    );
  }

  Widget modeSwitch() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    Icon modeIcon = themeProvider.isDarkMode ? const Icon(Icons.dark_mode) : const Icon(Icons.light_mode);
    Text modeText = themeProvider.isDarkMode ? const Text("Dark mode") : const Text("Light mode");

    return ListTile(
      leading: modeIcon,
      title: modeText,
      trailing: Switch.adaptive(
        activeTrackColor: Theme.of(context).colorScheme.primary,
        thumbColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.surface),
        inactiveTrackColor: Theme.of(context).colorScheme.surfaceTint,
        value: themeProvider.isDarkMode,
        onChanged: (value) {
          themeProvider.toggleTheme(value);
          modeIcon = value
              ? const Icon(Icons.dark_mode)
              : const Icon(Icons.light_mode);
          modeText = value ? const Text("Dark mode") : const Text("Light mode");
        },
      ),
    );
  }

  Widget thresholdSlider() {
    final aiModelProvider = Provider.of<AiModelProvider>(context, listen: false);
    double localThreshold = aiModelProvider.threshold;

    return ListTile(
      leading: const Icon(Icons.percent),
      title: const Text("Detection sensitivity"),
      trailing: SizedBox(
        width: 200,
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
}
