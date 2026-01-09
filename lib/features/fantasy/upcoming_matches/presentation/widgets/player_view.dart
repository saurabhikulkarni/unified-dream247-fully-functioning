import 'package:Dream247/core/global_widgets/safe_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';
import 'package:Dream247/core/app_constants/app_pages.dart';
import 'package:Dream247/core/app_constants/images.dart';
import 'package:Dream247/features/landing/data/singleton/app_singleton.dart';
import 'package:Dream247/features/upcoming_matches/data/models/players_model.dart';
import 'package:Dream247/features/upcoming_matches/data/models/teams_model.dart';

class SinglePlayer extends StatefulWidget {
  final CreateTeamPlayersData data;
  final List<CreateTeamPlayersData> allPlayers;
  final Function(List<CreateTeamPlayersData>) selectedPlayers;
  final String? teamType;
  final int index;
  const SinglePlayer({
    super.key,
    required this.data,
    required this.allPlayers,
    required this.selectedPlayers,
    required this.index,
    this.teamType,
  });

  @override
  State<SinglePlayer> createState() => _SinglePlayer();
}

class _SinglePlayer extends State<SinglePlayer> {
  bool checkSelection(
    List<CreateTeamPlayersData> list,
    CreateTeamPlayersData? data,
  ) {
    int totalCount = 0, team1Count = 0, team2Count = 0;
    double creditUsed = 0;
    double maxCredits = AppSingleton
            .singleton.appData.games?[0].sportCategory?.maxCredits
            ?.toDouble() ??
        0.0;
    int maxPlayers =
        AppSingleton.singleton.appData.games?[0].sportCategory?.maxPlayers ?? 0;
    List<CreateTeamPlayersData> list1 = [];

    // Find correct teamTypeIndex
    var teamTypes =
        AppSingleton.singleton.appData.games?[0].sportCategory?.teamType ?? [];
    int teamTypeIndex = teamTypes.indexWhere((e) => e.name == widget.teamType);

    // If not found, fallback to default 0
    if (teamTypeIndex < 0) teamTypeIndex = 0;

    // Initialize counters
    List<PlayerCountersAdapter> counter = [];
    for (var zz in AppSingleton.singleton.appData.games?[0].sportCategory
            ?.teamType?[teamTypeIndex].playerPositions ??
        []) {
      PlayerCountersAdapter ob = PlayerCountersAdapter();
      ob.count = 0;
      ob.key = zz.code;
      ob.name = zz.name;
      ob.min = zz.minPlayersPerTeam;
      ob.max = zz.maxPlayersPerTeam;
      counter.add(ob);
    }

    //Count selected players
    for (var zz in list) {
      if (zz.isSelectedPlayer) {
        totalCount++;
        creditUsed += zz.credit!;
        if (zz.team == "team1") {
          team1Count++;
        } else {
          team2Count++;
        }

        for (int k = 0; k < counter.length; k++) {
          if (zz.role == counter[k].key) {
            counter[k].count = counter[k].count! + 1;
          }
        }
      }

      if (zz.role == data!.role!) {
        list1.add(zz);
      }
    }

    // Get actual teamType max per team
    int maxPlayersPerTeam = AppSingleton.singleton.appData.games?[0]
            .sportCategory?.teamType?[teamTypeIndex].maxPlayersPerTeam ??
        7;

    // Block if credit exceeded
    if (maxCredits - creditUsed < data!.credit!.toDouble()) {
      return false;
    }

    // Block if total players full
    int playersToBeSelected = maxPlayers - totalCount;
    if (playersToBeSelected == 0) {
      return false;
    }

    // Block if position exceeded (max limit)
    int list1Size = list1.where((e) => e.isSelectedPlayer).length;
    for (var pos in AppSingleton.singleton.appData.games?[0].sportCategory
            ?.teamType?[teamTypeIndex].playerPositions ??
        []) {
      if (data.role == pos.code && list1Size >= (pos.maxPlayersPerTeam ?? 0)) {
        return false;
      }
    }

    // NEW: Check min players per role (added from cricket_fantasy_demo)
    int minPlayersToBeSelected = 0;
    Map<String, int> positionsToBeSelected = {};

    for (var pos in AppSingleton.singleton.appData.games?[0].sportCategory
            ?.teamType?[teamTypeIndex].playerPositions ??
        []) {
      String position = pos.code ?? '';
      int selectedCount =
          list.where((p) => p.isSelectedPlayer && p.role == position).length;

      if (selectedCount < (pos.minPlayersPerTeam ?? 0)) {
        int diff = (pos.minPlayersPerTeam ?? 0) - selectedCount;
        positionsToBeSelected[position] = diff;
        minPlayersToBeSelected += diff;
      }
    }

    if (playersToBeSelected <= minPlayersToBeSelected) {
      // If the player we're trying to select is NOT from a role
      // that still needs players, block the selection
      if (!positionsToBeSelected.containsKey(data.role)) {
        return false;
      }
    }

    // 🚫 Block if team player limit exceeded
    if (data.team == "team1" && team1Count >= maxPlayersPerTeam) {
      return false;
    } else if (data.team == "team2" && team2Count >= maxPlayersPerTeam) {
      return false;
    }

    return true;
  }

