import 'package:unified_dream247/features/fantasy/core/utils/model_parsers.dart';

class LiveLeaderboardModel {
  bool? success;
  String? message;
  bool? status;
  LiveLeaderboardData? data;
  int? totalJoinedTeams;

  LiveLeaderboardModel(
      {this.success,
      this.message,
      this.status,
      this.data,
      this.totalJoinedTeams});

  LiveLeaderboardModel.fromJson(Map<String, dynamic> json) {
    success = ModelParsers.toBoolParser(json["success"]);
    message = ModelParsers.toStringParser(json["message"]);
    status = ModelParsers.toBoolParser(json["status"]);
    data = json["data"] == null
        ? null
        : LiveLeaderboardData.fromJson(json["data"]);
    totalJoinedTeams = ModelParsers.toIntParser(json["total_joined_teams"]);
  }
}

class LiveLeaderboardData {
  List<LiveJointeams>? jointeams;

  LiveLeaderboardData({this.jointeams});

  LiveLeaderboardData.fromJson(Map<String, dynamic> json) {
    jointeams = json["jointeams"] == null
        ? null
        : (json["jointeams"] as List)
            .map((e) => LiveJointeams.fromJson(e))
            .toList();
  }
}

class LiveJointeams {
  String? id;
  String? challengeid;
  int? teamnumber;
  String? userno;
  String? userjoinid;
  String? userid;
  String? jointeamid;
  num? points;
  int? getcurrentrank;
  String? teamname;
  String? image;
  String? playerType;
  String? winingamount;
  String? challengeData;
  String? contestWinningType;

  LiveJointeams(
      {this.id,
      this.challengeid,
      this.teamnumber,
      this.userno,
      this.userjoinid,
      this.userid,
      this.jointeamid,
      this.points,
      this.getcurrentrank,
      this.teamname,
      this.image,
      this.playerType,
      this.winingamount,
      this.challengeData,
      this.contestWinningType});

  LiveJointeams.fromJson(Map<String, dynamic> json) {
    id = ModelParsers.toStringParser(json["_id"]);
    challengeid = ModelParsers.toStringParser(json["challengeid"]);
    teamnumber = ModelParsers.toIntParser(json["teamnumber"]);
    userno = ModelParsers.toStringParser(json["userno"]);
    userjoinid = ModelParsers.toStringParser(json["userjoinid"]);
    userid = ModelParsers.toStringParser(json["userid"]);
    jointeamid = ModelParsers.toStringParser(json["jointeamid"]);
    points = ModelParsers.toNumParser(json["points"]);
    getcurrentrank = ModelParsers.toIntParser(json["getcurrentrank"]);
    teamname = ModelParsers.toStringParser(json["teamname"]);
    image = ModelParsers.toStringParser(json["image"]);
    playerType = ModelParsers.toStringParser(json["player_type"]);
    winingamount = ModelParsers.toStringParser(json["winingamount"]);
    challengeData = ModelParsers.toStringParser(json["challengeData"]);
    contestWinningType =
        ModelParsers.toStringParser(json["contest_winning_type"]);
  }
}
