import 'package:flutter/foundation.dart';
import 'package:unified_dream247/features/fantasy/core/utils/model_parsers.dart';

class LeaderboardModel {
  bool? success;
  String? message;
  bool? status;
  List<LeaderboardModelData>? data;
  int? totalJoinedTeams;

  LeaderboardModel(
      {this.success,
      this.message,
      this.status,
      this.data,
      this.totalJoinedTeams,});

  LeaderboardModel.fromJson(Map<String, dynamic> json) {
    success = ModelParsers.toBoolParser(json['success']);
    message = ModelParsers.toStringParser(json['message']);
    status = ModelParsers.toBoolParser(json['status']);
    data = json['data'] == null
        ? null
        : (json['data'] as List)
            .map((e) => LeaderboardModelData.fromJson(e))
            .toList();
    totalJoinedTeams = ModelParsers.toIntParser(json['total_joined_teams']);
  }
}

class LeaderboardModelData {
  String? id;
  int? usernumber;
  String? joinleaugeid;
  int? joinTeamNumber;
  String? jointeamid;
  String? userid;
  String? team;
  String? image;
  int? teamnumber;

  LeaderboardModelData(
      {this.id,
      this.usernumber,
      this.joinleaugeid,
      this.joinTeamNumber,
      this.jointeamid,
      this.userid,
      this.team,
      this.image,
      this.teamnumber,});

  LeaderboardModelData.fromJson(Map<String, dynamic> json) {
    id = ModelParsers.toStringParser(json['_id']);
    usernumber = ModelParsers.toIntParser(json['usernumber']);
    joinleaugeid = ModelParsers.toStringParser(json['joinleaugeid']);
    joinTeamNumber = ModelParsers.toIntParser(json['joinTeamNumber']);
    jointeamid = ModelParsers.toStringParser(json['jointeamid']);
    userid = ModelParsers.toStringParser(json['userid']);
    team = ModelParsers.toStringParser(json['team']) ??
        ModelParsers.toStringParser(json['teamname']) ??
        '';
    image = ModelParsers.toStringParser(json['image']);
    teamnumber = ModelParsers.toIntParser(json['teamnumber']);
  }
}

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
      this.totalJoinedTeams,});

  LiveLeaderboardModel.fromJson(Map<String, dynamic> json) {
    debugPrint('📊 [MODEL] LiveLeaderboardModel.fromJson - parsing response');
    debugPrint('📊 [MODEL] json[data] type: ${json['data']?.runtimeType}');
    success = ModelParsers.toBoolParser(json['success']);
    message = ModelParsers.toStringParser(json['message']);
    status = ModelParsers.toBoolParser(json['status']);
    data = json['data'] == null
        ? null
        : LiveLeaderboardData.fromJson(json['data']);
    totalJoinedTeams = ModelParsers.toIntParser(json['total_joined_teams']);
    debugPrint('📊 [MODEL] Parsed - success: $success, status: $status, totalJoinedTeams: $totalJoinedTeams');
  }
}

class LiveLeaderboardData {
  List<LiveJointeams>? jointeams;

  LiveLeaderboardData({this.jointeams});

  LiveLeaderboardData.fromJson(Map<String, dynamic> json) {
    debugPrint('📊 [MODEL] LiveLeaderboardData.fromJson - jointeams type: ${json['jointeams']?.runtimeType}');
    debugPrint('📊 [MODEL] jointeams is null: ${json['jointeams'] == null}');
    if (json['jointeams'] != null) {
      debugPrint('📊 [MODEL] jointeams count: ${(json['jointeams'] as List).length}');
    }
    jointeams = json['jointeams'] == null
        ? null
        : (json['jointeams'] as List)
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
      this.contestWinningType,});

  LiveJointeams.fromJson(Map<String, dynamic> json) {
    id = ModelParsers.toStringParser(json['_id']);
    challengeid = ModelParsers.toStringParser(json['challengeid']);
    teamnumber = ModelParsers.toIntParser(json['teamnumber']);
    userno = ModelParsers.toStringParser(json['userno']);
    userjoinid = ModelParsers.toStringParser(json['userjoinid']);
    userid = ModelParsers.toStringParser(json['userid']);
    jointeamid = ModelParsers.toStringParser(json['jointeamid']);
    points = ModelParsers.toNumParser(json['points']);
    getcurrentrank = ModelParsers.toIntParser(json['getcurrentrank']);
    teamname = ModelParsers.toStringParser(json['teamname']);
    image = ModelParsers.toStringParser(json['image']);
    playerType = ModelParsers.toStringParser(json['player_type']);
    winingamount = ModelParsers.toStringParser(json['winingamount']);
    challengeData = ModelParsers.toStringParser(json['challengeData']);
    contestWinningType =
        ModelParsers.toStringParser(json['contest_winning_type']);
    // Debug log for winning amount tracking
    if (winingamount != null && winingamount!.isNotEmpty && winingamount != '0' && winingamount != '') {
      debugPrint('💰 [MODEL] LiveJointeams - WINNER FOUND: team=$teamname, rank=$getcurrentrank, winAmount=$winingamount');
    }
  }
}
