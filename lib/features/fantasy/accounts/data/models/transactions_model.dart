import 'package:Dream247/core/utils/model_parsers.dart';

class TransactionsModel {
  List<TransactionData>? transactions;
  int? totalCount;

  TransactionsModel({this.transactions, this.totalCount});

  factory TransactionsModel.fromJson(Map<String, dynamic> json) =>
      TransactionsModel(
        transactions: json["transactions"] == null
            ? []
            : List<TransactionData>.from(
                json["transactions"]!.map((x) => TransactionData.fromJson(x)),
              ),
        totalCount: ModelParsers.toIntParser(json["totalCount"]),
      );
}

class TransactionData {
  String? id;
  String? type;
  String? transactionId;
  String? transactionType;
  String? amount;
  String? matchName;
  String? dateTime;
  String? txnid;
  String? paymentstatus;
  String? paymentmethod;
  String? statusDescription;
  String? utr;
  String? withdrawfrom;
  String? expiresAt;
  String? gstAmount;
  String? tdsAmount;
  String? cashback;

  TransactionData({
    this.id,
    this.type,
    this.transactionId,
    this.transactionType,
    this.amount,
    this.matchName,
    this.dateTime,
    this.txnid,
    this.paymentstatus,
    this.paymentmethod,
    this.statusDescription,
    this.utr,
    this.withdrawfrom,
    this.expiresAt,
    this.gstAmount,
    this.tdsAmount,
    this.cashback,
  });

  factory TransactionData.fromJson(Map<String, dynamic> json) =>
      TransactionData(
        id: ModelParsers.toStringParser(json["_id"]),
        type: ModelParsers.toStringParser(json["type"]),
        transactionId: ModelParsers.toStringParser(json["id"]),
        transactionType: ModelParsers.toStringParser(json["transaction_type"]),
        amount: ModelParsers.toStringParser(json["amount"]),
        matchName: ModelParsers.toStringParser(json["matchName"]),
        dateTime: ModelParsers.toStringParser(json["date_time"]),
        txnid: ModelParsers.toStringParser(json["txnid"]),
        paymentstatus: ModelParsers.toStringParser(json["paymentstatus"]),
        paymentmethod: ModelParsers.toStringParser(json["paymentmethod"]),
        statusDescription: ModelParsers.toStringParser(
          json["status_description"],
        ),
        utr: ModelParsers.toStringParser(json["utr"]),
        withdrawfrom: ModelParsers.toStringParser(json["withdrawfrom"]),
        expiresAt: ModelParsers.toStringParser(json["expiresAt"]),
        gstAmount: ModelParsers.toStringParser(json["gst_amount"]),
        tdsAmount: ModelParsers.toStringParser(json["tds_amount"]),
        cashback: ModelParsers.toStringParser(json["cashback"]),
      );
}
