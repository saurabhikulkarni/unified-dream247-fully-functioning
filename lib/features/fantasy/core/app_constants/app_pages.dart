// import 'package:get/get.dart';
// import 'package:unified_dream247/features/fantasy/accounts/presentation/screens/my_balance_page.dart';
// import 'package:unified_dream247/features/fantasy/landing/presentation/screens/landing_page.dart';
// import 'package:unified_dream247/features/fantasy/menu_items/presentation/screens/edit_profile_page.dart';
// import 'package:unified_dream247/features/fantasy/onboarding/presentation/screens/login_screen.dart';
// import 'package:unified_dream247/features/fantasy/onboarding/presentation/screens/otp_verification_screen.dart';
// import 'package:unified_dream247/features/fantasy/onboarding/presentation/screens/splash.dart';
// import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/screens/contest_details.dart';
// import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/screens/contest_page.dart';
// import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/screens/create_team.dart';
// import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/screens/captain_vc.dart';

// import 'app_routes.dart';

// class AppPages {
//   static final pages = [
//     GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
//     // GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
//     // GetPage(name: AppRoutes.otp, page: () => OtpVerificationScreen(mobileNumber: ,),arguments: mobileNumber),
//     GetPage(name: AppRoutes.landing, page: () => const LandingPage()),
//     GetPage(name: AppRoutes.contest, page: () => ContestPage()),
//     GetPage(name: AppRoutes.contestDetails, page: () => ContestDetails()),
//     // GetPage(
//     //   name: AppRoutes.createPrivateContest,
//     //   page: () => const CreatePrivateContest(),
//     // ),
//     GetPage(
//       name: AppRoutes.createTeam,
//       page:
//           () => CreateTeam(
//             // teamNumber: 0,
//             // edit: false,
//             // matchKey: '',
//             // challengeId: null,
//             // isGuru: null,
//             // guruTeamId: null,
//             // previousPlayers: null,
//             // captainId: null,
//             // viceCaptainId: null,
//             // discount: null,
//             // isContestDetail: false,
//           ),
//     ),
//     GetPage(
//       name: AppRoutes.captainVc,
//       page:
//           () => CaptainViceCaptain(
//             // hasChanges: false,
//             // updateHasChanges: null,
//             // teamNumber: 0,
//             // discount: null,
//             // isGuru: 0,
//             // guruTeamId: '',
//             // challengeId: '',
//             // isContestDetail: false,
//           ),
//     ),
//     //     GetPage(name: AppRoutes.playerDetails, page: () => PlayerDetails()),
//     //     GetPage(
//     //       name: AppRoutes.myTeamsChallenges,
//     //       page:
//     //           () => MyTeamsChallenges(
//     //             challengeId: '',
//     //             list: const [],
//     //             maxTeams: 0,
//     //             mode: '',
//     //             leagueId: null,
//     //             leaderboardId: null,
//     //             isContestDetail: false,
//     //             discount: null,
//     //             entryfee: 0,
//     //           ),
//     //     ),
//     //     GetPage(
//     //       name: AppRoutes.preview,
//     //       page:
//     //           () => Preview(
//     //             joinTeamId: null,
//     //             multiplyPoints: null,
//     //             data: null,
//     //             title: null,
//     //             mode: '',
//     //             teamnumber: null,
//     //             hasEdited: null,
//     //             userId: '',
//     //           ),
//     //     ),
//     //     GetPage(
//     //       name: AppRoutes.liveMatchDetails,
//     //       page:
//     //           () => LiveMatchDetails(
//     //             mode: '',
//     //             isViewingOldMatches: false,
//     //             totalContestCount: null,
//     //             gameType: null,
//     //           ),
//     //     ),
//     //     GetPage(
//     //       name: AppRoutes.liveContestDetails,
//     //       page: () => ContestLiveDetails(),
//     //     ),
//     //     GetPage(
//     //       name: AppRoutes.teamCompare,
//     //       page:
//     //           () => TeamCompare(
//     //             team1Id: '',
//     //             team2Id: '',
//     //             userId: '',
//     //             challengeId: '',
//     //             l1: '',
//     //             l2: '',
//     //           ),
//     //     ),
//     //     GetPage(name: AppRoutes.profile, page: () => const Profile()),
//     //     GetPage(name: AppRoutes.editProfile, page: () => const EditProfile()),
//     //     GetPage(name: AppRoutes.myBalance, page: () => const MyBalancePage()),
//     //     GetPage(name: AppRoutes.addCash, page: () => const Recharge()),
//     //     GetPage(name: AppRoutes.promoCodes, page: () => PromoCodes()),
//     //     GetPage(
//     //       name: AppRoutes.razorPayPg,
//     //       page:
//     //           () => RazorPayPAymentGateway(
//     //             amount: '',
//     //             orderId: '',
//     //             paymentMethod: '',
//     //           ),
//     //     ),
//     //     GetPage(name: AppRoutes.transactions, page: () => const Transactions()),
//     //     GetPage(name: AppRoutes.referEarn, page: () => const ReferEarn()),
//     //     GetPage(name: AppRoutes.notifications, page: () => const Notifications()),
//     //     GetPage(
//     //       name: AppRoutes.storyPage,
//     //       page: () => StoryPage(stories: const [], index: 0),
//     //     ),
//     //     GetPage(name: AppRoutes.winnersDetail, page: () => WinnersDetailScreen()),
//     //     GetPage(name: AppRoutes.textScreen, page: () => const TextScreen()),
//     //     GetPage(
//     //       name: AppRoutes.seriesLeaderboardUsers,
//     //       page:
//     //           () => SeriesLeaderboardUsers(
//     //             seriesId: '',
//     //             seriesName: '',
//     //             priceCard: const [],
//     //           ),
//     //     ),
//     //     GetPage(name: AppRoutes.referUserList, page: () => const ReferUsersList()),
//     //     GetPage(name: AppRoutes.settings, page: () => const Settings()),
//     //     GetPage(name: AppRoutes.fantasyPoints, page: () => FantasyPointsSystem()),
//     //     GetPage(
//     //       name: AppRoutes.webview,
//     //       page: () => CustomWebView(title: '', url: ''),
//     //     ),
//     //     GetPage(name: AppRoutes.support, page: () => const Support()),
//     //     GetPage(name: AppRoutes.promoteApp, page: () => const PromoteApp()),
//     //     GetPage(
//     //       name: AppRoutes.investmentLeaderboard,
//     //       page: () => const InvestmentLeaderboard(),
//     //     ),
//     //     GetPage(
//     //       name: AppRoutes.investmentLeaderboardUsers,
//     //       page: () => InvestmentLeaderboardUsers(),
//     //     ),
//     //     GetPage(
//     //       name: AppRoutes.verifyDetails,
//     //       page: () => const VerifyDetailsScreen(),
//     //     ),
//     //     GetPage(
//     //       name: AppRoutes.paymentMethod,
//     //       page: () => PaymentMethodScreen(amount: '', promoId: ''),
//     //     ),
//     //     GetPage(name: AppRoutes.tdsDetails, page: () => const TdsDetailsScreen()),
//     //     GetPage(
//     //       name: AppRoutes.transactionDetails,
//     //       page: () => TransactionDetailsScreen(transactionId: '', type: ''),
//     //     ),
//     //     GetPage(name: AppRoutes.withdraw, page: () => const WithdrawScreen()),
//     //     GetPage(
//     //       name: AppRoutes.bankPaymentSuccess,
//     //       page: () => BankPaymentSuccessDone(),
//     //     ),
//     //     GetPage(
//     //       name: AppRoutes.walletPaymentSuccess,
//     //       page: () => WalletPaymentSuccessDone(),
//     //     ),
//     //     GetPage(
//     //       name: AppRoutes.p2pPaymentSuccess,
//     //       page: () => PaymentSuccessDoneP2P(),
//     //     ),
//     //     GetPage(name: AppRoutes.addCashSuccess, page: () => AddCashSuccessDone()),
//     //     GetPage(
//     //       name: AppRoutes.paymentProcess,
//     //       page: () => PaymentProcess(paymentStatus: '', amount: ''),
//     //     ),
//   ];
// }

