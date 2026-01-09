// ignore_for_file: unnecessary_null_comparison, use_build_context_synchronously

import 'dart:async';
import 'package:Dream247/core/app_constants/images.dart';
import 'package:flutter/material.dart';
import 'package:Dream247/features/upcoming_matches/data/models/team_type_model.dart';
import 'package:Dream247/features/upcoming_matches/presentation/widgets/team_type_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:Dream247/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:Dream247/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';
import 'package:Dream247/core/app_constants/app_pages.dart';
import 'package:Dream247/core/app_constants/strings.dart';
import 'package:Dream247/core/global_widgets/no_data_widget.dart';
import 'package:Dream247/core/utils/app_utils.dart';
import 'package:Dream247/features/landing/data/singleton/app_singleton.dart';
import 'package:Dream247/features/upcoming_matches/data/models/all_contests_model.dart';
import 'package:Dream247/features/upcoming_matches/data/models/teams_model.dart';
import 'package:Dream247/features/upcoming_matches/data/upcoming_match_datsource.dart';
import 'package:Dream247/features/upcoming_matches/domain/use_cases/upcoming_match_usecase.dart';
import 'package:Dream247/features/upcoming_matches/presentation/providers/myteams_provider.dart';
// import 'package:Dream247/features/upcoming_matches/presentation/screens/join_by_code_contest.dart';
import 'package:Dream247/features/upcoming_matches/presentation/widgets/contest_category.dart';
import 'package:Dream247/features/upcoming_matches/presentation/widgets/contest_list_view.dart';
import 'package:Dream247/features/upcoming_matches/presentation/widgets/contest_shimmer_view_widget.dart';
import 'package:Dream247/features/upcoming_matches/presentation/widgets/filter_bottomsheet.dart';

class AllContests extends StatefulWidget {
  final String? mode;
  const AllContests({super.key, this.mode});

  @override
  State<AllContests> createState() => _AllContests();
}

class _AllContests extends State<AllContests> {
  Future<void> initialLoadFuture = Future.value();
  List<AllNewContestResponseModel>? contestListData;
  List<TeamTypeModel>? teamTypeList;
  bool isInitialLoading = true;
  String sortedBy = "";
  String teamTypeBy = "";
  Set<String> appliedFilters = {};
  bool isEntryFee = true;
  bool isSpots = false;
  bool isPrizePool = false;
  bool isWinner = false;
  UpcomingMatchUsecase upcomingMatchUsecase = UpcomingMatchUsecase(
    UpcomingMatchDatsource(ApiImpl(), ApiImplWithAccessToken()),
  );

  @override
  void initState() {
    super.initState();

    // Fetch team types first
    upcomingMatchUsecase.getTeamTypes(context)?.then((value) {
      if (value != null && value.isNotEmpty) {
        setState(() {
          teamTypeList = value;
          teamTypeBy =
              value.first.name ?? ""; // Select first teamType by default
        });

        // Load contests filtered by the default selected teamType
        initialLoadFuture = loadData(
          showShimmer: true,
          selectedTeamType: teamTypeBy,
        );
      } else {
        // If no team types, just load all contests
        initialLoadFuture = loadData(showShimmer: true);
      }
    });

    // Fetch user's team & contest count
    upcomingMatchUsecase.userContestTeamCount(context).then((value) {
      if (value != null) {
        Timer(const Duration(milliseconds: 300), () {
          AppUtils.teamsCount.value = value["data"]["total_teams"];
          AppUtils.contestCount.value = value["data"]["total_joinedcontest"];
        });
      }
    });
  }

