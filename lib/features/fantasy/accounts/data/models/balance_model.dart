import 'package:unified_dream247/features/fantasy/core/utils/model_parsers.dart';

class BalanceModel {
  String? balance;
  String? winning;
  String? bonus;
  String? totalamount;
  int? allverify;
  num? totalamountwon;
  num? totaljoinedcontest;
  num? totaljoinedmatches;
  num? totaljoinedseries;
  num? totalwoncontest;
  String? videoLink;

  BalanceModel({
    this.balance,
    this.winning,
    this.bonus,
    this.totalamount,
    this.allverify,
    this.totalamountwon,
    this.totaljoinedcontest,
    this.totaljoinedmatches,
    this.totaljoinedseries,
    this.totalwoncontest,
    this.videoLink,
  });

  factory BalanceModel.fromJson(Map<String, dynamic> json) => BalanceModel(
        balance: ModelParsers.toStringParser(json["balance"]),
        winning: ModelParsers.toStringParser(json["winning"]),
        bonus: ModelParsers.toStringParser(json["bonus"]),
        totalamount: ModelParsers.toStringParser(json["totalamount"]),
        allverify: ModelParsers.toIntParser(json["allverify"]),
        totalamountwon: ModelParsers.toNumParser(json["totalamountwon"]),
        totaljoinedcontest:
            ModelParsers.toNumParser(json["totaljoinedcontest"]),
        totaljoinedmatches:
            ModelParsers.toNumParser(json["totaljoinedmatches"]),
        totaljoinedseries: ModelParsers.toNumParser(json["totaljoinedseries"]),
        totalwoncontest: ModelParsers.toNumParser(json["totalwoncontest"]),
        videoLink: ModelParsers.toStringParser(json["videoLink"]),
      );
}
