import 'package:flutter/material.dart';

class AppColors {
  // static const Color mainColor = Color(0xFF012356);
  static const Color mainColor = Color(0xFF2A0845);
  static const Color secondMainColor = Color(0xFF472575);
  static const Color mainLightColor = Color(0xFF6441A5);
  static const Color blackColor = Color(0xFF000000);
  static const Color lightGreen = Color(0xFF009140);
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Color(0x00000000);
  static const Color bgColor = Color(0xFFF8F8F8);
  static const Color letterColor = Color(0xFF343434);
  static const Color green = Color(0xFF097F2A);
  static const Color lightCard = Color(0xFFF0F0F0);
  static const Color editTextColor = Color(0xFFDFDFDD);
  static const Color orangeColor = Color(0xFFDF7F00);
  static const Color yellowColor = Color(0xFFFFB700);
  static const Color lightYellow = Color(0xFFFFF700);
  static const Color shade1White = Color(0xFFF0F3F8);
  static const Color megaColor = Color(0xFFFEF8DD);
  static const Color black = Color(0xFF424242);
  static const Color lightBlue = Color(0xFFEFFAFF);
  static const Color lightGrey = Color(0xFFd7d7d7);
  static const Color whiteFade1 = Color(0xFFededed);
  static const Color greyColor = Color(0xFF6a6767);
  static const Color blueColor = Color(0xFF00078F);

  static const LinearGradient progressGradeint = LinearGradient(
    colors: [AppColors.letterColor, AppColors.mainColor],
  );

  static const LinearGradient mainGradient = LinearGradient(
    colors: [AppColors.mainColor, AppColors.blackColor],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient appBarGradient = LinearGradient(colors: [
    AppColors.mainLightColor,
    AppColors.secondMainColor,
    AppColors.mainColor,
  ], begin: AlignmentGeometry.topCenter, end: AlignmentGeometry.bottomCenter,);
}
