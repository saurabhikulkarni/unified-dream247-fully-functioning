// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_urls.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_pages.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/app_toast.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/common_widgets.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/gradient_progress_bar.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_utils.dart';
import 'package:unified_dream247/features/fantasy/features/landing/data/singleton/app_singleton.dart';
import 'package:unified_dream247/features/fantasy/features/menu_items/presentation/providers/user_data_provider.dart';
import 'package:unified_dream247/features/fantasy/features/upcoming_matches/data/models/all_contests_model.dart';
import 'package:unified_dream247/features/fantasy/features/upcoming_matches/data/models/teams_model.dart';
import 'package:unified_dream247/features/fantasy/features/upcoming_matches/data/upcoming_match_datsource.dart';
import 'package:unified_dream247/features/fantasy/features/upcoming_matches/domain/use_cases/upcoming_match_usecase.dart';
import 'package:unified_dream247/features/fantasy/features/upcoming_matches/presentation/providers/myteams_provider.dart';
import 'package:unified_dream247/features/fantasy/features/upcoming_matches/presentation/widgets/join_contest_bottomsheet.dart';
import 'package:unified_dream247/features/fantasy/features/upcoming_matches/presentation/widgets/my_contest_list_view.dart';

class ContestDetailCard extends StatefulWidget {
  final AllContestResponseModel? data;
  final Function() onDismiss;
  final List<AllContestResponseModel> allContests;
  final String teamType;
  const ContestDetailCard({
    super.key,
    required this.data,
    required this.onDismiss,
    required this.allContests,
    required this.teamType,
  });

  @override
  State<ContestDetailCard> createState() => _ContestDetailCardState();
}

class _ContestDetailCardState extends State<ContestDetailCard> {
  bool previousJoined = false;
  UpcomingMatchUsecase upcomingMatchUsecase = UpcomingMatchUsecase(
    UpcomingMatchDatsource(ApiImpl(), ApiImplWithAccessToken()),
  );

