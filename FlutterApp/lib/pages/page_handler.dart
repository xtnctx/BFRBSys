// ignore_for_file: dead_code

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

import 'package:csv/csv.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bfrbsys/api/bluetooth_builder.dart';
import 'dart:io' as io;

part 'dashboard.dart';
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

  int currentPage = 1;

  late Future auth;
  late dynamic apiResponse;

  @override
  void initState() {
    super.initState();
    scaffoldKey = widget.scaffoldKey;

    pages = [
      const Dashboard(),
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

  void _onItemTapped(int index) {
    setState(() {
      currentPage = index;
    });
  }

  Widget _allowUserWidget() {
    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: IndexedStack(
          index: currentPage,
          children: pages!,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              width: 1.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
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
