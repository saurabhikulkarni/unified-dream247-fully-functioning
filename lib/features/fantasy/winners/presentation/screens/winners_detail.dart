// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_urls.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_pages.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/main_container.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/sub_container.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_utils.dart';
import 'package:unified_dream247/features/fantasy/my_matches/data/my_matches_datasource.dart';
import 'package:unified_dream247/features/fantasy/my_matches/domain/use_cases/my_matches_usecases.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/user_teams_model.dart';
import 'package:unified_dream247/features/fantasy/winners/data/models/winners_model.dart';
import 'package:unified_dream247/features/fantasy/winners/data/winners_datasource.dart';
import 'package:unified_dream247/features/fantasy/winners/domain/use_cases/winners_usecases.dart';

class WinnersDetail extends StatefulWidget {
  final WinnersModel? data;
  final List<WinContestData>? winContestData;
  const WinnersDetail({
    super.key,
    required this.data,
    required this.winContestData,
  });

  @override
  State<WinnersDetail> createState() => _WinnersDetail();
}

class _WinnersDetail extends State<WinnersDetail> {
  int selectedContestIndex = 0;
  WinnersUsecases winnersUsecases = WinnersUsecases(
    WinnersDatasource(ApiImplWithAccessToken()),
  );
  MyMatchesUsecases myMatchesUsecases = MyMatchesUsecases(
    MyMatchesDatasource(ApiImplWithAccessToken()),
  );
  List<WinContestData>? winContestData;
  @override
  Widget build(BuildContext context) {
    List<WinnersMatchchallenges> challenges =
        widget.data?.matchchallenges ?? [];
    return SubContainer(
      showAppBar: true,
      showWalletIcon: true,
      headerText: Strings.megaContestWinners,
      addPadding: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MainContainer(
              color: AppColors.bgColor,
              margin: const EdgeInsets.all(8).copyWith(bottom: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              textAlign: TextAlign.center,
                              widget.data?.seriesName ?? '',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.exo2(
                                color: AppColors.letterColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          AppUtils.formatDate(
                            widget.data?.startDate.toString() ?? '',
                          ),
                          style: GoogleFonts.exo2(
                            color: AppColors.letterColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 10.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ClipOval(
                                    child: Image.network(
                                      widget.data?.teamAImage ?? '',
                                      height: 35,
                                      width: 35,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${widget.data?.teamAShortName}',
                                    style: GoogleFonts.exo2(
                                      fontSize: 16,
                                      color: AppColors.letterColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3.0),
                              Text(
                                '${widget.data?.teamAName}',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.exo2(
                                  fontSize: 12,
                                  color: AppColors.letterColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Image.asset(Images.icVersus, height: 35, width: 120),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    '${widget.data?.teamBShortName}',
                                    style: GoogleFonts.exo2(
                                      fontSize: 15,
                                      color: AppColors.letterColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  ClipOval(
                                    child: Image.network(
                                      widget.data?.teamBImage ?? '',
                                      height: 35,
                                      width: 35,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3.0),
                              Text(
                                '${widget.data?.teamBName}',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.exo2(
                                  fontSize: 12,
                                  color: AppColors.letterColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: AppColors.whiteFade1,
                    width: MediaQuery.of(context).size.height * .9,
                    height: 1,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () async {
                        await myMatchesUsecases
                            .dreamTeam(context, widget.data?.matchkey ?? '')
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
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 10,
                        ),
                        child: Text(
                          'View ${APIServerUrl.appName} Team',
                          style: TextStyle(
                            color: AppColors.letterColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              child: SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: challenges.length,
                  itemBuilder: (context, index) {
                    return singleContest(
                      challenges[index],
                      index,
                      widget.data?.fantasyType ?? '',
                    );
                  },
                ),
              ),
            ),
            ((widget.winContestData ?? []).isNotEmpty)
                ? Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 5,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: widget.winContestData?.length,
                        itemBuilder: (context, index) {
                          WinContestData contestData =
                              widget.winContestData![index];
                          return singleContestWinnersList(contestData);
                        },
                      ),
                    ),
                  )
                : const Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'No user joined this contest',
                          style: TextStyle(
                            color: AppColors.letterColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget singleContestWinnersList(WinContestData data) {
    return MainContainer(
      margin: const EdgeInsets.all(8).copyWith(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: SizedBox(
                    height: 64,
                    width: 64,
                    child: Image.network('${data.userImage}'),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${data.userTeamName}',
                      style: GoogleFonts.exo2(
                        color: AppColors.letterColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${data.username}',
                      style: GoogleFonts.exo2(
                        color: AppColors.letterColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${data.state}',
                      style: GoogleFonts.exo2(
                        color: AppColors.letterColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.whiteFade1,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rank',
                      style: GoogleFonts.exo2(
                        color: AppColors.letterColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      '#${data.rank}',
                      style: GoogleFonts.exo2(
                        color: AppColors.letterColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Amount Won',
                      style: GoogleFonts.exo2(
                        color: AppColors.letterColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      '${Strings.indianRupee}${AppUtils.changeNumberToValue(data.amount!.toInt())}',
                      style: GoogleFonts.tomorrow(
                        color: AppColors.letterColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: Image.asset(Images.imageTrophy),
                ),
                const SizedBox(width: 8),
                Text(
                  'Won With Team 1',
                  style: GoogleFonts.exo2(
                    color: AppColors.letterColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget singleContest(
    WinnersMatchchallenges data,
    int index,
    String fantasyType,
  ) {
    return InkWell(
      onTap: () async {
        selectedContestIndex = index;
        winContestData = widget.winContestData;
        winContestData = await winnersUsecases.loadContestWinners(
          context,
          data.id ?? '',
          0,
          10,
          fantasyType,
          data.matchkey ?? '',
        );
        setState(() {});
      },
      child: Container(
        margin: const EdgeInsets.only(right: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: (selectedContestIndex == index)
              ? AppColors.letterColor
              : AppColors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '${Strings.indianRupee}${AppUtils.changeNumberToValue(data.winAmount!)} Contest',
            style: GoogleFonts.tomorrow(
              color: (selectedContestIndex == index)
                  ? AppColors.white
                  : AppColors.letterColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
