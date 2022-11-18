import 'package:bfrbsys/api_page.dart';
import 'package:bfrbsys/ble_connection.dart';

import 'package:bfrbsys/profile_page.dart';
import 'package:bfrbsys/home_page.dart';
import 'package:bfrbsys/results_page.dart';
import 'package:bfrbsys/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bfrbsys/providers.dart';
import 'package:provider/provider.dart';
import 'package:bfrbsys/colors.dart' as custom_color;

import 'package:bfrbsys/api/env.dart';
import 'package:http/http.dart' as http;
import 'package:bfrbsys/device_storage.dart';
import 'package:bfrbsys/login_page.dart';

import 'package:bfrbsys/api/api_response_widget.dart';

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
        child: const MyApp(),
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
          title: 'Bfrbsys',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.getTheme,
          routes: {
            '/': (context) => RootPage(),
            '/login': (context) => const LoginPage(),
          },
        );
      },
    );
  }
}

class RootPage extends StatefulWidget {
  RootPage({super.key});

  final GlobalKey<ScaffoldState>? scaffoldKey = GlobalKey<ScaffoldState>();
  final PageController pageController = PageController();

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  List<Widget>? pages;
  GlobalKey<ScaffoldState>? scaffoldKey;
  PageController? pageController;
  int currentPage = 0;

  late Future auth;

  late dynamic apiResponse;

  @override
  void initState() {
    scaffoldKey = widget.scaffoldKey;
    pageController = widget.pageController;
    pages = const [
      HomePage(),
      BluetoothBuilderPage(),
      ResultsPage(),
      ProfilePage(),
      SettingsPage(),
      ApiService(),
    ];
    auth = authenticate();
    auth.then((value) {
      setState(() {
        apiResponse = value;
      });
    });
    super.initState();
  }

  Future authenticate() async {
    var token = await UserSecureStorage.getToken();

    // ignore: unnecessary_null_comparison
    if (token == null) {
      return false; // then proceed the login page
    } else {
      final response = await http.get(
        Uri.parse("${Env.URL_PREFIX}/api/auth/user/"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token $token',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          return http.Response('Connection timed out', 408);
        },
      );
      //     .onError((error, _) {
      //   return http.Response(error.toString(), 408);
      // });

      return response;
    }
  }

  Color getTextColorForBackground(Color backgroundColor) {
    if (ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark) {
      return Colors.white;
    }

    return Colors.black;
  }

  Widget _createHeader() {
    return DrawerHeader(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        decoration: const BoxDecoration(
          image: DecorationImage(fit: BoxFit.cover, image: AssetImage('images/Sakura_Nene_CPP.jpg')),
        ),
        child: Stack(children: const [
          Positioned(
              bottom: 12.0,
              left: 16.0,
              child: Text(
                "xtnctx",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              )),
        ]));
  }

