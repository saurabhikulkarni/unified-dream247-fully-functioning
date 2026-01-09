import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';

class TeamTypeWidget extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback? onTap;
  const TeamTypeWidget({
    super.key,
    required this.title,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(microseconds: 100),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(
                    colors: [
                      AppColors.mainColor,
                      AppColors.mainColor.withValues(alpha: 0.6),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : LinearGradient(
                    colors: [
                      AppColors.whiteFade1,
                      AppColors.white.withValues(alpha: 0.6),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? AppColors.mainColor : AppColors.greyColor,
              width: 0.8,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.mainColor.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Icon(
                Icons.sports_cricket,
                color: isActive ? AppColors.white : AppColors.black,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? AppColors.white
                      : AppColors.black.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
