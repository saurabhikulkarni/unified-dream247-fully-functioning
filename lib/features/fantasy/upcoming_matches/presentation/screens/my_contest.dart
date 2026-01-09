import 'package:Dream247/core/app_constants/images.dart';
import 'package:flutter/material.dart';
import 'package:Dream247/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:Dream247/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';
import 'package:Dream247/core/global_widgets/common_shimmer_view_widget.dart';
import 'package:Dream247/core/global_widgets/no_data_widget.dart';
import 'package:Dream247/features/upcoming_matches/data/models/all_contests_model.dart';
import 'package:Dream247/features/upcoming_matches/data/models/team_type_model.dart';
import 'package:Dream247/features/upcoming_matches/data/upcoming_match_datsource.dart';
import 'package:Dream247/features/upcoming_matches/domain/use_cases/upcoming_match_usecase.dart';
import 'package:Dream247/features/upcoming_matches/presentation/widgets/contest_shimmer_view_widget.dart';
import 'package:Dream247/features/upcoming_matches/presentation/widgets/my_contest_list_view.dart';
import 'package:Dream247/features/upcoming_matches/presentation/widgets/team_type_widget.dart';

class MyContests extends StatefulWidget {
  final String? teamType;
  final String? mode;
  const MyContests({super.key, this.mode, this.teamType});

  @override
  State<MyContests> createState() => _MyContests();
}

class _MyContests extends State<MyContests> {
  Future<List<AllContestResponseModel>?>? contestList;
  List<AllContestResponseModel> _fullList = [];
  List<AllContestResponseModel> list = [];
  final int chunkSize = 10;
  int totalCount = 0;
  int skip = 0;
  int limit = 100;
  bool scroll = true;
  bool isLoadingMore = false;
  bool isRefreshing = false;
  List<TeamTypeModel>? teamTypeList;
  String teamTypeBy = "";
  late ScrollController _scrollController;
  UpcomingMatchUsecase upcomingMatchUsecase = UpcomingMatchUsecase(
    UpcomingMatchDatsource(ApiImpl(), ApiImplWithAccessToken()),
  );
  bool isInitialLoading = true;

  @override
  void initState() {
    super.initState();

    // load team types first
    upcomingMatchUsecase.getTeamTypes(context)?.then((value) {
      if (value != null && value.isNotEmpty) {
        setState(() {
          teamTypeList = value;
          teamTypeBy = widget.teamType ?? (value.first.name ?? "");
        });
      } else {
        setState(() {
          teamTypeBy = widget.teamType ?? "";
        });
      }

      // call AFTER state updated
      contestList = _fetchInitialData();
    });

    _scrollController = ScrollController()..addListener(_scrollListener);
  }

  Future<List<AllContestResponseModel>?> _fetchInitialData() async {
    setState(() {
      isInitialLoading = true;
    });

    final joinedContestList = await upcomingMatchUsecase.getJoinedContests(
      context,
      0,
      100,
    );

    if (!mounted) return null;

    if (joinedContestList != null && joinedContestList.isNotEmpty) {
      setState(() {
        _fullList = joinedContestList;
        totalCount = _fullList.length;
        list = _fullList.take(chunkSize).toList();
        skip = chunkSize;
        scroll = true;
        isInitialLoading = false;
      });
    } else {
      setState(() {
        scroll = false;
        list.clear();
        _fullList.clear();
        isInitialLoading = false;
      });
    }

    return joinedContestList;
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        scroll &&
        !isLoadingMore &&
        skip < totalCount) {
      loadData();
    }
  }

  Future<void> loadData() async {
    if (isLoadingMore) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      if (_fullList.isEmpty) {
        final joinedContestList = await upcomingMatchUsecase.getJoinedContests(
          context,
          0,
          100,
        );
        if (joinedContestList != null && joinedContestList.isNotEmpty) {
          _fullList = joinedContestList;
          totalCount = _fullList.length;
          skip = 0;
        } else {
          scroll = false;
          return;
        }
      }

      final nextChunk = _fullList.skip(skip).take(chunkSize).toList();

      if (nextChunk.isNotEmpty) {
        setState(() {
          list.addAll(nextChunk);
          skip += chunkSize;
        });
      } else {
        scroll = false;
      }
    } catch (e) {
      scroll = false;
      debugPrint("Error in loadData: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.mainColor,
      onRefresh: () async {
        setState(() {
          isRefreshing = true;
        });

        final joinedContestList = await upcomingMatchUsecase.getJoinedContests(
          context,
          0,
          100,
        );

        if (joinedContestList != null && joinedContestList.isNotEmpty) {
          setState(() {
            _fullList = joinedContestList;
            totalCount = _fullList.length;
            list = _fullList.take(chunkSize).toList();
            skip = chunkSize;
          });
        } else {
          setState(() {
            scroll = false;
            list.clear();
            _fullList.clear();
          });
        }
        setState(() {
          isRefreshing = false;
        });
      },
      child: Column(
        children: [
          SizedBox(height: 10),
          //Team-Type
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Team-Type
              if (teamTypeList != null &&
                  teamTypeList!.isNotEmpty &&
                  (teamTypeList ?? []).length > 1)
                Row(
                  children: teamTypeList!.map((type) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: TeamTypeWidget(
                        title: type.name ?? "",
                        isActive: teamTypeBy == (type.name ?? ""),
                        onTap: () {
                          setState(() {
                            teamTypeBy = type.name ?? "";
                            // reload contests with new filter
                            contestList = _fetchInitialData();
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
          Expanded(
            child: FutureBuilder(
              future: contestList,
              builder: (context, snapshot) {
                if (isInitialLoading) {
                  return ListView.builder(
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return const ContestShimmerViewWidget();
                    },
                  );
                } else if (snapshot.hasError) {
                  return ListView.builder(
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return const ContestShimmerViewWidget();
                    },
                  );
                } else {
                  return (!isInitialLoading && list.isEmpty)
                      ? const Center(
                          child: NoDataWidget(
                            image: Images.noContestImage,
                            showButton: false,
                            title: "No Contests Available!",
                          ),
                        )
                      : SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 30),
                            controller: _scrollController,
                            itemCount: list.length + 1,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              if (index == list.length) {
                                return (scroll && skip < totalCount)
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16.0,
                                        ),
                                        child: Container(
                                          margin: const EdgeInsets.all(
                                            10,
                                          ).copyWith(bottom: 0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color: AppColors.white,
                                            border: Border.all(
                                              color: AppColors.whiteFade1,
                                              width: 2,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    ShimmerWidget(
                                                      height: 50,
                                                      width: MediaQuery.of(
                                                            context,
                                                          ).size.width /
                                                          3,
                                                    ),
                                                    const SizedBox(height: 10),
                                                    const ShimmerWidget(
                                                        height: 55),
                                                    const SizedBox(height: 10),
                                                  ],
                                                ),
                                              ),
                                              const ShimmerWidget(
                                                height: 50,
                                                borderRadius: BorderRadius.only(
                                                  bottomRight:
                                                      Radius.circular(12),
                                                  bottomLeft:
                                                      Radius.circular(12),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : const SizedBox();
                              }
                              return Column(
                                children: [
                                  MyContestListView(
                                    teamType: widget.teamType ?? "",
                                    mode: widget.mode,
                                    data: list[index],
                                    onDismiss: () => _fetchInitialData(),
                                    allContests: list,
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
