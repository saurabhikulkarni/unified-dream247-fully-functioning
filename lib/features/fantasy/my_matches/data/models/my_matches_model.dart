import 'package:unified_dream247/features/fantasy/core/utils/model_parsers.dart';

class MyMatchesModel {
  String? matchkey;
  String? date;
  String? curDate;
  String? matchname;
  String? format;
  String? team1ShortName;
  String? team2ShortName;
  String? team1Fullname;
  String? team2Fullname;
  String? team1Color;
  String? team2Color;
  String? startDate;
  String? team1Logo;
  String? team2Logo;
  String? status;
  String? launchStatus;
  String? finalStatus;
  String? seriesName;
  String? type;
  String? seriesId;
  int? availableStatus;
  int? joinedcontest;
  int? playing11Status;
  int? totalTeams;
  num? totalWinningAmount;
  String? realMatchkey;
  int? secondInningStatus;

  MyMatchesModel({
    this.matchkey,
    this.date,
    this.curDate,
    this.matchname,
    this.format,
    this.team1ShortName,
    this.team2ShortName,
    this.team1Fullname,
    this.team2Fullname,
    this.team1Color,
    this.team2Color,
    this.startDate,
    this.team1Logo,
    this.team2Logo,
    this.status,
    this.launchStatus,
    this.finalStatus,
    this.seriesName,
    this.type,
    this.seriesId,
    this.availableStatus,
    this.joinedcontest,
    this.playing11Status,
    this.totalTeams,
    this.totalWinningAmount,
    this.realMatchkey,
    this.secondInningStatus,
  });

  MyMatchesModel.fromJson(Map<String, dynamic> json) {
    matchkey = ModelParsers.toStringParser(json["matchkey"]);
    date = ModelParsers.toStringParser(json["date"]);
    curDate = ModelParsers.toStringParser(json["curDate"]);
    matchname = ModelParsers.toStringParser(json["matchname"]);
    format = ModelParsers.toStringParser(json["format"]);
    team1ShortName = ModelParsers.toStringParser(json["team1ShortName"]);
    team2ShortName = ModelParsers.toStringParser(json["team2ShortName"]);
    team1Fullname = ModelParsers.toStringParser(json["team1fullname"]);
    team2Fullname = ModelParsers.toStringParser(json["team2fullname"]);
    team1Color = ModelParsers.toStringParser(json["team1color"]);
    team2Color = ModelParsers.toStringParser(json["team2color"]);
    startDate = ModelParsers.toStringParser(json["start_date"]);
    team1Logo = ModelParsers.toStringParser(json["team1logo"]);
    team2Logo = ModelParsers.toStringParser(json["team2logo"]);
    status = ModelParsers.toStringParser(json["status"]);
    launchStatus = ModelParsers.toStringParser(json["launch_status"]);
    finalStatus = ModelParsers.toStringParser(json["final_status"]);
    seriesName = ModelParsers.toStringParser(json["series_name"]);
    type = ModelParsers.toStringParser(json["type"]);
    seriesId = ModelParsers.toStringParser(json["series_id"]);
    availableStatus = ModelParsers.toIntParser(json["available_status"]);
    joinedcontest = ModelParsers.toIntParser(json["joinedcontest"]);
    playing11Status = ModelParsers.toIntParser(json["playing11_status"]);
    totalTeams = ModelParsers.toIntParser(json["total_teams"]);
    totalWinningAmount = ModelParsers.toNumParser(json["totalWinningAmount"]);
    realMatchkey = ModelParsers.toStringParser(json["real_matchkey"]);
    secondInningStatus = ModelParsers.toIntParser(json["second_inning_status"]);
  }
}
