import 'package:bfrbsys/profile_page.dart';
import 'package:bfrbsys/home_page.dart';
import 'package:bfrbsys/results_page.dart';
import 'package:bfrbsys/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bfrbsys/themes.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.getInstance().then((prefs) {
    var isDarkTheme = prefs.getBool("darkTheme") ?? false;
    return runApp(
      ChangeNotifierProvider<ThemeProvider>(
        child: const MyApp(),
        create: (BuildContext context) {
          return ThemeProvider(isDarkTheme);
        },
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: themeProvider.getTheme(),
          home: const RootPage(),
        );
      },
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int currentPage = 0;
  List pages = const [HomePage(), ResultsPage(), ProfilePage(), SettingsPage()];

  @override
  Widget build(BuildContext context) {
    int mid = pages.length ~/ 2;
    double navBarIconSize = 27;
    return Scaffold(
      body: pages[currentPage],
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        child: BottomAppBar(
          color: Theme.of(context).colorScheme.primaryContainer,
          shape: const CircularNotchedRectangle(),
          notchMargin: 6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List<Widget>.generate(pages.length, (int index) {
              var widget = pages[index];
              if (mid == index) {
                return Wrap(children: [
                  const SizedBox(width: 60),
                  IconButton(
                    enableFeedback: false,
                    // iconSize: navBarIconSize,
                    icon: index == currentPage ? widget.navBarIconSelected : widget.navBarIcon,
                    onPressed: index == currentPage ? () {} : () => setState(() => currentPage = index),
                  )
                ]);
              } else {
                return IconButton(
                  enableFeedback: false,
                  // iconSize: navBarIconSize,
                  icon: index == currentPage ? widget.navBarIconSelected : widget.navBarIcon,
                  onPressed: index == currentPage ? () {} : () => setState(() => currentPage = index),
                );
              }
            }),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
