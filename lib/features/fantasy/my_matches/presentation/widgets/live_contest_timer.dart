import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/landing/data/singleton/app_singleton.dart';

class LiveContestTimer extends StatelessWidget {
  final String? mode;
  final bool transparent;
  const LiveContestTimer({super.key, this.mode,required this.transparent});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: AppSingleton.singleton.matchData.team1Name ?? "IND",
                style: GoogleFonts.exo2(
                  fontSize: 16.0,
                  color: transparent ? AppColors.blackColor : AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: " VS ",
                style: GoogleFonts.exo2(
                  fontSize: 14.0,
                  color: transparent ? AppColors.blackColor : AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: AppSingleton.singleton.matchData.team2Name ?? "AUS",
                style: GoogleFonts.exo2(
                  fontSize: 16.0,
                  color: transparent ? AppColors.blackColor : AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
