import 'package:unified_dream247/features/fantasy/core/utils/model_parsers.dart';

class PriceCardModel {
  String? success;
  bool? status;
  String? message;
  List<PriceCardWinnerData>? data;

  PriceCardModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  factory PriceCardModel.fromJson(Map<String, dynamic> json) => PriceCardModel(
        success: ModelParsers.toStringParser(json['success']),
        status: ModelParsers.toBoolParser(json['status']),
        message: ModelParsers.toStringParser(json['message']),
        data: json['data'] == null
            ? []
            : List<PriceCardWinnerData>.from(
                json['data']!.map((x) => PriceCardWinnerData.fromJson(x)),),
      );
}

class PriceCardWinnerData {
  List<PriceCardData>? priceCard;
  Details? details;
  int? winner;

  PriceCardWinnerData({
    this.priceCard,
    this.details,
    this.winner,
  });

  factory PriceCardWinnerData.fromJson(Map<String, dynamic> json) =>
      PriceCardWinnerData(
        priceCard: json['PriceCard'] == null
            ? []
            : List<PriceCardData>.from(
                json['PriceCard']!.map((x) => PriceCardData.fromJson(x)),),
        details:
            json['details'] == null ? null : Details.fromJson(json['details']),
        winner: ModelParsers.toIntParser(json['winner']),
      );
}

class Details {
  num? totalWiningAmount;
  num? fristPrice;

  Details({
    this.totalWiningAmount,
    this.fristPrice,
  });

  factory Details.fromJson(Map<String, dynamic> json) => Details(
        totalWiningAmount: ModelParsers.toNumParser(json['totalWiningAmount']),
        fristPrice: ModelParsers.toNumParser(json['fristPrice']),
      );
}

class PriceCardData {
  int? rank;
  num? prize;
  int? min;
  int? max;

  PriceCardData({
    this.rank,
    this.prize,
    this.min,
    this.max,
  });

  factory PriceCardData.fromJson(Map<String, dynamic> json) => PriceCardData(
        rank: ModelParsers.toIntParser(json['rank']),
        prize: ModelParsers.toNumParser(json['prize']),
        min: ModelParsers.toIntParser(json['min']),
        max: ModelParsers.toIntParser(json['max']),
      );
}