  Future<void> loadData({
    bool showShimmer = false,
    String? selectedTeamType,
  }) async {
    if (showShimmer) setState(() => isInitialLoading = true);

    final data = await upcomingMatchUsecase.getAllNewContests(context);

    if (!mounted) return;

    setState(() {
      isInitialLoading = false;

      if (data == null || data.isEmpty) {
        contestListData = [];
        AppUtils.teamsCount.value = 0;
        AppUtils.contestCount.value = 0;
        return;
      }

      // When a team type is selected, filter contests accordingly
      if (selectedTeamType != null &&
          selectedTeamType.isNotEmpty &&
          selectedTeamType != "10-1") {
        // Step 1: Separate categories & contests
        final allContests = data.where((e) => e.type == "contest").toList();

        // Step 2: Filter contests by selected team type name
        final filteredContests = allContests
            .where(
              (c) =>
                  c.teamType == selectedTeamType ||
                  c.teamType == selectedTeamType,
            )
            .toList();

        // Step 3: Get category IDs that contain those contests
        final filteredCatIds = filteredContests
            .map((c) => c.contestCat)
            .where((id) => id != null)
            .toSet();

        contestListData = [];

        for (var item in data) {
          if (item.type == "category" && filteredCatIds.contains(item.catid)) {
            contestListData!.add(item);
          } else if (item.type == "contest" &&
              filteredContests
                  .any((c) => c.matchchallengeid == item.matchchallengeid)) {
            contestListData!.add(item);
          }
        }
      } else {
        // No team type filter — show all contests and categories
        contestListData = data;
      }

      // Update user’s contest/team counts
      if ((contestListData ?? []).isEmpty) {
        AppUtils.teamsCount.value = 0;
        AppUtils.contestCount.value = 0;
      } else {
        upcomingMatchUsecase.userContestTeamCount(context).then((value) {
          if (value != null) {
            Timer(const Duration(milliseconds: 300), () {
              AppUtils.teamsCount.value = value["data"]["total_teams"];
              AppUtils.contestCount.value =
                  value["data"]["total_joinedcontest"];
            });
          }
        });
      }
    });
  }

  // Future<void> loadData({
  //   bool showShimmer = false,
  //   String? selectedTeamType,
  // }) async {
  //   if (showShimmer) setState(() => isInitialLoading = true);

  //   final data = await upcomingMatchUsecase.getAllNewContests(context);

  //   if (mounted) {
  //     setState(() {
  //       contestListData = data ?? [];
  //       isInitialLoading = false;

  //       // Default teamType on initial load
  //       // if (selectedTeamType == null &&
  //       //     (contestListData != null && contestListData!.isNotEmpty)) {
  //       //   teamTypeBy = contestListData?.first.teamType ?? "";
  //       // }

  //       // If user selected a teamType, filter contests by that teamType
  //       if (selectedTeamType != null && selectedTeamType.isNotEmpty) {
  //         contestListData =
  //             contestListData
  //                 ?.where((c) => c.teamType == selectedTeamType)
  //                 .toList();
  //       }

