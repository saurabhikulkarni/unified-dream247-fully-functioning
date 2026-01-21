import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/common_shimmer_view_widget.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_utils.dart';
import 'package:unified_dream247/features/fantasy/landing/data/singleton/app_singleton.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/all_contests_model.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/upcoming_match_datsource.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/domain/use_cases/upcoming_match_usecase.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/widgets/contest_detail_card.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/widgets/contest_head.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/widgets/upcoming_leaderboard.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/widgets/price_card.dart';
// Note: fantasy/main.dart doesn't exist - this import is not needed

class ContestDetails extends StatefulWidget {
  final String? mode;
  final String? matchChallengeId;
  final String teamType;
  const ContestDetails({
    super.key,
    this.matchChallengeId,
    this.mode,
    required this.teamType,
  });

  @override
  State<ContestDetails> createState() => _ContestDetails();
}

class _ContestDetails extends State<ContestDetails> with RouteAware {
  AllContestResponseModel? contestDetails;
  List<AllContestResponseModel> list = [];
  List<Matchpricecards>? currentFillCards;
  final GlobalKey<UpcomingLeaderboardState> leaderboardKey = GlobalKey();
  UpcomingMatchUsecase upcomingMatchUsecase = UpcomingMatchUsecase(
    UpcomingMatchDatsource(ApiImpl(), ApiImplWithAccessToken()),
  );

  @override
  void initState() {
    super.initState();
    getContestDetails();
  }

  Future<void> getContestDetails() async {
    contestDetails = await upcomingMatchUsecase.getContestDetails(
      context,
      widget.matchChallengeId ?? '',
    );
    if (mounted) {
      setState(() {
        currentFillCards =
            // contestDetails?.flexibleContest == "1" &&
            // AppSingleton.singleton.appData.flexibleContest == 1
            // ? generateCurrentFillPriceCard(
            //     joinedUsers: contestDetails?.joinedusers?.toInt() ?? 0,
            //     maxUsers: contestDetails?.maximumUser?.toInt() ?? 1,
            //     winAmount: contestDetails?.winAmount ?? 0,
            //     entryFee: contestDetails?.entryfee ?? 0,
            //     defaultCards: contestDetails?.matchpricecard ?? [],
            //   )
            // :
            contestDetails?.matchpricecard ?? [];
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getContestDetails();
    ModalRoute.of(context)?.addScopedWillPopCallback(() async {
      return true;
    });
  }

  @override
  void dispose() {
    AppUtils.isSelected.value = false;
    // routeObserver.unsubscribe(this); // TODO: Define routeObserver if needed
    super.dispose();
  }

  @override
  void didPopNext() {
    leaderboardKey.currentState?.refresh();
    super.didPopNext();
  }

  @override
  Widget build(BuildContext context) {
    return ContestHead(
      safeAreaColor: AppColors.white,
      showAppBar: true,
      showWalletIcon: true,
      addPadding: false,
      isLiveContest: false,
      updateIndex: (p0) => 0,
      child: Column(
        children: [
          (contestDetails != null)
              ? ContestDetailCard(
                  teamType: widget.teamType,
                  data: contestDetails,
                  onDismiss: () {
                    getContestDetails();
                  },
                  allContests: list,
                )
              : Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10).copyWith(bottom: 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.white,
                        border:
                            Border.all(color: AppColors.whiteFade1, width: 2),
                      ),
                      child: Column(
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ShimmerWidget(
                                      height: 20,
                                      width:
                                          MediaQuery.of(context).size.width / 4,
                                    ),
                                    const SizedBox(height: 5),
                                    ShimmerWidget(
                                      height: 30,
                                      width:
                                          MediaQuery.of(context).size.width / 3,
                                    ),
                                    const SizedBox(height: 10),
                                    const ShimmerWidget(height: 5),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        ShimmerWidget(
                                          height: 10,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              4,
                                        ),
                                        ShimmerWidget(
                                          height: 10,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              4,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const ShimmerWidget(
                                height: 45,
                                borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const ShimmerWidget(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                      height: 40,
                    ),
                  ],
                ),
          ((contestDetails?.textNote ?? '').isEmpty ||
                  AppSingleton.singleton.matchData.textNote == '' ||
                  AppSingleton.singleton.matchData.textNote == null)
              ? const SizedBox.shrink()
              : Container(
                  padding: const EdgeInsets.all(10.0),
                  height: 50,
                  child: Center(
                    child: Marquee(
                      text: contestDetails?.textNote ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.letterColor,
                      ),
                      scrollAxis: Axis.horizontal,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      blankSpace: 20.0,
                      velocity: 100.0,
                      pauseAfterRound: const Duration(seconds: 1),
                      startPadding: 10.0,
                      accelerationDuration: const Duration(seconds: 1),
                      accelerationCurve: Curves.linear,
                      decelerationDuration: const Duration(milliseconds: 500),
                      decelerationCurve: Curves.easeOut,
                    ),
                  ),
                ),
          const SizedBox(height: 15),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Scaffold(
                backgroundColor: AppColors.white,
                appBar: const TabBar(
                  indicatorColor: AppColors.black,
                  tabAlignment: TabAlignment.start,
                  isScrollable: true,
                  tabs: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        'Winnings',
                        style: TextStyle(
                          color: AppColors.letterColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        'Leaderboard',
                        style: TextStyle(
                          color: AppColors.letterColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                body: TabBarView(
                  children: [
                    PriceCard(
                      list: contestDetails?.matchpricecard ?? [],
                      currentFillCards: currentFillCards,
                      flexible: contestDetails?.flexibleContest,
                      extraPriceList: contestDetails?.extrapricecard,
                      mode: widget.mode,
                      textNote: contestDetails?.textNote,
                    ),
                    UpcomingLeaderboard(
                      teamType: widget.teamType,
                      key: leaderboardKey,
                      teamCount: (p0) {
                        int limit = ((contestDetails?.multiEntry ?? 0) == 1)
                            ? (contestDetails?.teamLimit ?? 1)
                            : 1;
                        if (limit == p0) {
                          contestDetails?.isselected = true;
                          AppUtils.isSelected.value = true;
                        }
                      },
                      challengeId: contestDetails?.id ?? '',
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
