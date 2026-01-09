import 'package:unified_dream247/features/fantasy/core/utils/model_parsers.dart';

class PlayersModel {
  bool? success;
  String? message;
  bool? status;
  List<CreateTeamPlayersData>? data;
  int? ttlCridit;

  PlayersModel({
    this.success,
    this.message,
    this.status,
    this.data,
    this.ttlCridit,
  });

  PlayersModel.fromJson(Map<String, dynamic> json) {
    success = ModelParsers.toBoolParser(json["success"]);
    message = ModelParsers.toStringParser(json["message"]);
    status = ModelParsers.toBoolParser(json["status"]);
    data = json["data"] == null
        ? null
        : (json["data"] as List)
            .map((e) => CreateTeamPlayersData.fromJson(e))
            .toList();
    ttlCridit = ModelParsers.toIntParser(json["ttlCridit"]);
  }
}

class CreateTeamPlayersData {
  String? role;
  num? credit;
  String? name;
  int? playingstatus;
  bool? lastMatchPlayingStatus;
  int? vplaying;
  num? totalSelected;
  int? captainSelected;
  int? vicecaptainSelected;
  String? playerid;
  String? pId;
  int? playersKey;
  String? image;
  String? teamName;
  String? teamcolor;
  String? teamLogo;
  String? teamShortName;
  String? totalpoints;
  String? team;
  num? playerSelectionPercentage;
  num? captainSelectionPercentage;
  num? viceCaptainSelectionPercentage;
  bool isSelectedPlayer = false;

  CreateTeamPlayersData({
    this.role,
    this.credit,
    this.name,
    this.playingstatus,
    this.lastMatchPlayingStatus,
    this.vplaying,
    this.totalSelected,
    this.captainSelected,
    this.vicecaptainSelected,
    this.playerid,
    this.pId,
    this.playersKey,
    this.image,
    this.teamName,
    this.teamcolor,
    this.teamLogo,
    this.teamShortName,
    this.totalpoints,
    this.team,
    this.playerSelectionPercentage,
    this.captainSelectionPercentage,
    this.viceCaptainSelectionPercentage,
    required this.isSelectedPlayer,
  });

  CreateTeamPlayersData.fromJson(Map<String, dynamic> json) {
    role = ModelParsers.toStringParser(json["role"]);
    credit = ModelParsers.toNumParser(json["credit"]);
    name = ModelParsers.toStringParser(json["name"]);
    playingstatus = ModelParsers.toIntParser(json["playingstatus"]);
    lastMatchPlayingStatus = ModelParsers.toBoolParser(json["lastMatchPlayed"]);
    vplaying = ModelParsers.toIntParser(json["vplaying"]);
    totalSelected = ModelParsers.toNumParser(json["totalSelected"]);
    captainSelected = ModelParsers.toIntParser(json["captainSelected"]);
    vicecaptainSelected = ModelParsers.toIntParser(json["vicecaptainSelected"]);
    playerid = ModelParsers.toStringParser(json["playerid"]);
    pId = ModelParsers.toStringParser(json["p_id"]);
    playersKey = ModelParsers.toIntParser(json["players_key"]);
    image = ModelParsers.toStringParser(json["image"]);
    teamName = ModelParsers.toStringParser(json["teamName"]);
    teamcolor = ModelParsers.toStringParser(json["teamcolor"]);
    teamLogo = ModelParsers.toStringParser(json["team_logo"]);
    teamShortName = ModelParsers.toStringParser(json["team_short_name"]);
    totalpoints = ModelParsers.toStringParser(json["totalpoints"]);
    team = ModelParsers.toStringParser(json["team"]);
    playerSelectionPercentage = ModelParsers.toNumParser(
      json["player_selection_percentage"],
    );
    captainSelectionPercentage = ModelParsers.toNumParser(
      json["captain_selection_percentage"],
    );
    viceCaptainSelectionPercentage = ModelParsers.toNumParser(
      json["vice_captain_selection_percentage"],
    );
    isSelectedPlayer =
        ModelParsers.toBoolParser(json["isSelectedPlayer"]) ?? false;
  }
}
