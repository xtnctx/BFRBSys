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

  set setConnected(bool value) {
    _value = value;
    notifyListeners();
  }

  void toggle(bool value) {
    _notifyValue = value;
    if (value) notifyListeners();
  }

  bool get isConnected => _value;
  bool get isNotified => _notifyValue;
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
