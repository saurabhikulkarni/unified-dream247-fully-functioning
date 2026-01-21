// ignore_for_file: must_be_immutable

import 'dart:math';

import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/cached_images.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/sub_container.dart';
import 'package:unified_dream247/features/fantasy/my_matches/data/models/team_compare_model.dart';
import 'package:unified_dream247/features/fantasy/my_matches/data/my_matches_datasource.dart';
import 'package:unified_dream247/features/fantasy/my_matches/domain/use_cases/my_matches_usecases.dart';
import 'package:unified_dream247/features/fantasy/my_matches/presentation/widgets/team_compare_shimmer.dart';

class TeamCompare extends StatefulWidget {
  final String team1Id;
  final String team2Id;
  final String userId;
  final String challengeId;
  final String l1;
  final String l2;
  const TeamCompare({
    super.key,
    required this.team1Id,
    required this.team2Id,
    required this.userId,
    required this.challengeId,
    required this.l1,
    required this.l2,
  });

  @override
  State<TeamCompare> createState() => _TeamCompareState();
}

class _TeamCompareState extends State<TeamCompare> {
  Future<TeamCompareModel?>? teamCompareModel;
  List<UserTeamData> team1Data = [];
  List<UserTeamData> team2Data = [];
  List<Common> unmatchedTeam1 = [];
  List<Common> unmatchedTeam2 = [];
  List<Common> commonTeam1 = [];
  List<Common> captainTeam1 = [];
  List<Common> captainTeam2 = [];
  List<Common> viceCaptainTeam1 = [];
  List<Common> viceCaptainTeam2 = [];
  num totalPointsDiff = 0, captainPointsDiff = 0, differentPlayerPointsDiff = 0;
  MyMatchesUsecases myMatchesUsecases = MyMatchesUsecases(
    MyMatchesDatasource(ApiImplWithAccessToken()),
  );

  @override
  void initState() {
    super.initState();
    compareTeams();
  }

