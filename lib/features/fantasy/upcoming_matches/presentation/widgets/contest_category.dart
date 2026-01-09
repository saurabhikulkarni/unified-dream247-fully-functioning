import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';

class ContestCategory extends StatefulWidget {
  final String? name;
  final String? subTitle;
  const ContestCategory({super.key, this.name, this.subTitle});

  @override
  State<ContestCategory> createState() => _ContestCategory();
}

class _ContestCategory extends State<ContestCategory> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.white, AppColors.whiteFade1],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.whiteFade1, width: 0.7),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ---------- Title & Subtitle ----------
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name ?? '',
                    style: GoogleFonts.exo2(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subTitle ?? '',
                    style: GoogleFonts.exo2(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.greyColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
