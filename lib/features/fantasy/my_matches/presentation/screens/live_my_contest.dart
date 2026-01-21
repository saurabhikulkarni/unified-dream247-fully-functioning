import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/no_data_widget.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_utils.dart';
import 'package:unified_dream247/features/fantasy/landing/data/singleton/app_singleton.dart';
import 'package:unified_dream247/features/fantasy/my_matches/data/models/live_challenges_model.dart';
import 'package:unified_dream247/features/fantasy/my_matches/data/my_matches_datasource.dart';
import 'package:unified_dream247/features/fantasy/my_matches/domain/use_cases/my_matches_usecases.dart';
import 'package:unified_dream247/features/fantasy/my_matches/presentation/provider/joined_live_contest_provider.dart';
import 'package:unified_dream247/features/fantasy/my_matches/presentation/widgets/joined_contest_shimmer_widget.dart';
import 'package:unified_dream247/features/fantasy/my_matches/presentation/widgets/live_contest_view.dart';

class LiveMyContests extends StatefulWidget {
  final String? mode;
  final String? totalContestCount;
  final Function() updateScoreboard;
  const LiveMyContests({
    super.key,
    required this.updateScoreboard,
    this.mode,
    this.totalContestCount,
  });

  @override
  State<LiveMyContests> createState() => _LiveMyContests();
}

class _LiveMyContests extends State<LiveMyContests> {
  Future<LiveChallengesModel>? contestListFuture;
  List<LiveChallengesData> list = [];
  int skip = 0;
  int limit = 10;
  bool scroll = true;
  int shownItemCount = 0;
  int chunkSize = 10;
  bool isLoadingMore = false;
  late ScrollController _scrollController;
  MyMatchesUsecases myMatchesUsecases = MyMatchesUsecases(
    MyMatchesDatasource(ApiImplWithAccessToken()),
  );

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenHeight = MediaQuery.of(context).size.height;
      chunkSize = (screenHeight ~/ 160);
      contestListFuture = loadData();
    });
    widget.updateScoreboard();
  }

  void _scrollListener() {
    if (widget.mode == 'Live') {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          shownItemCount < list.length &&
          !isLoadingMore) {
        setState(() => isLoadingMore = true);

        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            int nextCount = shownItemCount + chunkSize;
            if (shownItemCount < list.length) {
              setState(() {
                shownItemCount =
                    nextCount > list.length ? list.length : nextCount;
                isLoadingMore = false;
              });
            } else {
              setState(() {
                isLoadingMore = false;
              });
            }
          }
        });
      }
    } else {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          scroll &&
          !isLoadingMore &&
          skip < num.parse(widget.totalContestCount ?? '0')) {
        loadData();
      }
    }
  }

  Future<LiveChallengesModel> loadData() async {
    final provider = Provider.of<JoinedLiveContestProvider>(
      context,
      listen: false,
    );
    String matchKey = AppSingleton.singleton.matchData.id ?? '';

    if (!mounted) return Future.error('Widget not mounted');

    setState(() => isLoadingMore = true);

    try {
      if (widget.mode == 'Live') {
        final result = await myMatchesUsecases.getJoinedLiveContests(
          context,
          0,
          50,
        );
        list = result.data ?? [];
        shownItemCount = chunkSize < list.length ? chunkSize : list.length;
        return result;
      } else {
        LiveChallengesModel? cachedList = provider.joinedContest[matchKey];

        if (cachedList == null) {
          final result = await myMatchesUsecases.getJoinedLiveContests(
            context,
            skip,
            limit,
          );

          if (skip == 0) list.clear();
          final newList = result.data ?? [];

          if (newList.isNotEmpty) {
            list.addAll(newList);
            skip += limit;
            shownItemCount = list.length;

            provider.setjoinedContest(result, matchKey);
          } else {
            scroll = false;
          }

          return result;
        } else {
          list = cachedList.data ?? [];
          shownItemCount = list.length;
          scroll = false;
          return cachedList;
        }
      }
    } catch (e, st) {
      debugPrint('Error: $e\n$st');
      rethrow;
    } finally {
      if (mounted) {
        setState(() => isLoadingMore = false);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.mainLightColor,
      onRefresh: () async {
        skip = 0;
        scroll = true;

        try {
          final result = await loadData();
          setState(() {
            list = result.data ?? [];
            shownItemCount =
                (chunkSize < list.length) ? chunkSize : list.length;
          });
        } catch (e) {
          debugPrint('Refresh failed: $e');
        }
      },
      child: FutureBuilder<LiveChallengesModel>(
        future: contestListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return const JoinedContestShimmerWidget();
              },
            );
          } else if (snapshot.hasError) {
            return ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return const JoinedContestShimmerWidget();
              },
            );
          }
          return Column(
            children: [
              if (AppSingleton.singleton.appData.myJoinedContest == true)
                _buildStatsSection(snapshot.data),
              Expanded(
                child: list.isEmpty
                    ? const Center(
                        child: NoDataWidget(
                          title: 'No Contests Available!',
                          showButton: false,
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: (widget.mode == 'Live')
                            ? (shownItemCount < list.length
                                ? shownItemCount + 1
                                : shownItemCount)
                            : list.length + (isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= list.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: SizedBox(
                                  height: 30,
                                  width: 30,
                                  // child: LoadingIndicator(
                                  //   strokeWidth: 1.0,
                                  //   indicatorType: Indicator.lineSpinFadeLoader,
                                  //   backgroundColor: AppColor.transparent,
                                  //   pathBackgroundColor: AppColor.transparent,
                                  //   colors: [
                                  //     AppColor.textColor,
                                  //     AppColor.greyColor
                                  //   ],
                                  // ),
                                ),
                              ),
                            );
                          }

                          final data = list[index];
                          return LiveContestView(
                            data: data,
                            mode: widget.mode,
                            challengeId: data.matchchallengeid ?? '',
                            finalStatus: data.matchFinalstatus ?? '',
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsSection(LiveChallengesModel? data) {
    final investment = data?.totalinvestment ?? 0;
    final winning = data?.totalwon ?? 0;
    final profit = winning - investment;

    return Container(
      margin: const EdgeInsets.all(10).copyWith(bottom: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.whiteFade1, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatsColumn('Investment', investment),
          _buildStatsColumn('Winning', winning),
          _buildStatsColumn(
            'Profit',
            (widget.mode == 'Live') ? 0 : profit,
            color: profit >= 0 ? AppColors.green : Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsColumn(String label, num amount, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: GoogleFonts.exo2(
            color: AppColors.greyColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${Strings.indianRupee}${AppUtils.formatAmount(amount.toString())}',
          style: GoogleFonts.tomorrow(
            color: color ?? AppColors.blackColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
