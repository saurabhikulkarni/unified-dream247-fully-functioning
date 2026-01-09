// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/app_toast.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/main_button.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/teams_model.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/upcoming_match_datsource.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/domain/use_cases/upcoming_match_usecase.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/widgets/contest_head.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/widgets/join_contest_bottomsheet.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/widgets/team_view.dart';

class MyTeamsChallenges extends StatefulWidget {
  String teamType;
  String challengeId, mode;
  String? leagueId;
  List<TeamsModel> list;
  int maxTeams;
  int? discount;
  num entryfee;
  bool? isContestDetail;
  final String? leaderboardId;
  MyTeamsChallenges({
    super.key,
    required this.teamType,
    required this.challengeId,
    this.discount,
    required this.list,
    required this.maxTeams,
    required this.mode,
    this.leagueId,
    this.isContestDetail,
    this.leaderboardId,
    required this.entryfee,
  });
  @override
  State<MyTeamsChallenges> createState() => _MyTeamsChallenges();
}

class _MyTeamsChallenges extends State<MyTeamsChallenges> {
  bool allSelected = false;
  UpcomingMatchUsecase upcomingMatchUsecase = UpcomingMatchUsecase(
    UpcomingMatchDatsource(ApiImpl(), ApiImplWithAccessToken()),
  );

  @override
  void initState() {
    super.initState();

    String type = widget.teamType.trim().toLowerCase();

    // default team type = "10-1"
    if (type.isEmpty || type == "null") {
      type = "10-1";
    }

    // Only filter if type is NOT "10-1"
    if (type != "10-1") {
      widget.list = widget.list
          .where(
            (team) => (team.teamType ?? "").trim().toLowerCase() == type,
          )
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContestHead(
      safeAreaColor: AppColors.white,
      showAppBar: true,
      updateIndex: (p0) => 0,
      showWalletIcon: true,
      isLiveContest: false,
      addPadding: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (widget.mode != "Switch Team" && widget.maxTeams > 1)
            Container(
              width: 110,
              padding: const EdgeInsets.fromLTRB(0, 10, 10, 5),
              child: Row(
                children: [
                  Transform.scale(
                    scale: 0.8,
                    child: Checkbox(
                      checkColor: AppColors.blackColor,
                      activeColor: AppColors.shade1White,
                      shape: const CircleBorder(),
                      value: allSelected,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      onChanged: (value) {
                        setState(() {
                          allSelected = value ?? false;
                          for (var dd in widget.list) {
                            if (!dd.isSelected!) {
                              dd.isPicked = allSelected;
                            }
                          }
                        });
                      },
                    ),
                  ),
                  const Text(
                    'Select All',
                    style: TextStyle(
                      color: AppColors.letterColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                (widget.list.isEmpty)
                    ? Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        padding: const EdgeInsets.all(20),
                        alignment: Alignment.topLeft,
                        child: const Center(child: Text("No Teams Found")),
                      )
                    : SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 86),
                          itemCount: widget.list.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            TeamsModel data = widget.list[index];
                            return TeamView(
                              teamType: widget.teamType,
                              challengeId: widget.challengeId,
                              data: data,
                              chooseTeam: true,
                              mode: "Upcoming",
                              length: widget.list.length,
                              updateTeams: (pList) {
                                setState(() {
                                  widget.list = pList;
                                });
                              },
                            );
                          },
                        ),
                      ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: MainButton(
                    margin: const EdgeInsets.only(
                      right: 15,
                      left: 15,
                      bottom: 10,
                    ),
                    color: AppColors.green,
                    textColor: AppColors.white,
                    text: (widget.mode == "Switch Team")
                        ? 'Switch Team'
                        : 'Join Contest',
                    onTap: () {
                      if (widget.mode == "Switch Team") {
                        String selectedId = '';
                        int count = 0;
                        for (var ii in widget.list) {
                          if (ii.isPicked) {
                            selectedId = ii.jointeamid!;
                            count++;
                          }
                        }
                        if (count > 1) {
                          appToast('Select only 1 team to switch', context);
                        } else if (selectedId == '') {
                          appToast(
                            'Please select/create new team to switch',
                            context,
                          );
                          Navigator.pop(context);
                        } else {
                          upcomingMatchUsecase
                              .switchTeam(
                                context,
                                widget.leagueId ?? "",
                                selectedId,
                                widget.challengeId,
                                widget.leaderboardId ?? "",
                              )
                              .then((value) => {Navigator.of(context).pop()});
                        }
                      } else {
                        int count = 0;
                        String selectedId = "";
                        for (var ii in widget.list) {
                          if (ii.isPicked) {
                            count++;
                            selectedId += ",${ii.jointeamid}";
                          }
                        }
                        if (count >
                            (widget.maxTeams -
                                widget.list
                                    .where(
                                      (element) => element.isSelected ?? false,
                                    )
                                    .length)) {
                          appToast(
                            'You can select maximum of ${widget.maxTeams - widget.list.where((element) => element.isSelected ?? false).toList().length} teams',
                            context,
                          );
                        } else if (count == 0) {
                          appToast('Please select team to join', context);
                        } else {
                          selectedId = selectedId.substring(1);
                          showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(10.0),
                              ),
                            ),
                            builder: (BuildContext context) {
                              return JoinContestBottomsheet(
                                fantasyType: "Cricket",
                                isClosedContestNew: false,
                                previousJoined: false,
                                challengeId: widget.challengeId,
                                newTeam: true,
                                isContestDetail: widget.isContestDetail,
                                selectedTeam: selectedId,
                                discount: widget.discount ?? 0,
                                removePage: () {
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
