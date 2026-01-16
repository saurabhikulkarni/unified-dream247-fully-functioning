import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/landing/data/singleton/app_singleton.dart';
import 'package:unified_dream247/features/fantasy/my_matches/data/models/match_livescore_model.dart';

class Scoreboard extends StatelessWidget {
  final List<MatchLiveScoreModel>? list;
  final String? mode;
  const Scoreboard({super.key, this.list, this.mode});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main scoreboard card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              decoration:
                  BoxDecoration(color: Colors.white.withValues(alpha: 0.5)),
              child: Column(
                children: [
                  // ================= TEAM ROW =================
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /// LEFT TEAM
                        _buildTeamSection(
                          context,
                          isLeft: true,
                          logo: ((list ?? []).isEmpty)
                              ? AppSingleton.singleton.matchData.team1Logo ?? ""
                              : ((list?[0].teams?.isNotEmpty ?? false)
                                      ? list![0].teams![0].logoUrl ??
                                          AppSingleton
                                              .singleton.matchData.team1Logo
                                      : list?[0].teama?.logoUrl ??
                                          AppSingleton
                                              .singleton.matchData.team1Logo) ??
                                  '',
                          name: ((list ?? []).isEmpty)
                              ? AppSingleton.singleton.matchData.team1Name ?? ""
                              : ((list?[0].teams?.isNotEmpty ?? false)
                                      ? list![0].teams![0].title ??
                                          AppSingleton
                                              .singleton.matchData.team1Name
                                      : list?[0].teama?.shortName ??
                                          AppSingleton
                                              .singleton.matchData.team1Name) ??
                                  '',
                          score: ((list ?? []).isEmpty)
                              ? "---"
                              : ((list?[0].teams ?? []).isNotEmpty)
                                  ? (list?[0].teams?[0].scoresFull != null &&
                                          list?[0].teams?[0].scoresFull != '')
                                      ? (list?[0].teams?[0].scoresFull ?? "---")
                                          .replaceAll('&', '\n')
                                      : 'Yet to Bat'
                                  : (list?[0].teamb?.scoresFull != null &&
                                          list?[0].teama?.scoresFull != '')
                                      ? (list?[0].teama?.scoresFull ?? "---")
                                          .replaceAll('&', '\n')
                                      : 'Yet to Bat',
                        ),

                        /// RIGHT TEAM
                        _buildTeamSection(
                          context,
                          isLeft: false,
                          logo: ((list ?? []).isEmpty)
                              ? AppSingleton.singleton.matchData.team2Logo ?? ""
                              : ((list?[0].teams?.isNotEmpty ?? false)
                                      ? list![0].teams![1].logoUrl ??
                                          AppSingleton
                                              .singleton.matchData.team2Logo
                                      : list?[0].teamb?.logoUrl ??
                                          AppSingleton
                                              .singleton.matchData.team2Logo) ??
                                  '',
                          name: ((list ?? []).isEmpty)
                              ? AppSingleton.singleton.matchData.team2Name ?? ""
                              : ((list?[0].teams?.isNotEmpty ?? false)
                                      ? list![0].teams![1].title ??
                                          AppSingleton
                                              .singleton.matchData.team2Name
                                      : list?[0].teamb?.shortName ??
                                          AppSingleton
                                              .singleton.matchData.team2Name) ??
                                  '',
                          score: ((list ?? []).isEmpty)
                              ? "---"
                              : ((list?[0].teams ?? []).isNotEmpty)
                                  ? (list?[0].teams?[1].scoresFull != null &&
                                          list?[0].teams?[1].scoresFull != '')
                                      ? (list?[0].teams?[1].scoresFull ?? "---")
                                          .replaceAll('&', '\n')
                                      : 'Yet to Bat'
                                  : (list?[0].teamb?.scoresFull != null &&
                                          list?[0].teamb?.scoresFull != '')
                                      ? (list?[0].teamb?.scoresFull ?? "---")
                                          .replaceAll('&', '\n')
                                      : 'Yet to Bat',
                        ),
                      ],
                    ),
                  ),

                  // ================= BATTING ROW =================
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 14),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: [
                  //       _iconText(Icons.sports_cricket, "S Verma • 18(9)"),
                  //       _iconText(Icons.rice_bowl_outlined, "Pots 0/8"),
                  //     ],
                  //   ),
                  // ),

                  const SizedBox(height: 10),

                  // ================= OVER BALLS =================
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: List.generate(
                  //     6,
                  //     (index) => Container(
                  //       margin: const EdgeInsets.symmetric(horizontal: 3),
                  //       height: 22,
                  //       width: 22,
                  //       alignment: Alignment.center,
                  //       decoration: BoxDecoration(
                  //         color: index == 3
                  //             ? AppColors.green
                  //             : AppColors.lightGrey,
                  //         borderRadius: BorderRadius.circular(6),
                  //       ),
                  //       child: Text(
                  //         ["0", "2", "1", "4", "0", "1"][index],
                  //         style: GoogleFonts.exo2(
                  //           fontWeight: FontWeight.bold,
                  //           fontSize: 11,
                  //           color: index == 3 ? Colors.white : AppColors.black,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),

                  const SizedBox(height: 8),

                  // ================= TOSS TEXT =================
                  if ((list ?? []).isNotEmpty)
                    if (list?[0].statusNote != null &&
                        (list?[0].statusNote ?? "").isNotEmpty)
                      Text(
                        list?[0].statusNote ?? "---",
                        style: GoogleFonts.exo2(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black.withOpacity(0.75),
                        ),
                      ),

                  const SizedBox(height: 10),

                  // ================= BOTTOM STRIP =================
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey.withOpacity(0.25),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                      ),
                    ),
                    // child: Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     _pill("Highlight", AppColors.mainColor),
                    //     _pill("T2 - 146 pts", AppColors.mainColor),
                    //     _pill("T1 - 130 pts", AppColors.mainLightColor),
                    //     // Container(
                    //     //   padding: const EdgeInsets.symmetric(
                    //     //     horizontal: 14,
                    //     //     vertical: 6,
                    //     //   ),
                    //     //   decoration: BoxDecoration(
                    //     //     color: Colors.green.withOpacity(0.15),
                    //     //     borderRadius: BorderRadius.circular(20),
                    //     //   ),
                    //     //   child: Text(
                    //     //     "View Scorecard ›",
                    //     //     style: GoogleFonts.exo2(
                    //     //       fontSize: 12,
                    //     //       fontWeight: FontWeight.w600,
                    //     //       color: Colors.green.shade700,
                    //     //     ),
                    //     //   ),
                    //     // ),
                    //   ],
                    // ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Mode label (Live, Upcoming, etc.)
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          height: 32,
          width: MediaQuery.of(context).size.width * 0.25,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                (mode == 'Live')
                    ? Colors.red.withValues(alpha: 0.8)
                    : AppColors.lightGrey.withValues(alpha: 0.4),
                (mode == 'Live')
                    ? Colors.red.withValues(alpha: 0.6)
                    : AppColors.lightGrey.withValues(alpha: 0.3),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: 8,
                  width: 8,
                  decoration: BoxDecoration(
                    color: (mode == 'Live')
                        ? AppColors.white
                        : Colors.red.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  mode?.toUpperCase() ?? "---",
                  style: GoogleFonts.exo2(
                    color: (mode == 'Live')
                        ? AppColors.white
                        : AppColors.greyColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper widget for each team side
  Widget _buildTeamSection(
    BuildContext context, {
    required bool isLeft,
    required String logo,
    required String name,
    required String score,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (isLeft)
          ClipOval(
            child: Image.network(
              logo,
              height: 40.h,
              width: 40.w,
              fit: BoxFit.cover,
            ),
          ),
        if (isLeft) const SizedBox(width: 8),

        // ✅ Wrapped text in a constrained box so long names don’t overflow
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth:
                MediaQuery.of(context).size.width * 0.28, // keeps layout stable
          ),
          child: Column(
            crossAxisAlignment:
                isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              Text(
                name,
                textAlign: isLeft ? TextAlign.start : TextAlign.end,
                overflow: TextOverflow.ellipsis,
                maxLines: 1, // allows name to wrap or ellipsis
                style: GoogleFonts.exo2(
                  color: AppColors.letterColor,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                score,
                textAlign: isLeft ? TextAlign.start : TextAlign.end,
                style: GoogleFonts.tomorrow(
                  color: AppColors.letterColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        if (!isLeft) SizedBox(width: 8.w),
        if (!isLeft)
          ClipOval(
            child: Image.network(
              logo,
              height: 42.h,
              width: 42.w,
              fit: BoxFit.cover,
            ),
          ),
      ],
    );
  }
}
