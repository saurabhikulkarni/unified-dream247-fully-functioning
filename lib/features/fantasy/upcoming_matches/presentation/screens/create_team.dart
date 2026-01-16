// ignore_for_file: use_build_context_synchronously

import 'dart:ui';
import 'package:unified_dream247/features/fantasy/core/utils/app_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_pages.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/landing/data/singleton/app_singleton.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/players_model.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/user_teams_model.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/upcoming_match_datsource.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/domain/use_cases/upcoming_match_usecase.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/widgets/contest_head.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/widgets/player_view.dart';

class CreateTeam extends StatefulWidget {
  final int teamNumber;
  final bool edit;
  final String? challengeId;
  final int? isGuru;
  final String? guruTeamId;
  final String matchKey;
  final String? captainId, viceCaptainId, previousPlayers;
  final int? discount;
  final bool isContestDetail;
  final String teamType;

  const CreateTeam({
    super.key,
    required this.teamNumber,
    required this.edit,
    this.challengeId,
    required this.matchKey,
    this.previousPlayers,
    this.captainId,
    this.discount,
    this.isGuru,
    this.guruTeamId,
    this.viceCaptainId,
    required this.isContestDetail,
    this.teamType = "10-1",
  });

  @override
  State<CreateTeam> createState() => _CreateTeam();
}

class _CreateTeam extends State<CreateTeam> {
  bool hasChanges = false;
  int selectedPlayers = 0;
  int team1Count = 0, team2Count = 0;
  int totalPlayers = 11;
  double creditLeft = 100.0;
  Future<PlayersModel?>? allPlayers;
  List<CreateTeamPlayersData> list = [];
  List<List<CreateTeamPlayersData>> playersList = [];
  String filter = "both";
  String selectedRole = "All Players";

  UpcomingMatchUsecase upcomingMatchUsecase = UpcomingMatchUsecase(
    UpcomingMatchDatsource(ApiImpl(), ApiImplWithAccessToken()),
  );

  int teamTypeIndex = -1;

  @override
  void initState() {
    super.initState();

    // debugPrint("=== INIT START ===");
    // debugPrint("Widget TeamType: ${widget.teamType}");

    final teamTypes =
        AppSingleton.singleton.appData.games?[0].sportCategory?.teamType ?? [];

    for (int i = 0; i < teamTypes.length; i++) {
      // debugPrint(
      //   "teamType[$i] => ${teamTypes[i].name}, "
      //   "minPlayers: ${teamTypes[i].minPlayersPerTeam}, "
      //   "maxPlayers: ${teamTypes[i].maxPlayersPerTeam}",
      // );
    }

    teamTypeIndex = teamTypes.indexWhere(
      (element) => element.name == widget.teamType,
    );

    if (teamTypeIndex == -1) {
      teamTypeIndex = 0; // default fallback
    }

    // debugPrint("Selected teamType index: $teamTypeIndex");
    // debugPrint("Selected teamType name: ${teamTypes[teamTypeIndex].name}");
    // debugPrint(
    //   "Selected teamType minPlayers: ${teamTypes[teamTypeIndex].minPlayersPerTeam}",
    // );
    // debugPrint(
    //   "Selected teamType maxPlayers: ${teamTypes[teamTypeIndex].maxPlayersPerTeam}",
    // );
    // debugPrint("=== INIT END ===");
    getAllPlayers();
  }

  void updateHasChanges(bool value) {
    setState(() {
      hasChanges = value;
    });
  }

  void updateScores(List<CreateTeamPlayersData> list) {
    setState(() {
      hasChanges = true;
      selectedPlayers = 0;
      team1Count = 0;
      team2Count = 0;
      creditLeft = 100;

      for (var kk in list) {
        if (kk.isSelectedPlayer) {
          selectedPlayers++;
          creditLeft = creditLeft - kk.credit!.toDouble();
          if (kk.team == 'team1') {
            team1Count++;
          } else {
            team2Count++;
          }
        }
      }

      var maxPerTeam = AppSingleton.singleton.appData.games?[0].sportCategory
              ?.teamType?[teamTypeIndex].maxPlayersPerTeam ??
          7;

      printX(
        "Team1: $team1Count | Team2: $team2Count | Max Allowed: $maxPerTeam",
      );

      // Update position-wise counts (WK, BAT, AR, BOWL)
      for (int i = 0;
          i <
              (AppSingleton.singleton.appData.games?[0].sportCategory!
                      .teamType?[teamTypeIndex].playerPositions?.length ??
                  0);
          i++) {
        int count = 0;
        for (var player in list) {
          if (player.isSelectedPlayer &&
              player.role ==
                  AppSingleton.singleton.appData.games?[0].sportCategory!
                      .teamType?[teamTypeIndex].playerPositions?[i].code) {
            count++;
          }
        }

        AppSingleton.singleton.appData.games?[0].sportCategory!
            .teamType?[teamTypeIndex].playerPositions?[i].count = count;
      }
    });
  }

