/// API Server URLs for fantasy gaming backend
library;

class ApiServerUrls {
  // Base URLs
  static const String devBaseUrl = 'https://dev-api.dream247.com';
  static const String prodBaseUrl = 'https://api.dream247.com';
  
  // Current base URL (change based on environment)
  static String get baseUrl => devBaseUrl;
  
  // Authentication endpoints
  static const String login = '/auth/login';
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String register = '/auth/register';
  
  // User endpoints
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/update';
  static const String userStats = '/user/stats';
  
  // Match endpoints
  static const String upcomingMatches = '/matches/upcoming';
  static const String liveMatches = '/matches/live';
  static const String completedMatches = '/matches/completed';
  static const String matchDetails = '/matches/details';
  
  // Player endpoints
  static const String matchPlayers = '/players/match';
  static const String playerStats = '/players/stats';
  
  // Team endpoints
  static const String createTeam = '/teams/create';
  static const String updateTeam = '/teams/update';
  static const String myTeams = '/teams/my-teams';
  static const String teamDetails = '/teams/details';
  
  // Contest endpoints
  static const String allContests = '/contests/all';
  static const String joinContest = '/contests/join';
  static const String myContests = '/contests/my-contests';
  static const String leaderboard = '/contests/leaderboard';
  
  // Wallet endpoints
  static const String walletBalance = '/wallet/balance';
  static const String addMoney = '/wallet/add-money';
  static const String withdraw = '/wallet/withdraw';
  static const String transactions = '/wallet/transactions';
  static const String p2pTransfer = '/wallet/p2p-transfer';
  
  // KYC endpoints
  static const String kycDetails = '/kyc/details';
  static const String submitKyc = '/kyc/submit';
  static const String updateBankDetails = '/kyc/bank-details';
  
  // Live score endpoints
  static const String liveScore = '/live/score';
  static const String scorecard = '/live/scorecard';
  static const String playerLiveStats = '/live/player-stats';
  
  // Notification endpoints
  static const String registerDevice = '/notifications/register';
  static const String unregisterDevice = '/notifications/unregister';
  
  // Referral endpoints
  static const String referralCode = '/referral/code';
  static const String applyReferral = '/referral/apply';
  static const String referralStats = '/referral/stats';
}
