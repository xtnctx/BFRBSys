import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

class ThemeProvider extends ChangeNotifier {
  late ThemeData _selectedTheme;
  late Typography defaultTypography;
  late SharedPreferences prefs;

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
    // To use the playground font, add GoogleFonts package and uncomment
    // fontFamily: GoogleFonts.notoSans().fontFamily,
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
    // To use the playground font, add GoogleFonts package and uncomment
    // fontFamily: GoogleFonts.notoSans().fontFamily,
  );

  ThemeProvider(bool darkThemeOn) {
    _selectedTheme = darkThemeOn ? dark : light;
  }

  Future<void> swapTheme() async {
    prefs = await SharedPreferences.getInstance();

    if (_selectedTheme == dark) {
      _selectedTheme = light;
      await prefs.setBool("darkTheme", false);
    } else {
      _selectedTheme = dark;
      await prefs.setBool("darkTheme", true);
    }

    notifyListeners();
  }

  ThemeData getTheme() => _selectedTheme;
}

class ConnectionProvider extends ChangeNotifier {
  bool _value = false;

  set setConnected(bool value) {
    _value = value;
    notifyListeners();
  }

  bool get isConnected => _value;
}
