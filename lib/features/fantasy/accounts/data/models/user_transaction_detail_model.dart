import 'package:unified_dream247/features/fantasy/core/utils/model_parsers.dart';

class UsersTransactionDetailsModel {
  String? id;
  String? userid;
  num? amount;
  String? paymentstatus;
  num? deposit;
  num? winning;
  num? bonus;
  num? totalEntry;
  String? date;
  num? spots;
  num? entryFee;
  num? prizePool;
  String? matchName;
  String? team1;
  String? team2;
  String? team1Logo;
  String? team2Logo;
  String? transactionId;
  String? teamName1;
  String? teamName2;

  UsersTransactionDetailsModel({
    this.id,
    this.userid,
    this.amount,
    this.paymentstatus,
    this.deposit,
    this.winning,
    this.bonus,
    this.totalEntry,
    this.date,
    this.spots,
    this.entryFee,
    this.prizePool,
    this.matchName,
    this.team1,
    this.team2,
    this.team1Logo,
    this.team2Logo,
    this.transactionId,
    this.teamName1,
    this.teamName2,
  });

  factory UsersTransactionDetailsModel.fromJson(Map<String, dynamic> json) =>
      UsersTransactionDetailsModel(
        id: ModelParsers.toStringParser(json["_id"]),
        userid: ModelParsers.toStringParser(json["userid"]),
        amount: ModelParsers.toNumParser(json["amount"]),
        paymentstatus: ModelParsers.toStringParser(json["paymentstatus"]),
        deposit: ModelParsers.toNumParser(json["deposit"]),
        winning: ModelParsers.toNumParser(json["winning"]),
        bonus: ModelParsers.toNumParser(json["bonus"]),
        totalEntry: ModelParsers.toNumParser(json["totalEntry"]),
        date: ModelParsers.toStringParser(json["Date"]),
        spots: ModelParsers.toNumParser(json["spots"]),
        entryFee: ModelParsers.toNumParser(json["entryFee"]),
        prizePool: ModelParsers.toNumParser(json["prizePool"]),
        matchName: ModelParsers.toStringParser(json["matchName"]),
        team1: ModelParsers.toStringParser(json["team1"]),
        team2: ModelParsers.toStringParser(json["team2"]),
        team1Logo: ModelParsers.toStringParser(json["team1Logo"]),
        team2Logo: ModelParsers.toStringParser(json["team2Logo"]),
        transactionId: ModelParsers.toStringParser(json["transaction_id"]),
        teamName1: ModelParsers.toStringParser(json["teamName1"]),
        teamName2: ModelParsers.toStringParser(json["teamName2"]),
      );
}
