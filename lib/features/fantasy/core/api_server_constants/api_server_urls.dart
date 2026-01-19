import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:unified_dream247/config/api_config.dart';

class APIServerUrl {
  static const String appName = "Dream247";
  static const String razorPayKey = "zKHU8Fuln1197fo21PYNmVbI";

  static const String getAppData = "get-version";
  static const String sendOtp = "add-temporary-user";
  static const String loginOtp = "verify-otp";
  static const String resendOtp = "otp-resend";
  static const String socialAuthentication = "social-authenticate";
  static const String getUserDetails = "user-complete-details";
  static const String popupNotify = "fetch-popup-notify";
  static const String getMainBanner = "fetch-main-banner";
  static const String getMatchlist = "fetch-match-list?filter=";
  static const String getMatchlistWithoutRedis = "fetch-match-list?filter=";
  static const String getTeamTypes = "team-types";
  static const String userContestTeamCount =
      "user-contest-team-count?matchkey=";
  static const String getAllNewContestsRedis =
      "fetch-all-new-contest-redis?matchkey=";
  static const String getAllContests = "fetch-all-contest?matchkey=";
  static const String getContestDetails =
      "fetch-contest-details?matchchallengeid=";
  static const String getJoinedContests = "user-join-contest?matchkey=";
  static const String getJoinedContestsRedis =
      "myjoinedcontestsRedis?matchkey=";
  static const String getMyTeams = "fetch-user-teams?matchkey=";
  static const String getUserTeam = "get-user-team?matchkey=";
  static const String getJoinedUpcomingMatches =
      "fetch-new-joined-matches?fantasy_type=";
  static const String getLiveMatches = "fetch-live-matches?fantasy_type=";
  static const String getCompletedMatches =
      "fetch-completed-matches-list?fantasy_type=";
  static const String getCompletedOldMatches =
      "fetch-completed-match-data?fantasy_type=";
  static const String userRecentMatches =
      "fetch-user-recent-matches?fantasy_type=";
  static const String getNotifications = "fetch-notifications";
  static const String getUserStory = "fetch-user-story";
  static const String getRecentWinner =
      "fetch-recent-winner?pageNumber=1&limit=10";
  static const String getAllPlayers = "fetch-all-players/";
  static const String joinContest = "contest-join";
  static const String closedContestJoin = "closed-join-contest";
  static const String getUsableBalance =
      "fetch-usable-balance?matchchallengeid=";
  static const String createTeam = "create-user-team";
  static const String switchTeam = "change-team";
  static const String dreamTeam = "fetch-dream-team/";
  static const String getGuruTeams = "fetch-guru-team?matchkey=";
  static const String liveGetMyTeams = "fetch-live-user-teams?matchkey=";
  static const String liveGetUserTeam = "get-user-live-team-data?matchkey=";
  static const String liveViewTeam = "live-show-team?matchkey=";
  static const String createPrivateContest = "create-private-contest";
  static const String joinContestByCode = "join-contest-by-code";
  static const String getPrivateContestPriceCard = "private-contest-price-card";
  static const String getTeamFilesPdf = "create-pdf-new?challengeid=";
  static const String getScorecard = "fetch-match-live-score-data?matchkey=";
  static const String teamCompare = "compare-team?team1id=";
  static const String getMatchLiveScore = "fetch-match-live-score/";
  static const String getMatchPlayerInfo = "fetch-player-info?matchkey=";
  static const String getPlayerPreviewInfo = "match-particular-player-info/";
  static const String getContestWinners = "fetch-recent-Contest/";
  static const String getSelfLeaderboard = "user-self-leaderboard?matchkey=";
  static const String getLeaderboardUpcoming = "user-leaderboard?matchkey=";
  static const String getSelfLiveLeaderboard =
      "/leaderboard-self-live-ranks?matchkey=";
  static const String getLiveRankLeaderboard =
      "leaderboard-live-ranks?matchkey=";
  static const String completeMatchGetMyTeams =
      "fetch-my-complete-match-teams?matchkey=";
  static const String getLeaderboardSeries = "fetch-leaderboard-data/";
  static const String getAllSeries = "fetch-all-series";
  static const String getFantasyPoints = "fetch-point-system-data";
  static const String requestPromoter = "post-promoter-data";
  static const String getAffiliateData = "fetch-promoter-data?startdate=";
  static const String getInvestorCategory = "fetch-investor-category";
  static const String getInvestorUserData =
      "fetch-investor-user-data?startDate=";
  static const String imageUploadUser = "upload-user-image";
  static const String sendAadhaarOTP = "adharcard-send-otp";
  static const String verifyAadhaarOTP = "adharcard-verify-otp";
  static const String verifyPanRequest = "pan-verification";
  static const String getBankDetails = "fetch-bank-details";
  static const String getKycDetails = "kyc-full-detail";
  static const String verifyBankRequest = "bank-verfication-req";
  static const String newRequestAddCash = "add-cash-new-request";
  static const String verifyRazorpayPayment = "razorPay-paymentverify";
  static const String openMysteryBox = "spinandwin";
  static const String requestwithdraw = "requestwithdraw";
  static const String tdsDeductionDetails = "tds-deduction-details";
  static const String tdsDashboard = "tds-dashboard";
  static const String winningToDeposit = "winning-to-deposist-transfer";
  static const String p2pUserValidation = "withdraw-p2p-validation?mobile=";
  static const String p2pSendOtp = "send-otp-p2p";
  static const String verifyp2pOtp = "withdraw-p2p-transfer";
  static const String getoffers = "fetch-offers";
  static const String tokenTier = "getTiers";
  static const String mytransactions = "my-transactions?type=";
  static const String mytransactionsredis = "my-redis-transaction?type=";
  static const String usersTransactionDetails =
      "my-detailed-transactions?transactionId=";
  static const String sabPaisaTxnResponse = "sabPaisa-callback";
  static const String phonePeTxnResponse = "/phonepay-callback/";
  static const String supportRequest = "help-desk-mail";
  static const String editProfile = "edit-user-profile";
  static const String getAllReferUsers = "get-all-user-refer-codes";
  // Note: Backend API has typo "refferals" (double-f) - keeping as-is for compatibility
  static const String getReferralDashboard = "user-refferals";
  static const String getLevelRewards = "fetch-user-level-data";
  static const String updateContestWon = "contest-won-update";
  static const String editTeamName = "edit-user-team-name";
  static const String myWalletDetails = "user-wallet-details";
  static const String fantasyscorecards = "fetch-fantasy-score-cards?matchkey=";
  static const String matchPlayerTeamsData = "match-players-team-data?teamid=";
  static const String matchplayerfantasyscorecards =
      "players-fantasy-score-cards?matchkey=";
  static const String getExpertAdvice = "expert-advice-list";

