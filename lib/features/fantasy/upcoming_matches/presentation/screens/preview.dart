// ignore_for_file: must_be_immutable

import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_urls.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/cached_images.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/sub_container.dart';
import 'package:unified_dream247/features/fantasy/features/landing/data/models/games_get_set.dart';
import 'package:unified_dream247/features/fantasy/features/landing/data/singleton/app_singleton.dart';
import 'package:unified_dream247/features/fantasy/features/my_matches/data/my_matches_datasource.dart';
import 'package:unified_dream247/features/fantasy/features/my_matches/domain/use_cases/my_matches_usecases.dart';
import 'package:unified_dream247/features/fantasy/features/upcoming_matches/data/upcoming_match_datsource.dart';
import 'package:unified_dream247/features/fantasy/features/upcoming_matches/domain/use_cases/upcoming_match_usecase.dart';
import 'package:unified_dream247/features/fantasy/features/upcoming_matches/presentation/providers/team_preview_provider.dart';
import 'package:unified_dream247/features/fantasy/features/upcoming_matches/data/models/user_teams_model.dart';
import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/features/upcoming_matches/presentation/screens/preview_player_info_screen.dart';

class Preview extends StatefulWidget {
  final List<UserTeamsModel>? data;
  final String mode;
  final String? title;
  final bool? multiplyPoints;
  final String? joinTeamId;
  final bool? hasEdited;
  final int? teamnumber;
  final String? userId;
  const Preview({
    super.key,
    this.data,
    this.title,
    required this.mode,
    this.multiplyPoints,
    this.joinTeamId,
    this.hasEdited,
    this.teamnumber,
    this.userId,
  });

  @override
  State<Preview> createState() => _PreviewState();
}

class _PreviewState extends State<Preview> {
  double totalCredits = 0, totalPoints = 0;
  int team1Count = 0, team2Count = 0;
  List<UserTeamsModel>? userTeamsModel;
  UpcomingMatchUsecase upcomingMatchUsecase = UpcomingMatchUsecase(
    UpcomingMatchDatsource(ApiImpl(), ApiImplWithAccessToken()),
  );
  MyMatchesUsecases myMatchesUsecases = MyMatchesUsecases(
    MyMatchesDatasource(ApiImplWithAccessToken()),
  );

  @override
  void initState() {
    super.initState();
    getUserTeams();
  }

  getUserTeams() async {
    final provider = Provider.of<TeamPreviewProvider>(context, listen: false);

    if ((widget.joinTeamId ?? "").isNotEmpty && widget.mode == "Upcoming") {
      List<UserTeamsModel>? existingTeams = provider.getUserTeam(
        widget.joinTeamId!,
      );

      if (existingTeams == null ||
          existingTeams.isEmpty ||
          widget.hasEdited == false ||
          widget.hasEdited == null) {
        List<UserTeamsModel>? fetchedTeams =
            await upcomingMatchUsecase.getUserTeam(context, widget.joinTeamId!);

        if (fetchedTeams.isNotEmpty) {
          setState(() {
            userTeamsModel = fetchedTeams;
            provider.setUserTeam(widget.joinTeamId!, fetchedTeams);
          });
        } else {}
      } else {
        setState(() {
          userTeamsModel = existingTeams;
        });
      }
    } else if (widget.mode == "Live" &&
        widget.title != "${APIServerUrl.appName} Team") {
      var response = await myMatchesUsecases.liveViewTeam(
        context,
        widget.joinTeamId ?? "",
        widget.teamnumber ?? 0,
        widget.userId ?? "",
      );

      if (response != null) {
        List<UserTeamsModel> finalPlayers = response.map((zz) {
          return UserTeamsModel(
            playerid: zz.playerid,
            playerimg: zz.image,
            image: zz.image,
            team: zz.team,
            name: zz.name,
            role: zz.role,
            credit: zz.credit?.toDouble() ?? 0.0,
            points: zz.points ?? 0,
            playingstatus: zz.playingstatus,
            captain: zz.captain,
            vicecaptain: zz.vicecaptain,
          );
        }).toList();

        setState(() {
          userTeamsModel = finalPlayers;
        });
      } else {
        debugPrint("View team API returned no data.");
      }
    } else if (widget.mode == "Completed" &&
        widget.title != "${APIServerUrl.appName} Team") {
      var response = await myMatchesUsecases.liveViewTeam(
        context,
        widget.joinTeamId ?? "",
        widget.teamnumber ?? 0,
        widget.userId ?? "",
      );

      if (response != null) {
        List<UserTeamsModel> finalPlayers = response.map((zz) {
          return UserTeamsModel(
            playerid: zz.playerid,
            playerimg: zz.image,
            image: zz.image,
            team: zz.team,
            name: zz.name,
            role: zz.role,
            credit: zz.credit?.toDouble() ?? 0.0,
            points: zz.points ?? 0,
            playingstatus: zz.playingstatus,
            captain: zz.captain,
            vicecaptain: zz.vicecaptain,
          );
        }).toList();

        setState(() {
          userTeamsModel = finalPlayers;
        });
      } else {
        debugPrint("View team API returned no data.");
      }
    } else {
      userTeamsModel = widget.data;
    }
  }

