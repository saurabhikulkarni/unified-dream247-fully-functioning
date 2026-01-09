// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';
import 'package:Dream247/core/app_constants/images.dart';
import 'package:Dream247/features/landing/data/singleton/app_singleton.dart';
import 'package:Dream247/features/upcoming_matches/data/models/players_model.dart';
import 'package:Dream247/features/upcoming_matches/presentation/widgets/player_card_shimmer.dart';
import 'package:Dream247/features/upcoming_matches/presentation/widgets/player_view.dart';

class SingleTabPlayer extends StatefulWidget {
  List<CreateTeamPlayersData> list = [];
  List<CreateTeamPlayersData> allPlayers = [];
  String title, challengeId;
  Function(List<CreateTeamPlayersData>) selectedPlayers;
  Function(String) changeFilter;
  int teamNumber;
  String filter;
  String? teamType;

  SingleTabPlayer({
    super.key,
    required this.list,
    required this.allPlayers,
    required this.title,
    required this.selectedPlayers,
    required this.changeFilter,
    required this.teamNumber,
    required this.challengeId,
    required this.filter,
    this.teamType,
  });

  @override
  State<SingleTabPlayer> createState() => _SingleTabPlayerState();
}

class _SingleTabPlayerState extends State<SingleTabPlayer> {
  String sortBy = "";
  String filter = "";
  bool isPointsEnable = false;
  bool isCreditEnable = false;
  bool isSelectedPlayerEnable = false;

  @override
  void initState() {
    super.initState();
    filter = widget.filter;
    widget.list.sort((a, b) => b.totalpoints!.compareTo(a.totalpoints!));
  }

