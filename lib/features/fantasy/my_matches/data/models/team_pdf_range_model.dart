import 'package:unified_dream247/features/fantasy/core/utils/model_parsers.dart';

class TeamPdfRangeModel {
  String? min;
  String? max;
  int? index;

  TeamPdfRangeModel({
    this.min,
    this.max,
    this.index,
  });

  factory TeamPdfRangeModel.fromJson(Map<String, dynamic> json) =>
      TeamPdfRangeModel(
        min: ModelParsers.toStringParser(json["min"]),
        max: ModelParsers.toStringParser(json["max"]),
        index: ModelParsers.toIntParser(json["index"]),
      );
}
