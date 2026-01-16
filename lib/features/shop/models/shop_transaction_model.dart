import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Shop Transaction Model
/// Represents a single shop wallet transaction
class ShopTransaction {
  final String id;
  final String type; // 'add_money', 'purchase', 'refund'
  final double amount; // positive for add, negative for deduct
  final String? description; // e.g., "Added 1000 RS", "Purchased T-shirt"
  final String? itemName; // e.g., "Blue T-shirt", "Cricket Game"
  final DateTime timestamp;
  final String status; // 'success', 'pending', 'failed'
  final String? referenceId; // razorpay order ID, product ID, etc.

  ShopTransaction({
    required this.id,
    required this.type,
    required this.amount,
    this.description,
    this.itemName,
    required this.timestamp,
    required this.status,
    this.referenceId,
  });

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'description': description,
      'itemName': itemName,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'referenceId': referenceId,
    };
  }

  /// Create from JSON
  factory ShopTransaction.fromJson(Map<String, dynamic> json) {
    return ShopTransaction(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String?,
      itemName: json['itemName'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: json['status'] as String,
      referenceId: json['referenceId'] as String?,
    );
  }

  @override
  String toString() {
    return 'ShopTransaction(id: $id, type: $type, amount: $amount, timestamp: $timestamp, status: $status)';
  }
}

/// Shop Transaction Manager
/// Handles storage and retrieval of shop transactions
class ShopTransactionManager {
  static const String _key = 'shop_transaction_history';

  /// Add a new transaction to history
  static Future<void> addTransaction({
    required String type,
    required double amount,
    String? description,
    String? itemName,
    String? referenceId,
    String status = 'success',
  }) async {
    try {
      final prefs = await _getPrefs();
      final transactions = await getTransactions();

      final newTransaction = ShopTransaction(
        id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        type: type,
        amount: amount,
        description: description,
        itemName: itemName,
        timestamp: DateTime.now(),
        status: status,
        referenceId: referenceId,
      );

      transactions.add(newTransaction);

      // Keep only last 100 transactions to avoid storage bloat
      if (transactions.length > 100) {
        transactions.removeRange(0, transactions.length - 100);
      }

      final jsonList = transactions.map((t) => jsonEncode(t.toJson())).toList();
      await prefs.setStringList(_key, jsonList);

      print('✅ [SHOP_TXN] Transaction added: ${newTransaction.id}');
    } catch (e) {
      print('❌ [SHOP_TXN] Error adding transaction: $e');
    }
  }

  /// Get all transactions
  static Future<List<ShopTransaction>> getTransactions() async {
    try {
      final prefs = await _getPrefs();
      final jsonList = prefs.getStringList(_key) ?? [];

      return jsonList
          .map((json) => ShopTransaction.fromJson(jsonDecode(json)))
          .toList()
          .reversed
          .toList(); // Newest first
    } catch (e) {
      print('❌ [SHOP_TXN] Error retrieving transactions: $e');
      return [];
    }
  }

  /// Get transactions by type
  static Future<List<ShopTransaction>> getTransactionsByType(String type) async {
    final all = await getTransactions();
    return all.where((t) => t.type == type).toList();
  }

  /// Get total spent on shopping
  static Future<double> getTotalSpent() async {
    final purchases = await getTransactionsByType('purchase');
    return purchases.fold<double>(0, (sum, t) => sum + (t.amount.abs()));
  }

  /// Get total added
  static Future<double> getTotalAdded() async {
    final added = await getTransactionsByType('add_money');
    return added.fold<double>(0, (sum, t) => sum + t.amount);
  }

  /// Clear all transactions (use with caution)
  static Future<void> clearAll() async {
    try {
      final prefs = await _getPrefs();
      await prefs.remove(_key);
      print('⚠️ [SHOP_TXN] All transactions cleared');
    } catch (e) {
      print('❌ [SHOP_TXN] Error clearing transactions: $e');
    }
  }

  /// Get SharedPreferences instance
  static Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }
}

/// Extension method for readable display
extension ShopTransactionDisplay on ShopTransaction {
  /// Get display text for transaction
  String getDisplayText() {
    switch (type) {
      case 'add_money':
        return '+$amount Shop Tokens (Added ${(amount).toStringAsFixed(0)} RS)';
      case 'purchase':
        return '-${amount.abs()} Shop Tokens (${itemName ?? 'Purchase'})';
      case 'refund':
        return '+$amount Shop Tokens (Refund for $itemName)';
      default:
        return '$amount tokens ($type)';
    }
  }

  /// Get icon for transaction type
  String getIcon() {
    switch (type) {
      case 'add_money':
        return '➕';
      case 'purchase':
        return '🛍️';
      case 'refund':
        return '↩️';
      default:
        return '📝';
    }
  }

  /// Get color indicator (positive = green, negative = red)
  bool isPositive() => amount > 0;
}