  // server urls with fallbacks (now using centralized ApiConfig)
  static String get kycServerUrl =>
      dotenv.env['KycServerUrl'] ?? ApiConfig.fantasyKycUrl;
  static String get leaderboardServerUrl =>
      dotenv.env['LeaderboardServerUrl'] ?? ApiConfig.fantasyLeaderboardUrl;
  static String get userServerUrl =>
      dotenv.env['UserServerUrl'] ?? ApiConfig.fantasyUserUrl;
  static String get teamsServerUrl =>
      dotenv.env['TeamsServerUrl'] ?? ApiConfig.fantasyTeamsUrl;
  static String get matchServerUrl =>
      dotenv.env['MatchServerUrl'] ?? ApiConfig.fantasyMatchUrl;
  static String get contestServerUrl =>
      dotenv.env['ContestServerUrl'] ?? ApiConfig.fantasyContestUrl;
  static String get depositServerUrl =>
      dotenv.env['DepositServerUrl'] ?? ApiConfig.fantasyDepositUrl;
  static String get withdrawServerUrl =>
      dotenv.env['WithdrawServerUrl'] ?? ApiConfig.fantasyWithdrawUrl;
  static String get joinContestServerUrl =>
      dotenv.env['JoinContestServerUrl'] ?? ApiConfig.fantasyJoinContestUrl;
  static String get liveMatchServerUrl =>
      dotenv.env['LiveMatchServerUrl'] ?? ApiConfig.fantasyLiveMatchUrl;
  static String get myJoinContestServerUrl =>
      dotenv.env['MyJoinContestServerUrl'] ?? ApiConfig.fantasyMyJoinContestUrl;
  static String get getMyTeamsServerUrl =>
      dotenv.env['MyTeamsServerUrl'] ?? ApiConfig.fantasyMyTeamsUrl;
  static String get completedMatchServerUrl =>
      dotenv.env['CompletedMatchServerUrl'] ?? ApiConfig.fantasyCompletedMatchUrl;
  static String get otherApiServerUrl =>
      dotenv.env['OtherApiServerUrl'] ?? ApiConfig.fantasyOtherUrl;
}
