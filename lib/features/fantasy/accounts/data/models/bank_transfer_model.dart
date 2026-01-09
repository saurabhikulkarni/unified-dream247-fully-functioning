import 'package:unified_dream247/features/fantasy/core/utils/model_parsers.dart';

class BankTransferModel {
  String? remainingBalance;
  String? remainingWinning;
  String? paymentstatus;
  String? username;
  num? mobile;
  String? amount;
  String? transactionId;
  String? tdsAmount;
  String? receiverAmount;
  String? dateTime;
  bool? note;
  String? noteText;

  BankTransferModel({
    this.remainingBalance,
    this.remainingWinning,
    this.paymentstatus,
    this.username,
    this.mobile,
    this.amount,
    this.transactionId,
    this.tdsAmount,
    this.receiverAmount,
    this.dateTime,
    this.note,
    this.noteText,
  });

  factory BankTransferModel.fromJson(Map<String, dynamic> json) =>
      BankTransferModel(
        remainingBalance: ModelParsers.toStringParser(json["remainingBalance"]),
        remainingWinning: ModelParsers.toStringParser(json["remainingWinning"]),
        paymentstatus: ModelParsers.toStringParser(json["paymentstatus"]),
        username: ModelParsers.toStringParser(json["username"]),
        mobile: ModelParsers.toNumParser(json["mobile"]),
        amount: ModelParsers.toStringParser(json["amount"]),
        transactionId: ModelParsers.toStringParser(json["transaction_id"]),
        tdsAmount: ModelParsers.toStringParser(json["tds_amount"]),
        receiverAmount: ModelParsers.toStringParser(json["receiverAmount"]),
        dateTime: ModelParsers.toStringParser(json["dateTime"]),
        note: ModelParsers.toBoolParser(json["note"]),
        noteText: ModelParsers.toStringParser(json["noteValue"]),
      );
}