  //       // Update counters
  //       if ((contestListData ?? []).isEmpty) {
  //         AppUtils.teamsCount.value = 0;
  //         AppUtils.contestCount.value = 0;
  //       } else {
  //         upcomingMatchUsecase.userContestTeamCount(context).then((value) {
  //           if (value != null) {
  //             Timer(const Duration(milliseconds: 300), () {
  //               AppUtils.teamsCount.value = value["data"]["total_teams"];
  //               AppUtils.contestCount.value =
  //                   value["data"]["total_joinedcontest"];
  //             });
  //           }
  //         });
  //       }
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    List<AllNewContestResponseModel> filterChallenges(
      List<AllNewContestResponseModel> challenges,
    ) {
      if (appliedFilters.isEmpty) return challenges;

      return challenges.where((challenge) {
        bool matches = true;

        // Filtering by Entry Fee
        if (appliedFilters.contains(
          '${Strings.indianRupee}0 - ${Strings.indianRupee}50',
        )) {
          matches &= challenge.entryfee! <= 50;
        } else if (appliedFilters.contains(
          '${Strings.indianRupee}51 - ${Strings.indianRupee}100',
        )) {
          matches &= challenge.entryfee! > 50 && challenge.entryfee! <= 100;
        } else if (appliedFilters.contains(
          '${Strings.indianRupee}101 - ${Strings.indianRupee}1,000',
        )) {
          matches &= challenge.entryfee! > 100 && challenge.entryfee! <= 1000;
        } else if (appliedFilters.contains(
          '${Strings.indianRupee}1001 & above',
        )) {
          matches &= challenge.entryfee! > 1000;
        }

        // Filtering by Spots
        if (appliedFilters.contains('2')) {
          matches &= challenge.maximumUser == 2;
        } else if (appliedFilters.contains('3 - 10')) {
          matches &=
              challenge.maximumUser! >= 3 && challenge.maximumUser! <= 10;
        } else if (appliedFilters.contains('11 - 100')) {
          matches &=
              challenge.maximumUser! >= 11 && challenge.maximumUser! <= 100;
        } else if (appliedFilters.contains('101 - 1,000')) {
          matches &=
              challenge.maximumUser! >= 101 && challenge.maximumUser! <= 1000;
        } else if (appliedFilters.contains('1,001 & above')) {
          matches &= challenge.maximumUser! >= 1001;
        }

        // Filtering by Prize Pool
        if (appliedFilters.contains(
          '${Strings.indianRupee}1 - ${Strings.indianRupee}10,000',
        )) {
          matches &= challenge.winAmount! <= 10000;
        } else if (appliedFilters.contains(
          '${Strings.indianRupee}10,000 - ${Strings.indianRupee}1 Lakh',
        )) {
          matches &=
              challenge.winAmount! > 10000 && challenge.winAmount! <= 100000;
        } else if (appliedFilters.contains(
          '${Strings.indianRupee}1 Lakh - ${Strings.indianRupee}10 Lakh',
        )) {
          matches &=
              challenge.winAmount! > 100000 && challenge.winAmount! <= 1000000;
        } else if (appliedFilters.contains(
          '${Strings.indianRupee}10 Lakh - ${Strings.indianRupee}25 Lakh',
        )) {
          matches &=
              challenge.winAmount! > 1000000 && challenge.winAmount! <= 2500000;
        } else if (appliedFilters.contains(
          '${Strings.indianRupee}25 Lakh or more',
        )) {
          matches &= challenge.winAmount! > 2500000;
        }

        // Filtering by Contest Type
        if (appliedFilters.contains(Strings.multiEntry)) {
          matches &= challenge.multiEntry == 1;
        }
        if (appliedFilters.contains(Strings.guaranteed)) {
          matches &= challenge.confirmedChallenge! == 1;
        }
        if (appliedFilters.contains(Strings.singleEntry)) {
          matches &= challenge.multiEntry == 0;
        }
        if (appliedFilters.contains(Strings.singleWinner)) {
          matches &= challenge.totalwinners == 1;
        }
        if (appliedFilters.contains(Strings.multiWinner)) {
          matches &= challenge.totalwinners! > 1;
        }

        return matches;
      }).toList();
    }

    List<AllNewContestResponseModel> contestListSorted = [];

