import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';
import 'package:Dream247/core/app_constants/app_pages.dart';
import 'package:Dream247/core/utils/app_utils.dart';
import 'package:Dream247/features/landing/data/models/joined_matches_model.dart';
import 'package:Dream247/features/landing/data/models/match_list_model.dart';
import 'package:Dream247/features/landing/data/singleton/app_singleton.dart';

class RecentMatchCard extends StatelessWidget {
  final JoinedMatchesModel data;
  const RecentMatchCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    String mode;
    switch (data.finalStatus) {
      case "pending":
      case "IsReviewed":
        mode = "Live";
        break;
      case "IsCanceled":
        mode = "Cancelled";
        break;
      case "IsAbandoned":
        mode = "Abandoned";
        break;
      default:
        mode = "Completed";
    }

    return InkWell(
      onTap: () {
        final matchData = MatchListModel(
          team1Name: data.team1ShortName,
          team2Name: data.team2ShortName,
          team1Logo: data.team1Logo ?? '',
          team2Logo: data.team2Logo ?? '',
          team1Color: "#ffffff",
          team2Color: "#000000",
          fantasyType: data.fantasyType,
          timeStart: data.startDate,
          id: data.matchkey,
          playing11Status: data.playing11Status,
          format: "",
          teamfullname1: data.team1,
          teamfullname2: data.team2,
          series: data.series,
          realMatchkey: data.realMatchkey,
          textNote: data.textNote,
        );

        AppSingleton().matchData = matchData;

        if (data.status == "notstarted") {
          AppNavigation.gotoUpcomingContestScreen(context, mode);
        } else {
          AppUtils.teamsCount.value = data.totalJoinTeam ?? 0;
          AppUtils.contestCount.value = data.totalJoinedContest ?? 0;
          AppNavigation.gotoLiveMatchDetails(
            context,
            mode,
            false,
            data.totalJoinedContest.toString(),
            "Cricket",
          );
        }
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 8.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.greyColor, width: 0.3.w),
          gradient:
              LinearGradient(colors: [AppColors.mainLightColor, AppColors.mainColor]),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// --- TEAMS INFO ROW ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTeamRow(
                            data.team1Logo, data.team1ShortName, data.team1),
                        SizedBox(height: 10.h),
                        _buildTeamRow(
                            data.team2Logo, data.team2ShortName, data.team2),
                      ],
                    ),
                  ),
                  Container(
                    height: 45.h,
                    width: 1.5.w,
                    color: AppColors.white,
                  ),
                  SizedBox(width: 10.w),
                  (data.status == "notstarted")
                      ? _buildUpcomingInfo(data)
                      : _buildCompletedInfo(data, mode),
                ],
              ),

              SizedBox(height: 8.h),
              Divider(color: AppColors.white, thickness: 0.2.h, height: 0.2.h),

              /// --- FOOTER INFO ---
              Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 6.w),
                child: Row(
                  children: [
                    Text(
                      '${data.totalJoinedContest}',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      'Contests',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 11.sp,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Icon(Icons.circle, color: AppColors.white, size: 6.sp),
                    SizedBox(width: 6.w),
                    Text(
                      '${data.totalJoinTeam}',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      'Teams',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper: Team Row
  Widget _buildTeamRow(String? logo, String? shortName, String? fullName) {
    return Row(
      children: [
        ClipOval(
          child: Image.network(
            logo ?? "",
            height: 26.h,
            width: 26.w,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Icon(Icons.error_outline, color: AppColors.white, size: 18.sp),
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          shortName ?? "",
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 6.w),
        Flexible(
          child: Text(
            fullName ?? "",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.sp,
              color: AppColors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// Helper: Upcoming info
  Widget _buildUpcomingInfo(JoinedMatchesModel data) {
    return SizedBox(
      width: 80.w,
      child: Column(
        children: [
          Text(
            "Upcoming",
            style: TextStyle(
              color: AppColors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppUtils().showCountdownTimerTextColorRecentMatches(
            data.startDate!,
            AppColors.white,
          ),
          Text(
            AppUtils.formatTime(data.startDate!),
            style: TextStyle(
              color: AppColors.white,
              fontSize: 9.sp,
            ),
          ),
        ],
      ),
    );
  }

  /// Helper: Completed/Live info
  Widget _buildCompletedInfo(JoinedMatchesModel data, String mode) {
    return Column(
      children: [
        Text(
          mode,
          style: TextStyle(
            color: AppColors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          AppUtils.formatTime(data.startDate!),
          style: TextStyle(
            color: AppColors.white,
            fontSize: 9.sp,
          ),
        ),
      ],
    );
  }
}
