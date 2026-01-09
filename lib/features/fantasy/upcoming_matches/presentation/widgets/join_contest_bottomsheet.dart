// ignore_for_file: use_build_context_synchronously, unrelated_type_equality_checks

import 'dart:ffi';

import 'package:Dream247/core/app_constants/images.dart';
import 'package:Dream247/core/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:Dream247/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:Dream247/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:Dream247/core/api_server_constants/api_server_urls.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';
import 'package:Dream247/core/app_constants/app_pages.dart';
import 'package:Dream247/core/app_constants/strings.dart';
import 'package:Dream247/core/global_widgets/app_toast.dart';
import 'package:Dream247/core/global_widgets/dashed_border.dart';
import 'package:Dream247/core/global_widgets/main_container.dart';
import 'package:Dream247/features/accounts/data/accounts_datasource.dart';
import 'package:Dream247/features/accounts/domain/use_cases/accounts_usecases.dart';
import 'package:Dream247/features/accounts/presentation/providers/wallet_details_provider.dart';
import 'package:Dream247/features/landing/data/singleton/app_singleton.dart';
import 'package:Dream247/features/menu_items/presentation/providers/user_data_provider.dart';
import 'package:Dream247/features/upcoming_matches/data/upcoming_match_datsource.dart';
import 'package:Dream247/features/upcoming_matches/domain/use_cases/upcoming_match_usecase.dart';
import 'package:Dream247/features/upcoming_matches/presentation/widgets/contest_filled_bottom_sheet.dart';

class JoinContestBottomsheet extends StatefulWidget {
  final String challengeId, selectedTeam;
  final String? totalWinners;
  final int? discount;
  final bool previousJoined;
  final bool isClosedContestNew;
  final String? winAmount;
  final String? maximumUser;
  final bool newTeam;
  final bool? isContestDetail;
  final Function() removePage;
  final String fantasyType;
  const JoinContestBottomsheet({
    super.key,
    required this.challengeId,
    required this.previousJoined,
    this.totalWinners,
    required this.selectedTeam,
    required this.removePage,
    this.discount,
    this.newTeam = false,
    this.isContestDetail,
    required this.isClosedContestNew,
    this.winAmount,
    this.maximumUser,
    required this.fantasyType,
  });

  @override
  State<JoinContestBottomsheet> createState() => _JoinContestBottomsheetState();
}

class _JoinContestBottomsheetState extends State<JoinContestBottomsheet> {
  num? usableBalance = 0,
      usertotalbalance = 0,
      entryfee = 0,
      bonus = 0,
      totalWinning = 0,
      totalBonus = 0,
      totalDeposit = 0,
      payableAmount = 0,
      usedBonus = 0,
      usedDeposit = 0,
      usedWinning = 0;
  bool isJoining = false;
  AccountsUsecases accountsUsecases = AccountsUsecases(
    AccountsDatasource(ApiImpl(), ApiImplWithAccessToken()),
  );
  UpcomingMatchUsecase upcomingMatchUsecase = UpcomingMatchUsecase(
    UpcomingMatchDatsource(ApiImpl(), ApiImplWithAccessToken()),
  );
  @override
  void initState() {
    super.initState();
    fetchBalance();
  }

  void fetchBalance() async {
    try {
      final response = await upcomingMatchUsecase.getUsableBalance(
        context,
        widget.challengeId,
        widget.selectedTeam.split(',').length,
        widget.discount ?? 0,
      );
      if (!mounted) return;

      final data = response?["data"];

      setState(() {
        usableBalance =
            num.tryParse(data['usablebalance']?.toString() ?? '0') ?? 0;
        usertotalbalance =
            num.tryParse(data['usertotalbalance']?.toString() ?? '0') ?? 0;
        entryfee = num.tryParse(data['entryfee']?.toString() ?? '0') ?? 0;
        totalWinning =
            num.tryParse(data['totalWinning']?.toString() ?? '0') ?? 0;
        totalBonus = num.tryParse(data['totalBonus']?.toString() ?? '0') ?? 0;
        totalDeposit =
            num.tryParse(data['totalDeposit']?.toString() ?? '0') ?? 0;

        usedBonus = num.tryParse(data['bonus']?.toString() ?? '0') ?? 0;
        usedDeposit =
            num.tryParse(data['deductFromBalance']?.toString() ?? '0') ?? 0;
        usedWinning =
            num.tryParse(data['deductFromWinning']?.toString() ?? '0') ?? 0;

        payableAmount = num.tryParse(
                data['requiredAdditionalBalance']?.toString() ?? '0') ??
            0;
      });

      // if (response != null) {
      //   setState(() {
      //     usableBalance = num.tryParse(response["data"]['usablebalance']) ?? 0;
      //     usertotalbalance =
      //         num.tryParse(response["data"]['usertotalbalance']) ?? 0;
      //     entryfee =
      //         num.tryParse(response["data"]['entryfee'].toString() ?? '0') ?? 0;
      //     totalWinning = num.tryParse(response["data"]['totalWinning']) ?? 0;
      //     totalBonus = num.tryParse(response["data"]['totalBonus']) ?? 0;
      //     totalDeposit = num.tryParse(response["data"]['totalDeposit']) ?? 0;
      //     usedBonus = num.tryParse(response["data"]['bonus']) ?? 0;
      //     usedDeposit =
      //         num.tryParse(response["data"]['deductFromBalance']) ?? 0;
      //     usedWinning =
      //         num.tryParse(response["data"]['deductFromWinning']) ?? 0;
      //     payableAmount =
      //         num.tryParse(response["data"]["requiredAdditionalBalance"]) ?? 0;
      //   });
      // }
    } catch (e) {
      printX("Error fetching balance: $e");
    }
  }

