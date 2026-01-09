import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';

class AccountGlobalWidget {
  static Widget detailRow(String title, String answer, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: Text(
              title,
              style: GoogleFonts.exo2(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: AppColors.letterColor,
              ),
            ),
          ),
          const SizedBox(width: 50),
          Flexible(
            child: Text(
              answer,
              textAlign: TextAlign.end,
              overflow: TextOverflow.clip,
              style: GoogleFonts.tomorrow(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppColors.letterColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
