// ignore_for_file: use_build_context_synchronously

import 'package:Dream247/core/global_widgets/safe_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Dream247/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:Dream247/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';
import 'package:Dream247/core/app_constants/app_pages.dart';
import 'package:Dream247/core/app_constants/images.dart';
import 'package:Dream247/core/global_widgets/main_container.dart';
import 'package:Dream247/features/landing/data/singleton/app_singleton.dart';
import 'package:Dream247/features/menu_items/presentation/providers/user_data_provider.dart';
import 'package:Dream247/features/upcoming_matches/data/models/teams_model.dart';
import 'package:Dream247/features/upcoming_matches/data/models/user_teams_model.dart';
import 'package:Dream247/features/upcoming_matches/data/upcoming_match_datsource.dart';
import 'package:Dream247/features/upcoming_matches/domain/use_cases/upcoming_match_usecase.dart';

class TeamView extends StatefulWidget {
  final String teamType;
  final String? challengeId;
  final TeamsModel data;
  final bool chooseTeam;
  final String mode;
  final int length;
  final Function(List<TeamsModel> list) updateTeams;
  final Function(bool)? updateHasChanges;
  const TeamView({
    super.key,
    required this.teamType,
    this.challengeId,
    required this.data,
    required this.chooseTeam,
    required this.mode,
    required this.length,
    required this.updateTeams,
    this.updateHasChanges,
  });

  @override
  State<TeamView> createState() => _TeamView();
}

class _TeamView extends State<TeamView> {
  bool hasChanges = false;

  UpcomingMatchUsecase upcomingMatchUsecase = UpcomingMatchUsecase(
    UpcomingMatchDatsource(ApiImpl(), ApiImplWithAccessToken()),
  );