  void getAllPlayers() async {
    await upcomingMatchUsecase.getAllPlayersbyRealMatchKey(context).then((
      value,
    ) {
      List<String> pPlayers = [];
      list = value ?? [];
      if (list.isEmpty) {
        upcomingMatchUsecase.getAllPlayers(context).then((value) {
          list = value!.data!.toList();

          if (widget.edit) {
            pPlayers = widget.previousPlayers!.split(',');
            for (var i in list) {
              if (pPlayers.contains(i.playerid)) {
                i.isSelectedPlayer = true;
                if (widget.captainId != null &&
                    i.playerid == widget.captainId) {
                  i.captainSelected = 1;
                } else {
                  i.captainSelected = 0;
                }
                if (widget.viceCaptainId != null &&
                    i.playerid == widget.viceCaptainId) {
                  i.vicecaptainSelected = 1;
                } else {
                  i.vicecaptainSelected = 0;
                }
              }
            }
          }

          for (var zz in AppSingleton.singleton.appData.games?[0].sportCategory!
                  .teamType?[teamTypeIndex].playerPositions ??
              []) {
            List<CreateTeamPlayersData> innerList1 = [];
            for (var xx in list) {
              if (zz.code == xx.role) {
                innerList1.add(xx);
              }
            }
            playersList.add(innerList1);
          }

          for (int i = 0; i < playersList.length; i++) {
            int count = 0;
            for (var kk in playersList[i]) {
              if (kk.isSelectedPlayer) {
                selectedPlayers++;
                count++;
              }
            }
            AppSingleton.singleton.appData.games?[0].sportCategory!
                .teamType?[teamTypeIndex].playerPositions![i].count = count;
          }

          updateScores(list);
        });
      } else {
        if (widget.edit) {
          pPlayers = widget.previousPlayers!.split(',');
          for (var i in list) {
            if (pPlayers.contains(i.playerid)) {
              i.isSelectedPlayer = true;
              if (widget.captainId != null && i.playerid == widget.captainId) {
                i.captainSelected = 1;
              } else {
                i.captainSelected = 0;
              }
              if (widget.viceCaptainId != null &&
                  i.playerid == widget.viceCaptainId) {
                i.vicecaptainSelected = 1;
              } else {
                i.vicecaptainSelected = 0;
              }
            }
          }
        }

        for (var zz in AppSingleton.singleton.appData.games?[0].sportCategory
                ?.teamType?[teamTypeIndex].playerPositions ??
            []) {
          List<CreateTeamPlayersData> innerList1 = [];
          for (var xx in list) {
            if (zz.code == xx.role) {
              innerList1.add(xx);
            }
          }
          playersList.add(innerList1);
        }

        for (int i = 0; i < playersList.length; i++) {
          int count = 0;
          for (var kk in playersList[i]) {
            if (kk.isSelectedPlayer) {
              selectedPlayers++;
              count++;
            }
          }
          AppSingleton.singleton.appData.games?[0].sportCategory!
              .teamType?[teamTypeIndex].playerPositions![i].count = count;
        }

        updateScores(list);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    printX("MatchData => ${AppSingleton.singleton.matchData}");
    printX("Team1 Logo => ${AppSingleton.singleton.matchData.team1Logo}");
    printX("Team2 Logo => ${AppSingleton.singleton.matchData.team2Logo}");
    printX("Team1 Name => ${AppSingleton.singleton.matchData.team1Name}");
    printX("Team2 Name => ${AppSingleton.singleton.matchData.team2Name}");

    return ContestHead(
      safeAreaColor: AppColors.white,
      updateIndex: (p0) => 0,
      showAppBar: true,
      showWalletIcon: true,
      isLiveContest: false,
      addPadding: false,
      onWillPop: () async {
        backPressAction(context);
        return false;
      },
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // HEADER Section
              Container(
                color: AppColors.mainColor,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Column(
                  children: [
                    // Title
                    Center(
                      child: Text(
                        (AppSingleton.singleton.appData.games?[0]
                                    .sportCategory ==
                                null)
                            ? '--'
                            : 'Max ${((AppSingleton.singleton.appData.games?[0].sportCategory?.maxPlayers ?? 0) - (AppSingleton.singleton.appData.games?[0].sportCategory?.teamType?[teamTypeIndex].minPlayersPerTeam ?? 0))} Players from a team',
                        style: GoogleFonts.exo2(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Team selection row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Team 1
                        Row(
                          children: [
                            ClipOval(
                              child: Image.network(
                                AppSingleton.singleton.matchData.team1Logo ??
                                    "",
                                width: 20,
                                height: 20,
                                errorBuilder: (_, __, ___) => const SizedBox(
                                  width: 20,
                                  height: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              AppSingleton.singleton.matchData.team1Name ?? "",
                              style: GoogleFonts.exo2(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$team1Count',
                              style: GoogleFonts.exo2(
                                color: AppColors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '|',
                            style: GoogleFonts.exo2(
                              color: AppColors.greyColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        // Team 2
                        Row(
                          children: [
                            Text(
                              '$team2Count',
                              style: GoogleFonts.exo2(
                                color: AppColors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: 14.sp,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              AppSingleton.singleton.matchData.team2Name ?? "",
                              style: GoogleFonts.exo2(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            ClipOval(
                              child: Image.network(
                                AppSingleton.singleton.matchData.team2Logo ??
                                    "",
                                width: 20.w,
                                height: 20.h,
                                errorBuilder: (_, __, ___) => SizedBox(
                                  width: 20.w,
                                  height: 20.h,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Progress bar
                    _playerCountBar(context),
                  ],
                ),
              ),

              // Match Info Tabs
              Container(
                color: AppColors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _matchInfoTab('STATS', isSelected: true),
                      // const SizedBox(width: 12),
                      _matchInfoTab('Pitch: Batting'),
                      // const SizedBox(width: 12),
                      _matchInfoTab('Weather: Cloudy'),
                      // const SizedBox(width: 12),
                      _matchInfoTab('Good for: Spinners'),
                    ],
                  ),
                ),
              ),
              // Role Filter Buttons
              Container(
                color: AppColors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _roleFilterTab(
                        'All Players',
                        isSelected: selectedRole == 'All Players',
                      ),
                      if (AppSingleton.singleton.appData.games?[0].sportCategory
                              ?.teamType?[teamTypeIndex].playerPositions !=
                          null)
                        ...AppSingleton
                            .singleton
                            .appData
                            .games![0]
                            .sportCategory!
                            .teamType![teamTypeIndex]
                            .playerPositions!
                            .map((position) {
                          return _roleFilterTab(
                            position.name ?? '',
                            isSelected: selectedRole == (position.name ?? ''),
                          );
                        }).toList(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),
              // Two-Column Player List
              if (AppSingleton.singleton.appData.games?[0].sportCategory !=
                  null)
                Expanded(
                  child: _twoColumnPlayerList(),
                ),

              // Substitute Bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.mainColor,
                ),
                child: Center(
                  child: Text(
                    'Substitute',
                    style: GoogleFonts.exo2(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              // Bottom Buttons
              Align(
                alignment: Alignment.bottomCenter,
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.65),
                        border: Border(
                          top: BorderSide(
                            color: AppColors.mainColor.withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 18,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _glassButton(
                            label: 'PREVIEW',
                            icon: Icons.remove_red_eye_outlined,
                            onTap: () async {
                              List<UserTeamsModel> finalPlayers = [];
                              for (var zz in list) {
                                if (zz.isSelectedPlayer) {
                                  finalPlayers.add(
                                    UserTeamsModel(
                                      playerid: zz.playerid,
                                      playerimg: zz.image,
                                      image: zz.image,
                                      team: zz.team,
                                      name: zz.name,
                                      role: zz.role,
                                      credit: zz.credit!.toDouble(),
                                      playingstatus: zz.playingstatus,
                                      captain: zz.captainSelected,
                                      vicecaptain: zz.vicecaptainSelected,
                                    ),
                                  );
                                }
                              }
                              await AppNavigation.gotoPreviewScreen(
                                context,
                                "",
                                false,
                                finalPlayers,
                                "Team Preview",
                                "Upcoming",
                                0,
                                false,
                                "",
                              );
                            },
                            filled: false,
                          ),
                          _glassButton(
                            label: 'NEXT',
                            onTap: () {
                              List<CreateTeamPlayersData> finalPlayers = [];
                              for (var zz in list) {
                                if (zz.isSelectedPlayer) {
                                  finalPlayers.add(zz);
                                }
                              }
                              if (finalPlayers.length ==
                                  (AppSingleton.singleton.appData.games?[0]
                                          .sportCategory?.maxPlayers ??
                                      10)) {
                                list = finalPlayers;
                                AppNavigation.gotoCaptainViceCaptain(
                                  context,
                                  hasChanges,
                                  updateHasChanges,
                                  widget.teamNumber,
                                  widget.discount,
                                  widget.isGuru ?? 0,
                                  widget.guruTeamId ?? "",
                                  widget.challengeId ?? "",
                                  widget.isContestDetail,
                                  list,
                                  widget.teamType,
                                );
                              }
                            },
                            filled: selectedPlayers == totalPlayers,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _playerCountBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${selectedPlayers.toString().padLeft(2, '0')}/$totalPlayers',
          style: GoogleFonts.exo2(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
            fontSize: 11.sp,
          ),
        ),
        SizedBox(width: 12.w),
        ...List.generate(
          totalPlayers,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 24.w,
            height: 12.h,
            decoration: BoxDecoration(
              color:
                  index < selectedPlayers ? AppColors.green : AppColors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _matchInfoTab(String text, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.transparent : AppColors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.exo2(
          color: isSelected ? AppColors.letterColor : AppColors.letterColor,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _roleFilterTab(String text, {bool isSelected = false}) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedRole = text;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: GoogleFonts.exo2(
                color: isSelected ? AppColors.mainColor : AppColors.greyColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2,
              width: isSelected ? 24 : 0,
              decoration: BoxDecoration(
                color: AppColors.mainColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _twoColumnPlayerList() {
    // Filter players by selected role
    List<CreateTeamPlayersData> filteredList = list;
    if (selectedRole != 'All Players') {
      var positions = AppSingleton.singleton.appData.games?[0].sportCategory
              ?.teamType?[teamTypeIndex].playerPositions ??
          [];
      try {
        var position = positions.firstWhere((p) => p.name == selectedRole);
        if (position.code != null) {
          filteredList = list.where((p) => p.role == position.code).toList();
        }
      } catch (e) {
        // Role not found, show all players
      }
    }

    // Separate by team
    List<CreateTeamPlayersData> team1Players =
        filteredList.where((p) => p.team == 'team1').toList();
    List<CreateTeamPlayersData> team2Players =
        filteredList.where((p) => p.team == 'team2').toList();

    // Get role order from teamType configuration
    var roleOrder = AppSingleton.singleton.appData.games?[0].sportCategory
            ?.teamType?[teamTypeIndex].playerPositions
            ?.map((p) => p.code ?? '')
            .toList() ??
        [];

    // Function to sort players: group by role first, then by points within role
    List<CreateTeamPlayersData> sortPlayersByRoleAndPoints(
        List<CreateTeamPlayersData> players) {
      // Group by role
      Map<String, List<CreateTeamPlayersData>> playersByRole = {};
      for (var player in players) {
        String role = player.role ?? '';
        if (!playersByRole.containsKey(role)) {
          playersByRole[role] = [];
        }
        playersByRole[role]!.add(player);
      }

      // Sort each role group by points (descending)
      for (var role in playersByRole.keys) {
        playersByRole[role]!.sort((a, b) => num.parse(b.totalpoints ?? "0")
            .compareTo(num.parse(a.totalpoints ?? "0")));
      }

      // Combine in role order
      List<CreateTeamPlayersData> sorted = [];
      for (var roleCode in roleOrder) {
        if (playersByRole.containsKey(roleCode)) {
          sorted.addAll(playersByRole[roleCode]!);
        }
      }

      // Add any remaining players with roles not in the order list
      for (var role in playersByRole.keys) {
        if (!roleOrder.contains(role)) {
          sorted.addAll(playersByRole[role]!);
        }
      }

      return sorted;
    }

    // Sort both teams
    team1Players = sortPlayersByRoleAndPoints(team1Players);
    team2Players = sortPlayersByRoleAndPoints(team2Players);

    return Container(
      color: AppColors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Team 1 Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.lightCard,
                    border: Border(
                      bottom: BorderSide(color: AppColors.lightGrey, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      ClipOval(
                        child: Image.network(
                          AppSingleton.singleton.matchData.team1Logo ?? "",
                          width: 20,
                          height: 20,
                          errorBuilder: (_, __, ___) => SizedBox(
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      Text(
                        AppSingleton.singleton.matchData.team1Name ?? "",
                        style: GoogleFonts.exo2(
                          color: AppColors.letterColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.lightCard,
                    border: Border(
                      bottom: BorderSide(color: AppColors.lightGrey, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Spacer for position number (24) + gap (0) + image (40) + gap (8) = 72
                      72.horizontalSpace,
                      // Spacer for name column (expanded)
                      Expanded(
                        child: Text(
                          '% Sel by',
                          style: GoogleFonts.exo2(
                            color: AppColors.greyColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      // Points header aligned to the right
                      Text(
                        'Points',
                        style: GoogleFonts.exo2(
                          color: AppColors.greyColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                // Players List
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: team1Players.length,
                    itemBuilder: (context, index) {
                      return SinglePlayer(
                        index: index + 1,
                        data: team1Players[index],
                        allPlayers: list,
                        teamType: widget.teamType,
                        // positionNumber: index + 1,
                        selectedPlayers: (p0) {
                          updateScores(p0);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Divider
          Container(
            width: 1,
            color: AppColors.lightGrey,
          ),
          // Team 2 Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.lightCard,
                    border: Border(
                      bottom: BorderSide(color: AppColors.lightGrey, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      ClipOval(
                        child: Image.network(
                          AppSingleton.singleton.matchData.team2Logo ?? "",
                          width: 20,
                          height: 20,
                          errorBuilder: (_, __, ___) => const SizedBox(
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppSingleton.singleton.matchData.team2Name ?? "",
                        style: GoogleFonts.exo2(
                          color: AppColors.letterColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.lightCard,
                    border: Border(
                      bottom: BorderSide(color: AppColors.lightGrey, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Spacer for position number (24) + gap (0) + image (40) + gap (8) = 72
                      const SizedBox(width: 72),
                      // Spacer for name column (expanded)
                      Expanded(
                        child: Text(
                          '% Sel by',
                          style: GoogleFonts.exo2(
                            color: AppColors.greyColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      // Points header aligned to the right
                      Text(
                        'Points',
                        style: GoogleFonts.exo2(
                          color: AppColors.greyColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                // Players List
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: team2Players.length,
                    itemBuilder: (context, index) {
                      return SinglePlayer(
                        index: index + 1,
                        data: team2Players[index],
                        allPlayers: list,
                        teamType: widget.teamType,
                        // positionNumber: index + 1,
                        selectedPlayers: (p0) {
                          updateScores(p0);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassButton({
    required String label,
    required VoidCallback onTap,
    IconData? icon,
    bool filled = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 42,
        width: MediaQuery.of(context).size.width * 0.4,
        decoration: BoxDecoration(
          gradient: filled ? AppColors.appBarGradient : null,
          border: filled
              ? null
              : Border.all(
                  color: AppColors.mainColor.withValues(alpha: 0.3),
                  width: 1,
                ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: AppColors.mainColor.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(
                icon,
                size: 16,
                color: filled ? AppColors.white : AppColors.mainColor,
              ),
            if (icon != null) const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.exo2(
                color: filled ? AppColors.white : AppColors.mainColor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void backPressAction(BuildContext myContext) {
    showModalBottomSheet(
      context: myContext,
      backgroundColor: AppColors.transparent,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.8),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Go Back?',
                    style: TextStyle(
                      color: AppColors.letterColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Image.asset(Images.imageDiscardTeam, height: 60),
                  const SizedBox(height: 8),
                  const Text(
                    'This team will not be saved!',
                    style: TextStyle(color: AppColors.greyColor, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  _glassButton(
                    label: 'DISCARD TEAM',
                    onTap: () {
                      updateHasChanges(false);
                      Navigator.pop(myContext);
                      Navigator.pop(myContext);
                    },
                    filled: true,
                  ),
                  const SizedBox(height: 10),
                  _glassButton(
                    label: 'CONTINUE EDITING',
                    onTap: () => Navigator.pop(context),
                    filled: false,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
