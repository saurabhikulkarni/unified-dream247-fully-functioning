// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_pages.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/app_toast.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/accounts_datasource.dart';
import 'package:unified_dream247/features/fantasy/accounts/domain/use_cases/accounts_usecases.dart';
import 'package:unified_dream247/features/fantasy/landing/data/singleton/app_singleton.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/players_model.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/user_teams_model.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/upcoming_match_datsource.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/domain/use_cases/upcoming_match_usecase.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/widgets/contest_head.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/widgets/join_contest_bottomsheet.dart';

class CaptainViceCaptain extends StatefulWidget {
  final bool? hasChanges;
  final Function(bool)? updateHasChanges;
  final int teamNumber;
  final String challengeId;
  final int isGuru;
  final String guruTeamId;
  final int? discount;
  final bool? isContestDetail;
  final List<CreateTeamPlayersData>? list;
  final String teamType;
  const CaptainViceCaptain({
    super.key,
    required this.hasChanges,
    required this.updateHasChanges,
    required this.teamNumber,
    this.discount,
    required this.isGuru,
    required this.guruTeamId,
    required this.challengeId,
    this.isContestDetail,
    this.list,
    required this.teamType,
  });

  @override
  State<CaptainViceCaptain> createState() => _CaptainViceCaptain();
}

class _CaptainViceCaptain extends State<CaptainViceCaptain> {
  // Column widths (keep SAME for header & rows)
  static const double avatarWidth = 56;
  static const double selByWidth = 70;
  static const double pointsWidth = 70;
  static const double creditsWidth = 60;
  static const double captainWidth = 44;
  static const double viceCaptainWidth = 44;

  String captainName = '', viceCaptainName = '';
  String captainImage = '', viceCaptainImage = '';
  final int pointsThreshold = 50;
  bool isPointsEnable = false;
  bool isTypeEnable = false;
  bool isCaptainEnable = false;
  bool isViceCaptainEnable = false;
  String sortBy = '';
  final List<String> roles = ['keeper', 'batsman', 'all-rounder', 'bowler'];
  AccountsUsecases accountsUsecases = AccountsUsecases(
    AccountsDatasource(ApiImpl(), ApiImplWithAccessToken()),
  );
  UpcomingMatchUsecase upcomingMatchUsecase = UpcomingMatchUsecase(
    UpcomingMatchDatsource(ApiImpl(), ApiImplWithAccessToken()),
  );

