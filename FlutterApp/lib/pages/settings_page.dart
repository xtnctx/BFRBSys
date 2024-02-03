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
