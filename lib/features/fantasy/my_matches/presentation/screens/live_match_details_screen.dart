// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_urls.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_pages.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_utils.dart';
import 'package:unified_dream247/features/fantasy/landing/data/singleton/app_singleton.dart';
import 'package:unified_dream247/features/fantasy/my_matches/data/models/match_livescore_model.dart';
import 'package:unified_dream247/features/fantasy/my_matches/data/my_matches_datasource.dart';
import 'package:unified_dream247/features/fantasy/my_matches/domain/use_cases/my_matches_usecases.dart';
import 'package:unified_dream247/features/fantasy/my_matches/presentation/provider/live_score_provider.dart';
import 'package:unified_dream247/features/fantasy/my_matches/presentation/screens/live_my_contest.dart';
import 'package:unified_dream247/features/fantasy/my_matches/presentation/screens/scorecard.dart';
import 'package:unified_dream247/features/fantasy/my_matches/presentation/screens/player_stats.dart';
import 'package:unified_dream247/features/fantasy/my_matches/presentation/widgets/scoreboard.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/user_teams_model.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/screens/my_teams.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/widgets/contest_head.dart';

class LiveMatchDetails extends StatefulWidget {
  final String? mode;
  final String? totalContestCount;
  final bool? isViewingOldMatches;
  final String? gameType;
  const LiveMatchDetails({
    super.key,
    this.mode,
    this.isViewingOldMatches,
    this.totalContestCount,
    this.gameType,
  });
  @override
  State<LiveMatchDetails> createState() => _LiveMatchDetailsState();
}

