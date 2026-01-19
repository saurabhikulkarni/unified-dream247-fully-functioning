/// Auth Response Model
/// Returned after login/OTP verification
class AuthResponse {
  final bool success;
  final String? message;
  final String? accessToken;
  final String? refreshToken;
  final String? userId;
  final UserData? user;

  AuthResponse({
    required this.success,
    this.message,
    this.accessToken,
    this.refreshToken,
    this.userId,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['status'] == true || json['success'] == true,
      message: json['message'],
      accessToken: json['data']?['auth_key'] ?? json['authToken'] ?? json['token'],
      refreshToken: json['data']?['refresh_token'] ?? json['refreshToken'],
      userId: json['data']?['userid'] ?? json['userId'] ?? json['user']?['userId'],
      user: json['data'] != null 
          ? UserData.fromJson(json['data']) 
          : (json['user'] != null ? UserData.fromJson(json['user']) : null),
    );
  }

  @override
  String toString() {
    return 'AuthResponse(success: $success, userId: $userId, message: $message)';
  }
}

/// User Data Model
/// Contains user profile information from Fantasy backend
class UserData {
  final String id;
  final String mobile;
  final String? firstName;
  final String? lastName;
  final String? name;
  final String? username;
  final String? email;
  final String? referCode;
  final String? team;
  final String? profileImage;
  final bool shopEnabled;
  final bool fantasyEnabled;
  final List<String> modules;
  final WalletBalance? balance;
  final bool isNewUser;

  UserData({
    required this.id,
    required this.mobile,
    this.firstName,
    this.lastName,
    this.name,
    this.username,
    this.email,
    this.referCode,
    this.team,
    this.profileImage,
    this.shopEnabled = true,
    this.fantasyEnabled = true,
    this.modules = const ['shop', 'fantasy'],
    this.balance,
    this.isNewUser = false,
  });

  /// Full name (firstName + lastName or name)
  String get fullName {
    if (name != null && name!.isNotEmpty) return name!;
    return '$firstName $lastName'.trim();
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['userid'] ?? json['_id'] ?? json['userId'] ?? json['id'] ?? '',
      mobile: json['mobile']?.toString() ?? json['mobile_number'] ?? json['mobileNumber'] ?? '',
      firstName: json['first_name'] ?? json['firstName'],
      lastName: json['last_name'] ?? json['lastName'],
      name: json['name'],
      username: json['username'],
      email: json['email'],
      referCode: json['refer_code'] ?? json['referCode'],
      team: json['team'],
      profileImage: json['profile_image'] ?? json['profileImage'],
      shopEnabled: json['shop_enabled'] ?? json['shopEnabled'] ?? true,
      fantasyEnabled: json['fantasy_enabled'] ?? json['fantasyEnabled'] ?? true,
      modules: List<String>.from(json['modules'] ?? ['shop', 'fantasy']),
      balance: json['userbalance'] != null 
          ? WalletBalance.fromJson(json['userbalance'])
          : (json['balance'] != null ? WalletBalance.fromJson(json['balance']) : null),
      isNewUser: json['isNewUser'] ?? json['is_new_user'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userid': id,
      'mobile': mobile,
      'first_name': firstName,
      'last_name': lastName,
      'name': name,
      'username': username,
      'email': email,
      'refer_code': referCode,
      'team': team,
      'profile_image': profileImage,
      'shop_enabled': shopEnabled,
      'fantasy_enabled': fantasyEnabled,
      'modules': modules,
      'userbalance': balance?.toJson(),
      'isNewUser': isNewUser,
    };
  }

  @override
  String toString() {
    return 'UserData(id: $id, mobile: $mobile, name: $fullName)';
  }
}

/// Wallet Balance Model
/// Contains wallet balance breakdown
class WalletBalance {
  final double balance;
  final double winning;
  final double bonus;
  final double shopTokens;
  final double gameTokens;
  final double totalSpent;

  WalletBalance({
    this.balance = 0,
    this.winning = 0,
    this.bonus = 0,
    this.shopTokens = 0,
    this.gameTokens = 0,
    this.totalSpent = 0,
  });

  /// Total available balance
  double get total => balance + winning + bonus;

  /// Total fantasy balance (for game entry)
  double get fantasyTotal => balance + winning + bonus;

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      balance: (json['balance'] ?? 0).toDouble(),
      winning: (json['winning'] ?? 0).toDouble(),
      bonus: (json['bonus'] ?? 0).toDouble(),
      shopTokens: (json['shopTokens'] ?? json['shop_tokens'] ?? 0).toDouble(),
      gameTokens: (json['gameTokens'] ?? json['game_tokens'] ?? 0).toDouble(),
      totalSpent: (json['totalSpent'] ?? json['total_spent'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'winning': winning,
      'bonus': bonus,
      'shopTokens': shopTokens,
      'gameTokens': gameTokens,
      'totalSpent': totalSpent,
    };
  }

  @override
  String toString() {
    return 'WalletBalance(balance: $balance, winning: $winning, bonus: $bonus, shopTokens: $shopTokens)';
  }
}

/// Transaction Model
/// Represents a wallet transaction
class TransactionModel {
  final String id;
  final String type;
  final double amount;
  final String? description;
  final String? module; // 'shop' or 'fantasy'
  final String status;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    this.description,
    this.module,
    this.status = 'completed',
    required this.createdAt,
  });

  /// Check if transaction is positive (credit)
  bool get isCredit => amount > 0;

  /// Get display icon based on type
  String get icon {
    switch (type) {
      case 'add_money':
      case 'topup':
      case 'deposit':
        return '💰';
      case 'purchase':
      case 'debit':
        return '🛒';
      case 'contest_entry':
        return '🎮';
      case 'contest_won':
      case 'winning':
        return '🏆';
      case 'bonus':
        return '🎁';
      case 'refund':
        return '↩️';
      default:
        return '📝';
    }
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['_id'] ?? json['transaction_id'] ?? json['id'] ?? '',
      type: json['type'] ?? 'unknown',
      amount: (json['amount'] ?? 0).toDouble(),
      description: json['description'],
      module: json['module'],
      status: json['status'] ?? 'completed',
      createdAt: DateTime.tryParse(json['created_at'] ?? json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'description': description,
      'module': module,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
