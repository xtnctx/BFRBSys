import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bfrbsys/pages/page_handler.dart';
import 'package:bfrbsys/shared/shared.dart';
import 'package:bfrbsys/accounts/account_setup.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.getInstance().then((prefs) {
    var isDarkTheme = prefs.getBool("darkTheme") ?? false;
    return runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>(create: (context) => ThemeProvider(isDarkTheme)),
          ChangeNotifierProvider<ConnectionProvider>(create: (context) => ConnectionProvider()),
        ],
        child: const App(),
      ),
    );
  });
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Bfrbsys',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.getTheme,
          routes: {
            '/': (context) => PageHandler(),
            '/login': (context) => const LoginPage(),
          },
        );
      },
    );
  }
}