  @override
  void initState() {
    super.initState();
    setState(() {
      captainImage = '';
      captainName = '';
      viceCaptainImage = '';
      viceCaptainName = '';

      for (var zz in widget.list ?? []) {
        if (zz.captainSelected == 1) {
          captainName = zz.name ?? '';
          captainImage = zz.image ?? '';
        } else if (zz.vicecaptainSelected == 1) {
          viceCaptainName = zz.name ?? '';
          viceCaptainImage = zz.image ?? '';
        }
      }
      widget.list
          ?.sort((a, b) => b.totalpoints?.compareTo(a.totalpoints ?? '0') ?? 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sortedPlayersList = widget.list
      ?..sort((a, b) => a.role?.compareTo(b.role ?? '') ?? 0);
    if (sortBy == 'points') {
      widget.list?.sort(
        (a, b) => isPointsEnable
            ? a.totalpoints?.compareTo(b.totalpoints ?? '0') ?? 0
            : b.totalpoints?.compareTo(a.totalpoints ?? '0') ?? 0,
      );
    } else if (sortBy == 'type') {
      widget.list?.sort(
        (a, b) => isTypeEnable
            ? a.role?.compareTo(b.role ?? '') ?? 0
            : b.role?.compareTo(a.role ?? '') ?? 0,
      );
    } else if (sortBy == '%c') {
      widget.list?.sort(
        (a, b) => isCaptainEnable
            ? a.captainSelectionPercentage?.compareTo(
                  b.captainSelectionPercentage ?? 0,
                ) ??
                0
            : b.captainSelectionPercentage?.compareTo(
                  a.captainSelectionPercentage ?? 0,
                ) ??
                0,
      );
    } else if (sortBy == '%vc') {
      widget.list?.sort(
        (a, b) => isViceCaptainEnable
            ? a.viceCaptainSelectionPercentage?.compareTo(
                  b.viceCaptainSelectionPercentage ?? 0,
                ) ??
                0
            : b.viceCaptainSelectionPercentage
                    ?.compareTo(a.viceCaptainSelectionPercentage ?? 0) ??
                0,
      );
    }

    final Map<String, List<CreateTeamPlayersData>> playersByRole = {
      for (var role in roles) role: [],
    };

    for (var player in sortedPlayersList ?? []) {
      if (playersByRole.containsKey(player.role)) {
        playersByRole[player.role]?.add(player);
      }
    }

    return ContestHead(
      safeAreaColor: AppColors.white,
      showAppBar: true,
      isLiveContest: false,
      showWalletIcon: true,
      addPadding: false,
      updateIndex: (p0) => 0,
      child: Column(
        children: [
          // Premium Gradient Header
          Container(
            padding: const EdgeInsets.fromLTRB(15, 5, 15, 10),
            decoration: BoxDecoration(
              gradient: AppColors.mainGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.25),
                  offset: const Offset(0, 2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Choose your Captain & Vice Captain',
                  style: GoogleFonts.poppins(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15.sp,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Captain card
                    _buildCaptainCard(
                      'Captain gets',
                      captainName,
                      captainImage,
                      '2x (double) Points',
                    ),
                    // const Icon(
                    //   Icons.compare_arrows,
                    //   color: AppColors.lightGrey,
                    //   size: 40,
                    // ),
                    _buildCaptainCard(
                      'Vice Captain gets',
                      viceCaptainName,
                      viceCaptainImage,
                      '1.5x Points',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Sort Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                const SizedBox(width: avatarWidth),
                // Expanded(
                //   child: Text(
                //     "Player",
                //     style: GoogleFonts.poppins(
                //       fontSize: 12,
                //       color: AppColors.greyColor,
                //       fontWeight: FontWeight.w500,
                //     ),
                //   ),
                // ),
                SizedBox(
                  width: selByWidth,
                  child: _buildSortButton('Sel by', '%c', isCaptainEnable),
                ),
                SizedBox(
                  width: pointsWidth,
                  child: _buildSortButton('Points', 'points', isPointsEnable),
                ),
                SizedBox(
                  width: creditsWidth,
                  child:
                      _buildSortButton('Credits', '%vc', isViceCaptainEnable),
                ),
                const SizedBox(width: captainWidth),
                const SizedBox(width: viceCaptainWidth),
              ],
            ),
          ),

          // Players List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 50),
              itemCount: sortedPlayersList?.length,
              itemBuilder: (context, index) {
                final currentPlayer = sortedPlayersList?[index];
                final previousRole =
                    index == 0 ? null : sortedPlayersList?[index - 1].role;
                final showRoleHeader = currentPlayer?.role != previousRole;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showRoleHeader)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Text(
                          currentPlayer?.role?.toUpperCase() ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    _buildPlayerCard(
                      currentPlayer ??
                          CreateTeamPlayersData(
                              isSelectedPlayer:
                                  currentPlayer?.isSelectedPlayer ?? false),
                      index,
                      sortedPlayersList?.length ?? 0,
                    ),
                  ],
                );
              },
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
                          for (var zz in widget.list ?? []) {
                            if (zz.isSelectedPlayer) {
                              finalPlayers.add(
                                UserTeamsModel(
                                  playerid: zz.playerid,
                                  playerimg: zz.image,
                                  image: zz.image,
                                  team: zz.team,
                                  name: zz.name,
                                  role: zz.role,
                                  credit: zz.credit,
                                  playingstatus: zz.playingstatus,
                                  captain: zz.captainSelected,
                                  vicecaptain: zz.vicecaptainSelected,
                                ),
                              );
                            }
                          }
                          await AppNavigation.gotoPreviewScreen(
                            context,
                            '',
                            false,
                            finalPlayers,
                            'Team Preview',
                            'Upcoming',
                            0,
                            false,
                            '',
                          );
                        },
                        filled: false,
                      ),
                      _glassButton(
                        label: 'NEXT',
                        onTap: () async {
                          String captainID = '',
                              viceCaptainID = '',
                              allPlayers = '';
                          for (var zz in widget.list ?? []) {
                            if (zz.captainSelected == 1) {
                              captainID = zz.playerid!;
                            }
                            if (zz.vicecaptainSelected == 1) {
                              viceCaptainID = zz.playerid!;
                            }
                            allPlayers += ',${zz.playerid!}';
                          }

                          if (captainID.isEmpty || viceCaptainID.isEmpty) {
                            appToast(
                              'Please select Captain & Vice Captain First',
                              context,
                            );
                            return;
                          }

                          if (allPlayers.isEmpty || allPlayers.length <= 1) {
                            appToast(
                              'Please select at least one player',
                              context,
                            );
                            return;
                          }

                          _createTeam(
                            context,
                            allPlayers.substring(1),
                            captainID,
                            viceCaptainID,
                          );
                        },
                        filled:
                            captainName.isNotEmpty && viceCaptainName.isNotEmpty
                                ? true
                                : false,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Helper UI Widgets ----------

  Widget _buildCaptainCard(
    String title,
    String name,
    String image,
    String points,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 26.r,
          backgroundColor: Colors.white24,
          backgroundImage: (image.isEmpty)
              ? const AssetImage(Images.imageDefalutPlayer) as ImageProvider
              : NetworkImage(image),
        ),
        const SizedBox(width: 6),
        Column(children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          // Text(
          //   name.isEmpty ? '------' : name,
          //   style: GoogleFonts.exo2(
          //     color: AppColors.white,
          //     fontWeight: FontWeight.w600,
          //     fontSize: 13,
          //   ),
          //   overflow: TextOverflow.ellipsis,
          // ),
          Text(
            points,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ])
      ],
    );
  }

  Widget _buildSortButton(String label, String key, bool isAsc) {
    return InkWell(
      onTap: () {
        setState(() {
          sortBy = key;
          if (key == 'points') isPointsEnable = !isPointsEnable;
          if (key == 'type') isTypeEnable = !isTypeEnable;
          if (key == '%c') isCaptainEnable = !isCaptainEnable;
          if (key == '%vc') isViceCaptainEnable = !isViceCaptainEnable;
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: AppColors.greyColor,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          AnimatedRotation(
            turns: sortBy == key ? (isAsc ? 0 : 0.5) : 0,
            duration: const Duration(milliseconds: 250),
            child: Icon(
              Icons.arrow_upward_rounded,
              size: 14,
              color: sortBy == key ? AppColors.mainColor : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(CreateTeamPlayersData data, int index, int length) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          // Avatar
          SizedBox(
            width: avatarWidth,
            child: InkWell(
              onTap: () => AppNavigation.gotoPlayerDetails(context, data),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: (data.image?.isEmpty ?? true)
                        ? Image.asset(
                            Images.imageDefalutPlayer,
                            width: 48,
                            height: 48,
                          )
                        : Image.network(
                            data.image ?? '',
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset(
                              Images.imageDefalutPlayer,
                              width: 48,
                              height: 48,
                            ),
                          ),
                  ),

                  // ✅ TEAM NAME BADGE (DERIVED FROM data.team)
                  Positioned(
                    bottom: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: data.team == 'team1'
                            ? AppColors.green
                            : AppColors.green,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppColors.lightGrey,
                          width: 0.6,
                        ),
                      ),
                      child: Text(
                        data.team == 'team1'
                            ? (AppSingleton.singleton.matchData.team1Name ??
                                AppSingleton.singleton.matchData.team1Name ??
                                '')
                            : (AppSingleton.singleton.matchData.team2Name ??
                                AppSingleton.singleton.matchData.team2Name ??
                                ''),
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: data.team == 'team1'
                              ? AppColors.white
                              : AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Name + % Sel By
          SizedBox(
            width: selByWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.name ?? '',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: AppColors.letterColor,
                  ),
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Text(
                  '${data.playerSelectionPercentage}%',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.greyColor,
                  ),
                ),
              ],
            ),
          ),

          // Sel By
          // SizedBox(
          //   width: selByWidth,
          //   child: Text(
          //     "${data.playerSelectionPercentage}%",
          //     textAlign: TextAlign.center,
          //     style: GoogleFonts.poppins(
          //       fontSize: 12,
          //       color: AppColors.black,
          //       fontWeight: FontWeight.w500,
          //     ),
          //   ),
          // ),

          // Points
          SizedBox(
            width: pointsWidth,
            child: Text(
              '${data.totalpoints}',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ),

          // Credits
          SizedBox(
            width: creditsWidth,
            child: Text(
              '${data.credit}',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ),
          Spacer(),

          // Captain
          SizedBox(
            width: captainWidth,
            child: _buildRoleButton(
              data,
              'C',
              data.captainSelected == 1,
              () {
                setState(() {
                  for (var p in widget.list ?? []) {
                    p.captainSelected = 0;
                  }
                  data.captainSelected = 1;
                  data.vicecaptainSelected = 0;
                  _updateSelectedCaptains();
                });
              },
            ),
          ),

          // Vice Captain
          SizedBox(
            width: viceCaptainWidth,
            child: _buildRoleButton(
              data,
              'VC',
              data.vicecaptainSelected == 1,
              () {
                setState(() {
                  for (var p in widget.list ?? []) {
                    p.vicecaptainSelected = 0;
                  }
                  data.vicecaptainSelected = 1;
                  data.captainSelected = 0;
                  _updateSelectedCaptains();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildPlayerCard(CreateTeamPlayersData data, int index, int length) {
  //   return Padding(
  //     padding: const EdgeInsets.all(8),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         InkWell(
  //           onTap: () => AppNavigation.gotoPlayerDetails(context, data),
  //           child: ClipRRect(
  //             borderRadius: BorderRadius.circular(30),
  //             child: Image.network(
  //               data.image ?? '',
  //               width: 50,
  //               height: 50,
  //               fit: BoxFit.cover,
  //               errorBuilder: (_, __, ___) => Image.asset(
  //                 Images.imageDefalutPlayer,
  //                 width: 50,
  //                 height: 50,
  //               ),
  //             ),
  //           ),
  //         ),
  //         Expanded(
  //           child: Padding(
  //             padding: const EdgeInsets.symmetric(horizontal: 2.0),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   data.name ?? "",
  //                   style: GoogleFonts.poppins(
  //                     fontWeight: FontWeight.w600,
  //                     fontSize: 14,
  //                     color: AppColors.letterColor,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 2),
  //                 Row(
  //                   children: [
  //                     // Text(
  //                     //   AppUtils.changeRole(data.role),
  //                     //   style: GoogleFonts.poppins(
  //                     //     fontSize: 12,
  //                     //     color: AppColors.black,
  //                     //     fontWeight: FontWeight.w500,
  //                     //   ),
  //                     // ),
  //                     // const SizedBox(width: 6),
  //                     // Container(
  //                     //   height: 4,
  //                     //   width: 4,
  //                     //   decoration: const BoxDecoration(
  //                     //     color: AppColors.greyColor,
  //                     //     shape: BoxShape.circle,
  //                     //   ),
  //                     // ),
  //                     // const SizedBox(width: 6),
  //                     Text(
  //                       "${data.playerSelectionPercentage}%",
  //                       // data.team == "team1"
  //                       //     ? AppSingleton.singleton.matchData.team1Name ?? ""
  //                       //     : AppSingleton.singleton.matchData.team2Name ?? "",
  //                       style: GoogleFonts.poppins(
  //                         fontSize: 12,
  //                         color: AppColors.greyColor,
  //                       ),
  //                     ),
  //                     // Text(
  //                     //   data.team == "team1"
  //                     //       ? AppSingleton.singleton.matchData.team1Name ?? ""
  //                     //       : AppSingleton.singleton.matchData.team2Name ?? "",
  //                     //   style: GoogleFonts.poppins(
  //                     //     fontSize: 12,
  //                     //     color: AppColors.greyColor,
  //                     //   ),
  //                     // ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //         Text(
  //           "${data.totalpoints} pts",
  //           style: GoogleFonts.poppins(
  //             fontSize: 13,
  //             fontWeight: FontWeight.w600,
  //             color: AppColors.black,
  //           ),
  //         ),
  //         30.horizontalSpace,
  //         Text(
  //           "${data.credit}",
  //           style: GoogleFonts.poppins(
  //             fontSize: 13,
  //             fontWeight: FontWeight.w600,
  //             color: AppColors.black,
  //           ),
  //         ),
  //         const SizedBox(width: 40),
  //         _buildRoleButton(data, "C", data.captainSelected == 1, () {
  //           setState(() {
  //             for (var p in widget.list ?? []) {
  //               p.captainSelected = 0;
  //             }
  //             data.captainSelected = 1;
  //             data.vicecaptainSelected = 0;
  //             _updateSelectedCaptains();
  //           });
  //         }),
  //         const SizedBox(width: 20),
  //         _buildRoleButton(data, "VC", data.vicecaptainSelected == 1, () {
  //           setState(() {
  //             for (var p in widget.list ?? []) {
  //               p.vicecaptainSelected = 0;
  //             }
  //             data.vicecaptainSelected = 1;
  //             data.captainSelected = 0;
  //             _updateSelectedCaptains();
  //           });
  //         }),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildRoleButton(
    CreateTeamPlayersData data,
    String text,
    bool isActive,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: 36,
        width: 36,
        decoration: BoxDecoration(
          gradient: isActive
              ? AppColors.appBarGradient
              : AppColors.progressGradeint.withOpacity(0.0),
          border: Border.all(
            color: isActive ? AppColors.mainColor : AppColors.lightGrey,
            width: 1.2,
          ),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: isActive ? AppColors.white : AppColors.greyColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
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

  void _updateSelectedCaptains() {
    captainImage = '';
    captainName = '';
    viceCaptainImage = '';
    viceCaptainName = '';

    for (var zz in widget.list ?? []) {
      if (zz.captainSelected == 1) {
        captainName = zz.name!;
        captainImage = zz.image!;
      } else if (zz.vicecaptainSelected == 1) {
        viceCaptainName = zz.name!;
        viceCaptainImage = zz.image!;
      }
    }
  }

  void _createTeam(
    BuildContext context,
    String allPlayers,
    String captainID,
    String viceCaptainID,
  ) {
    upcomingMatchUsecase
        .createTeam(
      context,
      allPlayers,
      captainID,
      viceCaptainID,
      widget.isGuru,
      widget.guruTeamId,
      widget.teamNumber,
      widget.teamType,
    )
        .then((value) {
      if (value != null) {
        setState(() {
          widget.updateHasChanges!.call(widget.hasChanges ?? true);
        });
        if (widget.challengeId.isNotEmpty) {
          Navigator.of(context).pop();
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(10.0),
              ),
            ),
            builder: (BuildContext context) {
              return JoinContestBottomsheet(
                fantasyType: 'Cricket',
                isClosedContestNew: false,
                previousJoined: false,
                challengeId: widget.challengeId,
                selectedTeam: value,
                discount: widget.discount ?? 0,
                newTeam: true,
                isContestDetail: widget.isContestDetail,
                removePage: () {
                  Navigator.pop(context, true);
                },
              );
            },
          );
        } else {
          Navigator.of(context).pop(true);
          Navigator.of(context).pop(true);
        }
      } else {
        Navigator.of(context).pop(false);
        Navigator.of(context).pop(false);
      }
    });
  }
}