  @override
  Widget build(BuildContext context) {
    totalPoints = 0;
    if ((userTeamsModel ?? []).isNotEmpty) {
      for (var dataModel in userTeamsModel ?? []) {
        totalCredits += dataModel.credit!.toDouble();
        if (dataModel.team == 'team1') {
          team1Count++;
        } else {
          team2Count++;
        }
        if (widget.mode != 'Upcoming') {
          if (widget.multiplyPoints ?? false) {
            if (dataModel.captain == 1) {
              totalPoints +=
                  (double.parse(dataModel.points!.toString()) * 2).toDouble();
            } else if (dataModel.vicecaptain == 1) {
              totalPoints +=
                  (double.parse(dataModel.points!.toString()) * 1.5).toDouble();
            } else {
              totalPoints +=
                  double.parse(dataModel.points!.toString()).toDouble();
            }
          } else {
            totalPoints +=
                double.parse(dataModel.points!.toString()).toDouble();
          }
        }
      }
    } else {
      for (var dataModel in widget.data ?? []) {
        totalCredits += dataModel.credit!.toDouble();
        if (dataModel.team == 'team1') {
          team1Count++;
        } else {
          team2Count++;
        }
        if (widget.mode != 'Upcoming') {
          if (widget.multiplyPoints ?? false) {
            if (dataModel.captain == 1) {
              totalPoints +=
                  (double.parse(dataModel.points!.toString()) * 2).toDouble();
            } else if (dataModel.vicecaptain == 1) {
              totalPoints +=
                  (double.parse(dataModel.points!.toString()) * 1.5).toDouble();
            } else {
              totalPoints +=
                  double.parse(dataModel.points!.toString()).toDouble();
            }
          } else {
            totalPoints +=
                double.parse(dataModel.points!.toString()).toDouble();
          }
        }
      }
    }

    return SubContainer(
      showAppBar: true,
      showWalletIcon: false,
      headerText: widget.title ?? '${APIServerUrl.appName} Games',
      addPadding: false,
      child: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Images.imageGroundFinal),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        bottom: 300,
                        left: 30,
                        right: 30,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              Images.nameLogo,
                              color: AppColors.lightCard,
                              width: 70,
                            ),
                            Image.asset(
                              Images.nameLogo,
                              color: AppColors.lightCard,
                              width: 70,
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            for (var i in AppSingleton
                                    .singleton
                                    .appData
                                    .games?[0]
                                    .sportCategory
                                    ?.teamType?[0]
                                    .playerPositions ??
                                [])
                              singlePlayerList(
                                context,
                                i,
                                userTeamsModel ?? widget.data ?? [],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(gradient: AppColors.appBarGradient),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Players',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                '${userTeamsModel?.length ?? widget.data?.length}',
                                style: GoogleFonts.tomorrow(
                                  color: AppColors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '/${AppSingleton.singleton.appData.games?[0].sportCategory?.maxPlayers}',
                                style: GoogleFonts.tomorrow(
                                  color: AppColors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: AppColors.white,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            child: Text(
                              AppSingleton.singleton.matchData.team1Name ?? "",
                              style: GoogleFonts.exo2(
                                color: AppColors.letterColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '$team1Count',
                            style: GoogleFonts.tomorrow(
                              color: AppColors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            ':',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '$team2Count',
                            style: GoogleFonts.tomorrow(
                              color: AppColors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: AppColors.letterColor,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            child: Text(
                              AppSingleton.singleton.matchData.team2Name ?? "",
                              style: GoogleFonts.exo2(
                                color: AppColors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      (widget.mode == 'Upcoming')
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Credits Left',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${(AppSingleton.singleton.appData.games?[0].sportCategory?.maxCredits ?? 0) - totalCredits}',
                                      style: GoogleFonts.tomorrow(
                                        color: AppColors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '/${AppSingleton.singleton.appData.games?[0].sportCategory?.maxCredits}',
                                      style: GoogleFonts.tomorrow(
                                        color: AppColors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Total Points',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  '$totalPoints',
                                  style: GoogleFonts.tomorrow(
                                    color: AppColors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
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
        ],
      ),
    );
  }

  Widget singlePlayerList(
    BuildContext context,
    PlayerPosition data,
    List<UserTeamsModel> allPlayers,
  ) {
    List<UserTeamsModel> myPlayers = [];
    List<UserTeamsModel> myPlayers1 = [];
    allPlayers.sort((a, b) => a.name!.compareTo(b.name!));

    for (var i in allPlayers) {
      if (i.role == data.code!) {
        if (myPlayers.length < 4) {
          myPlayers.add(i);
        } else {
          myPlayers1.add(i);
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20, top: 20),
            child: Text(
              data.fullName ?? "",
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var player in myPlayers)
                InkWell(
                  onTap: () {
                    if (widget.mode != 'Upcoming') {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          opaque: false,
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  PreviewPlayerinfoScreen(
                            joinTeamId: widget.joinTeamId ?? "",
                            playerId: player.playerid ?? "",
                          ),
                          transitionsBuilder: (
                            context,
                            animation,
                            secondaryAnimation,
                            child,
                          ) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                        ),
                      );
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 22.0,
                            child: ClipOval(
                              child: CachedImage(
                                imageUrl: player.playerimg ?? "",
                                errorWidget: Image.asset(
                                  Images.imageDefalutPlayer,
                                ),
                              ),
                            ),
                          ),
                          if (player.playingstatus == 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: AppColors.mainLightColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          Visibility(
                            visible: player.captain == 1,
                            child: Container(
                              width: 16,
                              height: 16,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: (player.team == "team1")
                                    ? AppColors.letterColor
                                    : AppColors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'C',
                                style: TextStyle(
                                  color: (player.team == "team1")
                                      ? AppColors.white
                                      : AppColors.letterColor,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Visibility(
                            visible: player.vicecaptain == 1,
                            child: Container(
                              width: 16,
                              height: 16,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: (player.team == "team1")
                                    ? AppColors.letterColor
                                    : AppColors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'VC',
                                style: TextStyle(
                                  color: (player.team! == "team1")
                                      ? AppColors.white
                                      : AppColors.letterColor,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 80,
                        margin: const EdgeInsets.all(5),
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          color: (player.team! == "team1")
                              ? AppColors.white
                              : AppColors.letterColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          player.name!,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.exo2(
                            fontWeight: FontWeight.w400,
                            fontSize: 10,
                            color: (player.team! == "team1")
                                ? AppColors.letterColor
                                : AppColors.white,
                          ),
                        ),
                      ),
                      Text(
                        (widget.mode == 'Upcoming')
                            ? '${player.credit} Cr'
                            : "${player.points} pts",
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.tomorrow(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (myPlayers1.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (var player in myPlayers1)
                    InkWell(
                      onTap: () {
                        if (widget.mode != 'Upcoming') {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              opaque: false,
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      PreviewPlayerinfoScreen(
                                joinTeamId: widget.joinTeamId ?? "",
                              ),
                              transitionsBuilder: (
                                context,
                                animation,
                                secondaryAnimation,
                                child,
                              ) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 22.0,
                                child: ClipOval(
                                  child: CachedImage(
                                    imageUrl: player.playerimg ??
                                        Images.imageDefalutPlayer,
                                    errorWidget: Image.asset(
                                      Images.imageDefalutPlayer,
                                    ),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: player.captain == 1,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: (player.team! == "team1")
                                        ? AppColors.letterColor
                                        : AppColors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'C',
                                    style: TextStyle(
                                      color: (player.team! == "team1")
                                          ? AppColors.white
                                          : AppColors.letterColor,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: player.vicecaptain == 1,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: (player.team! == "team1")
                                        ? AppColors.letterColor
                                        : AppColors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'VC',
                                    style: TextStyle(
                                      color: (player.team! == "team1")
                                          ? AppColors.white
                                          : AppColors.letterColor,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 80,
                            margin: const EdgeInsets.all(5),
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 10,
                            ),
                            decoration: BoxDecoration(
                              color: (player.team! == "team1")
                                  ? AppColors.white
                                  : AppColors.letterColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              player.name!,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.exo2(
                                fontWeight: FontWeight.w400,
                                fontSize: 10,
                                color: (player.team! == "team1")
                                    ? AppColors.letterColor
                                    : AppColors.white,
                              ),
                            ),
                          ),
                          Text(
                            (widget.mode == 'Upcoming')
                                ? '${player.credit} Cr'
                                : "${player.points} pts",
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.tomorrow(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: AppColors.white,
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
    );
  }
}
