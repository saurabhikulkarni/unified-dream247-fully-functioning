// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';
import 'package:Dream247/core/app_constants/app_pages.dart';
import 'package:Dream247/core/app_constants/images.dart';
import 'package:Dream247/core/app_constants/strings.dart';
import 'package:Dream247/core/global_widgets/app_toast.dart';
import 'package:Dream247/core/utils/app_utils.dart';
import 'package:Dream247/features/landing/data/singleton/app_singleton.dart';
import 'package:Dream247/features/menu_items/presentation/providers/user_data_provider.dart';
import 'package:Dream247/features/upcoming_matches/data/models/all_contests_model.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:Dream247/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:Dream247/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:Dream247/core/global_widgets/gradient_progress_bar.dart';
import 'package:Dream247/features/upcoming_matches/data/upcoming_match_datsource.dart';
import 'package:Dream247/features/upcoming_matches/domain/use_cases/upcoming_match_usecase.dart';
import 'package:Dream247/features/upcoming_matches/presentation/providers/myteams_provider.dart';
import 'package:Dream247/features/upcoming_matches/presentation/widgets/join_contest_bottomsheet.dart';
import 'package:Dream247/features/upcoming_matches/presentation/widgets/join_coupon_contest_bottomsheet.dart';
import 'package:Dream247/core/api_server_constants/api_server_urls.dart';
import 'package:Dream247/features/upcoming_matches/data/models/teams_model.dart';
import 'package:flutter/material.dart';

class ContestListView extends StatelessWidget {
  final String? mode;
  final String teamType;
  final AllNewContestResponseModel? data;
  final Function() onDismiss;
  final List<AllNewContestResponseModel> allContests;
  ContestListView({
    super.key,
    required this.data,
    required this.onDismiss,
    required this.allContests,
    this.mode,
    required this.teamType,
  });

  bool previousJoined = false;

  UpcomingMatchUsecase upcomingMatchUsecase = UpcomingMatchUsecase(
    UpcomingMatchDatsource(ApiImpl(), ApiImplWithAccessToken()),
  );
  void checkForMandatoryContest(
    BuildContext context,
    String mandatoryContestID,
  ) async {
    List<AllNewContestResponseModel>? joinedContestList = [];
    bool contestFound = false;
    for (var contest in joinedContestList) {
      if (contest.challengeId == mandatoryContestID) {
        contestFound = true;
        break;
      }
    }
    if (contestFound) {
      if (context.mounted) {
        joinContest(context);
      }
    } else {
      int entryFee = 0;
      for (var contest in allContests) {
        if (contest.challengeId == mandatoryContestID) {
          entryFee = contest.entryfee!;
          break;
        }
      }
      appToast(
        "You need to join another contest of 💎$entryFee to join this contest",
        context,
      );
    }
  }

