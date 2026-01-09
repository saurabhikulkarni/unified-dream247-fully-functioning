import 'package:Dream247/core/utils/model_parsers.dart';

class GamesModel {
  bool? success;
  String? message;
  bool? status;
  GamesData? data;

  GamesModel({this.success, this.message, this.status, this.data});

  GamesModel.fromJson(Map<String, dynamic> json) {
    success = ModelParsers.toBoolParser(json["success"]);
    message = ModelParsers.toStringParser(json["message"]);
    status = ModelParsers.toBoolParser(json["status"]);
    data = json["data"] == null ? null : GamesData.fromJson(json["data"]);
  }
}

class GamesData {
  List<MatchListModel>? upcomingMatches;

  GamesData({this.upcomingMatches});

  GamesData.fromJson(Map<String, dynamic> json) {
    upcomingMatches = json["upcomingMatches"] == null
        ? null
        : (json["upcomingMatches"] as List)
            .map((e) => MatchListModel.fromJson(e))
            .toList();
  }
}

class MatchListModel {
  String? name;
  String? notify;
  String? launchStatus;
  String? infoCenter;
  int? playing11Status;
  int? orderStatus;
  String? format;
  String? id;
  String? series;
  String? seriesname;
  String? team1Name;
  String? team2Name;
  String? teamfullname1;
  String? teamfullname2;
  String? fantasyType;
  String? winnerstatus;
  String? team1Color;
  String? team2Color;
  String? team1Logo;
  String? team2Logo;
  String? matchopenstatus;
  String? timeStart;
  String? locktime;
  String? createteamnumber;
  String? status;
  int? mega;
  num? giveawaycontestAmount;
  int? teamcount;
  int? giveawaycontest;
  int? joinContestCount;
  String? textNote;
  String? realMatchkey;
  String? contestType;
  int? secondInningStatus;
  String? capTeam1Image;
  String? capTeam2Image;

  MatchListModel(
      {this.name,
      this.notify,
      this.launchStatus,
      this.infoCenter,
      this.playing11Status,
      this.giveawaycontest,
      this.giveawaycontestAmount,
      this.orderStatus,
      this.format,
      this.id,
      this.series,
      this.seriesname,
      this.team1Name,
      this.team2Name,
      this.teamfullname1,
      this.teamfullname2,
      this.fantasyType,
      this.winnerstatus,
      this.team1Color,
      this.team2Color,
      this.team1Logo,
      this.team2Logo,
      this.matchopenstatus,
      this.timeStart,
      this.locktime,
      this.createteamnumber,
      this.status,
      this.mega,
      this.teamcount,
      this.joinContestCount,
      this.textNote,
      this.realMatchkey,
      this.contestType,
      this.secondInningStatus,
      this.capTeam1Image,
      this.capTeam2Image});

  MatchListModel.fromJson(Map<String, dynamic> json) {
    name = ModelParsers.toStringParser(json["name"]);
    notify = ModelParsers.toStringParser(json["notify"]);
    launchStatus = ModelParsers.toStringParser(json["launch_status"]);
    infoCenter = ModelParsers.toStringParser(json["info_center"]);
    playing11Status = ModelParsers.toIntParser(json["playing11_status"]);
    orderStatus = ModelParsers.toIntParser(json["order_status"]);
    format = ModelParsers.toStringParser(json["format"]);
    id = ModelParsers.toStringParser(json["id"]);
    series = ModelParsers.toStringParser(json["series"]);
    seriesname = ModelParsers.toStringParser(json["seriesname"]);
    team1Name = ModelParsers.toStringParser(json["team1name"]);
    team2Name = ModelParsers.toStringParser(json["team2name"]);
    teamfullname1 = ModelParsers.toStringParser(json["teamfullname1"]);
    teamfullname2 = ModelParsers.toStringParser(json["teamfullname2"]);
    fantasyType = ModelParsers.toStringParser(json["fantasy_type"]);
    winnerstatus = ModelParsers.toStringParser(json["winnerstatus"]);
    team1Color = ModelParsers.toStringParser(json["team1color"]);
    team2Color = ModelParsers.toStringParser(json["team2color"]);
    team1Logo = ModelParsers.toStringParser(json["team1logo"]);
    team2Logo = ModelParsers.toStringParser(json["team2logo"]);
    matchopenstatus = ModelParsers.toStringParser(json["matchopenstatus"]);
    timeStart = ModelParsers.toStringParser(json["time_start"]);
    locktime = ModelParsers.toStringParser(json["locktime"]);
    createteamnumber = ModelParsers.toStringParser(json["createteamnumber"]);
    status = ModelParsers.toStringParser(json["status"]);
    mega = ModelParsers.toIntParser(json["mega"]);
    teamcount = ModelParsers.toIntParser(json["teamcount"]);
    joinContestCount = ModelParsers.toIntParser(json["joinContestCount"]);
    giveawaycontest = ModelParsers.toIntParser(json["giveawaycontest"]);
    giveawaycontestAmount = ModelParsers.toNumParser(
      json["giveawaycontestAmount"],
    );
    textNote = ModelParsers.toStringParser(json["textNote"]);
    realMatchkey = ModelParsers.toStringParser(json["real_matchkey"]);
    contestType = ModelParsers.toStringParser(json["contestType"]);
    secondInningStatus = ModelParsers.toIntParser(json["second_inning_status"]);
    capTeam1Image = ModelParsers.toStringParser(json["capTeam1Image"]);
    capTeam2Image = ModelParsers.toStringParser(json["capTeam2Image"]);
  }
}
