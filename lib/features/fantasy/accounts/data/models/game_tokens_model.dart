import 'package:intl/intl.dart';

/// Game Tokens Model
/// Represents user's game tokens balance and transaction history
class GameTokens {
  final double balance;
  final List<Transaction> transactions;
  final DateTime lastUpdated;

  GameTokens({
    required this.balance,
    required this.transactions,
    required this.lastUpdated,
  });

  factory GameTokens.fromJson(Map<String, dynamic> json) {
    return GameTokens(
      balance: (json['balance'] ?? 0).toDouble(),
      transactions: (json['transactions'] as List?)
              ?.map((t) => Transaction.fromJson(t))
              .toList() ??
          [],
      lastUpdated: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'balance': balance,
        'transactions': transactions.map((t) => t.toJson()).toList(),
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  @override
  String toString() => 'GameTokens(balance: $balance, transactions: ${transactions.length})';
}

/// Transaction Model
/// Represents a single game token transaction
class Transaction {
  final double amount;
  final String type; // 'topup', 'debit', 'bonus', 'refund', 'add_money'
  final String description;
  final String transactionId;
  final DateTime createdAt;
  final String? status; // 'completed', 'pending', 'failed'

  Transaction({
    required this.amount,
    required this.type,
    required this.description,
    required this.transactionId,
    required this.createdAt,
    this.status = 'completed',
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      amount: (json['amount'] ?? 0).toDouble(),
      type: json['type'] ?? 'unknown',
      description: json['description'] ?? '',
      transactionId: json['transaction_id'] ?? json['transactionId'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : (json['createdAt'] != null
              ? DateTime.parse(json['createdAt'].toString())
              : DateTime.now()),
      status: json['status'] ?? 'completed',
    );
  }

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'type': type,
        'description': description,
        'transaction_id': transactionId,
        'created_at': createdAt.toIso8601String(),
        'status': status,
      };

  /// Format transaction for display
  String get formattedAmount {
    final prefix = type == 'debit' ? '-' : '+';
    return '$prefix₹${amount.toStringAsFixed(0)}';
  }

  /// Format date for display
  String get formattedDate {
    return DateFormat('MMM dd, yyyy HH:mm').format(createdAt);
  }

  /// Get transaction icon type
  String get iconType {
    switch (type) {
      case 'topup':
      case 'add_money':
        return 'add';
      case 'debit':
        return 'subtract';
      case 'bonus':
        return 'gift';
      case 'refund':
        return 'return';
      default:
        return 'transaction';
    }
  }

  @override
  String toString() => 'Transaction($type: $formattedAmount, $description)';
}
