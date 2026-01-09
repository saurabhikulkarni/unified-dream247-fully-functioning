import 'package:Dream247/core/utils/model_parsers.dart';

class ReferUserModel {
  String? id;
  String? referCode;
  String? username;
  String? image;
  String? team;
  int? totalrefercount;
  num? totalreferAmount;

  ReferUserModel({
    this.id,
    this.referCode,
    this.username,
    this.image,
    this.team,
    this.totalrefercount,
    this.totalreferAmount,
  });

  ReferUserModel.fromJson(Map<String, dynamic> json) {
    id = ModelParsers.toStringParser(json["_id"]);
    referCode = ModelParsers.toStringParser(json["refer_code"]);
    username = ModelParsers.toStringParser(json["username"]);
    image = ModelParsers.toStringParser(json["image"]);
    team = ModelParsers.toStringParser(json["team"]);
    totalrefercount = ModelParsers.toIntParser(json["totalrefercount"]);
    totalreferAmount = ModelParsers.toNumParser(json["totalreferAmount"]);
  }
}
