import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';

class NoDataWidget extends StatelessWidget {
  final String? title;
  final String? image;
  final String? buttonText;
  final bool showButton;
  final Function()? onTap;
  const NoDataWidget({
    super.key,
    this.title,
    this.image,
    this.buttonText,
    this.onTap,
    required this.showButton,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title ?? 'No Contests Found',
          style: GoogleFonts.exo2(fontWeight: FontWeight.w600, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        Image.asset(image ?? Images.noContests, height: 250, width: 300),
        if (showButton)
          Container(
            margin: EdgeInsets.only(top: 20),
            width: 250,
            height: 45,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.greyColor),
              gradient: AppColors.appBarGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
              onTap: onTap,
              child: Center(
                child: Text(
                  buttonText ?? "Join Contest Now",
                  style: GoogleFonts.exo2(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
