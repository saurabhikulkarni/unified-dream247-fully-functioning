import 'package:unified_dream247/features/fantasy/core/utils/model_parsers.dart';

/// Model for Referral Dashboard Response
class ReferralDashboardModel {
  num? totalBalance;
  int? totalReferrals;
  num? totalCommission;
  List<ReferredUser>? referredUsers;
  List<CommissionTransaction>? commissionHistory;

  ReferralDashboardModel({
    this.totalBalance,
    this.totalReferrals,
    this.totalCommission,
    this.referredUsers,
    this.commissionHistory,
  });

  ReferralDashboardModel.fromJson(Map<String, dynamic> json) {
    totalBalance = ModelParsers.toNumParser(json['totalBalance']);
    totalReferrals = ModelParsers.toIntParser(json['totalReferrals']);
    totalCommission = ModelParsers.toNumParser(json['totalCommission']);
    
    if (json['referredUsers'] != null) {
      referredUsers = <ReferredUser>[];
      json['referredUsers'].forEach((v) {
        referredUsers!.add(ReferredUser.fromJson(v));
      });
    }
    
    if (json['commissionHistory'] != null) {
      commissionHistory = <CommissionTransaction>[];
      json['commissionHistory'].forEach((v) {
        commissionHistory!.add(CommissionTransaction.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['totalBalance'] = totalBalance;
    data['totalReferrals'] = totalReferrals;
    data['totalCommission'] = totalCommission;
    if (referredUsers != null) {
      data['referredUsers'] = referredUsers!.map((v) => v.toJson()).toList();
    }
    if (commissionHistory != null) {
      data['commissionHistory'] = commissionHistory!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

/// Model for individual referred user
class ReferredUser {
  String? id;
  String? username;
  String? mobile;
  String? image;
  String? team;
  String? referCode;
  num? depositAmount;
  num? commissionEarned;
  String? joinedDate;
  int? status;

  ReferredUser({
    this.id,
    this.username,
    this.mobile,
    this.image,
    this.team,
    this.referCode,
    this.depositAmount,
    this.commissionEarned,
    this.joinedDate,
    this.status,
  });

  ReferredUser.fromJson(Map<String, dynamic> json) {
    id = ModelParsers.toStringParser(json['_id'] ?? json['id']);
    username = ModelParsers.toStringParser(json['username']);
    mobile = ModelParsers.toStringParser(json['mobile']);
    image = ModelParsers.toStringParser(json['image']);
    team = ModelParsers.toStringParser(json['team']);
    referCode = ModelParsers.toStringParser(json['referCode'] ?? json['refer_code']);
    depositAmount = ModelParsers.toNumParser(json['depositAmount']);
    commissionEarned = ModelParsers.toNumParser(json['commissionEarned']);
    joinedDate = ModelParsers.toStringParser(json['joinedDate'] ?? json['createdAt']);
    status = ModelParsers.toIntParser(json['status']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['mobile'] = mobile;
    data['image'] = image;
    data['team'] = team;
    data['referCode'] = referCode;
    data['depositAmount'] = depositAmount;
    data['commissionEarned'] = commissionEarned;
    data['joinedDate'] = joinedDate;
    data['status'] = status;
    return data;
  }
}

/// Model for commission transaction history
class CommissionTransaction {
  String? id;
  String? transactionId;
  String? referredUserId;
  String? referredUsername;
  num? amount;
  num? commissionAmount;
  String? transactionType;
  String? transactionDate;
  String? description;
  int? status;

  CommissionTransaction({
    this.id,
    this.transactionId,
    this.referredUserId,
    this.referredUsername,
    this.amount,
    this.commissionAmount,
    this.transactionType,
    this.transactionDate,
    this.description,
    this.status,
  });

  CommissionTransaction.fromJson(Map<String, dynamic> json) {
    id = ModelParsers.toStringParser(json['_id'] ?? json['id']);
    transactionId = ModelParsers.toStringParser(json['transactionId']);
    referredUserId = ModelParsers.toStringParser(json['referredUserId']);
    referredUsername = ModelParsers.toStringParser(json['referredUsername']);
    amount = ModelParsers.toNumParser(json['amount']);
    commissionAmount = ModelParsers.toNumParser(json['commissionAmount']);
    transactionType = ModelParsers.toStringParser(json['transactionType'] ?? json['type']);
    transactionDate = ModelParsers.toStringParser(json['transactionDate'] ?? json['createdAt']);
    description = ModelParsers.toStringParser(json['description']);
    status = ModelParsers.toIntParser(json['status']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['transactionId'] = transactionId;
    data['referredUserId'] = referredUserId;
    data['referredUsername'] = referredUsername;
    data['amount'] = amount;
    data['commissionAmount'] = commissionAmount;
    data['transactionType'] = transactionType;
    data['transactionDate'] = transactionDate;
    data['description'] = description;
    data['status'] = status;
    return data;
  }
}
