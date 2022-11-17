import 'package:flutter/material.dart';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:google_fonts/google_fonts.dart';

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

  set setConnected(bool value) {
    _value = value;
    notifyListeners();
  }

  bool get isConnected => _value;
}
