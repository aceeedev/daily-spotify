import 'package:flutter/material.dart';

class Styles {
  // theme data:
  static final _backgroundColor = _createMaterialColor(const Color(0xff121212));
  static const _font = 'WorkSans';
  static const _primarySwatch = Colors.green;
  static const _mainColor = Colors.white;
  static final _secondaryColor = _createMaterialColor(_backgroundColor[300]);

  final ThemeData _themeData = ThemeData(
      fontFamily: _font,
      scaffoldBackgroundColor: _backgroundColor,
      primaryColor: _backgroundColor,
      primarySwatch: _primarySwatch,
      iconTheme: const IconThemeData(color: _mainColor),
      colorScheme: ColorScheme.fromSeed(seedColor: _primarySwatch),
      useMaterial3: true);

  ThemeData get themeData => _themeData;
  Color get primarySwatch => _primarySwatch;
  Color get mainColor => _mainColor;
  Color get secondaryColor => _secondaryColor;
  Color get backgroundColor => _backgroundColor;

  // text:
  static const _textSizeDefault = 11.0;
  static const _textSizeTitle = 18.0;
  static const _textSizeSubtitle = 14.0;
  static const _textSizeLarge = 24.0;
  static const _textSizeBrand = 26.0;

  final TextStyle _defaultText = const TextStyle(
      fontSize: _textSizeDefault,
      fontWeight: FontWeight.w400,
      color: _mainColor);

  final TextStyle _titleText = const TextStyle(
      fontSize: _textSizeTitle, fontWeight: FontWeight.w700, color: _mainColor);

  final TextStyle _subtitleText = const TextStyle(
      fontSize: _textSizeSubtitle,
      fontWeight: FontWeight.w500,
      color: _mainColor);

  late final TextStyle _subtitleTextWithPrimaryColor =
      _subtitleText.copyWith(color: _primarySwatch);

  final TextStyle _largeText = const TextStyle(
      fontSize: _textSizeLarge, fontWeight: FontWeight.w600, color: _mainColor);

  final TextStyle _calendarText =
      const TextStyle(fontSize: _textSizeTitle, color: _mainColor);

  final TextStyle _calendarTextIfImage =
      const TextStyle(fontSize: _textSizeTitle, color: _mainColor);

  final TextStyle _brandText = const TextStyle(
      fontSize: _textSizeBrand, fontWeight: FontWeight.w900, color: _mainColor);

  TextStyle get defaultText => _defaultText;
  TextStyle get subtitleTextWithPrimaryColor => _subtitleTextWithPrimaryColor;
  TextStyle get titleText => _titleText;
  TextStyle get subtitleText => _subtitleText;
  TextStyle get largeText => _largeText;
  TextStyle get calendarText => _calendarText;
  TextStyle get calendarTextIfImage => _calendarTextIfImage;
  TextStyle get brandText => _brandText;

  // color:
  static final MaterialColor _accentColor =
      _createMaterialColor(const Color(0x001db9a2));

  MaterialColor get accentColor => _accentColor;

  // buttons
  static const _unselectedElevation = 2.0;
  static final _selectedColor = _secondaryColor[900];
  static const _selectedElevation = 0.1;
  static final _shadowColor = _secondaryColor[200];

  static final ButtonStyle _unselectedElevatedButtonStyle =
      ElevatedButton.styleFrom(
          elevation: _unselectedElevation,
          backgroundColor: _secondaryColor,
          shadowColor: _shadowColor);

  static final ButtonStyle _selectedElevatedButtonStyle =
      ElevatedButton.styleFrom(
          backgroundColor: _selectedColor,
          elevation: _selectedElevation,
          shadowColor: _shadowColor);

  double get unselectedElevation => _unselectedElevation;
  Color? get selectedColor => _selectedColor;
  Color? get shadowColor => _shadowColor;
  double get selectedElevation => _selectedElevation;
  ButtonStyle get unselectedElevatedButtonStyle =>
      _unselectedElevatedButtonStyle;
  ButtonStyle get selectedElevatedButtonStyle => _selectedElevatedButtonStyle;

  // helper functions:
  static MaterialColor _createMaterialColor(Color? color) {
    List strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = color!.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }

    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - r)) * ds).round(),
        b + ((ds < 0 ? b : (255 - r)) * ds).round(),
        1,
      );
    }

    return MaterialColor(color.value, swatch);
  }
}
