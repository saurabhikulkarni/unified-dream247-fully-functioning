// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_pages.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_utils.dart';
import 'package:unified_dream247/features/fantasy/landing/data/singleton/app_singleton.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/guru_teams_model.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/teams_model.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/upcoming_match_datsource.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/domain/use_cases/upcoming_match_usecase.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/providers/myteams_provider.dart';

class GuruTeams extends StatefulWidget {
  const GuruTeams({super.key});

  @override
  State<GuruTeams> createState() => _GuruTeams();
}

class _GuruTeams extends State<GuruTeams> {
  Future<List<GuruTeamsModel>?>? guruTeamsList;
  UpcomingMatchUsecase upcomingMatchUsecase = UpcomingMatchUsecase(
    UpcomingMatchDatsource(ApiImpl(), ApiImplWithAccessToken()),
  );

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() {
    guruTeamsList = upcomingMatchUsecase.getGuruTeams(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: FutureBuilder(
          future: guruTeamsList,
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
                                highlightColor: AppColors.lightCard,
                                child: Container(
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: AppColors.whiteFade1.withAlpha(102),
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
            } else if (snapshot.hasError) {
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
                                highlightColor: AppColors.lightCard,
                                child: Container(
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: AppColors.whiteFade1.withAlpha(102),
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
            } else if (snapshot.hasData && (snapshot.data ?? []).isNotEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      GuruTeamsModel data = snapshot.data![index];
                      return singleGuruTeam(data);
                    },
                  ),
                ],
              );
            } else {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text('No guru has shared their team right now.'),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget singleGuruTeam(GuruTeamsModel data) {
    int team1Count = 0, team2Count = 0;
    for (var ii in data.player ?? []) {
      if (ii.team == 'team1') {
        team1Count++;
      } else {
        team2Count++;
      }
    }

    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.letterColor, width: 0.25),
        color: AppColors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 45,
                  height: 45,
                  child: ClipOval(
                    child: Image.asset(
                      data.userImage ?? Images.imageDefalutPlayer,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${data.team}',
                      style: const TextStyle(
                        color: AppColors.letterColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage(Images.imageGround),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 22.0,
                                        child: Image.network(
                                          '${data.captainimage}',
                                        ),
                                      ),
                                      Container(
                                        width: 16,
                                        height: 16,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: AppColors.white,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Text(
                                          'C',
                                          style: TextStyle(
                                            color: AppColors.letterColor,
                                            fontSize: 8,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: 80,
                                    margin: const EdgeInsets.all(5),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                      horizontal: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.letterColor,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      data.captinName ?? "",
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 10,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${data.team1Name}',
                                        style: const TextStyle(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.w300,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        '$team1Count',
                                        style: const TextStyle(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${data.team2Name}',
                                        style: const TextStyle(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.w300,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        '$team2Count',
                                        style: const TextStyle(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 22.0,
                                        child: Image.network(
                                          '${data.vicecaptainimage}',
                                        ),
                                      ),
                                      Container(
                                        width: 16,
                                        height: 16,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: AppColors.white,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Text(
                                          'VC',
                                          style: TextStyle(
                                            color: AppColors.letterColor,
                                            fontSize: 8,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: 80,
                                    margin: const EdgeInsets.all(5),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                      horizontal: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      data.viceCaptainName ?? "",
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 10,
                                        color: AppColors.letterColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(5),
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.shade1White,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${data.countCopied ?? 0} times Picked',
                        style: const TextStyle(
                          color: AppColors.letterColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          int teamNumber = (AppUtils.teamsCount.value) + 1;

                          String selectedPlayers = "";
                          for (var i in data.player ?? []) {
                            selectedPlayers += ',${i.id}';
                          }
                          bool? hasChanges =
                              await AppNavigation.gotoCreateTeamScreen(
                                  context,
                                  teamNumber,
                                  true,
                                  AppSingleton.singleton.matchData.id ?? "",
                                  "",
                                  1,
                                  data.jointeamid,
                                  selectedPlayers,
                                  data.captainId,
                                  data.vicecaptainId,
                                  0,
                                  false,
                                  "");
                          if (hasChanges == true) {
                            List<TeamsModel> updatedTeams =
                                await upcomingMatchUsecase.getMyTeams(context);
                            Provider.of<MyTeamsProvider>(
                              context,
                              listen: false,
                            ).updateMyTeams(
                              updatedTeams,
                              AppSingleton.singleton.matchData.id ?? "",
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: AppColors.letterColor,
                              width: 0.15,
                            ),
                            color: AppColors.letterColor,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 15,
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Pick Team'.toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Image.asset(
                                Images.imageGuruTeamPin,
                                width: 16,
                                height: 16,
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
          ),
        ],
      ),
    );
  }
}
