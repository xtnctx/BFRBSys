import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bfrbsys/themes.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Provider.of<ThemeProvider>(context, listen: false).swapTheme();
        },
        child: const Text('Change theme'),
      ),
    );
  }
}
