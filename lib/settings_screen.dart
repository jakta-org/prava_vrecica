import 'package:flutter/material.dart';
import 'package:prava_vrecica/theme_provider.dart';
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
    modeIcon = provider.isDarkMode ? Icon(Icons.dark_mode) : Icon(Icons.light_mode);
    modeText = provider.isDarkMode ? Text("Dark mode") : Text("Light mode");

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text("Settings", style: TextStyle(color: Theme.of(context).colorScheme.onBackground)),
        backgroundColor: Theme.of(context).colorScheme.background,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onBackground,
        ),
        shadowColor: Colors.transparent,
        shape: const Border(bottom: BorderSide(color: Colors.grey, width: 0.1)),
      ),
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
          modeIcon = value ? Icon(Icons.dark_mode) : Icon(Icons.light_mode);
          modeText = value ? Text("Dark mode") : Text("Light mode");
        },
    );
  }
}