import 'package:flutter/material.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/models/bank_transfer_model.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/models/p2p_payment_done_model.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/models/wallet_payment_done_model.dart';
import 'package:unified_dream247/features/fantasy/accounts/presentation/screens/add_money_page.dart';
import 'package:unified_dream247/features/fantasy/accounts/presentation/screens/my_balance_page.dart';
import 'package:unified_dream247/features/fantasy/accounts/presentation/screens/my_transactions.dart';
import 'package:unified_dream247/features/fantasy/accounts/presentation/screens/promo_code.dart';
import 'package:unified_dream247/features/fantasy/accounts/presentation/screens/tds_details_screen.dart';
import 'package:unified_dream247/features/fantasy/accounts/presentation/screens/withdraw_screen.dart';
import 'package:unified_dream247/features/fantasy/accounts/presentation/widgets/bank_payment_success_done.dart';
import 'package:unified_dream247/features/fantasy/accounts/presentation/widgets/p2p_payment_success_done.dart';
import 'package:unified_dream247/features/fantasy/accounts/presentation/widgets/wallet_payment_success_done.dart';
import 'package:unified_dream247/features/fantasy/landing/presentation/screens/landing_page.dart';
import 'package:unified_dream247/features/fantasy/landing/presentation/screens/notification_page.dart';
import 'package:unified_dream247/features/fantasy/menu_items/data/models/offers_model.dart';
import 'package:unified_dream247/features/fantasy/menu_items/presentation/screens/edit_profile_page.dart';
import 'package:unified_dream247/features/fantasy/menu_items/presentation/screens/refer_and_earn_page.dart';
import 'package:unified_dream247/features/fantasy/more_options/presentation/screens/about_us_page.dart';
import 'package:unified_dream247/features/fantasy/more_options/presentation/screens/fantasy_point_system.dart';
import 'package:unified_dream247/features/fantasy/more_options/presentation/screens/faq_page.dart';
import 'package:unified_dream247/features/fantasy/more_options/presentation/screens/how_to_play.dart';
import 'package:unified_dream247/features/fantasy/more_options/presentation/screens/privacy_policy_page.dart';
import 'package:unified_dream247/features/fantasy/more_options/presentation/screens/responsible_gaming.dart';
import 'package:unified_dream247/features/fantasy/more_options/presentation/screens/terms_conditions_page.dart';
import 'package:unified_dream247/features/fantasy/more_options/presentation/widgets/web_view.dart';
import 'package:unified_dream247/features/fantasy/my_matches/data/models/live_challenges_model.dart';
import 'package:unified_dream247/features/fantasy/my_matches/presentation/screens/contest_live_details.dart';
import 'package:unified_dream247/features/fantasy/my_matches/presentation/screens/live_match_details_screen.dart';
import 'package:unified_dream247/features/fantasy/my_matches/presentation/screens/team_compare.dart';
import 'package:go_router/go_router.dart';
import 'package:unified_dream247/config/routes/route_names.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/players_model.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/teams_model.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/user_teams_model.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/screens/captain_vc.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/screens/contest_details.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/screens/contest_page.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/screens/create_private_contest.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/screens/create_team.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/screens/my_teams_challenges.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/screens/player_details.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/screens/preview.dart';
import 'package:unified_dream247/features/fantasy/user_verification/presentation/screens/verify_details_page.dart';
import 'package:unified_dream247/features/fantasy/winners/data/models/winners_model.dart';
import 'package:unified_dream247/features/fantasy/winners/data/models/stories_model.dart';
import 'package:unified_dream247/features/fantasy/winners/presentation/screens/winners_detail.dart';
import 'package:unified_dream247/features/fantasy/winners/presentation/widgets/story_page.dart';

