import 'package:unified_dream247/features/fantasy/core/utils/model_parsers.dart';

class TdsTransactionHistoryList {
  List<TdsTransactionData>? transactions;
  int? totalCount;

  TdsTransactionHistoryList({this.transactions, this.totalCount});

  factory TdsTransactionHistoryList.fromJson(Map<String, dynamic> json) =>
      TdsTransactionHistoryList(
        transactions: json['transactions'] == null
            ? []
            : List<TdsTransactionData>.from(
                json['transactions']!.map(
                  (x) => TdsTransactionData.fromJson(x),
                ),
              ),
        totalCount: ModelParsers.toIntParser(json['totalCount']),
      );
}

class TdsTransactionData {
  String? id;
  String? type;
  String? transactionId;
  String? amount;
  String? dateTime;

  TdsTransactionData({
    this.id,
    this.type,
    this.transactionId,
    this.amount,
    this.dateTime,
  });

  factory TdsTransactionData.fromJson(Map<String, dynamic> json) =>
      TdsTransactionData(
        id: ModelParsers.toStringParser(json['_id']),
        type: ModelParsers.toStringParser(json['type']),
        transactionId: ModelParsers.toStringParser(json['id']),
        amount: ModelParsers.toStringParser(json['amount']),
        dateTime: ModelParsers.toStringParser(json['date_time']),
      );
}
