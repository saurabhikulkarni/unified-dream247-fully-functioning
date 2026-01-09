// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Dream247/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:Dream247/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';
import 'package:Dream247/core/app_constants/app_pages.dart';
import 'package:Dream247/core/global_widgets/app_toast.dart';
import 'package:Dream247/core/global_widgets/custom_textfield.dart';
import 'package:Dream247/features/landing/data/singleton/app_singleton.dart';
import 'package:Dream247/features/upcoming_matches/data/models/all_contests_model.dart';
import 'package:Dream247/features/upcoming_matches/data/models/teams_model.dart';
import 'package:Dream247/features/upcoming_matches/data/upcoming_match_datsource.dart';
import 'package:Dream247/features/upcoming_matches/domain/use_cases/upcoming_match_usecase.dart';
import 'package:Dream247/features/upcoming_matches/presentation/providers/myteams_provider.dart';
import 'package:Dream247/features/upcoming_matches/presentation/screens/my_teams_challenges.dart';
import 'package:Dream247/features/upcoming_matches/presentation/widgets/join_contest_bottomsheet.dart';

class JoinCouponContestBottomsheet extends StatefulWidget {
  final AllNewContestResponseModel? data;
  final Function() onDismiss;
  final bool? previousJoined;
  const JoinCouponContestBottomsheet({
    super.key,
    this.data,
    required this.onDismiss,
    this.previousJoined,
  });

  @override
  State<JoinCouponContestBottomsheet> createState() =>
      _JoinCouponContestBottomsheet();
}

class _JoinCouponContestBottomsheet
    extends State<JoinCouponContestBottomsheet> {
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
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Join Coupon Code Contest',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.letterColor,
                      ),
                    ),
                  ),
                  CustomTextfield(
                    keyboardType: TextInputType.text,
                    controller: codeController,
                    labelText: "Contest Code",
                    hintText: "Enter Contest Code",
                  ),
                  InkWell(
                    onTap: () {
                      if (codeController.text.isEmpty) {
                        appToast(
                          "Please enter your contest code first",
                          context,
                        );
                      } else {
                        joinByCode(context, codeController.text);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
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

  void joinByCode(BuildContext context, String code) {
    upcomingMatchUsecase.joinByCode(context, code, 1).then((value) {
      if (value != null) {
        if (value['status']) {
          String matchchallengeid = value['data']['matchchallengeid'];
          Navigator.pop(context);
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
              bool? hasChanges = await AppNavigation.gotoCreateTeamScreen(
                      context,
                      (value.length + 1),
                      false,
                      AppSingleton.singleton.matchData.id!,
                      widget.data?.id,
                      0,
                      "",
                      "",
                      "",
                      "",
                      widget.data?.discountFee ?? 0,
                      false,
                      "")
                  .then((value) {
                widget.onDismiss();
                return null;
              });
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
                    previousJoined: widget.previousJoined ?? false,
                    challengeId: widget.data?.id ?? "",
                    selectedTeam: value
                        .firstWhere((element) => !element.isSelected!)
                        .jointeamid!,
                    discount: widget.data?.discountFee ?? 0,
                    isContestDetail: false,
                    removePage: () {
                      Navigator.of(context).pop();
                    },
                  );
                },
              );
            } else {
              await Navigator.of(context)
                  .push(
                MaterialPageRoute(
                  builder: (context) => MyTeamsChallenges(
                    teamType: widget.data?.teamType ?? "",
                    entryfee: widget.data?.entryfee ?? 0,
                    challengeId: widget.data?.matchchallengeid ?? "",
                    discount: widget.data?.discountFee ?? 0,
                    list: Provider.of<MyTeamsProvider>(
                          context,
                          listen: true,
                        ).myTeams[AppSingleton.singleton.matchData.id] ??
                        [],
                    maxTeams: 1,
                    mode: "Join Team",
                  ),
                ),
              )
                  .then((value) {
                widget.onDismiss();
              });
            }
          });
        }
      }
    });
  }
}
