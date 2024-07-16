/* Copyright 2024 Ryan Christopher Bahillo. All Rights Reserved.
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
=========================================================================*/

part of 'page_manager.dart';

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
    int bleMTU = Provider.of<ConnectionProvider>(context, listen: true).mtu;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          children: [
            Switch(
              value: isDark,
              onChanged: (bool newBool) {
                lightsOff(newBool, withContext: context);
              },
            ),
            Text('$bleMTU'),
          ],
        ),
      ),
    );
  }
}