  Widget _createDrawerItem({
    Icon? icon,
    String? text,
    bool selected = false,
    Color? selectedColor,
    GestureTapCallback? onTap,
  }) {
    return ListTile(
      selected: selected,
      selectedColor: selectedColor,
      title: Row(
        children: <Widget>[
          icon!,
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(text!),
          )
        ],
      ),
      onTap: onTap,
    );
  }

  Row _chartLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Wrap(
          children: const [
            Icon(
              Icons.horizontal_rule_rounded,
              color: custom_color.lineXColor,
            ),
            Text('x'),
          ],
        ),
        Wrap(
          children: const [
            Icon(
              Icons.horizontal_rule_rounded,
              color: custom_color.lineYColor,
            ),
            Text('y'),
          ],
        ),
        Wrap(
          children: const [
            Icon(
              Icons.horizontal_rule_rounded,
              color: custom_color.lineZColor,
            ),
            Text('z'),
          ],
        )
      ],
    );
  }

  Widget _buildPopupDialog(BuildContext context, String title, Widget content) {
    return AlertDialog(
      title: Text(title),
      content: content,
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Close',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }

  // todo: refactor to separate file
  Widget allowUserWidget() {
    bool isConnected = Provider.of<ConnectionProvider>(context, listen: true).isConnected;

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        actions: currentPage != 1
            ? null
            : [
                Container(
                  padding: const EdgeInsets.only(right: 25),
                  child: MyTooltip(
                      message: isConnected ? 'Connected' : 'Disconnected',
                      child: Icon(
                        Icons.rectangle,
                        size: 10,
                        color: isConnected ? Colors.greenAccent : Colors.redAccent,
                      )),
                ),
                PopupMenuButton(
                  tooltip: 'Show info',
                  icon: const Icon(Icons.info_outline),
                  itemBuilder: (context) => [
                    // PopupMenuItem 1
                    const PopupMenuItem(value: 1, child: Text('Chart Legend')),
                    const PopupMenuItem(value: 2, child: Text('Sensor Range')),
                  ],
                  onSelected: (value) {
                    if (value == 1) {
                      showDialog(
                        barrierColor: Theme.of(context).colorScheme.primaryContainer.withAlpha(125),
                        context: context,
                        builder: (BuildContext context, [_]) => _buildPopupDialog(
                          context,
                          'Chart Legend',
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  _chartLegend(),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    } else if (value == 2) {
                      showDialog(
                        barrierColor: Theme.of(context).colorScheme.primaryContainer.withAlpha(125),
                        context: context,
                        builder: (BuildContext context, [_]) => _buildPopupDialog(
                          context,
                          'Sensor Range',
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                children: const [
                                  Text('Accelerometer : ±4 g'),
                                  SizedBox(height: 5),
                                  Text('Gyroscope : ±2000 dps'),
                                  SizedBox(height: 5),
                                  Text('Distance : 200 cm (max)'),
                                  SizedBox(height: 5),
                                  Text('Temperature : -70 to 382°C'),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
      ),
      body: IndexedStack(
        index: currentPage,
        children: pages!,
      ),
      drawerEdgeDragWidth: MediaQuery.of(context).size.width / 40,
      drawerScrimColor: Theme.of(context).colorScheme.background.withAlpha(125),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _createHeader(),
            Column(
              children: List.generate(pages!.length, (int index) {
                dynamic curWidget = pages![index];
                return _createDrawerItem(
                  icon: currentPage == index ? curWidget.navBarIconSelected : curWidget.navBarIcon,
                  text: curWidget.navBarTitle,
                  selected: currentPage == index,
                  selectedColor: Theme.of(context).colorScheme.primary,
                  onTap: () {
                    if (scaffoldKey!.currentState!.isDrawerOpen) {
                      scaffoldKey!.currentState!.closeDrawer();
                    }
                    setState(() {
                      currentPage = index;
                    });
                    // pageController.jumpToPage(index);

                    // pageController.animateToPage(index,
                    //     duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  },
                );
              }),
            ),
            // _createDrawerItem(icon: Icons.contacts, text: 'Contacts'),
            // _createDrawerItem(icon: Icons.event, text: 'Events'),
            // _createDrawerItem(icon: Icons.note, text: 'Notes'),
            const Divider(),
            _createDrawerItem(
                icon: const Icon(Icons.navigate_next),
                text: 'Visit our site',
                onTap: () {
                  print(apiResponse);
                }),
            _createDrawerItem(icon: const Icon(Icons.read_more), text: 'Documentation'),
            _createDrawerItem(icon: const Icon(Icons.face), text: 'Authors'),
            const Divider(),
            _createDrawerItem(icon: const Icon(Icons.coffee), text: 'Buy me a coffee'),
            _createDrawerItem(icon: const Icon(Icons.bug_report), text: 'Bug report'),
            const ListTile(
              title: Text('v0.2.66', style: TextStyle(fontSize: 10)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    try {
      // Successful authentication.
      if (apiResponse.statusCode == 200) {
        return allowUserWidget();
      }
      // New user or device
      else if (apiResponse == false) {
        return const LoginPage();
      }
      // Invalid token: user may not be present in database or token might be expired.
      else if (apiResponse.statusCode == 401) {
        return const LoginPage();
      }
      // Request Timeout | HTTP Class 500
      else {
        return ResponseCodeWidget(response: apiResponse);
      }
    } catch (error) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
  }
}
