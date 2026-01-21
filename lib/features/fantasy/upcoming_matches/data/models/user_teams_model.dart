import 'package:unified_dream247/features/fantasy/core/utils/model_parsers.dart';

class UserTeamsModel {
  num? captainSelectionPercentage;
  num? credit;
  String? name;
  int? playingstatus;
  num? points;
  String? role;
  num? totalSelected;
  num? viceCaptainSelectionPercentage;
  int? vplaying;
  int? captainSelected;
  int? vicecaptainSelected;
  String? playerid;
  String? pId;
  bool? lastMatchPlayed;
  int? playersKey;
  String? image;
  String? teamName;
  String? teamid;
  String? teamLogo;
  String? teamShortName;
  String? totalpoints;
  String? team;
  num? playerSelectionPercentage;
  bool? isSelectedPlayer;
  int? captain;
  int? vicecaptain;
  String? playerimg;

  UserTeamsModel({
    this.captainSelectionPercentage,
    this.credit,
    this.name,
    this.playingstatus,
    this.points,
    this.role,
    this.totalSelected,
    this.viceCaptainSelectionPercentage,
    this.vplaying,
    this.captainSelected,
    this.vicecaptainSelected,
    this.playerid,
    this.pId,
    this.lastMatchPlayed,
    this.playersKey,
    this.image,
    this.teamName,
    this.teamid,
    this.teamLogo,
    this.teamShortName,
    this.totalpoints,
    this.team,
    this.playerSelectionPercentage,
    this.isSelectedPlayer,
    this.captain,
    this.vicecaptain,
    this.playerimg,
  });

  factory UserTeamsModel.fromJson(Map<String, dynamic> json) => UserTeamsModel(
        captainSelectionPercentage:
            ModelParsers.toNumParser(json['captain_selection_percentage']),
        credit: ModelParsers.toNumParser(json['credit']),
        name: ModelParsers.toStringParser(json['name']),
        playingstatus: ModelParsers.toIntParser(json['playingstatus']),
        points: ModelParsers.toNumParser(json['points']),
        role: ModelParsers.toStringParser(json['role']),
        totalSelected: ModelParsers.toNumParser(json['totalSelected']),
        viceCaptainSelectionPercentage:
            ModelParsers.toNumParser(json['vice_captain_selection_percentage']),
        vplaying: ModelParsers.toIntParser(json['vplaying']),
        captainSelected: ModelParsers.toIntParser(json['captainSelected']),
        vicecaptainSelected:
            ModelParsers.toIntParser(json['vicecaptainSelected']),
        playerid: ModelParsers.toStringParser(json['playerid']),
        pId: ModelParsers.toStringParser(json['p_id']),
        lastMatchPlayed: ModelParsers.toBoolParser(json['lastMatchPlayed']),
        playersKey: ModelParsers.toIntParser(json['players_key']),
        image: ModelParsers.toStringParser(json['image']),
        teamName: ModelParsers.toStringParser(json['teamName']),
        teamid: ModelParsers.toStringParser(json['teamid']),
        teamLogo: ModelParsers.toStringParser(json['team_logo']),
        teamShortName: ModelParsers.toStringParser(json['team_short_name']),
        totalpoints: ModelParsers.toStringParser(json['totalpoints']),
        team: ModelParsers.toStringParser(json['team']),
        playerSelectionPercentage:
            ModelParsers.toNumParser(json['player_selection_percentage']),
        isSelectedPlayer: ModelParsers.toBoolParser(json['isSelectedPlayer']),
        captain: ModelParsers.toIntParser(json['captain']),
        vicecaptain: ModelParsers.toIntParser(json['vicecaptain']),
        playerimg: ModelParsers.toStringParser(json['playerimg']),
      );
}