  void joinContest(BuildContext context) {
    upcomingMatchUsecase
        .getTeamswithChallengeId(context, data?.matchchallengeid ?? "")
        .then((value) async {
      int count = 0;
      for (var i in value) {
        if (!i.isSelected!) {
          count++;
        } else {
          previousJoined = true;
        }
      }
      if (count == 0) {
        bool? hasChanges = await AppNavigation.gotoCreateTeamScreen(
          context,
          (value.length + 1),
          false,
          AppSingleton.singleton.matchData.id!,
          data?.id,
          0,
          "",
          "",
          "",
          "",
          data?.discountFee ?? 0,
          false,
          teamType,
        ).then((value) {
          onDismiss();
          return null;
        });
        if (hasChanges == true) {
          debugPrint("Updating team list after creating new team...");
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
          ),
          builder: (BuildContext context) {
            return JoinContestBottomsheet(
              fantasyType: "Cricket",
              isClosedContestNew: false,
              totalWinners: data?.totalwinners.toString() ?? "",
              previousJoined: previousJoined,
              challengeId: data?.id ?? "",
              discount: data?.discountFee ?? 0,
              selectedTeam: value
                  .firstWhere((element) => !element.isSelected!)
                  .jointeamid!,
              isContestDetail: false,
              removePage: () {
                onDismiss();
              },
            );
          },
        );
      } else {
        await AppNavigation.gotoMyTeamsChallenges(
          context,
          teamType,
          data?.matchchallengeid ?? "",
          Provider.of<MyTeamsProvider>(
                context,
                listen: false,
              ).myTeams[AppSingleton.singleton.matchData.id] ??
              [],
          (data?.multiEntry == 1)
              ? (data?.isPromoCodeContest ?? false)
                  ? 1
                  : data?.teamLimit ?? 0
              : 1,
          "Join Team",
          "",
          "",
          false,
          data?.discountFee ?? 0,
          data?.entryfee ?? 0,
        ).then((value) {
          onDismiss();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int percent = (data?.joinedusers ?? 0) * 100 ~/ (data?.maximumUser ?? 1);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: () async {
            await AppNavigation.gotoUpcomingContestDetails(
              context,
              data?.id,
              mode ?? "",
              teamType,
            );
            onDismiss();
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightGrey, width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- HEADER ----------
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    // gradient: AppColors.mainGradient,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if ((data?.flexibleContest ?? "0") == "1" ||
                                  data?.compress == true)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.trending_up_rounded,
                                      size: 16.sp,
                                      color: AppColors.black,
                                    ),
                                    4.horizontalSpace,
                                    Text(
                                      Strings.flexiblePrizePool,
                                      style: GoogleFonts.exo2(
                                        color: AppColors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                  ],
                                )
                              else if (data?.confirmedChallenge == 1)
                                Row(
                                  children: [
                                    Image.asset(
                                      Images.verified,
                                      height: 16.h,
                                      width: 16.w,
                                      color: AppColors.black,
                                    ),
                                    4.horizontalSpace,
                                    Text(
                                      Strings.guaranteePrizePool,
                                      style: GoogleFonts.exo2(
                                        color: AppColors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Text(
                                  Strings.prizePool,
                                  style: GoogleFonts.exo2(
                                    color: AppColors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13.sp,
                                  ),
                                ),
                            ],
                          ),
                          5.verticalSpace,
                          Text(
                            '${Strings.indianRupee}${AppUtils.changeNumberToValue(data?.winAmount?.toInt() ?? 0)}',
                            style: GoogleFonts.tomorrow(
                              color: AppColors.blackColor,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if ((data?.discountFee ?? 0) != 0)
                            Row(
                              children: [
                                Image.asset(
                                  Images.matchToken,
                                  height: 10,
                                ),
                                Text(
                                  "${data?.entryfee}",
                                  style: GoogleFonts.tomorrow(
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: AppColors.black,
                                    color: AppColors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          _joinButton(context),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GradientProgressBar(
                        percent: percent,
                        gradient: AppColors.progressGradeint,
                        backgroundColor: AppColors.editTextColor,
                      ),
                      6.verticalSpace,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            ((data?.maximumUser ?? 0) ==
                                    (data?.joinedusers ?? 0))
                                ? "Contest Full"
                                : '${(data?.maximumUser ?? 0).toInt() - (data?.joinedusers ?? 0)} Spots Left',
                            style: GoogleFonts.roboto(
                              color: AppColors.mainColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 11.sp,
                            ),
                          ),
                          Text(
                            '${data?.maximumUser?.toInt()} Spots',
                            style: GoogleFonts.roboto(
                              color: AppColors.greyColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ---------- FOOTER ----------
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            _infoChip(
                              icon:
                                  //  data?.multiEntry == 1
                                  // ?
                                  Icons.groups_2,
                              // : Icons.person_outline,
                              label: data?.multiEntry == 1
                                  ? "Upto ${data?.maximumUser}"
                                  : "Upto 5",
                            ),
                            8.horizontalSpace,
                            _infoChip(
                              icon: Icons.emoji_events_outlined,
                              label:
                                  "${(((data?.totalwinners ?? 1) / (data?.maximumUser ?? 1)) * 100).round()}%",
                            ),
                          ],
                        ),
                      ),
                      // ---------- MAIN BODY ----------
                      // Expanded(
                      //   child: Padding(
                      //     padding: const EdgeInsets.symmetric(
                      //         horizontal: 16, vertical: 5),
                      //     child: Column(
                      //       crossAxisAlignment: CrossAxisAlignment.start,
                      //       children: [
                      //         Row(
                      //           mainAxisAlignment:
                      //               MainAxisAlignment.spaceBetween,
                      //           children: [
                      //             Text(
                      //               ((data?.maximumUser ?? 0) ==
                      //                       (data?.joinedusers ?? 0))
                      //                   ? "Contest Full"
                      //                   : '${(data?.maximumUser ?? 0).toInt() - (data?.joinedusers ?? 0)} Spots Left',
                      //               style: GoogleFonts.roboto(
                      //                 color: AppColors.red,
                      //                 fontWeight: FontWeight.w600,
                      //                 fontSize: 11,
                      //               ),
                      //             ),
                      //             Text(
                      //               '${data?.maximumUser?.toInt()} Spots',
                      //               style: GoogleFonts.roboto(
                      //                 color: AppColors.greyColor,
                      //                 fontWeight: FontWeight.w500,
                      //                 fontSize: 11,
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //         const SizedBox(height: 6),
                      //         GradientProgressBar(
                      //           percent: percent,
                      //           gradient: AppColors.progressGradeint,
                      //           backgroundColor: AppColors.editTextColor,
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.yellow.shade50,
                              Colors.yellow.shade100,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          // border: Border.all(color: AppColors.whiteFade1),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.looks_one_outlined,
                                size: 14.sp, color: Colors.orange.shade900),
                            3.horizontalSpace,
                            Text(
                              '${Strings.indianRupee}${AppUtils.changeNumberToValue(data?.winAmount?.toInt() ?? 0)}',
                              style: GoogleFonts.exo2(
                                color: Colors.orange.shade900,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
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
        ),

        // ---------- BONUS RIBBON ----------
        if (data?.isBonus == 1)
          Positioned(
            top: -2,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: AppColors.mainGradient,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mainLightColor.withValues(alpha: 0.25),
                    blurRadius: 8.r,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child:
              (data?.bonusType == "flat")?
              Row(
                children: [
                  Text('Flat ',
                          style: GoogleFonts.exo2(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 11.sp,
                          ),
                        ),
                        Image.asset(Images.matchToken,height: 10,),
                        Text(
                          '${data?.bonusPercentage} off',
                          style: GoogleFonts.exo2(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 11.sp,
                          ),
                        ),
                ],
              )
              : Text(
                 '${data?.bonusPercentage}% Bonus',
                style: GoogleFonts.exo2(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 11.sp,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// small info chip design
  Widget _infoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        // gradient: const LinearGradient(
        //   colors: [Color(0xFFF9FAFB), Color(0xFFF0F3F8)],
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        // ),
        borderRadius: BorderRadius.circular(8),
        // border: Border.all(color: AppColors.whiteFade1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15.sp, color: AppColors.mainColor),
          3.horizontalSpace,
          Text(
            label,
            style: GoogleFonts.exo2(
              color: AppColors.black,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// gradient premium join button
  Widget _joinButton(BuildContext context) {
    return InkWell(
      onTap: () {
        AppSingleton().contestData = data!;
        if (data!.isselected!) {
          String text = AppSingleton.singleton.appData.contestsharemessage!
              .replaceFirst(
                "%TeamName%",
                Provider.of<UserDataProvider>(
                      context,
                      listen: false,
                    ).userData?.team ??
                    "",
              )
              .replaceFirst(
                "%Team1%",
                AppSingleton.singleton.matchData.team1Name!,
              )
              .replaceFirst(
                "%Team2%",
                AppSingleton.singleton.matchData.team2Name!,
              )
              .replaceFirst("%AppName%", APIServerUrl.appName)
              .replaceFirst("%url_share%", '')
              .replaceFirst("%inviteCode%", data?.refercode ?? "");
          SharePlus.instance.share(ShareParams(text: text));
        } else {
          if (data?.isPromoCodeContest ?? false) {
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              builder: (BuildContext context) {
                return JoinCouponContestBottomsheet(
                  data: data,
                  onDismiss: onDismiss,
                  previousJoined: previousJoined,
                );
              },
            );
          } else if ((data?.conditionalContest ?? 0) == 1) {
            checkForMandatoryContest(context, data?.mandatoryContest ?? '');
          } else {
            joinContest(context);
          }
        }
      },
      child: Container(
        height: 30.h,
        width: 100.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: AppColors.appBarGradient,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              (data?.isselected == true)
                  ? Text('')
                  : ((data?.entryfee ?? 0) - (data?.discountFee ?? 0) == 0)
                      ? Text('')
                      : Image.asset(
                          Images.matchToken,
                          height: 18,
                        ),
              Text(
                (data?.isselected == true)
                    ? 'Invite'
                    : ((data?.entryfee ?? 0) - (data?.discountFee ?? 0) == 0)
                        ? 'Free'
                        : '${AppUtils.stringifyNumber((data?.entryfee ?? 0) - (data?.discountFee ?? 0))} ',
                style: GoogleFonts.tomorrow(
                  color: AppColors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SingleJoinedContest extends StatefulWidget {
  final AllNewContestResponseModel data;
  const SingleJoinedContest({super.key, required this.data});

  @override
  State<SingleJoinedContest> createState() => _SingleJoinedContestState();
}

class _SingleJoinedContestState extends State<SingleJoinedContest> {
  bool collapsed = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                collapsed = !collapsed;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    'Joined with ${widget.data.totalJoinedcontest} teams',
                    style: GoogleFonts.exo2(
                      color: AppColors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
                Icon(
                  collapsed ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                  color: AppColors.black,
                ),
              ],
            ),
          ),
          if (!collapsed)
            SizedBox(
              height: 40.h,
              child: Align(
                alignment: Alignment.topLeft,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.data.userTeams?.length,
                  itemBuilder: (context, index) {
                    var teamData = widget.data.userTeams![index];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 3,
                        horizontal: 5,
                      ),
                      margin: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.whiteFade1.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          'T${teamData.teamnumber}',
                          style: GoogleFonts.exo2(
                            color: AppColors.black,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
