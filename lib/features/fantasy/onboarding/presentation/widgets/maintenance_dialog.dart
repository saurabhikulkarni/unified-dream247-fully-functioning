import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/main_button.dart';

class MaintenanceDialog extends StatelessWidget {
  const MaintenanceDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Wrap(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: AppColors.mainColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Maintenance Mode!',
                    style: GoogleFonts.tomorrow(
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Image.asset(Images.logo, height: 80, width: 150),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Our app is currently undergoing maintenance.',
                      style: GoogleFonts.tomorrow(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'We apologize for the inconvenience and appreciate your patience.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.tomorrow(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  MainButton(
                    text: Strings.ok,
                    onTap: () async {
                      if (Platform.isAndroid) {
                        SystemNavigator.pop();
                      } else if (Platform.isIOS) {
                        exit(0);
                      }
                    },
                    color: AppColors.green,
                    textColor: AppColors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