class _LiveMatchDetailsState extends State<LiveMatchDetails>
    with SingleTickerProviderStateMixin {
  List<MatchLiveScoreModel>? list;
  late TabController _tabController;
  int _previousIndex = 0;
  Timer? timer;
  MyMatchesUsecases myMatchesUsecases = MyMatchesUsecases(
    MyMatchesDatasource(ApiImplWithAccessToken()),
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.animation!.addListener(_onTabSwipe);
    startApiPolling();
  }

  void _onTabSwipe() {
    double animationValue = _tabController.animation!.value;
    int targetIndex = animationValue.round();

    if ((animationValue - _previousIndex).abs() > 0.5) {
      if (_previousIndex != targetIndex) {
        _previousIndex = targetIndex;
      }
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    _tabController.animation!.removeListener(_onTabSwipe);
    _tabController.dispose();
    super.dispose();
  }

  void getMatchLiveScore() async {
    var provider = Provider.of<LiveScoreProvider>(context, listen: false);
    String matchKey = AppSingleton.singleton.matchData.id ?? '';

    if (widget.mode == 'Completed' ||
        widget.mode == 'Abandoned' ||
        widget.mode == 'Cancelled') {
      if ((provider.liveScore[matchKey]?.isNotEmpty ?? false)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            list = provider.liveScore[matchKey];
          });
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

    if (widget.mode == 'Live') {
      final data = await myMatchesUsecases.getMatchLiveScore(context);
      setState(() {
        list = data;
      });
      return;
    }
  }

  void startApiPolling() {
    if (widget.mode == 'Live') {
      timer = Timer.periodic(const Duration(seconds: 60), (timer) {
        getMatchLiveScore();
      });
    } else {
      getMatchLiveScore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContestHead(
      extendBodyBehindAppbar: true,
      safeAreaColor: AppColors.white,
      showAppBar: true,
      showWalletIcon: true,
      addPadding: false,
      isLiveContest: true,
      mode: widget.mode,
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/upcoming_matches/live_bg.png'),
                      fit: BoxFit.cover,),
                  // gradient: LinearGradient(
                  //     colors: [
                  //       AppColors.mainColor,
                  //       AppColors.red,
                  //       AppColors.blackColor
                  //     ],
                  //     begin: AlignmentGeometry.topCenter,
                  //     end: AlignmentGeometry.bottomCenter)
                ),
                padding: EdgeInsets.fromLTRB(
                  10,
                  MediaQuery.of(context).padding.top + 70, // ✅ AppBar height
                  10,
                  20,
                ),
                child: Column(
                  children: [Scoreboard(list: list, mode: widget.mode)],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      // indicator: BoxDecoration(
                      //   color: AppColors.mainColor.withValues(alpha: 0.15),
                      //   borderRadius: BorderRadius.circular(10),
                      //   border: Border.all(
                      //     color: AppColors.mainColor,
                      //     width: 1,
                      //   ),
                      // ),
                      indicatorPadding: const EdgeInsets.symmetric(vertical: 4),
                      labelColor: AppColors.mainColor,
                      unselectedLabelColor:
                          AppColors.blackColor.withValues(alpha: 0.6),
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
                        vertical: 2,
                      ),
                      tabs: [
                        Tab(
                          child: ValueListenableBuilder<int>(
                            valueListenable: AppUtils.contestCount,
                            builder: (
                              BuildContext context,
                              int value,
                              Widget? child,
                            ) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                  horizontal: 14,
                                ),
                                child: Text(
                                  'My Contest ($value)',
                                  style: GoogleFonts.exo2(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        if (widget.gameType == 'Cricket')
                          Tab(
                            child: ValueListenableBuilder<int>(
                              valueListenable: AppUtils.teamsCount,
                              builder: (
                                BuildContext context,
                                int value,
                                Widget? child,
                              ) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                    horizontal: 15,
                                  ),
                                  child: Text(
                                    'My Teams ($value)',
                                    style: GoogleFonts.exo2(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        Tab(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 2,
                              horizontal: 15,
                            ),
                            child: Text(
                              'Player Stats',
                              style: GoogleFonts.exo2(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Tab(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 2,
                              horizontal: 15,
                            ),
                            child: Text(
                              'ScoreCard',
                              style: GoogleFonts.exo2(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // ContestWinningsCard(
                          //   title: 'Grand Tournament',
                          //   spots: '15,000',
                          //   entryFee: '₹99',
                          //   currentWinnings: '₹100',
                          //   ranks: [
                          //     WinningRankItem(
                          //       rank: '#35',
                          //       label: 'In Winning zone',
                          //       tag: 'T1',
                          //       tagColor: Colors.green,
                          //       points: 710,
                          //     ),
                          //     WinningRankItem(
                          //       rank: '#40',
                          //       label: '',
                          //       tag: 'T2',
                          //       tagColor: Colors.purple,
                          //       points: 500,
                          //     ),
                          //     WinningRankItem(
                          //       rank: '#50',
                          //       label: '',
                          //       tag: 'T3',
                          //       tagColor: Colors.blue,
                          //       points: 200,
                          //     ),
                          //   ],
                          //   onViewMore: () {
                          //     // navigate
                          //   },
                          // ),

                          LiveMyContests(
                            totalContestCount: widget.totalContestCount ?? '0',
                            mode: widget.mode,
                            updateScoreboard: getMatchLiveScore,
                          ),
                          MyTeams(
                            mode: widget.mode,
                            isViewingOldMatches: widget.isViewingOldMatches,
                          ),
                          PlayerStats(mode: widget.mode),
                          Scorecard(
                            updateScoreboard: getMatchLiveScore,
                            mode: widget.mode,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.mode == 'Completed' && widget.gameType == 'Cricket')
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 150,
                  height: 35,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.greyColor),
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () async {
                      await myMatchesUsecases
                          .dreamTeam(
                        context,
                        AppSingleton.singleton.matchData.id ?? '',
                      )
                          ?.then((value) {
                        List<UserTeamsModel> finalPlayers = [];
                        for (var zz in value ?? []) {
                          finalPlayers.add(
                            UserTeamsModel(
                              playerid: zz.playerid,
                              playerimg: zz.image,
                              image: zz.image,
                              team: zz.team,
                              name: zz.name,
                              role: zz.role,
                              credit: zz.credit!.toDouble(),
                              points: zz.points!,
                              playingstatus: zz.playingstatus,
                              captain: zz.captain,
                              vicecaptain: zz.vicecaptain,
                            ),
                          );
                        }
                        AppNavigation.gotoPreviewScreen(
                          context,
                          '',
                          false,
                          finalPlayers,
                          '${APIServerUrl.appName} Team',
                          'completed',
                          0,
                          false,
                          '',
                        );
                      });
                    },
                    child: Center(
                      child: Text(
                        '${APIServerUrl.appName} Team',
                        style: GoogleFonts.exo2(
                          color: AppColors.blackColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ContestWinningsCard extends StatelessWidget {
  final String title;
  final String spots;
  final String entryFee;
  final String currentWinnings;
  final List ranks;
  final VoidCallback? onViewMore;

  const ContestWinningsCard({
    super.key,
    required this.title,
    required this.spots,
    required this.entryFee,
    required this.currentWinnings,
    required this.ranks,
    this.onViewMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ---------- TOP ROW ----------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.exo2(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Entry $entryFee',
                style: GoogleFonts.exo2(
                  fontSize: 12,
                  color: AppColors.greyColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spots $spots',
                style: GoogleFonts.exo2(
                  fontSize: 12,
                  color: AppColors.greyColor,
                ),
              ),
              Text(
                currentWinnings,
                style: GoogleFonts.exo2(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.grey.shade200),

          /// ---------- CURRENT WINNINGS ----------
          const SizedBox(height: 10),
          Text(
            'Current winnings',
            style: GoogleFonts.exo2(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),

          const SizedBox(height: 10),

          /// ---------- RANK LIST ----------
          ...ranks.map((e) => _rankRow(e)),

          const SizedBox(height: 8),
          Divider(height: 1, color: Colors.grey.shade200),

          /// ---------- VIEW MORE ----------
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: onViewMore,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'View more Teams  >',
                  style: GoogleFonts.exo2(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.greyColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rankRow(WinningRankItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              'Rank ${item.rank}',
              style: GoogleFonts.exo2(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              item.label,
              style: GoogleFonts.exo2(
                fontSize: 12,
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            height: 22,
            width: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: item.tagColor),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              item.tag,
              style: GoogleFonts.exo2(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: item.tagColor,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Points',
                style: GoogleFonts.exo2(
                  fontSize: 10,
                  color: AppColors.greyColor,
                ),
              ),
              Text(
                '${item.points}',
                style: GoogleFonts.exo2(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WinningRankItem {
  final String rank;
  final String label;
  final String tag; // T1, T2, T3
  final Color tagColor;
  final int points;

  WinningRankItem({
    required this.rank,
    required this.label,
    required this.tag,
    required this.tagColor,
    required this.points,
  });
}
