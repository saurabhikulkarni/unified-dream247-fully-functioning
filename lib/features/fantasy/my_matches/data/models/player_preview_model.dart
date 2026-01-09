import 'package:unified_dream247/features/fantasy/core/utils/model_parsers.dart';

class PlayerPreviewModel {
  String? id;
  String? playerid;
  String? name;
  String? role;
  num? credit;
  int? playingstatus;
  String? team;
  String? image;
  String? image1;
  int? captain;
  int? vicecaptain;
  num? points;
  bool? isSelected;

  PlayerPreviewModel(
      {this.id,
      this.playerid,
      this.name,
      this.role,
      this.credit,
      this.playingstatus,
      this.team,
      this.image,
      this.image1,
      this.captain,
      this.vicecaptain,
      this.points,
      this.isSelected});

  PlayerPreviewModel.fromJson(Map<String, dynamic> json) {
    id = ModelParsers.toStringParser(json["id"]);
    playerid = ModelParsers.toStringParser(json["playerid"]);
    name = ModelParsers.toStringParser(json["name"]);
    role = ModelParsers.toStringParser(json["role"]);
    credit = ModelParsers.toNumParser(json["credit"]);
    playingstatus = ModelParsers.toIntParser(json["playingstatus"]);
    team = ModelParsers.toStringParser(json["team"]);
    image = ModelParsers.toStringParser(json["image"]);
    image1 = ModelParsers.toStringParser(json["image1"]);
    captain = ModelParsers.toIntParser(json["captain"]);
    vicecaptain = ModelParsers.toIntParser(json["vicecaptain"]);
    points = ModelParsers.toNumParser(json["points"]);
    isSelected = ModelParsers.toBoolParser(json["isSelected"]);
  }
}
