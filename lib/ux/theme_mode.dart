import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier {

  final Color _primaryThemeColor = const Color(0xFFE31337);
  final Color _primaryColor = Colors.black;
  final Color _primaryColorTwo = const Color.fromARGB(255, 8, 8, 8);
  final Color _secondaryColor = Colors.white;
  final Color _secondaryColorTwo = const Color(0xFFf0f0f8);
  final Color _tertiaryColor = const Color(0xFFe7e7f1);
  final Color _errorColor = Colors.red;
  final Color _successColor = Colors.lightGreen;
  final Color _staticColor = Colors.white;
  final Color _lightGrey = const Color(0xFFf0f0f8);
  final Color _secondaryPrimaryColor = Colors.tealAccent;

  final String _fontFamily = 'Poppins';

  ThemeMode _themeMode = ThemeMode.dark;

  get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = isLightTheme() ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  bool isLightTheme() => _themeMode == ThemeMode.light;

  ThemeData getLightTheme() {
    return ThemeData(
      primaryColorLight: _secondaryColor,
      primaryColorDark: _primaryColor,
      scaffoldBackgroundColor: _secondaryColor,
      primaryColor: _primaryThemeColor,
      brightness: Brightness.light,
      dividerColor: _primaryColor.withOpacity(0.2),
      focusColor: _primaryThemeColor,
      hintColor: Colors.black54,
      cardColor: _lightGrey,
      dividerTheme: DividerThemeData(color: _primaryColor.withOpacity(0.1)),
      colorScheme: ColorScheme.light(
          onPrimary: _staticColor,
          onSecondary: _lightGrey,
          onTertiary: _successColor, // color used for success
          onTertiaryContainer: _tertiaryColor.withOpacity(0.3),
          primaryContainer: _primaryThemeColor,
          secondaryContainer: const Color.fromRGBO(5, 206, 179, 1),
          tertiaryContainer: _secondaryColorTwo,
          error: _errorColor,
          onError: Colors.redAccent,
          primary: _primaryColor,
          secondary: _secondaryColor,
          tertiary: _tertiaryColor),
      fontFamily: _fontFamily,
      iconTheme: IconThemeData(color: _primaryColor),
      textTheme: TextTheme(
        labelSmall: TextStyle(
          fontSize: 10.0,
          fontWeight: FontWeight.w400,
          color: _primaryColor,
        ),
        labelMedium: TextStyle(
          fontSize: 11.0,
          fontWeight: FontWeight.w400,
          color: _primaryColor,
        ),
        labelLarge: TextStyle(
          fontSize: 12,
          color: _primaryColor,
          fontWeight: FontWeight.w600,
        ),
        bodySmall: TextStyle(
          fontSize: 13.0,
          fontWeight: FontWeight.w400,
          color: _primaryColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: _primaryColor,
          fontWeight: FontWeight.w400,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          color: _primaryColor,
          fontWeight: FontWeight.w400,
        ),
        displaySmall: TextStyle(
          fontSize: 16,
          color: _primaryColor,
          fontWeight: FontWeight.w500,
        ),
        displayMedium: TextStyle(
          fontSize: 18,
          color: _primaryColor,
          fontWeight: FontWeight.w500,
        ),
        displayLarge: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: _primaryColor,
        ),
      ),
    );
  }

  ThemeData getDarkTheme() {
    return ThemeData(
      primaryColorLight: _primaryColor,
      primaryColorDark: _secondaryColor,
      scaffoldBackgroundColor: _primaryColor,
      primaryColor: _primaryThemeColor,
      brightness: Brightness.dark,
      dividerColor: _secondaryColor.withOpacity(0.2),
      focusColor: _primaryThemeColor,
      hintColor: Colors.white54,
      dividerTheme: DividerThemeData(color: _secondaryColor.withOpacity(0.1)),
      colorScheme: ColorScheme.dark(
          onPrimary: _staticColor,
          onTertiary: _successColor, // color used for success
          onSecondary: Colors.grey.shade800,
          onTertiaryContainer: Colors.grey.shade900.withOpacity(0.3),
          primaryContainer: _primaryThemeColor,
          secondaryContainer: const Color.fromRGBO(5, 206, 179, 1),
          tertiaryContainer: _primaryColorTwo,
          error: _errorColor,
          onError: Colors.redAccent,
          primary: _secondaryColor,
          secondary: _primaryColor,
          tertiary: Colors.grey.shade900),
      fontFamily: _fontFamily,
      iconTheme: IconThemeData(color: _secondaryColor),
      textTheme: TextTheme(
        labelSmall: TextStyle(
          fontSize: 10.0,
          fontWeight: FontWeight.w400,
          color: _secondaryColor,
        ),
        labelMedium: TextStyle(
          fontSize: 11.0,
          fontWeight: FontWeight.w400,
          color: _secondaryColor,
        ),
        labelLarge: TextStyle(
          fontSize: 12,
          color: _secondaryColor,
          fontWeight: FontWeight.w600,
        ),
        bodySmall: TextStyle(
          fontSize: 13.0,
          fontWeight: FontWeight.w400,
          color: _secondaryColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: _secondaryColor,
          fontWeight: FontWeight.w400,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          color: _secondaryColor,
          fontWeight: FontWeight.w400,
        ),
        displaySmall: TextStyle(
          fontSize: 16,
          color: _secondaryColor,
          fontWeight: FontWeight.w500,
        ),
        displayMedium: TextStyle(
          fontSize: 18,
          color: _secondaryColor,
          fontWeight: FontWeight.w500,
        ),
        displayLarge: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: _secondaryColor,
        ),
      ),
    );
  }
}
