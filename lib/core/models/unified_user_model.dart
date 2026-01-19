import 'package:equatable/equatable.dart';

/// Unified User Model for both Shop and Fantasy modules
/// 
/// This model represents a user across the entire Dream247 platform.
/// A single user can access both Shop and Fantasy features.
/// 
/// Key fields:
/// - [userId]: Primary ID from Hygraph (used for Shop operations)
/// - [fantasyUserId]: MongoDB ID from Fantasy backend (used for Fantasy API calls)
/// - [mobileNumber]: Phone number (unique identifier for login)
class UnifiedUserModel extends Equatable {
  /// Primary user ID from Hygraph (used as main identifier)
  final String userId;
  
  /// Fantasy backend user ID from MongoDB (for Fantasy API calls)
  final String? fantasyUserId;
  
  /// Mobile number (10 digits, used for OTP login)
  final String mobileNumber;
  
  /// User's first name
  final String firstName;
  
  /// User's last name
  final String lastName;
  
  /// Optional username
  final String? username;
  
  /// Email address (optional)
  final String? email;
  
  /// List of enabled modules: ['shop', 'fantasy']
  final List<String> modules;
  
  /// Whether Shop module is enabled for this user
  final bool shopEnabled;
  
  /// Whether Fantasy module is enabled for this user
  final bool fantasyEnabled;
  
  /// Current shop tokens balance
  final int shopTokens;
  
  /// Current game tokens balance (for Fantasy)
  final int gameTokens;
  
  /// Whether this is a newly created user
  final bool isNewUser;
  
  /// Profile image URL
  final String? profileImage;
  
  /// Account creation timestamp
  final DateTime? createdAt;
  
  /// Last update timestamp
  final DateTime? updatedAt;

  const UnifiedUserModel({
    required this.userId,
    this.fantasyUserId,
    required this.mobileNumber,
    required this.firstName,
    required this.lastName,
    this.username,
    this.email,
    required this.modules,
    required this.shopEnabled,
    required this.fantasyEnabled,
    required this.shopTokens,
    this.gameTokens = 0,
    required this.isNewUser,
    this.profileImage,
    this.createdAt,
    this.updatedAt,
  });

  /// Full name (firstName + lastName)
  String get fullName => '$firstName $lastName'.trim();

  /// Check if user has Shop access
  bool get hasShopAccess => shopEnabled && modules.contains('shop');

  /// Check if user has Fantasy access
  bool get hasFantasyAccess => fantasyEnabled && modules.contains('fantasy');

  /// Create UnifiedUserModel from JSON response
  factory UnifiedUserModel.fromJson(Map<String, dynamic> json) {
    return UnifiedUserModel(
      userId: json['userId'] ?? json['hygraph_user_id'] ?? json['id'] ?? '',
      fantasyUserId: json['fantasy_user_id'] ?? json['fantasyUserId'],
      mobileNumber: json['mobileNumber'] ?? json['mobile_number'] ?? json['phone'] ?? '',
      firstName: json['firstName'] ?? json['first_name'] ?? '',
      lastName: json['lastName'] ?? json['last_name'] ?? '',
      username: json['username'],
      email: json['email'],
      modules: List<String>.from(json['modules'] ?? ['shop']),
      shopEnabled: json['shop_enabled'] ?? json['shopEnabled'] ?? true,
      fantasyEnabled: json['fantasy_enabled'] ?? json['fantasyEnabled'] ?? false,
      shopTokens: (json['shopTokens'] as num?)?.toInt() ?? 
                  (json['shop_tokens'] as num?)?.toInt() ?? 0,
      gameTokens: (json['gameTokens'] as num?)?.toInt() ?? 
                  (json['game_tokens'] as num?)?.toInt() ?? 0,
      isNewUser: json['isNewUser'] ?? json['is_new_user'] ?? false,
      profileImage: json['profileImage'] ?? json['profile_image'],
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  /// Convert UnifiedUserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fantasy_user_id': fantasyUserId,
      'mobileNumber': mobileNumber,
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'email': email,
      'modules': modules,
      'shop_enabled': shopEnabled,
      'fantasy_enabled': fantasyEnabled,
      'shopTokens': shopTokens,
      'gameTokens': gameTokens,
      'isNewUser': isNewUser,
      'profileImage': profileImage,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  UnifiedUserModel copyWith({
    String? userId,
    String? fantasyUserId,
    String? mobileNumber,
    String? firstName,
    String? lastName,
    String? username,
    String? email,
    List<String>? modules,
    bool? shopEnabled,
    bool? fantasyEnabled,
    int? shopTokens,
    int? gameTokens,
    bool? isNewUser,
    String? profileImage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UnifiedUserModel(
      userId: userId ?? this.userId,
      fantasyUserId: fantasyUserId ?? this.fantasyUserId,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      email: email ?? this.email,
      modules: modules ?? this.modules,
      shopEnabled: shopEnabled ?? this.shopEnabled,
      fantasyEnabled: fantasyEnabled ?? this.fantasyEnabled,
      shopTokens: shopTokens ?? this.shopTokens,
      gameTokens: gameTokens ?? this.gameTokens,
      isNewUser: isNewUser ?? this.isNewUser,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    fantasyUserId,
    mobileNumber,
    firstName,
    lastName,
    username,
    email,
    modules,
    shopEnabled,
    fantasyEnabled,
    shopTokens,
    gameTokens,
    isNewUser,
    profileImage,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'UnifiedUserModel(userId: $userId, fantasyUserId: $fantasyUserId, '
        'mobileNumber: $mobileNumber, name: $fullName, '
        'modules: $modules, shopTokens: $shopTokens)';
  }
}
