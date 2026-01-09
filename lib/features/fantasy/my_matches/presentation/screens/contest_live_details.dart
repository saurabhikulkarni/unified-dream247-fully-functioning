import 'dart:async';

import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:Dream247/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';
import 'package:Dream247/features/landing/data/singleton/app_singleton.dart';
import 'package:Dream247/features/my_matches/data/models/live_challenges_model.dart';
import 'package:Dream247/features/my_matches/data/models/match_livescore_model.dart';
import 'package:Dream247/features/my_matches/data/my_matches_datasource.dart';
import 'package:Dream247/features/my_matches/domain/use_cases/my_matches_usecases.dart';
import 'package:Dream247/features/my_matches/presentation/provider/live_score_provider.dart';
import 'package:Dream247/features/my_matches/presentation/screens/live_leaderboard.dart';
import 'package:Dream247/features/my_matches/presentation/screens/player_stats.dart';
import 'package:Dream247/features/my_matches/presentation/screens/scorecard.dart';
import 'package:Dream247/features/my_matches/presentation/widgets/scoreboard.dart';
import 'package:Dream247/features/upcoming_matches/presentation/widgets/contest_head.dart';
import 'package:Dream247/features/upcoming_matches/presentation/widgets/price_card.dart';

class ContestLiveDetails extends StatefulWidget {
  final String? mode;
  final LiveChallengesData data;
  const ContestLiveDetails({super.key, required this.data, this.mode});

  @override
  State<ContestLiveDetails> createState() => _ContestLiveDetails();
}

class _ContestLiveDetails extends State<ContestLiveDetails> {
  List<MatchLiveScoreModel>? list;
  Timer? timer;
  MyMatchesUsecases myMatchesUsecases = MyMatchesUsecases(
    MyMatchesDatasource(ApiImplWithAccessToken()),
  );

  @override
  void initState() {
    super.initState();
    getMatchLiveScore();
    startApiPolling();
  }

  // void getMatchLiveScore() async {
  //   list = (await HomeServices.getMatchLiveScore(context)) ?? [];
  //   setState(() {});
  // }

  void getMatchLiveScore() async {
    var provider = Provider.of<LiveScoreProvider>(context, listen: false);
    String matchKey = AppSingleton.singleton.matchData.id ?? "";

    if (widget.mode == "Completed" ||
        widget.mode == "Abandoned" ||
        widget.mode == "Cancelled") {
      if ((provider.liveScore[matchKey]?.isNotEmpty ?? false)) {
        setState(() {
          list = provider.liveScore[matchKey];
        });
        return;
      } else {
        final data = await myMatchesUsecases.getMatchLiveScore(context);
        setState(() {
          list = data;
        });
        return;
      }
    }

    if (widget.mode == "Live") {
      final data = await myMatchesUsecases.getMatchLiveScore(context);
      setState(() {
        list = data;
      });
      return;
    }
  }

  void startApiPolling() {
    if (widget.mode == "Live") {
      timer = Timer.periodic(const Duration(seconds: 60), (timer) {
        getMatchLiveScore();
      });
    } else {
      getMatchLiveScore();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ContestHead(
      safeAreaColor: AppColors.white,
      showAppBar: true,
      showWalletIcon: true,
      addPadding: false,
      isLiveContest: true,
      mode: widget.mode,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [
                  AppColors.mainColor,
                  AppColors.mainLightColor,
                  AppColors.blackColor
                ],
                    begin: AlignmentGeometry.topCenter,
                    end: AlignmentGeometry.bottomCenter)),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Scoreboard(list: list, mode: widget.mode),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: DefaultTabController(
              length: 4,
              child: Scaffold(
                backgroundColor: AppColors.white,
                appBar: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicator: BoxDecoration(
                    color: AppColors.mainColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.black, width: 0.5),
                  ),
                  indicatorPadding: const EdgeInsets.symmetric(vertical: 4),
                  labelColor: AppColors.blackColor,
                  unselectedLabelColor: AppColors.black.withValues(alpha: 0.6),
                  labelStyle: GoogleFonts.exo2(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  unselectedLabelStyle: GoogleFonts.exo2(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                  splashBorderRadius: BorderRadius.circular(10),
                  labelPadding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  tabs: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 15,
                      ),
                      child: Text(
                        'Price Card',
                        style: GoogleFonts.exo2(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 15,
                      ),
                      child: Text(
                        'Leaderboard',
                        style: GoogleFonts.exo2(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 15,
                      ),
                      child: Text(
                        'Player Stats',
                        style: GoogleFonts.exo2(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 15,
                      ),
                      child: Text(
                        'ScoreCard',
                        style: GoogleFonts.exo2(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                body: TabBarView(
                  children: [
                    PriceCard(
                      mode: widget.mode,
                      list: widget.data.matchpricecards ?? [],
                      flexible: widget.data.flexibleContest ?? "0",
                      extraPriceList: widget.data.extrapricecard,
                    ),
                    LiveLeaderboard(
                      extraPriceCard: widget.data.extrapricecard ?? [],
                      totalCount: widget.data.joinedusers.toString(),
                      matchKey: widget.data.matchkey ?? "",
                      challengeId: widget.data.matchchallengeid ?? "",
                      totalwinners: widget.data.totalwinners ?? 1,
                      finalStatus: widget.data.matchFinalstatus ?? "",
                    ),
                    PlayerStats(mode: widget.mode),
                    Scorecard(
                      updateScoreboard: getMatchLiveScore,
                      mode: widget.mode,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
