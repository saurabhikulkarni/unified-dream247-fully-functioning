import 'package:flutter/material.dart';
import 'package:shop/theme/button_theme.dart';
import 'package:shop/theme/input_decoration_theme.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants.dart';
import 'checkbox_themedata.dart';
import 'theme_data.dart';

class AppTheme {
  static ThemeData lightTheme(BuildContext context) {
    final baseTextTheme = GoogleFonts.latoTextTheme(Theme.of(context).textTheme);
    return ThemeData(
      brightness: Brightness.light,
      fontFamily: GoogleFonts.lato().fontFamily,
      primarySwatch: primaryMaterialColor,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: const Color(0xFFF4F4F4),
      cardColor: Colors.white,
      iconTheme: const IconThemeData(color: blackColor),
      textTheme: baseTextTheme.apply(bodyColor: blackColor, displayColor: blackColor),
      elevatedButtonTheme: elevatedButtonThemeData,
      textButtonTheme: textButtonThemeData,
      outlinedButtonTheme: outlinedButtonTheme(),
      inputDecorationTheme: lightInputDecorationTheme,
      checkboxTheme: checkboxThemeData.copyWith(
        side: const BorderSide(color: blackColor40),
      ),
      appBarTheme: appBarLightTheme,
      scrollbarTheme: scrollbarThemeData,
      dataTableTheme: dataTableLightThemeData,
    );
  }

  // Dark theme is inclided in the Full template
}
