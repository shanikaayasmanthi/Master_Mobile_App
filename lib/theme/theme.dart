import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'Montserrat',
  colorScheme: ColorScheme.light(
    // background: Colors.grey.shade200,
    surface: Colors.grey.shade300,
    onSurface: Colors.black,
    primary: Color(0xFF8F26FF),
    onPrimary: Colors.white,
    secondary: Colors.white,
    onSecondary: Colors.black,
    tertiary: Colors.black,
    onTertiary: Color(0xFF9E9E9E),
  ),
  textTheme: const TextTheme(
    displaySmall: TextStyle(color: Colors.black,  fontSize: 43.0,fontWeight: FontWeight.w900),
    titleLarge: TextStyle(color: Color(0xFFFFFFFF),fontSize: 20.0,fontWeight: FontWeight.w600),
    titleMedium: TextStyle(color: Color(0xFF5F5F5F)),
    labelLarge: TextStyle(color: Colors.black),

  ),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: Color(0xFFF6F6F6),
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide.none
    ),
    labelStyle: TextStyle(
      color: Colors.black
    )

  ),
  iconButtonTheme: IconButtonThemeData(
    style: ButtonStyle(
    )
  )
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Montserrat',
  colorScheme: ColorScheme.dark(
    // background: Colors.grey.shade900,
    surface: Colors.grey.shade900,
    onSurface: Colors.grey.shade300,
    primary: Color(0xFF8F26FF),
    onPrimary: Colors.white,
    secondary: Color(0xFF373737),
    onSecondary: Color(0xFFFFFFFF),
    tertiary: Color(0xFF3E3E3E),
  ),
  textTheme: const TextTheme(
      displaySmall: TextStyle(color: Colors.white, fontSize: 43.0,fontWeight: FontWeight.w900),
      titleLarge: TextStyle(color: Color(0xFFFFFFFF),fontSize: 20.0,fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: Color(0xFFE3E3E3)),
      labelLarge: TextStyle(color: Color(0xFFE3E3E3)),
  ),
);
