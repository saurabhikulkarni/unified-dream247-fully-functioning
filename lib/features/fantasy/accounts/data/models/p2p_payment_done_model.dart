import 'package:unified_dream247/features/fantasy/core/utils/model_parsers.dart';

class P2pPaymentDoneModel {
  String? mobile;
  String? name;
  num? amountTransferred;
  num? tdsDeducted;
  num? cashbackReceived;
  num? receivedAmount;
  String? transactionId;
  String? transactionType;
  String? dateTime;
  bool? note;
  String? noteText;

  P2pPaymentDoneModel({
    this.mobile,
    this.name,
    this.amountTransferred,
    this.tdsDeducted,
    this.cashbackReceived,
    this.receivedAmount,
    this.transactionId,
    this.transactionType,
    this.dateTime,
    this.note,
    this.noteText,
  });

  factory P2pPaymentDoneModel.fromJson(Map<String, dynamic> json) =>
      P2pPaymentDoneModel(
        mobile: ModelParsers.toStringParser(json['mobile']),
        name: ModelParsers.toStringParser(json['name']),
        amountTransferred: ModelParsers.toNumParser(json['amountTransferred']),
        tdsDeducted: ModelParsers.toNumParser(json['tdsDeducted']),
        cashbackReceived: ModelParsers.toNumParser(json['cashbackReceived']),
        receivedAmount: ModelParsers.toNumParser(json['receivedAmount']),
        transactionId: ModelParsers.toStringParser(json['transactionId']),
        transactionType: ModelParsers.toStringParser(json['transactionType']),
        dateTime: ModelParsers.toStringParser(json['dateTime']),
        note: ModelParsers.toBoolParser(json['note']),
        noteText: ModelParsers.toStringParser(json['noteValue']),
      );
}
