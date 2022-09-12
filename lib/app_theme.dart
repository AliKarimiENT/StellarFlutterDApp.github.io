import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color primaryColor = Color(0xff6C63FF);
  static const Color red = Color(0xffFF6666);
  static const Color green = Color(0xff2EC4B6);
  static const Color darkBackgroundColor = Color(0xff2A2A2A);
  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xff2A2A2A),
    colorScheme: ColorScheme.dark(),
  );

  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.light(),
  );
}

class ThemeProvider extends ChangeNotifier {
  
  ThemeMode themeMode = ThemeMode.light;
  bool get isDarkMode => themeMode == ThemeMode.dark;

  void toggleTheme(bool isON) {
    themeMode = isON ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setTheme(bool dark) {
    if (dark) {
      themeMode = ThemeMode.dark;
    } else {
      themeMode = ThemeMode.light;
    }
  }
}
