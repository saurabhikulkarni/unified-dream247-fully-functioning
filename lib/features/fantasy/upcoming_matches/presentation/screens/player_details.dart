import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:Dream247/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';
import 'package:Dream247/core/app_constants/strings.dart';
import 'package:Dream247/core/global_widgets/main_container.dart';
import 'package:Dream247/core/global_widgets/sub_container.dart';
import 'package:Dream247/features/landing/data/singleton/app_singleton.dart';
import 'package:Dream247/features/my_matches/data/my_matches_datasource.dart';
import 'package:Dream247/features/my_matches/domain/use_cases/my_matches_usecases.dart';
import 'package:Dream247/features/upcoming_matches/data/models/player_details_model.dart';
import 'package:Dream247/features/upcoming_matches/data/models/players_model.dart';

class PlayerDetails extends StatefulWidget {
  final CreateTeamPlayersData data;
  const PlayerDetails({super.key, required this.data});

  @override
  State<PlayerDetails> createState() => _PlayerDetailsState();
}

class _PlayerDetailsState extends State<PlayerDetails> {
  Future<PlayerDetailsModel?>? playerData;
  num totalPoints = 0;
  MyMatchesUsecases myMatchesUsecases = MyMatchesUsecases(
    MyMatchesDatasource(ApiImplWithAccessToken()),
  );

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() {
    playerData = myMatchesUsecases.getPlayerDetails(
      context,
      widget.data.playerid ?? "",
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SubContainer(
      showAppBar: true,
      showWalletIcon: true,
      headerText: Strings.playerInfo,
      addPadding: false,
      child: FutureBuilder(
        future: playerData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SizedBox(
                height: 40,
                width: 40,
                // child: LoadingIndicator(
                //   strokeWidth: 1.0,
                //   indicatorType: Indicator.lineSpinFadeLoader,
                //   backgroundColor: AppColors.transparent,
                //   pathBackgroundColor: AppColors.transparent,
                //   colors: [AppColors.letterColor, AppColors.greyColor],
                // ),
              ),
            );
          } else if (!snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data?.data == null) {
            return const Center(
              child: Text(
                'Player Info Not Available',
                style: TextStyle(
                  color: AppColors.letterColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          } else {
            PlayerDetailsModelData data = snapshot.data!.data!;
            List<PlayerMatches> matches = snapshot.data!.matches!;

            for (var data in matches) {
              totalPoints += data.totalPoints!;
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.letterColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Stack(
                            children: [
                              Image.network(
                                '${data.image}',
                                width: 80,
                                height: 80,
                              ),
                              Positioned(
                                bottom: 0,
                                child: Container(
                                  margin: const EdgeInsets.only(left: 12),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: .5,
                                    horizontal: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (data.team! ==
                                            AppSingleton
                                                .singleton.matchData.team1Name!)
                                        ? AppColors.white
                                        : AppColors.letterColor,
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                  child: Text(
                                    data.team!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 9,
                                      color: (data.team! ==
                                              AppSingleton.singleton.matchData
                                                  .team1Name!)
                                          ? AppColors.letterColor
                                          : AppColors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${data.playerName}',
                                  style: GoogleFonts.exo2(
                                    color: AppColors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${widget.data.role?.toUpperCase()}',
                                        style: const TextStyle(
                                          color: AppColors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      (data.country != "")
                                          ? Text(
                                              '${data.country}',
                                              style: const TextStyle(
                                                color: AppColors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                      (data.battingstyle != "" &&
                                              data.bowlingstyle != "")
                                          ? Text(
                                              '${data.battingstyle} - ${data.bowlingstyle}',
                                              style: const TextStyle(
                                                color: AppColors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            )
                                          : (data.battingstyle != "")
                                              ? Text(
                                                  '${data.battingstyle}',
                                                  style: const TextStyle(
                                                    color: AppColors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                )
                                              : (data.bowlingstyle != "")
                                                  ? Text(
                                                      '${data.bowlingstyle}',
                                                      style: const TextStyle(
                                                        color: AppColors.white,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    )
                                                  : const SizedBox.shrink(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Total Points: ".toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                '$totalPoints',
                                style: GoogleFonts.tomorrow(
                                  color: AppColors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 1,
                            color: AppColors.white,
                            height: 20,
                          ),
                          Row(
                            children: [
                              Text(
                                "Credits: ".toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${data.credit}',
                                style: GoogleFonts.tomorrow(
                                  color: AppColors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: Text(
                              'Tour Fantasy Stats',
                              style: TextStyle(
                                color: AppColors.letterColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          MainContainer(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    const Text(
                                      'Matches',
                                      style: TextStyle(
                                        color: AppColors.greyColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Text(
                                      '${matches.length}',
                                      style: GoogleFonts.tomorrow(
                                        color: AppColors.greyColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 1,
                                  color: AppColors.lightGrey,
                                  height: 40,
                                ),
                                Column(
                                  children: [
                                    const Text(
                                      'Avg Points',
                                      style: TextStyle(
                                        color: AppColors.greyColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Text(
                                      (matches.isEmpty)
                                          ? '0'
                                          : '${(data.points ?? 0 / matches.length)}',
                                      style: GoogleFonts.tomorrow(
                                        color: AppColors.greyColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 1,
                                  color: AppColors.lightGrey,
                                  height: 40,
                                ),
                                Column(
                                  children: [
                                    const Text(
                                      'Dream Team',
                                      style: TextStyle(
                                        color: AppColors.greyColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Text(
                                      '0%',
                                      style: GoogleFonts.tomorrow(
                                        color: AppColors.greyColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: Text(
                              'Matchwise Fantasy Stats',
                              style: TextStyle(
                                color: AppColors.letterColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          ListView.builder(
                            itemCount: matches.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              PlayerMatches matchData = matches[index];
                              return singlePlayerStatMatch(matchData);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget singlePlayerStatMatch(PlayerMatches matchData) {
    return MainContainer(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '${matchData.shortName}',
                        style: GoogleFonts.exo2(
                          color: AppColors.letterColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '${matchData.startDate}',
                        style: const TextStyle(
                          color: AppColors.letterColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        color: AppColors.letterColor,
                        width: 0.25,
                        height: 10,
                      ),
                      const SizedBox(width: 5),
                      (matchData.tosswinnerTeam != null &&
                              matchData.tossDecision != null)
                          ? Text(
                              '${matchData.tosswinnerTeam} Won toss & selected ${matchData.tossDecision}',
                              style: const TextStyle(
                                color: AppColors.letterColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w300,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected By',
                      style: TextStyle(
                        color: AppColors.letterColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      '${matchData.selectper}%',
                      style: GoogleFonts.tomorrow(
                        color: AppColors.letterColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Points',
                      style: TextStyle(
                        color: AppColors.letterColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      '${matchData.totalPoints}',
                      style: GoogleFonts.tomorrow(
                        color: AppColors.letterColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Credits',
                      style: TextStyle(
                        color: AppColors.letterColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      '${matchData.credit}',
                      style: GoogleFonts.tomorrow(
                        color: AppColors.letterColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