  void checkForMandatoryContest(
    BuildContext context,
    String mandatoryContestID,
  ) async {
    List<AllContestResponseModel>? joinedContestList =
        await upcomingMatchUsecase.getJoinedContests(context, 0, 10);
    bool contestFound = false;
    for (var contest in joinedContestList!) {
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
      for (var contest in widget.allContests) {
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
        .getTeamswithChallengeId(context, widget.data?.id ?? "")
        .then((value) async {
      int count = 0;
      for (var i in value) {
        if (!i.isSelected!) {
          count++;
        } else {
          previousJoined = true;
        }
      }

      int limit = ((widget.data?.multiEntry ?? 0) == 1)
          ? (widget.data?.teamLimit ?? 1)
          : 1;
      int joinedTeams =
          value.where((element) => (element.isSelected ?? false)).length;

      if (limit == joinedTeams) {
        widget.data?.isselected = true;
        setState(() {});
      } else {
        if (count == 0) {
          await AppNavigation.gotoCreateTeamScreen(
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
            true,
            widget.teamType,
          ).then((value) {
            widget.onDismiss();
            return null;
          });
          List<TeamsModel> updatedTeams =
              await upcomingMatchUsecase.getMyTeams(context);
          Provider.of<MyTeamsProvider>(
            context,
            listen: false,
          ).updateMyTeams(
            updatedTeams,
            AppSingleton.singleton.matchData.id ?? "",
          );
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
                isClosedContestNew: false,
                previousJoined: previousJoined,
                challengeId: widget.data?.id ?? "",
                discount: widget.data?.discountFee ?? 0,
                isContestDetail: true,
                selectedTeam: value
                    .firstWhere((element) => !element.isSelected!)
                    .jointeamid!,
                removePage: () {
                  widget.onDismiss();
                },
                fantasyType: 'Cricket',
              );
            },
          );
        } else {
          await AppNavigation.gotoMyTeamsChallenges(
            context,
            widget.teamType,
            widget.data?.id ?? "",
            Provider.of<MyTeamsProvider>(
                  context,
                  listen: false,
                ).myTeams[AppSingleton.singleton.matchData.id] ??
                [],
            (widget.data?.multiEntry == 1)
                ? (widget.data?.isPromoCodeContest ?? false)
                    ? 1
                    : widget.data?.teamLimit ?? 0
                : 1,
            "Join Team",
            "",
            "",
            true,
            widget.data?.discountFee ?? 0,
            widget.data?.entryfee ?? 0,
          ).then((value) {
            widget.onDismiss();
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int percent = (widget.data?.joinedusers ?? 0) *
        100 ~/
        (widget.data?.maximumUser ?? 1);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ---------- MAIN CONTAINER ----------
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                            if ((widget.data?.flexibleContest ?? "0") == "1" ||
                                widget.data?.compress == true)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.trending_up_rounded,
                                    size: 16,
                                    color: AppColors.black,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    Strings.flexiblePrizePool,
                                    style: GoogleFonts.exo2(
                                      color: AppColors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              )
                            else if (widget.data?.confirmedChallenge == 1)
                              Row(
                                children: [
                                  Image.asset(
                                    Images.verified,
                                    height: 16,
                                    width: 16,
                                    color: AppColors.black,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    Strings.guaranteePrizePool,
                                    style: GoogleFonts.exo2(
                                      color: AppColors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
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
                                  fontSize: 13,
                                ),
                              ),
                          ],
                        ),
                        Text(
                          '${Strings.indianRupee}${AppUtils.changeNumberToValue(widget.data?.winAmount?.toInt() ?? 0)}',
                          style: GoogleFonts.tomorrow(
                            color: AppColors.blackColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if ((widget.data?.discountFee ?? 0) != 0 &&
                            widget.data?.isselected == false)
                          Row(
                            children: [
                              Image.asset(
                                Images.matchToken,
                                height: 10,
                              ),
                              Text(
                                "${widget.data?.entryfee}",
                                style: GoogleFonts.tomorrow(
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: AppColors.black,
                                  color: AppColors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        _joinButton(context),
                      ],
                    )
                  ],
                ),
              ),

              // ---------- FOOTER ----------

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
                          ((widget.data?.maximumUser ?? 0) ==
                                  (widget.data?.joinedusers ?? 0))
                              ? "Contest Full"
                              : '${(widget.data?.maximumUser ?? 0).toInt() - (widget.data?.joinedusers ?? 0)} Spots Left',
                          style: GoogleFonts.roboto(
                            color: AppColors.mainColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 11.sp,
                          ),
                        ),
                        Text(
                          '${widget.data?.maximumUser?.toInt()} Spots',
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
                  // color: AppColors.whiteFade1,
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
                                //  widget.data?.multiEntry == 1
                                // ?
                                Icons.groups_2,
                            // : Icons.person_outline,
                            label: widget.data?.multiEntry == 1
                                ? "Upto ${widget.data?.teamLimit}"
                                : "Upto 5",
                          ),
                          8.horizontalSpace,
                          _infoChip(
                            icon: Icons.emoji_events_outlined,
                            label:
                                "${(((widget.data?.totalwinners ?? 1) / (widget.data?.maximumUser ?? 1)) * 100).round()}%",
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
                            '${Strings.indianRupee}${AppUtils.changeNumberToValue(widget.data?.winAmount?.toInt() ?? 0)}',
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
              )
              // Container(
              //   padding: const EdgeInsets.symmetric(
              //     horizontal: 14,
              //     vertical: 5,
              //   ),
              //   decoration: BoxDecoration(
              //     color: AppColors.lightCard,
              //     borderRadius: const BorderRadius.vertical(
              //       bottom: Radius.circular(16),
              //     ),
              //   ),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       // ---- Left Info Chips with Tooltips ----
              //       Expanded(
              //         child: Row(
              //           children: [
              //             Tooltip(
              //               message: widget.data?.matchpricecards == null
              //                   ? 'First Prize = ${Strings.indianRupee}${AppUtils.changeNumberToValue(widget.data?.winAmount?.toInt() ?? 0)}'
              //                   : 'First Prize = ${Strings.indianRupee}${AppUtils.changeNumberToValue(widget.data?.matchpricecard?[0].price ?? 0)}',
              //               child: _infoChip(
              //                 icon: Icons.emoji_events_outlined,
              //                 label: (((widget.data?.totalwinners ?? 1) /
              //                                     (widget.data?.maximumUser ??
              //                                         1)) *
              //                                 100)
              //                             .round() <
              //                         1
              //                     ? "1%"
              //                     : "${(((widget.data?.totalwinners ?? 1) / (widget.data?.maximumUser ?? 1)) * 100).round()}%",
              //               ),
              //             ),
              //             const SizedBox(width: 8),
              //             Tooltip(
              //               message: widget.data?.multiEntry == 1
              //                   ? "Max ${widget.data?.teamLimit} entries per user"
              //                   : "Single entry contest",
              //               child: _infoChip(
              //                 icon: widget.data?.multiEntry == 1
              //                     ? Icons.group
              //                     : Icons.person_outline,
              //                 label: widget.data?.multiEntry == 1
              //                     ? "${widget.data?.teamLimit}"
              //                     : "S",
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //       Expanded(
              //         child: Padding(
              //           padding: const EdgeInsets.symmetric(
              //             horizontal: 16,
              //             vertical: 5,
              //           ),
              //           child: Column(
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: [
              //               Row(
              //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //                 children: [
              //                   Text(
              //                     ((widget.data?.maximumUser ?? 0) ==
              //                             (widget.data?.joinedusers ?? 0))
              //                         ? "Contest Full"
              //                         : '${(widget.data?.maximumUser ?? 0).toInt() - (widget.data?.joinedusers ?? 0)} Spots Left',
              //                     style: GoogleFonts.roboto(
              //                       color: AppColors.red,
              //                       fontWeight: FontWeight.w600,
              //                       fontSize: 11,
              //                     ),
              //                   ),
              //                   Text(
              //                     '${widget.data?.maximumUser?.toInt()} Spots',
              //                     style: GoogleFonts.roboto(
              //                       color: AppColors.greyColor,
              //                       fontWeight: FontWeight.w500,
              //                       fontSize: 11,
              //                     ),
              //                   ),
              //                 ],
              //               ),
              //               const SizedBox(height: 6),
              //               GradientProgressBar(
              //                 percent: percent,
              //                 gradient: AppColors.progressGradeint,
              //                 backgroundColor: AppColors.editTextColor,
              //               ),
              //             ],
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

              // ---- Joined Teams Section ----
              // if (widget.data?.userTeams != null &&
              //     widget.data!.userTeams!.isNotEmpty)
              //   SingleJoinedContest(data: widget.data!),
            ],
          ),
        ),

        // ---------- BONUS RIBBON ----------
        if (widget.data?.isBonus == 1)
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
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: (widget.data?.bonusType == "flat")
                  ? Row(
                      children: [
                        Text(
                          'Flat ',
                          style: GoogleFonts.exo2(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 11.sp,
                          ),
                        ),
                        Image.asset(
                          Images.matchToken,
                          height: 10,
                        ),
                        Text(
                          '${widget.data?.bonusPercentage} off',
                          style: GoogleFonts.exo2(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      '${widget.data?.bonusPercentage}% Bonus',
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
          Icon(icon, size: 15, color: AppColors.mainColor),
          const SizedBox(width: 3),
          Text(
            label,
            style: GoogleFonts.exo2(
              color: AppColors.black,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// gradient join button
  Widget _joinButton(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.data!.isselected!) {
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
              .replaceFirst("%inviteCode%", widget.data?.refercode ?? "");
          SharePlus.instance.share(ShareParams(text: text));
        } else {
          if (widget.data?.isPromoCodeContest ?? false) {
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              builder: (BuildContext context) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.all(5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 10, bottom: 3),
                            child: Text(
                              'Join Contest',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: AppColors.letterColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          customTextField(
                            codeController,
                            "Enter Contest code",
                            TextInputType.emailAddress,
                            0,
                            1,
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 20),
                            child: InkWell(
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
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else if ((widget.data?.conditionalContest ?? 0) == 1) {
            checkForMandatoryContest(
              context,
              widget.data?.mandatoryContest ?? '',
            );
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
              (widget.data?.isselected == true)
                  ? Text('')
                  : ((widget.data?.entryfee ?? 0) -
                              (widget.data?.discountFee ?? 0) ==
                          0)
                      ? Text('')
                      : Image.asset(
                          Images.matchToken,
                          height: 18,
                        ),
              Text(
                (widget.data?.isselected == true)
                    ? 'Invite'
                    : ((widget.data?.entryfee ?? 0) -
                                (widget.data?.discountFee ?? 0) ==
                            0)
                        ? 'Free'
                        : '${AppUtils.stringifyNumber((widget.data?.entryfee ?? 0) - (widget.data?.discountFee ?? 0))} ',
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

  TextEditingController codeController = TextEditingController();

  void showJoinContestDialog(
    BuildContext context,
    AllContestResponseModel data,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: FractionallySizedBox(
            heightFactor: 0.3,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 3),
                    child: Text(
                      'Join Contest',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.letterColor,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 3),
                    child: Text(
                      'Enter Contest Code',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: AppColors.letterColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  customTextField(
                    codeController,
                    "Enter Contest code",
                    TextInputType.emailAddress,
                    0,
                    1,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: InkWell(
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
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          gradient: AppColors.appBarGradient,
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
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
                true,
                widget.teamType,
              ).then((value) {
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
                    previousJoined: previousJoined,
                    challengeId: widget.data?.id ?? "",
                    selectedTeam: value
                        .firstWhere((element) => !element.isSelected!)
                        .jointeamid!,
                    discount: widget.data?.discountFee ?? 0,
                    isContestDetail: true,
                    removePage: () {
                      Navigator.of(context).pop();
                    },
                  );
                },
              );
            } else {
              await AppNavigation.gotoMyTeamsChallenges(
                context,
                widget.teamType,
                widget.data?.matchChallengeId ?? "",
                Provider.of<MyTeamsProvider>(
                      context,
                      listen: false,
                    ).myTeams[AppSingleton.singleton.matchData.id] ??
                    [],
                1,
                "Join Team",
                "",
                "",
                true,
                widget.data?.discountFee ?? 0,
                widget.data?.entryfee ?? 0,
              ).then((value) {
                widget.onDismiss();
              });
            }
          });
        }
      }
    });
  }
}