  String getRoleShortName(String? role) {
    switch (role?.toLowerCase()) {
      case 'keeper':
        return 'WK';
      case 'batsman':
        return 'BAT';
      case 'allrounder':
        return 'AR';
      case 'bowler':
        return 'BOWL';
      default:
        return role?.toUpperCase() ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          if (widget.data.isSelectedPlayer) {
            widget.allPlayers
                .firstWhere(
                  (element) => element.playerid == widget.data.playerid,
                )
                .isSelectedPlayer = !widget.allPlayers
                .firstWhere(
                  (element) => element.playerid == widget.data.playerid,
                )
                .isSelectedPlayer;
            widget.selectedPlayers(widget.allPlayers);
          } else {
            if (checkSelection(widget.allPlayers, widget.data)) {
              widget.allPlayers
                  .firstWhere(
                    (element) => element.playerid == widget.data.playerid,
                  )
                  .isSelectedPlayer = !widget.allPlayers
                  .firstWhere(
                    (element) => element.playerid == widget.data.playerid,
                  )
                  .isSelectedPlayer;

              widget.selectedPlayers(widget.allPlayers);
            }
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: (!widget.data.isSelectedPlayer)
              ? AppColors.white
              : AppColors.shade1White,
        ),
        foregroundDecoration: BoxDecoration(
          color: (!checkSelection(widget.allPlayers, widget.data) &&
                  !widget.data.isSelectedPlayer)
              ? AppColors.white.withAlpha(178)
              : AppColors.transparent,
        ),
        child: Padding(
          padding: const EdgeInsets.only(right: 10, top: 4, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32.w,
                padding: EdgeInsets.only(left: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.index.toString(),
                      style: GoogleFonts.exo2(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.greyColor),
                    ),
                    Text(
                      getRoleShortName(widget.data.role ?? ""),
                      style: GoogleFonts.exo2(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blackColor),
                    )
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  AppNavigation.gotoPlayerDetails(context, widget.data);
                },
                child: SizedBox(
                  // padding: const EdgeInsets.only(left: 10),
                  width: 50.w,
                  height: 60.h,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      SafeNetworkImage(
                        url: widget.data.image,
                      ),
                      // Align(
                      //   alignment: Alignment.bottomLeft,
                      //   child: Container(
                      //     padding: const EdgeInsets.symmetric(
                      //       vertical: .5,
                      //       horizontal: 2,
                      //     ),
                      //     decoration: BoxDecoration(
                      //       color: (widget.data.team == "team1")
                      //           ? AppColors.white
                      //           : AppColors.letterColor,
                      //       borderRadius: BorderRadius.circular(1),
                      //     ),
                      //     child: Text(
                      //       (widget.data.team == "team1")
                      //           ? AppSingleton.singleton.matchData.team1Name!
                      //           : AppSingleton.singleton.matchData.team2Name!,
                      //       style: GoogleFonts.exo2(
                      //         fontWeight: FontWeight.w400,
                      //         fontSize: 9.sp,
                      //         color: (widget.data.team == "team1")
                      //             ? AppColors.letterColor
                      //             : AppColors.white,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Icon(Icons.info_outline, size: 18.sp),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                  left: 0,
                  right: 8,
                ),
                // margin: const EdgeInsets.only(left: 10),
                // width: MediaQuery.of(context).size.width - 250,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 45.w,
                      child: Text(
                        widget.data.name!.trim(),
                        style: GoogleFonts.exo2(
                          fontWeight: FontWeight.w600,
                          fontSize: 11.sp,
                          color: AppColors.letterColor,
                        ),
                        maxLines: 1,
                      ),
                    ),
                    Text(
                      '${widget.data.playerSelectionPercentage} %',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12.sp,
                        color: (widget.data.isSelectedPlayer)
                            ? AppColors.letterColor
                            : AppColors.letterColor,
                      ),
                      maxLines: 1,
                    ),
                    // Visibility(
                    //   visible: widget.data.playingstatus == 1 ||
                    //       widget.data.playingstatus == 0 ||
                    //       widget.data.lastMatchPlayingStatus == true,
                    //   child: Text(
                    //     (widget.data.playingstatus == 1)
                    //         ? '⦿ In Playing 11'
                    //         : (widget.data.playingstatus == 0)
                    //             ? '⦿ Not in Playing 11'
                    //             : (widget.data.lastMatchPlayingStatus == true)
                    //                 ? '⦿ Played Last Match'
                    //                 : '',
                    //     style: TextStyle(
                    //       fontWeight: FontWeight.w600,
                    //       fontSize: 10.sp,
                    //       color: (widget.data.playingstatus == 1)
                    //           ? AppColors.green
                    //           : (widget.data.playingstatus == 0)
                    //               ? Colors.red
                    //               : AppColors.greyColor,
                    //     ),
                    //     maxLines: 1,
                    //   ),
                    // ),
                  ],
                ),
              ),
              Column(
                children: [
                  SizedBox(
                    width: 45.w,
                    child: Icon(
                      (widget.data.isSelectedPlayer)
                          ? Icons.remove_circle_outline_rounded
                          : Icons.add_circle_outline_rounded,
                      size: 22.sp,
                      color: (widget.data.isSelectedPlayer)
                          ? Colors.red
                          : AppColors.green,
                    ),
                  ),
                  Text(
                    '${widget.data.totalpoints}',
                    style: GoogleFonts.tomorrow(
                      fontWeight: FontWeight.w300,
                      fontSize: 12.sp,
                      color: AppColors.greyColor,
                    ),
                  ),
                ],
              ),
              // Container(
              //   margin: const EdgeInsets.only(right: 20),
              //   child: SizedBox(
              //     width: 40.w,
              //     child: Text(
              //       '${widget.data.credit}',
              //       textAlign: TextAlign.right,
              //       style: GoogleFonts.tomorrow(
              //         fontWeight: FontWeight.w600,
              //         fontSize: 12.sp,
              //         color: AppColors.letterColor,
              //       ),
              //     ),
              //   ),
              // ),
              // SizedBox(
              //   width: 50.w,
              //   child: Icon(
              //     (widget.data.isSelectedPlayer)
              //         ? Icons.remove_circle_outline_rounded
              //         : Icons.add_circle_outline_rounded,
              //     size: 22.sp,
              //     color: (widget.data.isSelectedPlayer)
              //         ? Colors.red
              //         : AppColors.green,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