  void joinContest(BuildContext ctx) async {
    if (!mounted) return;
    setState(() => isJoining = true);

    final isVerified = Provider.of<WalletDetailsProvider>(
          context,
          listen: false,
        ).walletData?.allverify ==
        1;
    final isVerificationRequired =
        AppSingleton.singleton.appData.verificationOnJoinContest == true;

    final hasSufficientBalance = (usableBalance ?? 0) >= (entryfee ?? 0);

    // Wallet verification if required
    if (isVerificationRequired && !isVerified) {
      if (isVerified == -1) {
        await accountsUsecases.myWalletDetails(context);
      } else {
        appToast(
          "Please complete your verification to join the contest",
          context,
        );
        AppNavigation.gotoVerifyDetailsScreen(context).then((_) {
          if (mounted) setState(() => isJoining = false);
        });
      }
      return;
    }

    if (!hasSufficientBalance) {
      AppNavigation.gotoAddCashScreen(context);
      setState(() => isJoining = false);
      return;
    }

    await handleContestJoin(ctx);

    if (mounted) setState(() => isJoining = false);
  }

  Future<void> handleContestJoin(BuildContext context) async {
    try {
      final Map<String, dynamic>? data;
      if (widget.fantasyType == "Cricket") {
        if (widget.isClosedContestNew == true) {
          data = await upcomingMatchUsecase.closedContestJoin(
            context,
            (entryfee ?? 0).toInt(),
            int.parse(widget.winAmount ?? "0"),
            int.parse(widget.maximumUser ?? "1"),
            widget.discount.toString(),
            widget.selectedTeam,
          );
        } else {
          data = await upcomingMatchUsecase.joinContest(
            context,
            widget.challengeId,
            widget.discount ?? 0,
            widget.selectedTeam,
          );
        }
      } else {
        return;
      }

      if (data != null) {
        if (data["data"]?["is_private"] == 1) {
          sharePrivateContest(data["data"]["referCode"]);
        } else if (data["success"] == false && data["is_closed"] == true) {
          showContestFilledSheet(context, data);
        } else {
          widget.removePage();
          Navigator.of(context).pop();
          if (widget.fantasyType == "H2H") Navigator.of(context).pop();
        }
      } else {
        widget.removePage();
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
    } catch (e) {
      printX("Error joining contest: $e");
    }
  }

  void sharePrivateContest(String referCode) {
    final team =
        Provider.of<UserDataProvider>(context, listen: false).userData?.team ??
            "";
    final text = AppSingleton.singleton.appData.contestsharemessage!
        .replaceFirst("%TeamName%", team)
        .replaceFirst("%Team1%", AppSingleton.singleton.matchData.team1Name!)
        .replaceFirst("%Team2%", AppSingleton.singleton.matchData.team2Name!)
        .replaceFirst("%AppName%", APIServerUrl.appName)
        .replaceFirst("%url_share%", '')
        .replaceFirst("%inviteCode%", referCode);

    SharePlus.instance.share(ShareParams(text: text));
  }

  void showContestFilledSheet(BuildContext context, Map<String, dynamic> data) {
    Navigator.of(context).pop();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      showModalBottomSheet(
        isDismissible: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
        ),
        context: context,
        builder: (context) {
          return ContestFilledBottomSheet(
            totalWinners: widget.totalWinners ?? "",
            entryFee: data["data"]["entryfee"].toString(),
            winAmount: data["data"]["win_amount"].toString(),
            spots: data["data"]["maximum_user"].toString(),
            totalBonus: data["data"]["totalBonus"].toString(),
            discountFee: int.parse(data["data"]["discount_fee"]),
            joinTeamId: data["data"]["jointeamid"],
            previousJoined: widget.previousJoined,
            challengeId: widget.challengeId,
            isContestDetail: widget.isContestDetail,
            newTeam: widget.newTeam,
            onDismiss: widget.removePage,
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Wrap(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 5, bottom: 10),
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                        right: 15,
                        top: 10,
                        bottom: 15,
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Icon(
                              Icons.close,
                              color: AppColors.letterColor,
                              size: 25,
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                'Confirmation'.toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.letterColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 25),
                        ],
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(
                    //     horizontal: 15,
                    //     vertical: 10,
                    //   ),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       Row(
                    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //         children: [
                    //           const Text(
                    //             Strings.myBalance,
                    //             style: TextStyle(
                    //               color: AppColors.letterColor,
                    //               fontSize: 16,
                    //               fontWeight: FontWeight.w700,
                    //             ),
                    //           ),
                    //           Text(
                    //             "${Strings.indianRupee}$usertotalbalance",
                    //             style: GoogleFonts.tomorrow(
                    //               color: AppColors.letterColor,
                    //               fontSize: 16,
                    //               fontWeight: FontWeight.w700,
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //       const SizedBox(height: 5),
                    //       const Text(
                    //         "Unutilized Balance + Winning",
                    //         style: TextStyle(
                    //           color: AppColors.letterColor,
                    //           fontSize: 12,
                    //           fontWeight: FontWeight.w600,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    MainContainer(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  Strings.entryFee,
                                  style: TextStyle(
                                    color: AppColors.letterColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      Images.matchToken,
                                      height: 12,
                                    ),
                                    Text(
                                      "${(entryfee ?? 0) + (num.tryParse(widget.discount?.toString() ?? '0') ?? 0)}",
                                      style: GoogleFonts.tomorrow(
                                        color: AppColors.letterColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if ((usedBonus ?? 0) > 0)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    Strings.bonusCash,
                                    style: TextStyle(
                                      color: AppColors.letterColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "${Strings.indianRupee}$usedBonus",
                                    style: GoogleFonts.tomorrow(
                                      color: AppColors.letterColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          if ((usedDeposit ?? 0) > 0)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    Strings.deposit,
                                    style: TextStyle(
                                      color: AppColors.letterColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "${Strings.indianRupee}$usedDeposit",
                                    style: GoogleFonts.tomorrow(
                                      color: AppColors.letterColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          if ((usedWinning ?? 0) > 0)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    Strings.winning,
                                    style: TextStyle(
                                      color: AppColors.letterColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "${Strings.indianRupee}$usedWinning",
                                    style: GoogleFonts.tomorrow(
                                      color: AppColors.letterColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Game Token",
                                  style: TextStyle(
                                    color: AppColors.letterColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      Images.matchToken,
                                      height: 12,
                                    ),
                                    Text(
                                      "${totalBonus ?? 0}",
                                      style: GoogleFonts.tomorrow(
                                        color: AppColors.letterColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const DashedBorderContainer(
                            dashWidth: 5,
                            dashSpace: 6,
                            strokeWidth: 0.25,
                            color: AppColors.letterColor,
                            child: SizedBox(
                              width: double.infinity,
                              height: 0.5,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'To Pay',
                                  style: TextStyle(
                                    color: AppColors.green,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "${Strings.indianRupee}$payableAmount",
                                  style: GoogleFonts.tomorrow(
                                    color: AppColors.green,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      child: Text(
                        "By Joining this contest, you accept ${APIServerUrl.appName}'s T&C",
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.letterColor,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    InkWell(
                      onTap: isJoining ? null : () => joinContest(context),
                      child: Container(
                        margin: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 10,
                          bottom: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color:
                              isJoining ? AppColors.lightGrey : AppColors.green,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 10,
                        ),
                        child: Center(
                          child: isJoining
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(5.0),
                                    child: SizedBox(
                                      height: 30,
                                      width: 30,
                                      // child: LoadingIndicator(
                                      //   strokeWidth: 1.0,
                                      //   indicatorType:
                                      //       Indicator.lineSpinFadeLoader,
                                      //   backgroundColor: AppColors.transparent,
                                      //   pathBackgroundColor:
                                      //       AppColors.transparent,
                                      //   colors: [
                                      //     AppColors.letterColor,
                                      //     AppColors.greyColor,
                                      //   ],
                                      // ),
                                    ),
                                  ),
                                )
                              : Text(
                                  'Join Contest'.toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
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
      ),
    );
  }
}