  Future<void> compareTeams() async {
    teamCompareModel = myMatchesUsecases.teamCompare(
      context,
      widget.team1Id,
      widget.team2Id,
      widget.userId,
      widget.challengeId,
      widget.l1,
      widget.l2,
    );

    teamCompareModel?.then((value) {
      if (value != null) {
        setState(() {
          team1Data =
              value.userTeamData?.where((data) => data.teams == 1).toList() ??
                  [];
          team2Data =
              value.userTeamData?.where((data) => data.teams == 2).toList() ??
                  [];
          unmatchedTeam1 =
              value.unmatched?.where((data) => data.teams == 1).toList() ?? [];
          unmatchedTeam2 =
              value.unmatched?.where((data) => data.teams == 2).toList() ?? [];
          commonTeam1 = value.common
                  ?.where((data) => (data.teams == 1 || data.teams == 2))
                  .toList() ??
              [];
          captainTeam1 =
              value.captain?.where((data) => data.teams == 1).toList() ?? [];
          captainTeam2 =
              value.captain?.where((data) => data.teams == 2).toList() ?? [];
          viceCaptainTeam1 =
              value.vicecaptain?.where((data) => data.teams == 1).toList() ??
                  [];
          viceCaptainTeam2 =
              value.vicecaptain?.where((data) => data.teams == 2).toList() ??
                  [];
        });
      }
    }).catchError((error) {
      debugPrint('Error fetching team comparison: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return SubContainer(
      headerText: Strings.teamCompare,
      showAppBar: true,
      addPadding: true,
      showWalletIcon: true,
      child: FutureBuilder(
        future: teamCompareModel,
        builder: (
          BuildContext context,
          AsyncSnapshot<TeamCompareModel?> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const TeamCompareShimmer();
          } else if (snapshot.hasError) {
            return const TeamCompareShimmer();
          } else {
            final teamCompareModel = snapshot.data;
            if (teamCompareModel?.userTeamData?.isNotEmpty ?? false) {
              if ((teamCompareModel?.userTeamData?.length ?? 0) >= 2) {
                totalPointsDiff =
                    (teamCompareModel?.userTeamData?[0].points ?? 0) -
                        (teamCompareModel?.userTeamData?[1].points ?? 0);
              } else {
                totalPointsDiff = 0;
              }

              if ((teamCompareModel?.vicecaptain?.length ?? 0) >= 2) {
                captainPointsDiff =
                    (teamCompareModel?.vicecaptain?[1].points ?? 0) -
                        (teamCompareModel?.vicecaptain?[0].points ?? 0);
              } else {
                captainPointsDiff = 0;
              }

              if ((teamCompareModel?.unmatched?.length ?? 0) >= 2) {
                differentPlayerPointsDiff =
                    (teamCompareModel?.unmatched?[1].points ?? 0) -
                        (teamCompareModel?.unmatched?[0].points ?? 0);
              } else {
                differentPlayerPointsDiff = 0;
              }
            }
            return (snapshot.data != null)
                ? SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        teamNames(team1Data, team2Data),
                        const SizedBox(height: 10),
                        teamPoints(
                          teamCompareModel?.userTeamData,
                          totalPointsDiff.toInt(),
                        ),
                        const SizedBox(height: 15),
                        if (unmatchedTeam1.isNotEmpty &&
                            unmatchedTeam2.isNotEmpty)
                          const Center(
                            child: Text(
                              'Different Players',
                              style: TextStyle(
                                color: AppColors.letterColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (unmatchedTeam1.isNotEmpty &&
                            unmatchedTeam2.isNotEmpty)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                (differentPlayerPointsDiff >= 0)
                                    ? 'Your players scored '
                                    : 'Your opponent players socred ',
                                style: const TextStyle(
                                  color: AppColors.letterColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              Text(
                                '${positiveNumber(differentPlayerPointsDiff)} Pts.',
                                style: const TextStyle(
                                  color: AppColors.mainLightColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Text(
                                ' more',
                                style: TextStyle(
                                  color: AppColors.letterColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        Column(
                          children: List.generate(
                            unmatchedTeam1.length > unmatchedTeam2.length
                                ? unmatchedTeam2.length
                                : unmatchedTeam1.length,
                            (index) {
                              return differentPlayers(
                                unmatchedTeam1[index],
                                unmatchedTeam2[index],
                              );
                            },
                          ),
                        ),
                        if (unmatchedTeam1.isNotEmpty &&
                            unmatchedTeam2.isNotEmpty)
                          const SizedBox(height: 15),
                        captainViceCap(
                          captainTeam1,
                          captainTeam2,
                          viceCaptainTeam1,
                          viceCaptainTeam2,
                          captainPointsDiff.toInt(),
                        ),
                        const SizedBox(height: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(
                              child: Text(
                                'Common Players',
                                style: TextStyle(
                                  color: AppColors.letterColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Column(
                              children: List.generate(commonTeam1.length, (
                                index,
                              ) {
                                return commonPlayer(commonTeam1[index]);
                              }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const Center(
                    child: Text(
                      Strings.noTeamsFound,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.letterColor,
                      ),
                    ),
                  );
          }
        },
      ),
    );
  }

  Widget teamNames(
    List<UserTeamData>? userTeam1,
    List<UserTeamData>? userTeam2,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              child: ClipOval(
                child: CachedImage(imageUrl: userTeam1?[0].image ?? ''),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              userTeam1?[0].teamName ?? '',
              style: const TextStyle(
                color: AppColors.letterColor,
                fontWeight: FontWeight.w400,
                fontSize: 13,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              userTeam2?[0].teamName ?? '',
              style: const TextStyle(
                color: AppColors.letterColor,
                fontWeight: FontWeight.w400,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 5),
            CircleAvatar(
              radius: 20,
              child: ClipOval(
                child: CachedImage(imageUrl: userTeam2?[0].image ?? ''),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget teamPoints(List<UserTeamData>? userTeam, int totalPointsDiff) {
    return Column(
      children: [
        const Center(
          child: Text(
            'Total Points',
            style: TextStyle(
              color: AppColors.letterColor,
              fontWeight: FontWeight.w400,
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${userTeam?[0].points ?? ""}",
                style: const TextStyle(
                  color: AppColors.letterColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Transform.rotate(
                angle: 30 * (pi / 180),
                child: Container(
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  width: 1,
                  height: 20,
                  color: AppColors.greyColor,
                ),
              ),
              Text(
                "${userTeam?[1].points ?? ""}",
                style: const TextStyle(
                  color: AppColors.letterColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              (totalPointsDiff >= 0) ? 'You won by ' : 'Your opponent won by ',
              style: const TextStyle(
                color: AppColors.letterColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${positiveNumber(totalPointsDiff)} Pts.',
              style: const TextStyle(
                color: AppColors.mainLightColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget commonPlayer(Common? commonTeam1) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            flex: 1,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  child: ClipOval(
                    child: CachedImage(imageUrl: commonTeam1?.image ?? ''),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${commonTeam1?.playerName}',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.exo2(
                          color: AppColors.letterColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${commonTeam1?.team} - ${commonTeam1?.role}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.letterColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: SizedBox(
                    height: 24,
                    child: Image.asset(Images.imageTeamCompareBg),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${commonTeam1?.points}',
                      style: GoogleFonts.tomorrow(
                        color: AppColors.letterColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Flexible(
            flex: 1,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${commonTeam1?.playerName}',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.exo2(
                          color: AppColors.letterColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${commonTeam1?.team} - ${commonTeam1?.role}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.letterColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                CircleAvatar(
                  radius: 20,
                  child: ClipOval(
                    child: CachedImage(imageUrl: commonTeam1?.image ?? ''),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget differentPlayers(Common unmatched1, Common unmatched2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            flex: 1,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  child: ClipOval(
                    child: CachedImage(imageUrl: unmatched1.image ?? ''),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${unmatched1.playerName}',
                        style: GoogleFonts.exo2(
                          color: AppColors.letterColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${unmatched1.team} - ${unmatched1.role}',
                        style: const TextStyle(
                          color: AppColors.letterColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w300,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: SizedBox(
                    height: 24,
                    child: Image.asset(Images.imageTeamCompareBg),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${unmatched1.points}',
                      style: GoogleFonts.tomorrow(
                        color: AppColors.letterColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      '${unmatched2.points}',
                      style: GoogleFonts.tomorrow(
                        color: AppColors.letterColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Flexible(
            flex: 1,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${unmatched2.playerName}',
                        style: GoogleFonts.exo2(
                          color: AppColors.letterColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${unmatched2.team} - ${unmatched2.role}',
                        style: const TextStyle(
                          color: AppColors.letterColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w300,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                CircleAvatar(
                  radius: 20,
                  child: ClipOval(
                    child: CachedImage(imageUrl: unmatched2.image ?? ''),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget captainViceCap(
    List<Common>? captainTeam1,
    List<Common>? captainTeam2,
    List<Common>? viceCaptainTeam1,
    List<Common>? viceCaptainTeam2,
    int captainPointsDiff,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Players with different caps',
              style: TextStyle(
                color: AppColors.letterColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                (captainPointsDiff >= 0)
                    ? 'Your players scored '
                    : 'Your opponent players socred ',
                style: const TextStyle(
                  color: AppColors.letterColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Text(
                '${positiveNumber(captainPointsDiff)} Pts',
                style: const TextStyle(
                  color: AppColors.mainLightColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Text(
                ' more',
                style: TextStyle(
                  color: AppColors.letterColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Stack(
                        alignment: Alignment.topLeft,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            child: ClipOval(
                              child: CachedImage(
                                imageUrl: captainTeam1?[0].image ?? '',
                              ),
                            ),
                          ),
                          Container(
                            width: 16,
                            height: 16,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.blackColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'C',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${captainTeam1?[0].playerName}',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.exo2(
                                color: AppColors.letterColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${captainTeam1?[0].team} - ${captainTeam1?[0].role}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.letterColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: SizedBox(
                          height: 24,
                          child: Image.asset(Images.imageTeamCompareBg),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${captainTeam1?[0].points}',
                            style: GoogleFonts.tomorrow(
                              color: AppColors.letterColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Text(
                            '${captainTeam2?[0].points}',
                            style: GoogleFonts.tomorrow(
                              color: AppColors.letterColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${captainTeam2?[0].playerName}',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.exo2(
                                color: AppColors.letterColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${captainTeam2?[0].team} - ${captainTeam2?[0].role}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.letterColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            child: ClipOval(
                              child: CachedImage(
                                imageUrl: captainTeam2?[0].image ?? '',
                              ),
                            ),
                          ),
                          Container(
                            width: 16,
                            height: 16,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.blackColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'C',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Stack(
                        alignment: Alignment.topLeft,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            child: ClipOval(
                              child: CachedImage(
                                imageUrl: viceCaptainTeam1?[0].image ?? '',
                              ),
                            ),
                          ),
                          Container(
                            width: 16,
                            height: 16,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.blackColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'VC',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${viceCaptainTeam1?[0].playerName}',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.exo2(
                                color: AppColors.letterColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${viceCaptainTeam1?[0].team} - ${viceCaptainTeam1?[0].role}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.letterColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: SizedBox(
                          height: 24,
                          child: Image.asset(Images.imageTeamCompareBg),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${viceCaptainTeam1?[0].points}',
                            style: GoogleFonts.tomorrow(
                              color: AppColors.letterColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Text(
                            '${viceCaptainTeam2?[0].points}',
                            style: GoogleFonts.tomorrow(
                              color: AppColors.letterColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${viceCaptainTeam2?[0].playerName}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.letterColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${viceCaptainTeam2?[0].team} - ${viceCaptainTeam2?[0].role}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.letterColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            child: ClipOval(
                              child: CachedImage(
                                imageUrl: viceCaptainTeam2?[0].image ?? '',
                              ),
                            ),
                          ),
                          Container(
                            width: 16,
                            height: 16,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.blackColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'VC',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
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

  num positiveNumber(num number) {
    if (number >= 0) {
      return number;
    } else {
      return -1 * number;
    }
  }
}