class AppNavigation {
  static Future<void> gotoSplashScreen(BuildContext context) async {
    // Navigate to shop splash screen (app entry point) using GoRouter
    if (context.mounted) {
      context.go(RouteNames.splash);
    }
  }

  static Future<void> gotoLoginScreen(BuildContext context) async {
    // Use GoRouter for navigation to login
    if (context.mounted) {
      context.go(RouteNames.login);
    }
  }

  // static gotoVerifyOtpScreen(
  //   BuildContext context,
  //   String tempUser,
  //   String mobileNumber,
  // ) async {
  //   return await Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder:
  //           (context) => OtpVerificationScreen(
  //             mobileNumber: mobileNumber,
  //             tempUser: tempUser,
  //           ),
  //     ),
  //   );
  // }

  static Future<dynamic> gotoLandingScreen(BuildContext context) async {
    return await Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LandingPage()),
      (Route<dynamic> route) => false,
    );
  }

  static Future<dynamic> gotoNotificationPage(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationPage()),
    );
  }

  static Future<dynamic> gotoLandingScreenReplacement(BuildContext context) async {
    return await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LandingPage()),
    );
  }

  static Future<dynamic> gotoUpcomingContestScreen(BuildContext context, String mode) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ContestPage(mode: mode)),
    );
  }

  static Future<dynamic> gotoUpcomingContestDetails(
    BuildContext context,
    String? matchChallengeId,
    String? mode,
    String teamType,
  ) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContestDetails(
          mode: mode,
          matchChallengeId: matchChallengeId,
          teamType: teamType,
        ),
      ),
    );
  }

  static Future<dynamic> gotoCreatePrivateContestScreen(
      BuildContext context, String teamType,) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CreatePrivateContest(
                teamType: teamType,
              ),),
    );
  }

  static Future<dynamic> gotoCreateTeamScreen(
    BuildContext context,
    int teamNumber,
    bool edit,
    String matchKey,
    String? challengeId,
    int? isGuru,
    String? guruTeamId,
    String? previouspLayers,
    String? captainId,
    String? viceCaptainId,
    int? discount,
    bool isContestDetail,
    String teamType,
  ) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTeam(
          teamNumber: teamNumber,
          edit: edit,
          matchKey: matchKey,
          challengeId: challengeId,
          isGuru: isGuru,
          guruTeamId: guruTeamId,
          previousPlayers: previouspLayers,
          captainId: captainId,
          viceCaptainId: viceCaptainId,
          discount: discount,
          isContestDetail: isContestDetail,
          teamType: teamType,
        ),
      ),
    );
  }

  static Future<dynamic> gotoCaptainViceCaptain(
    BuildContext context,
    bool? hasChanges,
    Function(bool)? updateHasChanges,
    int teamNumber,
    int? discount,
    int isGuru,
    String guruTeamId,
    String challengeId,
    bool isContestDetail,
    List<CreateTeamPlayersData> list,
    String teamType,
  ) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CaptainViceCaptain(
          hasChanges: hasChanges,
          updateHasChanges: updateHasChanges,
          teamNumber: teamNumber,
          discount: discount,
          isGuru: isGuru,
          guruTeamId: guruTeamId,
          challengeId: challengeId,
          isContestDetail: isContestDetail,
          list: list,
          teamType: teamType,
        ),
      ),
    );
  }

  static Future<dynamic> gotoPlayerDetails(
    BuildContext context,
    CreateTeamPlayersData data,
  ) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PlayerDetails(data: data)),
    );
  }

  static Future<dynamic> gotoMyTeamsChallenges(
    BuildContext context,
    String teamType,
    String challengeId,
    List<TeamsModel> data,
    int maxTeams,
    String mode,
    String? leagueId,
    String? leaderboardId,
    bool? isContestDetail,
    int? discount,
    num entryFee,
  ) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyTeamsChallenges(
          teamType: teamType,
          challengeId: challengeId,
          list: data,
          maxTeams: maxTeams,
          mode: mode,
          leagueId: leagueId,
          leaderboardId: leaderboardId,
          isContestDetail: isContestDetail,
          discount: discount,
          entryfee: entryFee,
        ),
      ),
    );
  }

  static Future<dynamic> gotoPreviewScreen(
    BuildContext context,
    String? joinTeamId,
    bool? multiplyPoints,
    List<UserTeamsModel>? data,
    String? title,
    String mode,
    int? teamNumber,
    bool? hasEdited,
    String userId,
  ) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Preview(
          joinTeamId: joinTeamId,
          multiplyPoints: multiplyPoints,
          data: data,
          title: title,
          mode: mode,
          teamnumber: teamNumber,
          hasEdited: hasEdited,
          userId: userId,
        ),
      ),
    );
  }

  static Future<dynamic> gotoLiveMatchDetails(
    BuildContext context,
    String gameMode,
    bool isViewingOldMatches,
    String? totalContestCount,
    String? gameType,
  ) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LiveMatchDetails(
          mode: gameMode,
          isViewingOldMatches: isViewingOldMatches,
          totalContestCount: totalContestCount,
          gameType: gameType,
        ),
      ),
    );
  }

  static Future<dynamic> gotoLiveContestDetails(
    BuildContext context,
    LiveChallengesData data,
    String? mode,
  ) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContestLiveDetails(data: data, mode: mode),
      ),
    );
  }

  static Future<dynamic> gotoTeamCompareScreen(
    BuildContext context,
    String team1Id,
    String team2Id,
    String userId,
    String challengeId,
    String l1,
    String l2,
  ) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeamCompare(
          team1Id: team1Id,
          team2Id: team2Id,
          userId: userId,
          challengeId: challengeId,
          l1: l1,
          l2: l2,
        ),
      ),
    );
  }

  //   static gotoProfileScreen(BuildContext context) async {
  //     return await Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => const Profile()),
  //     );
  //   }

  static Future<dynamic> gotoEditProfileScreen(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfile()),
    );
  }

  static Future<dynamic> gotoMyBalanceScreen(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyBalancePage()),
    );
  }

  static Future<dynamic> gotoAddCashScreen(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddMoneyPage()),
    );
  }

  static Future<dynamic> gotoPromoCodeScreen(
    BuildContext context,
    final String? amount,
    final bool? isApplied,
    final Future<List<OffersModel>?>? offerList,
  ) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PromoCode(
          amount: amount,
          isApplied: isApplied,
          offerList: offerList,
        ),
      ),
    );
  }

  // static gotoRazorPayPgScreen(
  //   BuildContext context,
  //   String amount,
  //   String orderId,
  //   String paymentMethod,
  // ) async {
  //   return await Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder:
  //           // (context) => RazorPayPAymentGateway(
  //           //   amount: amount,
  //           //   orderId: orderId,
  //           //   paymentMethod: paymentMethod,
  //           // ),
  //     ),
  //   );
  // }

  static Future<dynamic> gotoMyTransactionScreen(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyTransactions()),
    );
  }

  static Future<dynamic> gotoReferEarnScreen(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReferAndEarnPage()),
    );
  }

  // static gotoNotificationScreen(BuildContext context) async {
  //   return await Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const Notifications()),
  //   );
  // }

  static Future<dynamic> gotoStoryPage(
    BuildContext context,
    List<StoriesModel> stories,
    int index,
  ) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryPage(stories: stories, index: index),
      ),
    );
  }

  static Future<dynamic> gotoWinnersDetailScreen(
    BuildContext context,
    WinnersModel data,
  ) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WinnersDetail(
          data: data,
          winContestData: data.winContestData ?? [],
        ),
      ),
    );
  }

  //   static gotoSeriesLeaderboardUsers(
  //     BuildContext context,
  //     String seriesId,
  //     String seriesName,
  //     List<Matchpricecards> priceCard,
  //   ) async {
  //     return await Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder:
  //             (context) => SeriesLeaderboardUsers(
  //               seriesId: seriesId,
  //               seriesName: seriesName,
  //               priceCard: priceCard,
  //             ),
  //       ),
  //     );
  //   }

  //   static gotoReferUserListScreen(BuildContext context) async {
  //     return await Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => const ReferUsersList()),
  //     );
  //   }

  //   static gotoSettingScreen(BuildContext context) async {
  //     return await Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => const Settings()),
  //     );
  //   }

  static Future<dynamic> gotoFantasyPointSystem(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FantasyPointsSystem()),
    );
  }

  static Future<dynamic> gotoWebViewScreen(
    BuildContext context,
    String title,
    String url,
  ) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomWebView(title: title, url: url),
      ),
    );
  }

  //   static gotoSupportScreen(BuildContext context) async {
  //     return await Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => const Support()),
  //     );
  //   }

  //   static gotoPromoteOurAppScreen(BuildContext context) async {
  //     return await Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => const PromoteApp()),
  //     );
  //   }

  //   static gotoInvestmentLeaderboardScreen(BuildContext context) async {
  //     return await Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => const InvestmentLeaderboard()),
  //     );
  //   }

  //   static gotoInvestmentLeaderboardUsers(
  //     BuildContext context,
  //     String? startDate,
  //     String? endDate,
  //     String? contestName,
  //     List<Matchpricecards>? priceCard,
  //   ) async {
  //     return await Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder:
  //             (context) => InvestmentLeaderboardUsers(
  //               startDate: startDate,
  //               endDate: endDate,
  //               contestName: contestName,
  //               priceCard: priceCard,
  //             ),
  //       ),
  //     );
  //   }

  static Future<dynamic> gotoVerifyDetailsScreen(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VerifyDetailsPage()),
    );
  }

  // static gotoPaymentMethodScreen(
  //   BuildContext context,
  //   String amount,
  //   String promoId,
  // ) async {
  //   return await Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder:
  //           (context) => PaymentMethodScreen(amount: amount, promoId: promoId),
  //     ),
  //   );
  // }

  static Future<dynamic> gotoTdsDetailsScreen(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TdsDetailsScreen()),
    );
  }

  //   static gotoTransactionDetailsScreen(
  //     BuildContext context,
  //     String transactionId,
  //     String type,
  //   ) async {
  //     return await Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder:
  //             (context) => TransactionDetailsScreen(
  //               transactionId: transactionId,
  //               type: type,
  //             ),
  //       ),
  //     );
  //   }

  static Future<dynamic> gotoWithdrawScreen(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WithdrawScreen()),
    );
  }

  static Future<dynamic> gotoBankPaymentSuccessDone(
    BuildContext context,
    BankTransferModel data,
  ) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BankPaymentSuccessDone(data: data),
      ),
    );
  }

  static Future<dynamic> gotoWalletPaymentSuccessDone(
    BuildContext context,
    WalletPaymentDoneModel data,
  ) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WalletPaymentSuccessDone(data: data),
      ),
    );
  }

  static Future<dynamic> gotoPaymentSuccessDoneP2P(
    BuildContext context,
    P2pPaymentDoneModel data,
  ) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentSuccessDoneP2P(data: data),
      ),
    );
  }

  //   static gotoAddCashSuccessDone(
  //     BuildContext context,
  //     String? amount,
  //     String? txnStatus,
  //     String? txnId,
  //   ) async {
  //     return await Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder:
  //             (context) => AddCashSuccessDone(
  //               txnStatus: txnStatus,
  //               txnId: txnId,
  //               amount: amount,
  //             ),
  //       ),
  //     );
  //   }

  // static gotoPaymentProcess(
  //   BuildContext context,
  //   String paymentStatus,
  //   String amount,
  //   PaymentSuccessResponse? response,
  //   PaymentFailureResponse? failure,
  // ) async {
  //   return await Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder:
  //           (context) => PaymentProcess(
  //             paymentStatus: paymentStatus,
  //             amount: amount,
  //             success: response,
  //             failure: failure,
  //           ),
  //     ),
  //   );
  // }

  static Future<dynamic> gotoResponsibleGamingPage(BuildContext context) async {
    return await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ResponsibleGaming(),
        ),);
  }

  static Future<dynamic> gotoHowtoPlayPage(BuildContext context) async {
    return await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HowToPlay(),
        ),);
  }

  static Future<dynamic> gotoPrivacyPolicyPage(BuildContext context) async {
    return await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PrivacyPolicyPage(),
        ),);
  }

  static Future<dynamic> gotoFaqPage(BuildContext context) async {
    return await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const FaqPage(),
        ),);
  }

  static Future<dynamic> gotoAboutUsPage(BuildContext context) async {
    return await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AboutUsPage(),
        ),);
  }

  static Future<dynamic> gotoTermsConditionsPage(BuildContext context) async {
    return await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const TermsConditionsPage(),
        ),);
  }
}
