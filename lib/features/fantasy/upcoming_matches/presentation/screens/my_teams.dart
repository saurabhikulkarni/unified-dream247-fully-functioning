import 'dart:async';

import 'package:unified_dream247/features/fantasy/my_matches/presentation/screens/my_live_match_team.dart';
import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/team_type_model.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/screens/expert_advice_section.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/widgets/team_type_widget.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_pages.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/no_data_widget.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_utils.dart';
import 'package:unified_dream247/features/fantasy/landing/data/singleton/app_singleton.dart';
import 'package:unified_dream247/features/fantasy/my_matches/data/my_matches_datasource.dart';
import 'package:unified_dream247/features/fantasy/my_matches/domain/use_cases/my_matches_usecases.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/teams_model.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/upcoming_match_datsource.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/domain/use_cases/upcoming_match_usecase.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/providers/myteams_provider.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/widgets/team_view.dart';

class MyTeams extends StatefulWidget {
  final String? mode;
  final Function()? switchTab;
  final bool? hasChanges;
  final bool? hasEdited;
  final Function(bool)? updateHasChanges;
  final bool? isViewingOldMatches;
  const MyTeams({
    super.key,
    this.mode,
    this.switchTab,
    this.hasChanges,
    this.hasEdited,
    this.updateHasChanges,
    this.isViewingOldMatches,
  });

  @override
  State<MyTeams> createState() => _MyTeams();
}

class _MyTeams extends State<MyTeams> {
  Future<List<TeamsModel>?>? teamsList;
  List<TeamTypeModel>? teamTypeList;
  bool hasFetched = false;
  String teamTypeBy = '';
  bool hasEdited = true;
  bool isRefreshing = false;
  bool hasFetchedCompleted = false;
  UpcomingMatchUsecase upcomingMatchUsecase = UpcomingMatchUsecase(
    UpcomingMatchDatsource(ApiImpl(), ApiImplWithAccessToken()),
  );
  MyMatchesUsecases myMatchesUsecases = MyMatchesUsecases(
    MyMatchesDatasource(ApiImplWithAccessToken()),
  );
  Timer? liveTimer;

