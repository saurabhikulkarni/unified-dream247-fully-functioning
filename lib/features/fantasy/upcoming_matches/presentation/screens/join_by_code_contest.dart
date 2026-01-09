// ignore_for_file: use_build_context_synchronously

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_pages.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/app_toast.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/custom_textfield.dart';
import 'package:unified_dream247/features/fantasy/landing/data/singleton/app_singleton.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/teams_model.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/upcoming_match_datsource.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/domain/use_cases/upcoming_match_usecase.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/providers/myteams_provider.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/widgets/join_contest_bottomsheet.dart';

class JoinByCodeContest extends StatefulWidget {
  const JoinByCodeContest({super.key});

  @override
  State<JoinByCodeContest> createState() => _JoinByCodeContest();
}

class _JoinByCodeContest extends State<JoinByCodeContest> {
  TextEditingController codeController = TextEditingController();
  UpcomingMatchUsecase upcomingMatchUsecase = UpcomingMatchUsecase(
    UpcomingMatchDatsource(ApiImpl(), ApiImplWithAccessToken()),
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Wrap(
          children: [
            Container(
              height: 250,
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'If you have a contest invite code, enter it and join',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: AppColors.letterColor,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: CustomTextfield(
                      keyboardType: TextInputType.text,
                      controller: codeController,
                      labelText: "Invite Code",
                      hintText: "Enter Invite Code",
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (codeController.text.isEmpty) {
                        appToast(
                          "Please enter your contest code first",
                          context,
                        );
                      } else {
                        joinByCode();
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: AppColors.green,
                      ),
                      width: MediaQuery.of(context).size.width,
                      height: 45,
                      child: const Center(
                        child: Text(
                          'Join Contest',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void joinByCode() {
    upcomingMatchUsecase.joinByCode(context, codeController.text, 0).then((
      value,
    ) {
      if (value != null) {
        if (value['status']) {
          String matchchallengeid = value['data']['matchchallengeid'];
          num entryFee = value['data']['entryfee'] ?? 0;
          upcomingMatchUsecase
              .getTeamswithChallengeId(context, matchchallengeid)
              .then((value) async {
            int count = 0;
            for (var i in value) {
              if (!i.isSelected!) {
                count++;
              }
            }
            if (count == 0) {
              Navigator.pop(context);
              bool? hasChanges = await AppNavigation.gotoCreateTeamScreen(
                context,
                (value.length + 1),
                false,
                AppSingleton.singleton.matchData.id!,
                matchchallengeid,
                0,
                "",
                "",
                "",
                "",
                0,
                false,
                "",
              );

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
            } else if (count == 1) {
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
                    challengeId: matchchallengeid,
                    selectedTeam: value[0].jointeamid!,
                    isContestDetail: false,
                    removePage: () {
                      Navigator.of(context).pop();
                    },
                  );
                },
              );
            } else {
              Navigator.pop(context);
              await AppNavigation.gotoMyTeamsChallenges(
                context,
                "",
                matchchallengeid,
                Provider.of<MyTeamsProvider>(
                      context,
                      listen: true,
                    ).myTeams[AppSingleton.singleton.matchData.id] ??
                    [],
                1,
                "Join Team",
                "",
                "",
                false,
                0,
                entryFee,
              );
            }
          });
        }
      }
    });
  }
}
