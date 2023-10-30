import 'dart:math';

import 'package:bfrbsys/custom_widgets/data_button.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert' show json, utf8;
import 'dart:typed_data';

import 'package:bfrbsys/accounts/accounts.dart';
import 'package:bfrbsys/shared/shared.dart';

import 'package:bfrbsys/api/error_response_widget.dart';
import 'package:bfrbsys/api/http/http_service.dart';
import 'package:bfrbsys/api/models.dart';

import 'package:bfrbsys/custom_widgets/extra_widget.dart';
import 'package:bfrbsys/custom_widgets/tooltip.dart';

import 'package:csv/csv.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bfrbsys/api/bluetooth_builder.dart';
import 'dart:io' as io;

part 'home_page.dart';
part 'monitoring_page.dart';
part 'profile_page.dart';
part 'results_page.dart';
part 'settings_page.dart';

class PageHandler extends StatefulWidget {
  PageHandler({super.key});

  final GlobalKey<ScaffoldState>? scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  State<PageHandler> createState() => _PageHandlerState();
}

class _PageHandlerState extends State<PageHandler> {
  BluetoothBuilder ble = BluetoothBuilder();
  List<Widget>? pages;
  GlobalKey<ScaffoldState>? scaffoldKey;

  int currentPage = 0;

  late Future auth;

  late dynamic apiResponse;
  int x = min(1, 2);
  @override
  void initState() {
    super.initState();
    scaffoldKey = widget.scaffoldKey;

    pages = [
      HomePage(ble: ble),
      MonitoringPage(ble: ble),
      ResultsPage(ble: ble),
      const ProfilePage(),
      const SettingsPage(),
    ];
    auth = HttpService().authenticate();
    auth.then((value) {
      setState(() {
        apiResponse = value;
      });
    });
  }

  Widget _createHeader() {
    return DrawerHeader(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('images/ekusuuuu-calibaaaaaaaaaaaaa.png'),
          ),
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
              color: CustomColor.lineXColor,
            ),
            Text('x'),
          ],
        ),
        Wrap(
          children: const [
            Icon(
              Icons.horizontal_rule_rounded,
              color: CustomColor.lineYColor,
            ),
            Text('y'),
          ],
        ),
        Wrap(
          children: const [
            Icon(
              Icons.horizontal_rule_rounded,
              color: CustomColor.lineZColor,
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

  void _onItemTapped(int index) {
    setState(() {
      currentPage = index;
    });
  }

  Widget _allowUserWidget() {
    bool isConnected = Provider.of<ConnectionProvider>(context, listen: true).isConnected;

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.bluetooth),
            label: 'Connect',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.watch),
            label: 'Device',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'My Data',
          ),
        ],
        currentIndex: currentPage,
        onTap: _onItemTapped,
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
                  },
                );
              }),
            ),
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
              title: Text('v0.3.2', style: TextStyle(fontSize: 10)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _allowUserWidget();
    try {
      // New user or device
      if (apiResponse == false) {
        // return _allowUserWidget();
        return const LoginPage(
          msg: 'Enter your credentials to proceed',
        );
      }
      // Successful authentication.
      else if (apiResponse.statusCode == 200) {
        return _allowUserWidget();
      }
      // Invalid token: user may not be present in database or token might be expired.
      else if (apiResponse.statusCode == 401) {
        return const LoginPage(
          msg: 'Token expired, sign in again',
        );
      }
      // Request Timeout | HTTP Class 500
      else {
        // return _allowUserWidget();
        return ResponseCodeWidget(response: apiResponse);
      }
    } catch (error) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
  }
}
