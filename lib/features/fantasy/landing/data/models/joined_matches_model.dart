import 'package:unified_dream247/features/fantasy/core/utils/model_parsers.dart';

class JoinedMatchesModel {
  String? id;
  String? matchkey;
  String? fantasyType;
  String? shortName;
  String? name;
  String? startDate;
  String? status;
  String? finalStatus;
  int? playing11Status;
  String? team1;
  String? team1ShortName;
  String? team1Logo;
  String? team2;
  String? team2ShortName;
  String? team2Logo;
  int? totalJoinTeam;
  int? totalJoinedContest;
  String? textNote;
  String? realMatchkey;
  String? series;

  JoinedMatchesModel({
    this.id,
    this.matchkey,
    this.fantasyType,
    this.shortName,
    this.name,
    this.startDate,
    this.status,
    this.finalStatus,
    this.playing11Status,
    this.team1,
    this.team1ShortName,
    this.team1Logo,
    this.team2,
    this.team2ShortName,
    this.team2Logo,
    this.totalJoinTeam,
    this.totalJoinedContest,
    this.textNote,
    this.series,
    this.realMatchkey,
  });

  JoinedMatchesModel.fromJson(Map<String, dynamic> json) {
    id = ModelParsers.toStringParser(json['_id']);
    matchkey = ModelParsers.toStringParser(json['matchkey']);
    fantasyType = ModelParsers.toStringParser(json['fantasy_type']);
    shortName = ModelParsers.toStringParser(json['short_name']);
    name = ModelParsers.toStringParser(json['name']);
    startDate = ModelParsers.toStringParser(json['start_date']);
    status = ModelParsers.toStringParser(json['status']);
    finalStatus = ModelParsers.toStringParser(json['final_status']);
    playing11Status = ModelParsers.toIntParser(json['playing11_status']);
    team1 = ModelParsers.toStringParser(json['team1']);
    team1ShortName = ModelParsers.toStringParser(json['team1_short_name']);
    team1Logo = ModelParsers.toStringParser(json['team1logo']);
    team2 = ModelParsers.toStringParser(json['team2']);
    team2ShortName = ModelParsers.toStringParser(json['team2_short_name']);
    team2Logo = ModelParsers.toStringParser(json['team2logo']);
    totalJoinTeam = ModelParsers.toIntParser(json['totalJoinTeam']);
    totalJoinedContest = ModelParsers.toIntParser(json['totalJoinedContest']);
    textNote = ModelParsers.toStringParser(json['textNote']);
    series = ModelParsers.toStringParser(json['series']);
    realMatchkey = ModelParsers.toStringParser(json['real_matchkey']);
  }
}
