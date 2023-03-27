import 'package:flutter/material.dart';
import 'package:prava_vrecica/widgets/normal_appbar.dart';
import 'package:prava_vrecica/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  late Icon modeIcon;
  late Text modeText;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context, listen: false);
    modeIcon = provider.isDarkMode ? const Icon(Icons.dark_mode) : const Icon(Icons.light_mode);
    modeText = provider.isDarkMode ? const Text("Dark mode") : const Text("Light mode");

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: normalAppBar(context),
      body: SafeArea(
        child: ListView(
          children: [
            ListTile(
              leading: modeIcon,
              title: modeText,
              trailing: modeSwitch(),
            )
          ],
        ),
      ),
    );
  }

  Widget modeSwitch() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Switch.adaptive(
        value: themeProvider.isDarkMode,
        onChanged: (value) {
          final provider = Provider.of<ThemeProvider>(context, listen: false);
          provider.toggleTheme(value);
          modeIcon = value ? const Icon(Icons.dark_mode) : const Icon(Icons.light_mode);
          modeText = value ? const Text("Dark mode") : const Text("Light mode");
        },
    );
  }
}