  @override
  Widget build(BuildContext context) {
    widget.list.sort(
      (a, b) => num.parse(
        b.totalpoints ?? "0",
      ).compareTo(num.parse(a.totalpoints ?? "0")),
    );

    if (sortBy == 'players') {
      widget.list.sort(
        (a, b) => isSelectedPlayerEnable
            ? a.playerSelectionPercentage!.compareTo(
                b.playerSelectionPercentage!,
              )
            : b.playerSelectionPercentage!.compareTo(
                a.playerSelectionPercentage!,
              ),
      );
    } else if (sortBy == 'credits') {
      widget.list.sort(
        (a, b) => isCreditEnable
            ? a.credit!.compareTo(b.credit!)
            : b.credit!.compareTo(a.credit!),
      );
    } else if (sortBy == 'points') {
      widget.list.sort(
        (a, b) => isPointsEnable
            ? num.parse(
                a.totalpoints ?? "0",
              ).compareTo(num.parse(b.totalpoints ?? "0"))
            : num.parse(
                b.totalpoints ?? "0",
              ).compareTo(num.parse(a.totalpoints ?? "0")),
      );
    }
    List<CreateTeamPlayersData> listFiltered = [];
    if (filter == 'both') {
      listFiltered = widget.list;
    } else if (filter == 'team1') {
      listFiltered =
          widget.list.where((element) => element.team == 'team1').toList();
    } else if (filter == 'team2') {
      listFiltered =
          widget.list.where((element) => element.team == 'team2').toList();
    }

    List<CreateTeamPlayersData> listPlaying11 = [];
    List<CreateTeamPlayersData> listNotPlaying11 = [];

    listPlaying11 =
        listFiltered.where((element) => element.playingstatus == 1).toList();
    listNotPlaying11 =
        listFiltered.where((element) => element.playingstatus != 1).toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Text(
                widget.title,
                style: const TextStyle(
                  color: AppColors.letterColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: InkWell(
                onTap: () {
                  filterBottomSheet(context);
                },
                child: const Icon(
                  Icons.filter_alt_outlined,
                  color: AppColors.letterColor,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
        Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            border: Border(
              bottom: BorderSide(color: AppColors.letterColor, width: .25),
              top: BorderSide(color: AppColors.letterColor, width: .25),
            ),
          ),
          padding: const EdgeInsets.only(right: 16, top: 6, bottom: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    sortBy = "players";
                    isSelectedPlayerEnable = !isSelectedPlayerEnable;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 10),
                  width: MediaQuery.of(context).size.width - 208,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Selected By'.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.greyColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      if (sortBy == "players")
                        Icon(
                          isSelectedPlayerEnable
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: AppColors.greyColor,
                          size: 14,
                        ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    sortBy = "points";
                    isPointsEnable = !isPointsEnable;
                  });
                },
                child: SizedBox(
                  width: 60,
                  child: Row(
                    children: [
                      Text(
                        'Points'.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.greyColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      if (sortBy == "points")
                        Icon(
                          isPointsEnable
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: AppColors.greyColor,
                          size: 14,
                        ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 20),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      sortBy = "credits";
                      isCreditEnable = !isCreditEnable;
                    });
                  },
                  child: SizedBox(
                    width: 70,
                    child: Row(
                      children: [
                        Text(
                          'Credits'.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.greyColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        if (sortBy == "credits")
                          Icon(
                            isCreditEnable
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: AppColors.greyColor,
                            size: 14,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        (AppSingleton.singleton.matchData.playing11Status == 0)
            ? (listFiltered.isEmpty)
                ? const PlayerCardShimmer()
                : Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 86),
                      itemCount: listFiltered.length,
                      physics: const AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        CreateTeamPlayersData data = listFiltered[index];
                        return SinglePlayer(
                          index: index+1,
                          data: data,
                          allPlayers: widget.allPlayers,
                          teamType: widget.teamType,
                          selectedPlayers: (p0) {
                            widget.allPlayers = p0;
                            widget.selectedPlayers(p0);
                          },
                        );
                      },
                    ),
                  )
            : (listPlaying11.isEmpty && listNotPlaying11.isEmpty
                ? const PlayerCardShimmer()
                : Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (listPlaying11.isNotEmpty)
                            Image.asset(Images.imageAnnounced),
                          ListView.builder(
                            padding: const EdgeInsets.only(bottom: 0),
                            itemCount: listPlaying11.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              CreateTeamPlayersData data = listPlaying11[index];
                              return SinglePlayer(
                                index: index+1,
                                teamType: widget.teamType,
                                data: data,
                                allPlayers: widget.allPlayers,
                                selectedPlayers: (p0) {
                                  widget.allPlayers = p0;
                                  widget.selectedPlayers(p0);
                                },
                              );
                            },
                          ),
                          if (listPlaying11.isNotEmpty)
                            Image.asset(Images.imageUnannounced),
                          ListView.builder(
                            padding: const EdgeInsets.only(bottom: 86),
                            itemCount: listNotPlaying11.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              CreateTeamPlayersData data =
                                  listNotPlaying11[index];
                              return SinglePlayer(
                                index: index+1,
                                teamType: widget.teamType,
                                data: data,
                                allPlayers: widget.allPlayers,
                                selectedPlayers: (p0) {
                                  widget.allPlayers = p0;
                                  widget.selectedPlayers(p0);
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  )),
      ],
    );
  }

  void filterBottomSheet(BuildContext myContext) {
    showModalBottomSheet(
      context: myContext,
      builder: (myContext) {
        return SafeArea(
          child: Wrap(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      color: AppColors.white,
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.clear,
                              size: 18,
                              color: AppColors.letterColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Filter By Teams',
                            style: TextStyle(
                              color: AppColors.letterColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        filter = 'team1';
                        widget.changeFilter("team1");
                        Navigator.pop(myContext);
                        setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${AppSingleton.singleton.matchData.team1Name}',
                                  style: TextStyle(
                                    color: AppColors.letterColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${AppSingleton.singleton.matchData.teamfullname1}',
                                  style: TextStyle(
                                    color: AppColors.letterColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              (filter == 'team1')
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: AppColors.letterColor,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        filter = 'team2';
                        widget.changeFilter("team2");
                        Navigator.pop(myContext);
                        setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${AppSingleton.singleton.matchData.team2Name}',
                                  style: TextStyle(
                                    color: AppColors.letterColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${AppSingleton.singleton.matchData.teamfullname2}',
                                  style: TextStyle(
                                    color: AppColors.letterColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              (filter == 'team2')
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: AppColors.letterColor,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        filter = 'both';
                        widget.changeFilter("both");
                        Navigator.pop(myContext);
                        setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Both',
                                  style: TextStyle(
                                    color: AppColors.letterColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              (filter == 'both')
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: AppColors.letterColor,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
