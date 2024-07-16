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

part of 'shared.dart';

class ThemeProvider extends ChangeNotifier {
  late ThemeData _selectedTheme;
  late bool _isDark;

  ThemeData light = FlexThemeData.light(
    scheme: FlexScheme.ebonyClay,
    surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
    blendLevel: 20,
    appBarOpacity: 0.95,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 20,
      blendOnColors: false,
      fabSchemeColor: SchemeColor.tertiaryContainer,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    fontFamily: GoogleFonts.notoSans().fontFamily,
  );

  ThemeData dark = FlexThemeData.dark(
    scheme: FlexScheme.ebonyClay,
    surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
    blendLevel: 15,
    appBarOpacity: 0.90,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 30,
      fabSchemeColor: SchemeColor.tertiaryContainer,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    fontFamily: GoogleFonts.notoSans().fontFamily,
  );

  ThemeProvider(bool darkThemeOn) {
    _selectedTheme = darkThemeOn ? dark : light;
    _isDark = darkThemeOn;
  }

  Future<void> setDark(bool value) async {
    if (value) {
      _selectedTheme = dark;
    } else {
      _selectedTheme = light;
    }
    _isDark = value;
    notifyListeners();
  }

  ThemeData get getTheme => _selectedTheme;
  bool get isDark => _isDark;
}

class ConnectionProvider extends ChangeNotifier {
  bool _value = false;
  bool _notifyValue = false;
  int _mtu = 0;

  set setConnected(bool value) {
    _value = value;
    notifyListeners();
  }

  void toggle(bool value) {
    _notifyValue = value;
    if (value) notifyListeners();
  }

  void setMTU(int value) {
    _mtu = value;
    notifyListeners();
  }

  bool get isConnected => _value;
  bool get isNotified => _notifyValue;
  int get mtu => _mtu;
}

class BluetoothValueProvider extends ChangeNotifier {
  String _accValue = '';
  String _gyroValue = '';
  String _distValue = '';

  set setAcc(String value) {
    _accValue = value;
    notifyListeners();
  }

  set setGyro(String value) {
    _gyroValue = value;
    notifyListeners();
  }

  set setDist(String value) {
    _distValue = value;
    notifyListeners();
  }

  String get accValue => _accValue;
  String get gyroValue => _gyroValue;
  String get distValue => _distValue;
}

class CallbackProvider extends ChangeNotifier {
  String _message = '';
  int _statusCode = 0;

  void inform(String message, [int statusCode = 0]) {
    _message = message;
    _statusCode = statusCode;
    notifyListeners();
  }

  List get infoMsg => [_message, _statusCode];
}
