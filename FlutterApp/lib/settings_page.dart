import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bfrbsys/themes.dart';

class SettingsPage extends StatefulWidget {
  final Icon navBarIcon = const Icon(Icons.settings_outlined);
  final Icon navBarIconSelected = const Icon(Icons.settings);
  final String navBarTitle = 'Settings';

  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Provider.of<ThemeProvider>(context, listen: false).swapTheme();
          },
          child: const Text('Change theme'),
        ),
      ),
    );
  }
}
