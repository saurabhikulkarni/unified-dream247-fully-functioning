import 'package:unified_dream247/features/fantasy/core/utils/model_parsers.dart';

class OffersModel {
  String? id;
  num? minAmount;
  num? maxAmount;
  num? bonus;
  String? offerCode;
  String? bonusType;
  String? title;
  num? userTime;
  String? type;
  String? createdAt;
  String? enddate;
  String? description;
  num? usedCount;

  OffersModel({
    this.id,
    this.minAmount,
    this.maxAmount,
    this.bonus,
    this.offerCode,
    this.bonusType,
    this.title,
    this.userTime,
    this.type,
    this.createdAt,
    this.enddate,
    this.description,
    this.usedCount,
  });

  OffersModel.fromJson(Map<String, dynamic> json) {
    id = ModelParsers.toStringParser(json['_id']);
    minAmount = ModelParsers.toNumParser(json['min_amount']);
    maxAmount = ModelParsers.toNumParser(json['max_amount']);
    bonus = ModelParsers.toNumParser(json['bonus']);
    offerCode = ModelParsers.toStringParser(json['offer_code']);
    bonusType = ModelParsers.toStringParser(json['bonus_type']);
    title = ModelParsers.toStringParser(json['title']);
    userTime = ModelParsers.toNumParser(json['user_time']);
    type = ModelParsers.toStringParser(json['type']);
    createdAt = ModelParsers.toStringParser(json['createdAt']);
    enddate = ModelParsers.toStringParser(json['enddate']);
    description = ModelParsers.toStringParser(json['description']);
    usedCount = ModelParsers.toNumParser(json['usedCount']);
  }
}
