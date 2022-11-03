import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bfrbsys/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final Icon navBarIcon = const Icon(Icons.settings_outlined);
  final Icon navBarIconSelected = const Icon(Icons.settings);
  final String navBarTitle = 'Settings';

  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SharedPreferences prefs;
  late bool isDark;

  Future<void> lightsOff(bool value, {BuildContext? withContext}) async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setBool("darkTheme", value);
    Provider.of<ThemeProvider>(withContext!, listen: false).setDark(value);
  }

  @override
  Widget build(BuildContext context) {
    isDark = Provider.of<ThemeProvider>(context, listen: true).isDark;
    return Scaffold(
      body: Center(
        child: Switch(
          value: isDark,
          onChanged: (bool newBool) {
            lightsOff(newBool, withContext: context);
          },
        ),
      ),
    );
  }
}
