import 'package:unified_dream247/features/fantasy/core/utils/model_parsers.dart';

class TeamCompareModel {
  List<UserTeamData>? userTeamData;
  List<Common>? captain;
  List<Common>? vicecaptain;
  List<Common>? common;
  List<Common>? unmatched;

  TeamCompareModel({
    this.userTeamData,
    this.captain,
    this.vicecaptain,
    this.common,
    this.unmatched,
  });

  factory TeamCompareModel.fromJson(Map<String, dynamic> json) =>
      TeamCompareModel(
        userTeamData: json["userTeamData"] == null
            ? []
            : List<UserTeamData>.from(
                json["userTeamData"]!.map((x) => UserTeamData.fromJson(x))),
        captain: json["captain"] == null
            ? []
            : List<Common>.from(
                json["captain"]!.map((x) => Common.fromJson(x))),
        vicecaptain: json["vicecaptain"] == null
            ? []
            : List<Common>.from(
                json["vicecaptain"]!.map((x) => Common.fromJson(x))),
        common: json["Common"] == null
            ? []
            : List<Common>.from(json["Common"]!.map((x) => Common.fromJson(x))),
        unmatched: json["unmatched"] == null
            ? []
            : List<Common>.from(
                json["unmatched"]!.map((x) => Common.fromJson(x))),
      );
}

class Common {
  String? playerId;
  String? matchPlayerId;
  String? playerName;
  int? playerKey;
  String? team;
  num? credit;
  String? role;
  String? image;
  int? teams;
  num? points;

  Common({
    this.playerId,
    this.matchPlayerId,
    this.playerName,
    this.playerKey,
    this.team,
    this.credit,
    this.role,
    this.image,
    this.teams,
    this.points,
  });

  factory Common.fromJson(Map<String, dynamic> json) => Common(
        playerId: ModelParsers.toStringParser(json["playerId"]),
        matchPlayerId: ModelParsers.toStringParser(json["matchPlayerId"]),
        playerName: ModelParsers.toStringParser(json["playerName"]),
        playerKey: ModelParsers.toIntParser(json["playerKey"]),
        team: ModelParsers.toStringParser(json["team"]),
        credit: ModelParsers.toNumParser(json["credit"]),
        role: ModelParsers.toStringParser(json["role"]),
        image: ModelParsers.toStringParser(json["image"]),
        teams: ModelParsers.toIntParser(json["teams"]),
        points: ModelParsers.toNumParser(json["points"]),
      );
}

class UserTeamData {
  String? id;
  num? points;
  int? teams;
  String? image;
  String? teamName;

  UserTeamData({
    this.id,
    this.points,
    this.teams,
    this.image,
    this.teamName,
  });

  factory UserTeamData.fromJson(Map<String, dynamic> json) => UserTeamData(
        id: ModelParsers.toStringParser(json["_id"]),
        points: ModelParsers.toNumParser(json["points"]),
        teams: ModelParsers.toIntParser(json["teams"]),
        image: ModelParsers.toStringParser(json["image"]),
        teamName: ModelParsers.toStringParser(json["teamName"]),
      );
}