  void updateHasChanges(bool value) {
    setState(() {
      hasChanges = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool showCheckbox = widget.chooseTeam && !widget.data.isSelected!;
    final userData =
        Provider.of<UserDataProvider>(context, listen: false).userData;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: SizedBox(
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: InkWell(
                onTap: () async {
                  await AppNavigation.gotoPreviewScreen(
                    context,
                    widget.data.jointeamid,
                    false,
                    [],
                    userData?.team,
                    widget.mode,
                    widget.data.teamnumber,
                    false,
                    widget.data.userid ?? "",
                  );
                },
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Material(
                    borderRadius: BorderRadius.circular(10),
                    elevation: 5,
                    child: MainContainer(
                      // margin: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Padding(
                            padding: (widget.mode == "Upcoming")
                                ? const EdgeInsets.only(left: 10.0, right: 10)
                                : const EdgeInsets.only(
                                    left: 10.0, right: 10, top: 10, bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${userData?.team ?? "${Provider.of<UserDataProvider>(context, listen: false).userData?.mobile}"} (T${widget.data.teamnumber})',
                                        style: GoogleFonts.exo2(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14.sp,
                                          color: AppColors.letterColor,
                                        ),
                                      ),
                                      (widget.mode == 'Upcoming' &&
                                              !showCheckbox)
                                          ? Row(
                                              children: [
                                                Icon(Icons.refresh),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.edit_outlined,
                                                    size: 18.sp,
                                                    color:
                                                        AppColors.letterColor,
                                                  ),
                                                  onPressed: () async {
                                                    int teamNumber =
                                                        widget.data.teamnumber!;
                                                    String selectedPlayers = "";

                                                    List<UserTeamsModel>
                                                        userTeams =
                                                        await upcomingMatchUsecase
                                                            .getUserTeam(
                                                      context,
                                                      widget.data.jointeamid ??
                                                          "",
                                                    );
                                                    for (var i in userTeams) {
                                                      selectedPlayers +=
                                                          ',${i.playerid}';
                                                    }

                                                    bool? hasChanges =
                                                        await AppNavigation
                                                            .gotoCreateTeamScreen(
                                                      context,
                                                      teamNumber,
                                                      true,
                                                      AppSingleton.singleton
                                                          .matchData.id!,
                                                      "",
                                                      0,
                                                      "",
                                                      selectedPlayers,
                                                      widget.data.captainId,
                                                      widget.data.vicecaptainId,
                                                      0,
                                                      false,
                                                      widget.teamType,
                                                    );
                                                    if (hasChanges == true) {
                                                      if (widget.chooseTeam ==
                                                          true) {
                                                        List<TeamsModel>
                                                            updatedTeams =
                                                            await upcomingMatchUsecase
                                                                .getTeamswithChallengeId(
                                                          context,
                                                          widget.challengeId ??
                                                              "",
                                                        );
                                                        widget.updateTeams(
                                                            updatedTeams);
                                                      } else {
                                                        List<TeamsModel>
                                                            updatedTeams =
                                                            await upcomingMatchUsecase
                                                                .getMyTeams(
                                                                    context);
                                                        widget.updateTeams(
                                                            updatedTeams);
                                                      }

                                                      widget.updateHasChanges
                                                          ?.call(true);
                                                    }
                                                  },
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.file_copy_outlined,
                                                    size: 18.sp,
                                                    color:
                                                        AppColors.letterColor,
                                                  ),
                                                  onPressed: () async {
                                                    int teamNumber =
                                                        widget.length + 1;
                                                    String selectedPlayers = "";
                                                    List<UserTeamsModel>
                                                        userTeams =
                                                        await upcomingMatchUsecase
                                                            .getUserTeam(
                                                      context,
                                                      widget.data.jointeamid ??
                                                          "",
                                                    );
                                                    for (var i in userTeams) {
                                                      selectedPlayers +=
                                                          ',${i.playerid}';
                                                    }

                                                    bool? hasChanges =
                                                        await AppNavigation
                                                            .gotoCreateTeamScreen(
                                                      context,
                                                      teamNumber,
                                                      true,
                                                      AppSingleton.singleton
                                                          .matchData.id!,
                                                      "",
                                                      0,
                                                      "",
                                                      selectedPlayers,
                                                      widget.data.captainId,
                                                      widget.data.vicecaptainId,
                                                      0,
                                                      false,
                                                      widget.teamType,
                                                    );
                                                    if (hasChanges == true) {
                                                      if (widget.chooseTeam ==
                                                          true) {
                                                        List<TeamsModel>
                                                            updatedTeams =
                                                            await upcomingMatchUsecase
                                                                .getTeamswithChallengeId(
                                                          context,
                                                          widget.challengeId ??
                                                              "",
                                                        );
                                                        widget.updateTeams(
                                                            updatedTeams);
                                                      } else {
                                                        List<TeamsModel>
                                                            updatedTeams =
                                                            await upcomingMatchUsecase
                                                                .getMyTeams(
                                                                    context);
                                                        widget.updateTeams(
                                                            updatedTeams);
                                                      }

                                                      widget.updateHasChanges
                                                          ?.call(true);
                                                    }
                                                  },
                                                ),
                                              ],
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ),
                                // (widget.chooseTeam && !widget.data.isSelected!)
                                //     ? Checkbox(
                                //         materialTapTargetSize:
                                //             MaterialTapTargetSize.padded,
                                //         shape: const CircleBorder(),
                                //         checkColor: AppColors.mainColor,
                                //         activeColor: AppColors.white,
                                //         fillColor: const WidgetStatePropertyAll(
                                //           AppColors.shade1White,
                                //         ),
                                //         value: widget.data.isPicked,
                                //         onChanged: (value) {
                                //           setState(() {
                                //             widget.data.isPicked = value ?? false;
                                //           });
                                //         },
                                //       )
                                //     : Container(),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 15),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color:
                                        AppColors.black.withValues(alpha: 0.1))
                                // image: const DecorationImage(
                                // image: AssetImage(Images.imageGround),
                                // fit: BoxFit.cover,
                                // ),
                                ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (widget.mode == 'Upcoming')
                                  Flexible(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Stack(
                                              children: [
                                                CircleAvatar(
                                                  radius: 24.r,
                                                  child: ClipOval(
                                                    child: SafeNetworkImage(
                                                      url: widget.data
                                                              .captainimage ??
                                                          Images
                                                              .imageDefalutPlayer,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 5),
                                            Container(
                                              width: 75,
                                              // margin: const EdgeInsets.all(0),
                                              padding: EdgeInsets.symmetric(
                                                vertical: 6,
                                                horizontal: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                    (widget.data.captainTeam ==
                                                            "team1")
                                                        ? AppColors.letterColor
                                                        : AppColors.letterColor,
                                              ),
                                              child: Text(
                                                widget.data.captain ?? "",
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.exo2(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 10,
                                                  color: (widget.data
                                                              .captainTeam ==
                                                          "team1")
                                                      ? AppColors.white
                                                      : AppColors.white,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 75,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 6,
                                                      horizontal: 6),
                                              decoration: BoxDecoration(
                                                color:
                                                    (widget.data.captainTeam ==
                                                            "team1")
                                                        ? AppColors.green
                                                        : AppColors.green,
                                              ),
                                              child: Text(
                                                "Captain",
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.exo2(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 10,
                                                  color: (widget.data
                                                              .captainTeam ==
                                                          "team1")
                                                      ? AppColors.white
                                                      : AppColors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if ((widget.mode != 'Upcoming'))
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Points',
                                                style: GoogleFonts.exo2(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16.sp,
                                                  color: AppColors.white,
                                                ),
                                              ),
                                              Text(
                                                '${widget.data.totalpoints}',
                                                style: GoogleFonts.tomorrow(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16.sp,
                                                  color: AppColors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Stack(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      right: showCheckbox
                                                          ? 5
                                                          : 10),
                                                  child: CircleAvatar(
                                                    radius: 24.r,
                                                    child: ClipOval(
                                                      child: SafeNetworkImage(
                                                        url: widget.data
                                                                .vicecaptainimage ??
                                                            Images
                                                                .imageDefalutPlayer,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 5),
                                            Container(
                                              // margin: const EdgeInsets.all(0),
                                              width: 75,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 6,
                                                horizontal: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: (widget.data
                                                            .viceCaptainTeam ==
                                                        "team1")
                                                    ? AppColors.letterColor
                                                    : AppColors.letterColor,
                                              ),
                                              child: Text(
                                                widget.data.vicecaptain ?? '',
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.exo2(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 10,
                                                  color: (widget.data
                                                              .viceCaptainTeam ==
                                                          "team1")
                                                      ? AppColors.white
                                                      : AppColors.white,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 75,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 6,
                                                      horizontal: 6),
                                              decoration: BoxDecoration(
                                                color: (widget.data
                                                            .viceCaptainTeam ==
                                                        "team1")
                                                    ? AppColors.green
                                                    : AppColors.green,
                                              ),
                                              child: Text(
                                                'Vice Captain',
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.exo2(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 10,
                                                  color: (widget.data
                                                              .viceCaptainTeam ==
                                                          "team1")
                                                      ? AppColors.white
                                                      : AppColors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                Flexible(
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 8.h,
                                              horizontal: 3.w,
                                            ),
                                            child: Column(
                                              children: [
                                                Text(
                                                  AppSingleton
                                                          .singleton
                                                          .matchData
                                                          .team1Name ??
                                                      "",
                                                  style: GoogleFonts.exo2(
                                                    color:
                                                        AppColors.letterColor,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16.sp,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  '${widget.data.team1Count}',
                                                  style: GoogleFonts.tomorrow(
                                                    color:
                                                        AppColors.letterColor,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16.sp,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 8.h,
                                              horizontal: 3.w,
                                            ),
                                            child: Column(
                                              children: [
                                                Text(
                                                  AppSingleton
                                                          .singleton
                                                          .matchData
                                                          .team2Name ??
                                                      "s",
                                                  style: GoogleFonts.exo2(
                                                    color:
                                                        AppColors.letterColor,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16.sp,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  '${widget.data.team2Count}',
                                                  style: GoogleFonts.tomorrow(
                                                    color:
                                                        AppColors.letterColor,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16.sp,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 8,
                              left: 15,
                              right: 15,
                              top: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "WK ",
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: AppColors.letterColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            '${widget.data.wicketKeeperCount}',
                                        style: GoogleFonts.tomorrow(
                                          fontSize: 14.sp,
                                          color: AppColors.letterColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "BAT ",
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: AppColors.letterColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '${widget.data.batsmancount}',
                                        style: GoogleFonts.tomorrow(
                                          fontSize: 14.sp,
                                          color: AppColors.letterColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "ALL ",
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: AppColors.letterColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '${widget.data.allroundercount}',
                                        style: GoogleFonts.tomorrow(
                                          fontSize: 14.sp,
                                          color: AppColors.letterColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "BWL ",
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: AppColors.letterColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '${widget.data.bowlercount}',
                                        style: GoogleFonts.tomorrow(
                                          fontSize: 14.sp,
                                          color: AppColors.letterColor,
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
                  ),
                ),
              ),
            ),

            /// CHECKBOX (RIGHT SIDE)
            if (showCheckbox)
              Checkbox(
                shape: const CircleBorder(),
                checkColor: AppColors.mainColor,
                activeColor: AppColors.white,
                fillColor: const WidgetStatePropertyAll(
                  AppColors.shade1White,
                ),
                value: widget.data.isPicked,
                onChanged: (value) {
                  setState(() {
                    widget.data.isPicked = value ?? false;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}