  @override
  void initState() {
    super.initState();
    upcomingMatchUsecase.getTeamTypes(context)?.then((value) {
      if (value != null && value.isNotEmpty) {
        setState(() {
          teamTypeList = value;
          teamTypeBy = value.first.name ?? ''; // default from API
        });
      }
    });
    loadData();
    // Auto refresh only for live mode
    if (widget.mode == 'Live') {
      liveTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
        loadData(silent: true); // silently refresh data
      });
    }
  }

  @override
  void didUpdateWidget(covariant MyTeams oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasChanges == true || widget.hasEdited == true) {
      loadData();
      widget.updateHasChanges!(false);
    }
  }

  // List<TeamsModel> _filterTeamsByType(List<TeamsModel>? teams, String type) {
  //   if (teams == null) return [];
  //   return teams.where((team) => team.teamType == type).toList();
  // }

  List<TeamsModel> _filterTeamsByType(List<TeamsModel>? teams, String type) {
    if (teams == null) return [];

    // Default type "10-1" par filtering skip karo
    if (type == '10-1' || type.isEmpty) {
      return teams;
    }

    return teams.where((team) => team.teamType == type).toList();
  }

  Future<void> loadData({bool silent = false}) async {
    if (!silent) {
      setState(() {
        teamsList = null;
      });
    }

    var provider = Provider.of<MyTeamsProvider>(context, listen: false);
    String matchKey = AppSingleton.singleton.matchData.id ?? '';

    if (widget.mode == 'Upcoming' &&
        !(widget.hasChanges ?? false) &&
        provider.matchKey == matchKey &&
        provider.myTeams.containsKey(matchKey) &&
        (provider.myTeams[matchKey]?.isNotEmpty ?? false) &&
        AppUtils.teamsCount.value == provider.myTeams[matchKey]?.length) {
      teamsList = Future.value(provider.myTeams[matchKey]);
    } else if (widget.mode == 'Upcoming' && AppUtils.teamsCount.value == 0) {
      teamsList = Future.value(provider.myTeams[matchKey]);
    } else if (widget.mode == 'Live' && silent) {
      teamsList = myMatchesUsecases.liveGetMyTeams(context);
      teamsList!.then((value) {
        setState(() {
          teamsList = Future.value(value);
        });
      });
      return;
    } else if (widget.mode == 'Completed' ||
        widget.mode == 'Abandoned' ||
        widget.mode == 'Cancelled') {
      if ((provider.myTeams[matchKey]?.isNotEmpty ?? false)) {
        teamsList = Future.value(provider.myTeams[matchKey]);
      } else if (!hasFetchedCompleted) {
        if (widget.isViewingOldMatches == true) {
          teamsList = myMatchesUsecases.completeMatchGetMyTeams(context);
        } else {
          teamsList = myMatchesUsecases.liveGetMyTeams(context);
        }
        hasFetchedCompleted = true;
        if (!silent) setState(() {});
        return;
      } else {
        teamsList = Future.value(provider.myTeams[matchKey]);
        if (!silent) setState(() {});
        return;
      }
    } else if (widget.mode == 'Upcoming' && widget.hasChanges == true) {
      teamsList = upcomingMatchUsecase.getMyTeams(context);
      widget.updateHasChanges!(false);
    } else if (widget.mode == 'Upcoming' &&
        provider.matchKey == matchKey &&
        AppUtils.teamsCount.value == 1) {
      teamsList = upcomingMatchUsecase.getMyTeams(context);
      widget.updateHasChanges!(false);
    } else if (widget.mode == 'Upcoming' &&
            (!(widget.hasChanges ?? false) || widget.hasChanges == null) &&
            provider.matchKey == matchKey &&
            provider.myTeams.containsKey(matchKey) == false &&
            (provider.myTeams[matchKey]?.isEmpty ?? false) == false ||
        AppUtils.teamsCount.value != provider.myTeams[matchKey]?.length) {
      teamsList = upcomingMatchUsecase.getMyTeams(context);
    } else if (widget.mode == 'Upcoming' &&
            (!(widget.hasChanges ?? false) || widget.hasChanges == null) &&
            provider.matchKey != matchKey &&
            provider.myTeams.containsKey(matchKey) == false &&
            (provider.myTeams[matchKey]?.isEmpty ?? false) == false ||
        AppUtils.teamsCount.value != provider.myTeams[matchKey]?.length) {
      teamsList = upcomingMatchUsecase.getMyTeams(context);
    } else {
      teamsList = Future.value(provider.myTeams[matchKey]);
    }
    if (!silent) setState(() {});
  }

  @override
  void dispose() {
    liveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool disableRefresh = widget.mode == 'Completed' && hasFetchedCompleted;

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 15),
          //Team-Type
          if ((teamTypeList ?? []).length > 1) ...[
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: (teamTypeList ?? []).map((type) {
                return TeamTypeWidget(
                  title: type.name ?? '',
                  isActive: teamTypeBy == type.name,
                  onTap: () {
                    setState(() {
                      teamTypeBy = type.name ?? '10-1';
                    });
                  },
                );
              }).toList(),
            ),
          ],

          Expanded(
            child: RefreshIndicator(
              color: AppColors.mainColor,
              onRefresh: disableRefresh
                  ? () async {
                      // Disable refresh for completed mode after first fetch
                      // Maybe show a toast/snackbar here if needed
                      return Future.value();
                    }
                  : () async {
                      if (widget.mode == 'Live') {
                        // Silent refresh for live mode
                        await loadData(silent: true);
                      }
                    },
              child: FutureBuilder(
                future: teamsList,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: 7,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    Shimmer.fromColors(
                                      baseColor: AppColors.whiteFade1,
                                      highlightColor: AppColors.whiteFade1,
                                      child: Container(
                                        height: 80,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          color: AppColors.whiteFade1.withAlpha(
                                            102,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    final filteredList = _filterTeamsByType(
                      snapshot.data,
                      teamTypeBy,
                    );
                    return ((filteredList).isEmpty)
                        ? Column(
                            children: [
                              const Expanded(
                                child: Center(
                                  child: NoDataWidget(
                                    showButton: false,
                                    image: Images.myTeam,
                                    title: 'You have not created any team yet',
                                  ),
                                ),
                              ),
                              if (widget.mode == 'Upcoming')
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        height: 40,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.4,
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.lightCard,
                                          border: Border.all(
                                              color: AppColors.black,),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.blackColor
                                                  .withValues(alpha: 0.08),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: InkWell(
                                          onTap: () async {
                                            showModalBottomSheet(
                                              context: context,
                                              builder: (context) =>
                                                  const ExpertAdviceScreen(),
                                            );
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.person_3,
                                                color: AppColors.black,
                                                size: 24,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 6,
                                                ),
                                                child: Text(
                                                  Strings.expertAdvice
                                                      .toUpperCase(),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.black,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 40,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.4,
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.lightCard,
                                          border: Border.all(
                                              color: AppColors.black,),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.black
                                                  .withValues(alpha: 0.08),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: InkWell(
                                          onTap: () async {
                                            int teamNumber =
                                                (snapshot.data?.length ?? 0) +
                                                    1;
                                            bool? hasChanges =
                                                await AppNavigation
                                                    .gotoCreateTeamScreen(
                                              context,
                                              teamNumber,
                                              false,
                                              AppSingleton
                                                  .singleton.matchData.id!,
                                              '',
                                              0,
                                              '',
                                              '',
                                              '',
                                              '',
                                              0,
                                              false,
                                              teamTypeBy,
                                            );
                                            if (hasChanges == true) {
                                              widget.updateHasChanges!(true);
                                              setState(() {
                                                teamsList = upcomingMatchUsecase
                                                    .getMyTeams(context);
                                              });
                                            }
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons
                                                    .add_circle_outline_rounded,
                                                color: AppColors.blackColor,
                                                size: 24,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 6,
                                                ),
                                                child: Text(
                                                  Strings.createTeam
                                                      .toUpperCase(),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.black,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          )
                        : Column(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ListView.builder(
                                        padding: const EdgeInsets.only(
                                          bottom: 10,
                                        ),
                                        itemCount: filteredList.length,
                                        // itemCount: snapshot.data?.length,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          return widget.mode == 'Live'
                                              ? MyLiveMatchTeam(
                                                  data: filteredList[index],)
                                              : TeamView(
                                                  teamType:
                                                      widget.mode == 'Upcoming'
                                                          ? teamTypeBy
                                                          : '',
                                                  data: filteredList[index],
                                                  // data: snapshot.data![index],
                                                  chooseTeam: false,
                                                  mode: widget.mode ?? '',
                                                  length: filteredList.length,
                                                  // length: snapshot.data?.length ?? 0,
                                                  updateTeams: (pList) {
                                                    setState(() {
                                                      hasFetched = true;
                                                      widget.updateHasChanges!(
                                                          true,);
                                                      teamsList =
                                                          Future.value(pList);
                                                      hasEdited == true;
                                                    });
                                                  },
                                                );
                                        },
                                      ),
                                      // if (widget.mode == 'Upcoming')
                                      //   InkWell(
                                      //     onTap: () {
                                      //       widget.switchTab!();
                                      //     },
                                      //     child: Container(
                                      //       width: double.infinity,
                                      //       padding: const EdgeInsets.all(10),
                                      //       margin: const EdgeInsets.all(10),
                                      //       decoration: BoxDecoration(
                                      //         color: AppColors.lightYellow
                                      //             .withAlpha(27),
                                      //         borderRadius:
                                      //             BorderRadius.circular(
                                      //           10,
                                      //         ),
                                      //       ),
                                      //       child: Row(
                                      //         children: [
                                      //           SizedBox(
                                      //             width: 22,
                                      //             height: 22,
                                      //             child: Image.asset(
                                      //               Images.nameLogo,
                                      //               color: AppColors.mainColor,
                                      //             ),
                                      //           ),
                                      //           const SizedBox(width: 8),
                                      //           const Text(
                                      //             'Make more teams using Expert Advice',
                                      //             style: TextStyle(
                                      //               color: AppColors.mainColor,
                                      //               fontSize: 12,
                                      //               fontWeight: FontWeight.w400,
                                      //             ),
                                      //           ),
                                      //         ],
                                      //       ),
                                      //     ),
                                      //   ),
                                    ],
                                  ),
                                ),
                              ),
                              if (widget.mode == 'Upcoming')
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      // Container(
                                      //   height: 40,
                                      //   width:
                                      //       MediaQuery.of(context).size.width *
                                      //           0.4,
                                      //   margin: const EdgeInsets.symmetric(
                                      //     vertical: 10,
                                      //   ),
                                      //   decoration: BoxDecoration(
                                      //     color: AppColors.lightCard,
                                      //     border: Border.all(
                                      //         color: AppColors.black),
                                      //     borderRadius:
                                      //         BorderRadius.circular(12.0),
                                      //     boxShadow: [
                                      //       BoxShadow(
                                      //         color: AppColors.black
                                      //             .withValues(alpha: 0.08),
                                      //         blurRadius: 4,
                                      //         offset: const Offset(0, 2),
                                      //       ),
                                      //     ],
                                      //   ),
                                      //   child: InkWell(
                                      //     onTap: () async {
                                      //       showModalBottomSheet(
                                      //         context: context,
                                      //         builder: (context) =>
                                      //             ExpertAdviceScreen(),
                                      //       );
                                      //     },
                                      //     child: Row(
                                      //       mainAxisAlignment:
                                      //           MainAxisAlignment.center,
                                      //       children: [
                                      //         Icon(
                                      //           Icons.person_3,
                                      //           color: AppColors.black,
                                      //           size: 24,
                                      //         ),
                                      //         Padding(
                                      //           padding: const EdgeInsets.only(
                                      //             left: 6,
                                      //           ),
                                      //           child: Text(
                                      //             Strings.expertAdvice
                                      //                 .toUpperCase(),
                                      //             style: const TextStyle(
                                      //               fontWeight: FontWeight.w600,
                                      //               color: AppColors.black,
                                      //               fontSize: 12,
                                      //             ),
                                      //           ),
                                      //         ),
                                      //       ],
                                      //     ),
                                      //   ),
                                      // ),
                                      Container(
                                        height: 40,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.mainColor,
                                          border: Border.all(
                                              color: AppColors.black,),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.black
                                                  .withValues(alpha: 0.08),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: InkWell(
                                          onTap: () async {
                                            int teamNumber =
                                                (snapshot.data?.length ?? 0) +
                                                    1;

                                            bool? hasChanges =
                                                await AppNavigation
                                                    .gotoCreateTeamScreen(
                                              context,
                                              teamNumber,
                                              false,
                                              AppSingleton
                                                  .singleton.matchData.id!,
                                              '',
                                              0,
                                              '',
                                              '',
                                              '',
                                              '',
                                              0,
                                              false,
                                              teamTypeBy,
                                            );
                                            if (hasChanges == true) {
                                              widget.updateHasChanges!(true);
                                              setState(() {
                                                teamsList = upcomingMatchUsecase
                                                    .getMyTeams(context);
                                              });
                                            }
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons
                                                    .add_circle_outline_rounded,
                                                color: AppColors.white,
                                                size: 24,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 6,
                                                ),
                                                child: Text(
                                                  Strings.createTeam
                                                      .toUpperCase(),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
