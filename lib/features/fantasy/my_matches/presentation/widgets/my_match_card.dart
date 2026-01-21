import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_pages.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_utils.dart';
import 'package:unified_dream247/features/fantasy/landing/data/models/match_list_model.dart';
import 'package:unified_dream247/features/fantasy/landing/data/singleton/app_singleton.dart';
import 'package:unified_dream247/features/fantasy/my_matches/data/models/my_matches_model.dart';

class MyMatchCard extends StatefulWidget {
  final MyMatchesModel data;
  final String mode;
  final bool? isViewingOldMatches;
  final String? gameType;

  const MyMatchCard({
    super.key,
    required this.data,
    required this.mode,
    this.isViewingOldMatches,
    this.gameType,
  });

  @override
  State<MyMatchCard> createState() => _MyMatchCardState();
}

class _MyMatchCardState extends State<MyMatchCard> {
  String? mode;

  @override
  void initState() {
    super.initState();
    mode = widget.mode;
  }

  @override
  Widget build(BuildContext context) {
    // Preserve original mode logic
    if (widget.data.finalStatus == 'pending' ||
        widget.data.finalStatus == 'IsReviewed') {
      mode = 'Live';
    } else if (widget.data.finalStatus == 'IsCanceled') {
      mode = 'Cancelled';
    } else if (widget.data.finalStatus == 'IsAbandoned') {
      mode = 'Abandoned';
    } else {
      mode = widget.mode;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          // Keep full tap logic intact
          MatchListModel matchData = MatchListModel(
            team1Name: widget.data.team1ShortName,
            team2Name: widget.data.team2ShortName,
            team1Logo: widget.data.team1Logo,
            team2Logo: widget.data.team2Logo,
            team1Color: widget.data.team1Color,
            team2Color: widget.data.team2Color,
            fantasyType: widget.data.type,
            timeStart: widget.data.startDate,
            id: widget.data.matchkey,
            format: widget.data.format,
            teamfullname1: widget.data.team1Fullname,
            teamfullname2: widget.data.team2Fullname,
            seriesname: widget.data.seriesName,
            series: widget.data.seriesId,
            playing11Status: widget.data.playing11Status,
            realMatchkey: widget.data.realMatchkey,
          );

          AppSingleton().matchData = matchData;

          if (widget.mode == 'Upcoming') {
            AppNavigation.gotoUpcomingContestScreen(
              context,
              mode ?? 'upcoming',
            );
          } else {
            if (widget.data.finalStatus == 'pending' ||
                widget.data.finalStatus == 'IsReviewed') {
              mode = 'Live';
            } else if (widget.data.finalStatus == 'IsCanceled') {
              mode = 'Cancelled';
            } else if (widget.data.finalStatus == 'IsAbandoned') {
              mode = 'Abandoned';
            } else {
              mode = widget.mode;
            }
            AppUtils.teamsCount.value = widget.data.totalTeams ?? 0;
            AppUtils.contestCount.value = widget.data.joinedcontest ?? 0;
            AppNavigation.gotoLiveMatchDetails(
              context,
              mode ?? '',
              widget.isViewingOldMatches ?? false,
              widget.data.joinedcontest.toString(),
              widget.gameType,
            );
          }
          setState(() {});
        },
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: AppColors.greyColor, width: 0.2),
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                  colors: [AppColors.white, AppColors.whiteFade1],),),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 12.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              ClipOval(
                                child: Image.network(
                                  widget.data.team1Logo ?? '',
                                  height: 28,
                                  width: 28,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${widget.data.team1ShortName}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Flexible(
                                child: Text(
                                  '${widget.data.team1Fullname}',
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              ClipOval(
                                child: Image.network(
                                  widget.data.team2Logo ?? '',
                                  height: 28,
                                  width: 28,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${widget.data.team2ShortName}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Flexible(
                                child: Text(
                                  '${widget.data.team2Fullname}',
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(height: 40, width: 2, color: AppColors.black),
                    const SizedBox(width: 10),
                    (widget.data.status == 'notstarted')
                        ? SizedBox(
                            width: 80,
                            child: Column(
                              children: [
                                const Text(
                                  'Live',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                AppUtils()
                                    .showCountdownTimerTextColorRecentMatches(
                                  widget.data.startDate!,
                                  AppColors.black,
                                ),
                                Text(
                                  AppUtils.formatTime(widget.data.startDate!),
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.black,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              Text(
                                mode ?? 'Live',
                                style: TextStyle(
                                  color: mode == 'Live'
                                      ? Colors.red
                                      : AppColors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                AppUtils.formatTime(widget.data.startDate!),
                                style: const TextStyle(
                                  color: AppColors.black,
                                  fontSize: 9,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                  ],
                ),
              ),
              const Divider(
                color: AppColors.black,
                thickness: 0.15,
                height: 0.15,
              ),
              Container(
                decoration: const BoxDecoration(
                  // color: AppColors.lightGrey,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text(
                            '${widget.data.joinedcontest} ',
                            style: const TextStyle(
                              color: AppColors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 2),
                          child: Text(
                            'Contests ',
                            style: TextStyle(
                              color: AppColors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Icon(
                            Icons.circle,
                            color: AppColors.black,
                            size: 8.0,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            '${widget.data.totalTeams} ',
                            style: const TextStyle(
                              color: AppColors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 2),
                          child: Text(
                            'Teams ',
                            style: TextStyle(
                              color: AppColors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (widget.data.totalWinningAmount != null &&
                        widget.data.totalWinningAmount! > 0)
                      Row(
                        children: [
                          Text(
                            'Won ${Strings.indianRupee}${AppUtils.changeNumberToValue(widget.data.totalWinningAmount!.toInt())}',
                            style: GoogleFonts.tomorrow(
                              color: AppColors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Image.asset(
                            Images.imageIndianCurrency,
                            width: 18,
                            height: 18,
                          ),
                        ],
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
}