    if ((contestListData ?? []).isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppUtils.teamsCount.value = 0;
        AppUtils.contestCount.value = 0;
      });
    } else {
      upcomingMatchUsecase.userContestTeamCount(context).then((value) {
        if (value != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            AppUtils.teamsCount.value = value["data"]["total_teams"];
            AppUtils.contestCount.value = value["data"]["total_joinedcontest"];
          });
        }
      });
    }

    if ((contestListData ?? []).isNotEmpty) {
      contestListSorted =
          contestListData?.where((data) => data.type != "category").toList() ??
              [];
    }

    // Apply filtering
    contestListSorted = filterChallenges(contestListSorted);
    bool isSortingOrFiltering =
        sortedBy.isNotEmpty || appliedFilters.isNotEmpty;

    if (sortedBy == "entry") {
      contestListSorted.sort(
        (a, b) => isEntryFee
            ? a.entryfee!.compareTo(b.entryfee!)
            : b.entryfee!.compareTo(a.entryfee!),
      );
    } else if (sortedBy == "spots") {
      contestListSorted.sort(
        (a, b) => isSpots
            ? a.maximumUser!.compareTo(b.maximumUser!)
            : b.maximumUser!.compareTo(a.maximumUser!),
      );
    } else if (sortedBy == "prize") {
      contestListSorted.sort(
        (a, b) => isPrizePool
            ? a.winAmount!.compareTo(b.winAmount!)
            : b.winAmount!.compareTo(a.winAmount!),
      );
    } else if (sortedBy == "winners") {
      contestListSorted.sort(
        (a, b) => isWinner
            ? a.totalwinners!.compareTo(b.totalwinners!)
            : b.totalwinners!.compareTo(a.totalwinners!),
      );
    }
    return RefreshIndicator(
      color: AppColors.mainColor,
      onRefresh: () =>
          loadData(showShimmer: true, selectedTeamType: teamTypeBy),
      child: Scaffold(
        extendBody: false,
        backgroundColor: AppColors.white,
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          color: Colors.transparent,
          child: _bottomActionButton(
            context,
            icon: Icons.add_circle_outline_rounded,
            label: Strings.createTeam.toUpperCase(),
            onTap: () async {
              int teamNumber = AppUtils.teamsCount.value + 1;
              bool? hasChanges = await AppNavigation.gotoCreateTeamScreen(
                context,
                teamNumber,
                false,
                AppSingleton.singleton.matchData.id!,
                "",
                0,
                "",
                "",
                "",
                "",
                0,
                false,
                teamTypeBy,
              );
              if (hasChanges == true) {
                List<TeamsModel> updatedTeams =
                    await upcomingMatchUsecase.getMyTeams(context);
                Provider.of<MyTeamsProvider>(context, listen: false)
                    .updateMyTeams(updatedTeams,
                        AppSingleton.singleton.matchData.id ?? "");
              }
            },
          ),
        ),
        body: Column(
          children: [
            //  SORT & FILTER BAR (PREMIUM DESIGN)
            Container(
              width: double.infinity,
              color: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Text(
                              "Sort By:",
                              style: TextStyle(
                                color: AppColors.greyColor,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          _buildSortChip(
                            context,
                            title: "Entry",
                            isActive: sortedBy == "entry",
                            isAscending: isEntryFee,
                            onTap: () {
                              setState(() {
                                isEntryFee =
                                    sortedBy == "entry" ? !isEntryFee : true;
                                sortedBy = "entry";
                              });
                            },
                          ),
                          _buildSortChip(
                            context,
                            title: "Spots",
                            isActive: sortedBy == "spots",
                            isAscending: isSpots,
                            onTap: () {
                              setState(() {
                                isSpots = sortedBy == "spots" ? !isSpots : true;
                                sortedBy = "spots";
                              });
                            },
                          ),
                          _buildSortChip(
                            context,
                            title: "Prize Pool",
                            isActive: sortedBy == "prize",
                            isAscending: isPrizePool,
                            onTap: () {
                              setState(() {
                                isPrizePool =
                                    sortedBy == "prize" ? !isPrizePool : true;
                                sortedBy = "prize";
                              });
                            },
                          ),
                          _buildSortChip(
                            context,
                            title: "% Winners",
                            isActive: sortedBy == "winners",
                            isAscending: isWinner,
                            onTap: () {
                              setState(() {
                                isWinner =
                                    sortedBy == "winners" ? !isWinner : true;
                                sortedBy = "winners";
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (context) {
                          return FilterBottomSheet(
                            initialSelectedFilters: appliedFilters,
                            onApplyFilters: (filters) {
                              setState(() {
                                appliedFilters = filters;
                              });
                            },
                          );
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.lightCard,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.blackColor.withValues(alpha: 0.05),
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.filter_alt_outlined,
                        color: AppColors.letterColor,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // MARQUEE NOTICE
            if (AppSingleton.singleton.matchData.textNote != null &&
                AppSingleton.singleton.matchData.textNote!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                color: AppColors.lightCard,
                child: Marquee(
                  text: AppSingleton.singleton.matchData.textNote!,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                  ),
                  scrollAxis: Axis.horizontal,
                  blankSpace: 20.0,
                  velocity: 60.0,
                  pauseAfterRound: const Duration(seconds: 1),
                ),
              ),

            8.verticalSpace,
            //Team-Type
            if ((teamTypeList ?? []).length > 1) ...[
              8.verticalSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: (teamTypeList ?? []).map((type) {
                  return TeamTypeWidget(
                    title: type.name ?? "10-1",
                    isActive: teamTypeBy == type.name,
                    onTap: () {
                      setState(() {
                        teamTypeBy = type.name ?? "10-1";
                      });
                      loadData(
                        showShimmer: true,
                        selectedTeamType: teamTypeBy,
                      );
                    },
                  );
                }).toList(),
              ),
            ],

            // CONTEST LIST VIEW
            Expanded(
              child: FutureBuilder(
                future: initialLoadFuture,
                builder: (context, snapshot) {
                  if (isInitialLoading) {
                    return ListView.builder(
                      itemCount: 8,
                      itemBuilder: (context, index) =>
                          const ContestShimmerViewWidget(),
                    );
                  } else {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 20),
                        child: Column(
                          children: [
                            if (!isSortingOrFiltering)
                              for (var item in contestListData ?? []) ...[
                                if (item.type == "category")
                                  ContestCategory(
                                    name: item.name,
                                    subTitle: item.subTitle,
                                  ),
                                if (item.type == "contest" || item.type == "")
                                  ContestListView(
                                    teamType: teamTypeBy,
                                    mode: widget.mode,
                                    data: item,
                                    onDismiss: () => loadData(),
                                    allContests: contestListSorted,
                                  ),
                              ],
                            if (isSortingOrFiltering)
                              ...contestListSorted.map(
                                (contest) => ContestListView(
                                  teamType: teamTypeBy,
                                  mode: widget.mode,
                                  data: contest,
                                  onDismiss: () => loadData(),
                                  allContests: contestListSorted,
                                ),
                              ),
                            if (contestListSorted.isEmpty)
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.7,
                                child: const NoDataWidget(
                                  image: Images.noContestImage,
                                  showButton: false,
                                  title: "No Contests Available",
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),

            // BOTTOM ACTION BUTTONS
            // Align(
            //   alignment: Alignment.bottomCenter,
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       // _bottomActionButton(
            //       //   context,
            //       //   icon: Icons.emoji_events_outlined,
            //       //   label: Strings.contests.toUpperCase(),
            //       //   onTap: () {
            //       //     // existing create/join contest logic unchanged
            //       //     showModalBottomSheet(
            //       //       context: context,
            //       //       builder: (BuildContext context) {
            //       //         return SafeArea(
            //       //           child: Container(
            //       //             decoration: const BoxDecoration(
            //       //               borderRadius: BorderRadius.only(
            //       //                 topLeft: Radius.circular(10),
            //       //                 topRight: Radius.circular(10),
            //       //               ),
            //       //               color: AppColors.white,
            //       //             ),
            //       //             padding: const EdgeInsets.symmetric(
            //       //               horizontal: 10,
            //       //               vertical: 10,
            //       //             ),
            //       //             child: Column(
            //       //               mainAxisSize: MainAxisSize.min,
            //       //               children: <Widget>[
            //       //                 (AppSingleton.singleton.appData
            //       //                             .privateContest ==
            //       //                         1)
            //       //                     ? ListTile(
            //       //                         leading: const Icon(Icons.add_box),
            //       //                         title: const Text(
            //       //                           'Create Contest',
            //       //                           style: TextStyle(
            //       //                             fontWeight: FontWeight.w400,
            //       //                             fontSize: 12,
            //       //                             color: AppColors.letterColor,
            //       //                           ),
            //       //                         ),
            //       //                         onTap: () {
            //       //                           Navigator.pop(context);
            //       //                           AppNavigation
            //       //                               .gotoCreatePrivateContestScreen(
            //       //                                   context, teamTypeBy);
            //       //                         },
            //       //                       )
            //       //                     : const SizedBox.shrink(),
            //       //                 ListTile(
            //       //                   leading: const Icon(Icons.group),
            //       //                   title: const Text(
            //       //                     'Join With Code',
            //       //                     style: TextStyle(
            //       //                       fontWeight: FontWeight.w400,
            //       //                       fontSize: 12,
            //       //                       color: AppColors.letterColor,
            //       //                     ),
            //       //                   ),
            //       //                   onTap: () {
            //       //                     Navigator.pop(context);
            //       //                     showModalBottomSheet<void>(
            //       //                       context: context,
            //       //                       isScrollControlled: true,
            //       //                       shape: const RoundedRectangleBorder(
            //       //                         borderRadius: BorderRadius.vertical(
            //       //                           top: Radius.circular(10.0),
            //       //                         ),
            //       //                       ),
            //       //                       builder: (BuildContext context) {
            //       //                         return const JoinByCodeContest();
            //       //                       },
            //       //                     );
            //       //                   },
            //       //                 ),
            //       //               ],
            //       //             ),
            //       //           ),
            //       //         );
            //       //       },
            //       //     );
            //       //   },
            //       // ),
            //       // const SizedBox(width: 20),
            //       _bottomActionButton(
            //         context,
            //         icon: Icons.add_circle_outline_rounded,
            //         label: Strings.createTeam.toUpperCase(),
            //         onTap: () async {
            //           int teamNumber = AppUtils.teamsCount.value + 1;
            //           bool? hasChanges =
            //               await AppNavigation.gotoCreateTeamScreen(
            //             context,
            //             teamNumber,
            //             false,
            //             AppSingleton.singleton.matchData.id!,
            //             "",
            //             0,
            //             "",
            //             "",
            //             "",
            //             "",
            //             0,
            //             false,
            //             teamTypeBy,
            //           );
            //           if (hasChanges == true) {
            //             List<TeamsModel> updatedTeams =
            //                 await upcomingMatchUsecase.getMyTeams(context);
            //             Provider.of<MyTeamsProvider>(
            //               context,
            //               listen: false,
            //             ).updateMyTeams(
            //               updatedTeams,
            //               AppSingleton.singleton.matchData.id ?? "",
            //             );
            //           }
            //         },
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // Custom Chip Builder for Sort Tabs
  Widget _buildSortChip(
    BuildContext context, {
    required String title,
    required bool isActive,
    required bool isAscending,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(microseconds: 100),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? AppColors.lightCard : AppColors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? AppColors.mainColor : AppColors.greyColor,
              width: 0.8,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.mainColor.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                      ? AppColors.mainColor
                      : AppColors.greyColor.withValues(alpha: 0.9),
                ),
              ),
              3.horizontalSpace,
              Icon(
                isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                color: isActive ? AppColors.mainColor : AppColors.greyColor,
                size: 12.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  //  Bottom Action Button Builder
  Widget _bottomActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 50.h,
      width: MediaQuery.of(context).size.width * 0.9,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        gradient: AppColors.appBarGradient,
        // color: AppColors.lightCard,
        border: Border.all(color: AppColors.black),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 25.sp, color: AppColors.white),
            6.horizontalSpace,
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.white,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
