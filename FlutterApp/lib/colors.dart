import 'package:flutter/material.dart';

const MaterialColor primaryBlack = MaterialColor(
  _blackPrimaryValue,
  <int, Color>{
    50: Color.fromRGBO(255, 0, 0, 1),
    100: Color(0xFF000000),
    200: Color(0xFF000000),
    300: Color(0xFF000000),
    400: Color(0xFF000000),
    500: Color(_blackPrimaryValue), // Primary value
    600: Color(0xFF000000),
    700: Color(0xFF000000),
    800: Color(0xFF000000),
    900: Color.fromRGBO(255, 0, 0, 1),
  },
);
const int _blackPrimaryValue = 0xFF000000;

const ColorScheme flexSchemeDark = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xff4e597d),
  onPrimary: Color(0xfff0f1f5),
  primaryContainer: Color(0xff202541),
  onPrimaryContainer: Color(0xffd7d8df),
  secondary: Color(0xff4ba390),
  onSecondary: Color(0xffeffaf7),
  secondaryContainer: Color(0xff0b5341),
  onSecondaryContainer: Color(0xffd2e3df),
  tertiary: Color(0xff3d8475),
  onTertiary: Color(0xffeef6f4),
  tertiaryContainer: Color(0xff063f36),
  onTertiaryContainer: Color(0xffd1dfdc),
  error: Color(0xffcf6679),
  onError: Color(0xff1e1214),
  errorContainer: Color(0xffb1384e),
  onErrorContainer: Color(0xfff9dde2),
  background: Color(0xff141517),
  onBackground: Color(0xffe3e3e3),
  surface: Color(0xff121213),
  onSurface: Color(0xfff1f1f1),
  surfaceVariant: Color(0xff141416),
  onSurfaceVariant: Color(0xffe3e3e3),
  outline: Color(0xff969696),
  shadow: Color(0xff000000),
  inverseSurface: Color(0xfffafafb),
  onInverseSurface: Color(0xff0e0e0e),
  inversePrimary: Color(0xff2f3342),
  surfaceTint: Color(0xff4e597d),
);
