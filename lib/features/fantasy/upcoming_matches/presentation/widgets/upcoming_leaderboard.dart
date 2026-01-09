// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_pages.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/app_toast.dart';
import 'package:unified_dream247/features/fantasy/features/menu_items/presentation/providers/user_data_provider.dart';
import 'package:unified_dream247/features/fantasy/features/upcoming_matches/data/models/leaderboard_model.dart';
import 'package:unified_dream247/features/fantasy/features/upcoming_matches/data/models/user_teams_model.dart';
import 'package:unified_dream247/features/fantasy/features/upcoming_matches/data/upcoming_match_datsource.dart';
import 'package:unified_dream247/features/fantasy/features/upcoming_matches/domain/use_cases/upcoming_match_usecase.dart';
import 'package:unified_dream247/features/fantasy/features/upcoming_matches/presentation/widgets/upcoming_leaderboard_shimmer_widget.dart';

class UpcomingLeaderboard extends StatefulWidget {
  final String teamType;
  final String challengeId;
  final Function(int) teamCount;
  const UpcomingLeaderboard({
    super.key,
    required this.teamType,
    required this.challengeId,
    required this.teamCount,
  });

  @override
  State<UpcomingLeaderboard> createState() => UpcomingLeaderboardState();
}

class UpcomingLeaderboardState extends State<UpcomingLeaderboard> {
  bool isInitialLoad = true;
  List<LeaderboardModelData> list = [];
  int totalCount = 0;
  int skip = 0;
  int limit = 15;
  bool scroll = true;
  late ScrollController _scrollController;
  bool isLoading = false;
  UpcomingMatchUsecase upcomingMatchUsecase = UpcomingMatchUsecase(
    UpcomingMatchDatsource(ApiImpl(), ApiImplWithAccessToken()),
  );

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    loadSelfData();
  }

  void refresh() async {
    // Do not clear the UI list immediately
    final value = await upcomingMatchUsecase.getSelfLeaderboard(
      context,
      widget.challengeId,
      0,
      limit,
    );
    if (!mounted) return;

    if (value != null) {
      List<LeaderboardModelData> selfList =
          LeaderboardModel.fromJson(value).data ?? [];

      // Remove any duplicates
      List<LeaderboardModelData> newList = List.from(list);
      newList.removeWhere(
        (item) => selfList.any((self) => self.jointeamid == item.jointeamid),
      );

      newList.insertAll(0, selfList);
      int newTotal = value['total_joined_teams'] ?? 0;

      final value2 = await upcomingMatchUsecase.getLeaderboardUpcoming(
        context,
        widget.challengeId,
        0,
        limit,
        0,
      );
      if (!mounted) return;

      if (value2 != null) {
        List<LeaderboardModelData> fetchedList =
            LeaderboardModel.fromJson(value2).data ?? [];

        fetchedList.removeWhere(
          (newItem) => newList.any(
            (existingItem) => existingItem.jointeamid == newItem.jointeamid,
          ),
        );

        newList.addAll(fetchedList);

        setState(() {
          list = newList;
          totalCount = newTotal;
          skip = fetchedList.length;
          scroll = newList.length < newTotal;
          isLoading = false;
          isInitialLoad = false;
        });
      }
    }
  }

  @override
  void didUpdateWidget(covariant UpcomingLeaderboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    refresh();
  }

  void loadSelfData() async {
    if (isInitialLoad) {
      setState(() {
        isLoading = true;
      });
    }
    final value = await upcomingMatchUsecase.getSelfLeaderboard(
      context,
      widget.challengeId,
      0,
      limit,
    );
    if (!mounted) return;

    if (value != null) {
      List<LeaderboardModelData> selfList =
          LeaderboardModel.fromJson(value).data ?? [];

      list.removeWhere(
        (item) => selfList.any((self) => self.jointeamid == item.jointeamid),
      );

      setState(() {
        list.insertAll(0, selfList);
        totalCount = value['total_joined_teams'] ?? 0;
        isLoading = false;
        isInitialLoad = false;
      });

      loadData(force: true);
    }
  }

  void loadData({bool force = false}) async {
    if (!mounted || isLoading || !scroll && !force) return;

    if (list.length >= totalCount) {
      scroll = false;
      return;
    }

    setState(() {
      isLoading = true;
    });

    final value = await upcomingMatchUsecase.getLeaderboardUpcoming(
      context,
      widget.challengeId,
      skip,
      limit,
      0,
    );

    if (!mounted) return;
    if (value != null) {
      List<LeaderboardModelData> fetchedList =
          LeaderboardModel.fromJson(value).data ?? [];

      fetchedList.removeWhere(
        (newItem) => list.any(
          (existingItem) => existingItem.jointeamid == newItem.jointeamid,
        ),
      );

      setState(() {
        list.addAll(fetchedList);
        skip += fetchedList.length;
        isLoading = false;
      });

      if (fetchedList.isEmpty || list.length >= totalCount) {
        scroll = false;
      }
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (scroll && !isLoading) {
        loadData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: RefreshIndicator(
        onRefresh: () async {
          refresh();
        },
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(
                  bottom: BorderSide(color: AppColors.letterColor, width: 0.25),
                  top: BorderSide(color: AppColors.letterColor, width: 0.25),
                ),
              ),
              padding: const EdgeInsets.all(8),
              child: Text(
                'All Teams ($totalCount)',
                style: const TextStyle(
                  color: AppColors.letterColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: list.length +
                    ((scroll && isLoading && isInitialLoad) ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == list.length &&
                      isLoading &&
                      isInitialLoad &&
                      scroll) {
                    return Column(
                      children: List.generate(
                        10,
                        (index) => const UpcomingLeaderboardShimmerWidget(),
                      ),
                    );
                  }

                  return singleItem(list[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget singleItem(LeaderboardModelData data) {
    return Column(
      children: [
        InkWell(
          onTap: () async {
            if (data.team ==
                Provider.of<UserDataProvider>(
                  context,
                  listen: false,
                ).userData?.team) {
              await upcomingMatchUsecase
                  .getUserTeam(context, data.jointeamid!)
                  .then((value) {
                List<UserTeamsModel> finalPlayers = [];
                for (var zz in value) {
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
                      captain: zz.captain,
                      vicecaptain: zz.vicecaptain,
                    ),
                  );
                }
                AppNavigation.gotoPreviewScreen(
                  context,
                  "",
                  false,
                  finalPlayers,
                  data.team,
                  "Upcoming",
                  0,
                  false,
                  "",
                );
              });
            } else {
              appToast(
                "You can view other players team only after match is live",
                context,
              );
            }
          },
          child: Container(
            color: (data.team ==
                    Provider.of<UserDataProvider>(
                      context,
                      listen: false,
                    ).userData?.team!)
                ? AppColors.white
                : AppColors.white,
            padding: const EdgeInsets.only(
              top: 8.0,
              bottom: 8.0,
              left: 15.0,
              right: 20.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.transparent,
                      child: ClipOval(
                        child: Image.asset(Images.imageDefalutPlayer),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(1),
                            child: Text(
                              '${data.team}',
                              style: const TextStyle(
                                color: AppColors.letterColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 5),
                            color: AppColors.whiteFade1,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 3,
                              vertical: 3,
                            ),
                            child: Text(
                              'T${data.teamnumber}',
                              style: const TextStyle(
                                color: AppColors.letterColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: (data.team ==
                      Provider.of<UserDataProvider>(
                        context,
                        listen: false,
                      ).userData?.team!),
                  child: InkWell(
                    onTap: () {
                      String leagueId = data.joinleaugeid!;
                      upcomingMatchUsecase
                          .getTeamswithChallengeId(context, widget.challengeId)
                          .then((value) {
                        AppNavigation.gotoMyTeamsChallenges(
                          context,
                          widget.teamType,
                          widget.challengeId,
                          value,
                          1,
                          "Switch Team",
                          leagueId,
                          data.id ?? "",
                          true,
                          0,
                          0,
                        ).then((value) {
                          skip = 0;
                          list = [];
                          loadSelfData();
                        });
                      });
                    },
                    child: const Icon(
                      Icons.swap_horiz_sharp,
                      color: AppColors.letterColor,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(
          color: AppColors.letterColor,
          thickness: 0.1,
          height: 0.1,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
