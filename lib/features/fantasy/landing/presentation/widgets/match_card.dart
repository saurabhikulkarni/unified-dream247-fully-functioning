import 'package:Dream247/core/app_constants/strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';
import 'package:Dream247/core/app_constants/app_pages.dart';
import 'package:Dream247/core/utils/app_utils.dart';
import 'package:Dream247/features/landing/data/models/match_list_model.dart';
import 'package:Dream247/features/landing/data/singleton/app_singleton.dart';

class MatchCard extends StatelessWidget {
  final MatchListModel data;
  final String gameType;
  final int index;

  const MatchCard({
    super.key,
    required this.data,
    required this.gameType,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLineupOut = data.playing11Status == 1;

    return InkWell(
      onTap: () {
        AppSingleton().matchData = data;
        AppUtils.teamsCount.value = 0;
        AppUtils.contestCount.value = 0;
        AppNavigation.gotoUpcomingContestScreen(context, "upcoming");
      },
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 6),
        // padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 MATCH NAME + STATUS BADGE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0)
                  .copyWith(top: 14, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      data.seriesname ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  _statusBadge(),
                ],
              ),
            ),
            5.verticalSpace,
            Container(
              height: 1,
              color: AppColors.black.withValues(alpha: 0.3),
            ),

            16.verticalSpace,

            // 🔹 TEAM ROW
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _team(data.team1Logo, data.team1Name, data.teamfullname1),
                  isLineupOut ? _lineupBadge() : _timerWidget(),
                  _team(data.team2Logo, data.team2Name, data.teamfullname2),
                ],
              ),
            ),

            14.verticalSpace,

            Container(
              height: 1,
              color: AppColors.black.withValues(alpha: 0.3),
            ),
            5.verticalSpace,

            // 🔹 DATE + PRIZE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14)
                  .copyWith(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppUtils.formatDate(data.timeStart ?? ""),
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(colors: [
                          const Color.fromARGB(255, 251, 246, 247),
                          const Color.fromARGB(255, 254, 220, 223)
                        ])),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.gift,
                          color: Colors.deepOrange,
                          size: 16.sp,
                        ),
                        4.horizontalSpace,
                        Text(
                          "Win ${Strings.indianRupee}${AppUtils.changeNumberToValue(data.mega ?? 0)}",
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔸 TEAM WIDGET ------------------------------------------
  Widget _team(String? logo, String? name, String? fullname) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ClipOval(
              child: Image.network(
                logo ?? "",
                height: 32.h,
                width: 32.w,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.image_not_supported, size: 28.sp),
              ),
            ),
            6.horizontalSpace,
            Text(
              name ?? "",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
              ),
            ),
          ],
        ),
        SizedBox(
          width: 80.sp,
          child: Text(
            fullname ?? "",
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
            ),
          ),
        ),
      ],
    );
  }

  // 🔸 MATCH STATUS BADGE -----------------------------------
  Widget _statusBadge() {
    if (data.launchStatus == "live") {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          "Live",
          style: GoogleFonts.poppins(
            color: Colors.red,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (data.playing11Status == 1) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          "Lineup",
          style: GoogleFonts.poppins(
            color: Colors.green,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "Upcoming",
        style: GoogleFonts.poppins(
          color: Colors.grey[700],
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // 🔸 LINEUP BADGE -----------------------------------------
  Widget _lineupBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 14.sp),
          4.horizontalSpace,
          Text(
            "LINEUP",
            style: GoogleFonts.poppins(
              color: Colors.green,
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 🔸 TIMER + START TIME ------------------------------------
  Widget _timerWidget() {
    return Column(
      children: [
        AppUtils().showCountdownTimerTextColor(
          data.timeStart ?? "",
          Colors.red,
        ),
        4.verticalSpace,
        Text(
          AppUtils.formatTime(data.timeStart ?? ""),
          style: GoogleFonts.poppins(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }
}
