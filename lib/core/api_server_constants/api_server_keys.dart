/// API Server Keys for fantasy gaming backend

class ApiServerKeys {
  // Request Headers
  static const String authorization = 'Authorization';
  static const String contentType = 'Content-Type';
  static const String accept = 'Accept';
  static const String deviceId = 'X-Device-ID';
  static const String platform = 'X-Platform';
  
  // Common Response Keys
  static const String success = 'success';
  static const String message = 'message';
  static const String data = 'data';
  static const String error = 'error';
  static const String errorCode = 'errorCode';
  
  // Auth Keys
  static const String accessToken = 'accessToken';
  static const String refreshToken = 'refreshToken';
  static const String userId = 'userId';
  static const String phone = 'phone';
  static const String otp = 'otp';
  
  // User Keys
  static const String name = 'name';
  static const String email = 'email';
  static const String avatar = 'avatar';
  static const String username = 'username';
  
  // Match Keys
  static const String matchId = 'matchId';
  static const String team1 = 'team1';
  static const String team2 = 'team2';
  static const String matchTime = 'matchTime';
  static const String venue = 'venue';
  static const String series = 'series';
  static const String matchType = 'matchType';
  
  // Team Keys
  static const String teamId = 'teamId';
  static const String players = 'players';
  static const String captain = 'captain';
  static const String viceCaptain = 'viceCaptain';
  
  // Contest Keys
  static const String contestId = 'contestId';
  static const String entryFee = 'entryFee';
  static const String prizePool = 'prizePool';
  static const String totalSpots = 'totalSpots';
  static const String filledSpots = 'filledSpots';
  
  // Wallet Keys
  static const String balance = 'balance';
  static const String amount = 'amount';
  static const String transactionId = 'transactionId';
  static const String transactionType = 'transactionType';
  
  // KYC Keys
  static const String panNumber = 'panNumber';
  static const String aadharNumber = 'aadharNumber';
  static const String bankAccount = 'bankAccount';
  static const String ifscCode = 'ifscCode';
  static const String accountHolder = 'accountHolderName';
  
  // Pagination Keys
  static const String page = 'page';
  static const String limit = 'limit';
  static const String total = 'total';
}
