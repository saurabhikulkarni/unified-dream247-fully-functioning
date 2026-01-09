import 'package:Dream247/core/utils/model_parsers.dart';

class MatchPlayerTeamsModel {
  String? id;
  String? image;
  num? credit;
  num? totalSelected;
  List<MatchPlayerTeamsCard>? card;
  num? total;
  String? role;
  String? name;
  String? teamName;

  MatchPlayerTeamsModel(
      {this.id,
      this.image,
      this.credit,
      this.totalSelected,
      this.card,
      this.total,
      this.role,
      this.name,
      this.teamName});

  factory MatchPlayerTeamsModel.fromJson(Map<String, dynamic> json) =>
      MatchPlayerTeamsModel(
          id: ModelParsers.toStringParser(json["_id"]),
          image: ModelParsers.toStringParser(json["image"]),
          credit: ModelParsers.toNumParser(json["credit"]),
          totalSelected: ModelParsers.toNumParser(json["totalSelected"]),
          card: json["card"] == null
              ? []
              : List<MatchPlayerTeamsCard>.from(
                  json["card"]!.map((x) => MatchPlayerTeamsCard.fromJson(x))),
          total: ModelParsers.toNumParser(json["total"]),
          role: ModelParsers.toStringParser(json["role"]),
          name: ModelParsers.toStringParser(json["name"]),
          teamName: ModelParsers.toStringParser(json["teamShortName"]));
}

class MatchPlayerTeamsCard {
  String? type;
  dynamic actual;
  num? points;

  MatchPlayerTeamsCard({
    this.type,
    this.actual,
    this.points,
  });

  factory MatchPlayerTeamsCard.fromJson(Map<String, dynamic> json) =>
      MatchPlayerTeamsCard(
        type: ModelParsers.toStringParser(json["type"]),
        actual: json["actual"],
        points: ModelParsers.toNumParser(json["points"]),
      );
}
