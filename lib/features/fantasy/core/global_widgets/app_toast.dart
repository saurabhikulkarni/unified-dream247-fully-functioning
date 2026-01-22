import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';

ToastFuture appToast(String msg, BuildContext context) {
  return showToast(
    position: ToastPosition.bottom,
    duration: const Duration(seconds: 2),
    backgroundColor: AppColors.lightCard,
    textPadding: const EdgeInsets.all(10.0),
    msg,
    textStyle: const TextStyle(color: AppColors.blackColor, fontSize: 16.0),
  );
}
