import 'package:unified_dream247/features/fantasy/core/utils/model_parsers.dart';

class WalletPaymentDoneModel {
  String? winningTransactionId;
  String? depositTransactionId;
  num? transferredAmount;
  num? tds;
  num? cashback;
  num? receivedAmount;
  String? dateTime;

  WalletPaymentDoneModel({
    this.winningTransactionId,
    this.depositTransactionId,
    this.transferredAmount,
    this.tds,
    this.cashback,
    this.receivedAmount,
    this.dateTime,
  });

  factory WalletPaymentDoneModel.fromJson(Map<String, dynamic> json) =>
      WalletPaymentDoneModel(
        winningTransactionId: ModelParsers.toStringParser(
          json["winningTransactionId"],
        ),
        depositTransactionId: ModelParsers.toStringParser(
          json["depositTransactionId"],
        ),
        transferredAmount: ModelParsers.toNumParser(json["transferredAmount"]),
        tds: ModelParsers.toNumParser(json["tds"]),
        cashback: ModelParsers.toNumParser(json["cashback"]),
        receivedAmount: ModelParsers.toNumParser(json["receivedAmount"]),
        dateTime: ModelParsers.toStringParser(json["dateTime"]),
      );
}
