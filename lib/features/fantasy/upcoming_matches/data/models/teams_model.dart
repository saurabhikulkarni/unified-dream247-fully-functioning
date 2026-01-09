import 'package:unified_dream247/features/fantasy/core/utils/model_parsers.dart';

class TeamsModel {
  int? status;
  String? userid;
  int? teamnumber;
  String? jointeamid;
  String? team1Name;
  String? team2Name;
  String? playerType;
  String? captain;
  String? vicecaptain;
  String? captainimage;
  String? vicecaptainimage;
  String? captainimage1;
  String? vicecaptainimage1;
  bool? isSelected;
  String? captinName;
  String? viceCaptainName;
  int? team1Count;
  String? captainId;
  String? vicecaptainId;
  int? team2Count;
  int? batsmancount;
  int? bowlercount;
  int? wicketKeeperCount;
  int? allroundercount;
  int? totalTeams;
  int? totalJoinedcontest;
  num? totalpoints;
  String? team1Id;
  String? team2Id;
  bool isPicked = false;
  String? captainTeam;
  String? viceCaptainTeam;
  String? teamType;

  TeamsModel({
    this.status,
    this.userid,
    this.teamnumber,
    this.jointeamid,
    this.team1Name,
    this.team2Name,
    this.playerType,
    this.captain,
    this.vicecaptain,
    this.captainimage,
    this.vicecaptainimage,
    this.captainimage1,
    this.vicecaptainimage1,
    this.isSelected,
    this.captinName,
    this.viceCaptainName,
    this.team1Count,
    this.captainId,
    this.vicecaptainId,
    this.team2Count,
    this.batsmancount,
    this.bowlercount,
    this.wicketKeeperCount,
    this.allroundercount,
    this.totalTeams,
    this.totalJoinedcontest,
    this.totalpoints,
    this.team1Id,
    this.team2Id,
    this.captainTeam,
    this.viceCaptainTeam,
    this.teamType,
  });

  TeamsModel.fromJson(Map<String, dynamic> json) {
    status = ModelParsers.toIntParser(json["status"]);
    userid = ModelParsers.toStringParser(json["userid"]);
    teamnumber = ModelParsers.toIntParser(json["teamnumber"]);
    jointeamid = ModelParsers.toStringParser(json["jointeamid"]);
    team1Name = ModelParsers.toStringParser(json["team1_name"]);
    team2Name = ModelParsers.toStringParser(json["team2_name"]);
    playerType = ModelParsers.toStringParser(json["player_type"]);
    captain = ModelParsers.toStringParser(json["captain"]);
    vicecaptain = ModelParsers.toStringParser(json["vicecaptain"]);
    captainimage = ModelParsers.toStringParser(json["captainimage"]);
    vicecaptainimage = ModelParsers.toStringParser(json["vicecaptainimage"]);
    captainimage1 = ModelParsers.toStringParser(json["captainimage1"]);
    vicecaptainimage1 = ModelParsers.toStringParser(json["vicecaptainimage1"]);
    isSelected = ModelParsers.toBoolParser(json["isSelected"]);
    captinName = ModelParsers.toStringParser(json["captin_name"]);
    viceCaptainName = ModelParsers.toStringParser(json["viceCaptain_name"]);
    team1Count = ModelParsers.toIntParser(json["team1count"]);
    captainId = ModelParsers.toStringParser(json["captain_id"]);
    vicecaptainId = ModelParsers.toStringParser(json["vicecaptain_id"]);
    team2Count = ModelParsers.toIntParser(json["team2count"]);
    batsmancount = ModelParsers.toIntParser(json["batsmancount"]);
    bowlercount = ModelParsers.toIntParser(json["bowlercount"]);
    wicketKeeperCount = ModelParsers.toIntParser(json["wicketKeeperCount"]);
    allroundercount = ModelParsers.toIntParser(json["allroundercount"]);
    totalTeams = ModelParsers.toIntParser(json["total_teams"]);
    totalJoinedcontest = ModelParsers.toIntParser(json["total_joinedcontest"]);
    totalpoints = ModelParsers.toNumParser(json["totalpoints"]);
    team1Id = ModelParsers.toStringParser(json["team1Id"]);
    team2Id = ModelParsers.toStringParser(json["team2Id"]);
    isPicked = ModelParsers.toBoolParser(json["isPicked"]) ?? false;
    captainTeam = ModelParsers.toStringParser(json["captainTeam"]);
    viceCaptainTeam = ModelParsers.toStringParser(json["viceCaptainTeam"]);
    teamType = ModelParsers.toStringParser(json["teamType"]);
  }
}

class PlayerCountersAdapter {
  int? count;
  String? key;
  String? name;
  int? min;
  int? max;

  PlayerCountersAdapter({this.count, this.key, this.max, this.name, this.min});

  PlayerCountersAdapter.fromJson(Map<String, dynamic> json) {
    count = ModelParsers.toIntParser(json['count']);
    key = ModelParsers.toStringParser(json['key']);
    name = ModelParsers.toStringParser(json['name']);
    min = ModelParsers.toIntParser(json['min']);
    max = ModelParsers.toIntParser(json['max']);
  }
}
