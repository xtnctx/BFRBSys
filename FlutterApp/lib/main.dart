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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bfrbsys/pages/page_manager.dart';
import 'package:bfrbsys/shared/shared.dart';
import 'package:bfrbsys/accounts/accounts.dart';

void main() {
  // SystemChrome.setSystemUIOverlayStyle(
  //   SystemUiOverlayStyle(
  //     statusBarColor: Colors.transparent,
  //   ),
  // );

  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.getInstance().then((prefs) {
    var isDarkTheme = prefs.getBool("darkTheme") ?? false;
    return runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>(create: (context) => ThemeProvider(isDarkTheme)),
          ChangeNotifierProvider<ConnectionProvider>(create: (context) => ConnectionProvider()),
          ChangeNotifierProvider<CallbackProvider>(create: (context) => CallbackProvider()),
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
          initialRoute: '/',
          routes: {
            '/': (context) => PageHandler(),
            '/accounts': (context) => const Accounts(msg: 'Enter your credentials to proceed'),
            '/profile': (context) => const ProfilePage(),
          },
        );
      },
    );
  }
}
