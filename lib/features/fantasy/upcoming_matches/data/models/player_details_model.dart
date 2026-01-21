import 'package:unified_dream247/features/fantasy/core/utils/model_parsers.dart';

class PlayerDetailsModel {
  bool? success;
  String? message;
  bool? status;
  PlayerDetailsModelData? data;
  List<PlayerMatches>? matches;

  PlayerDetailsModel(
      {this.success, this.message, this.status, this.data, this.matches,});

  PlayerDetailsModel.fromJson(Map<String, dynamic> json) {
    success = ModelParsers.toBoolParser(json['success']);
    message = ModelParsers.toStringParser(json['message']);
    status = ModelParsers.toBoolParser(json['status']);
    data = json['data'] == null
        ? null
        : PlayerDetailsModelData.fromJson(json['data']);
    matches = json['matches'] == null
        ? null
        : (json['matches'] as List)
            .map((e) => PlayerMatches.fromJson(e))
            .toList();
  }
}

class PlayerMatches {
  num? totalPoints;
  String? tossDecision;
  String? tosswinnerTeam;
  num? selectper;
  String? startDate;
  String? shortName;
  num? credit;
  Player? player;

  PlayerMatches(
      {this.totalPoints,
      this.tossDecision,
      this.tosswinnerTeam,
      this.selectper,
      this.startDate,
      this.shortName,
      this.credit,
      this.player,});

  PlayerMatches.fromJson(Map<String, dynamic> json) {
    totalPoints = ModelParsers.toNumParser(json['total_points']);
    tossDecision = ModelParsers.toStringParser(json['toss_decision']);
    tosswinnerTeam = ModelParsers.toStringParser(json['tosswinner_team']);
    selectper = ModelParsers.toNumParser(json['selectper']);
    startDate = ModelParsers.toStringParser(json['start_date']);
    shortName = ModelParsers.toStringParser(json['short_name']);
    credit = ModelParsers.toNumParser(json['credit']);
    player = json['player'] == null ? null : Player.fromJson(json['player']);
  }
}

class Player {
  String? id;
  String? fantasyType;
  String? playerName;
  String? playersKey;
  String? team;
  num? credit;
  String? role;
  String? image;
  num? points;
  String? fullname;
  String? dob;
  String? country;
  String? battingstyle;
  String? bowlingstyle;
  bool? isDeleted;
  String? createdAt;
  String? updatedAt;

  Player(
      {this.id,
      this.fantasyType,
      this.playerName,
      this.playersKey,
      this.team,
      this.credit,
      this.role,
      this.image,
      this.points,
      this.fullname,
      this.dob,
      this.country,
      this.battingstyle,
      this.bowlingstyle,
      this.isDeleted,
      this.createdAt,
      this.updatedAt,});

  Player.fromJson(Map<String, dynamic> json) {
    id = ModelParsers.toStringParser(json['_id']);
    fantasyType = ModelParsers.toStringParser(json['fantasy_type']);
    playerName = ModelParsers.toStringParser(json['player_name']);
    playersKey = ModelParsers.toStringParser(json['players_key']);
    team = ModelParsers.toStringParser(json['team']);
    credit = ModelParsers.toNumParser(json['credit']);
    role = ModelParsers.toStringParser(json['role']);
    image = ModelParsers.toStringParser(json['image']);
    points = ModelParsers.toNumParser(json['points']);
    fullname = ModelParsers.toStringParser(json['fullname']);
    dob = ModelParsers.toStringParser(json['dob']);
    country = ModelParsers.toStringParser(json['country']);
    battingstyle = ModelParsers.toStringParser(json['battingstyle']);
    bowlingstyle = ModelParsers.toStringParser(json['bowlingstyle']);
    isDeleted = ModelParsers.toBoolParser(json['is_deleted']);
    createdAt = ModelParsers.toStringParser(json['createdAt']);
    updatedAt = ModelParsers.toStringParser(json['updatedAt']);
  }
}

class PlayerDetailsModelData {
  String? id;
  String? fantasyType;
  String? playerName;
  String? playersKey;
  String? team;
  num? credit;
  String? role;
  String? image;
  num? points;
  String? fullname;
  String? dob;
  String? country;
  String? battingstyle;
  String? bowlingstyle;
  bool? isDeleted;
  String? createdAt;
  String? updatedAt;

  PlayerDetailsModelData(
      {this.id,
      this.fantasyType,
      this.playerName,
      this.playersKey,
      this.team,
      this.credit,
      this.role,
      this.image,
      this.points,
      this.fullname,
      this.dob,
      this.country,
      this.battingstyle,
      this.bowlingstyle,
      this.isDeleted,
      this.createdAt,
      this.updatedAt,});

  PlayerDetailsModelData.fromJson(Map<String, dynamic> json) {
    id = ModelParsers.toStringParser(json['_id']);
    fantasyType = ModelParsers.toStringParser(json['fantasy_type']);
    playerName = ModelParsers.toStringParser(json['player_name']);
    playersKey = ModelParsers.toStringParser(json['players_key']);
    team = ModelParsers.toStringParser(json['team']);
    credit = ModelParsers.toNumParser(json['credit']);
    role = ModelParsers.toStringParser(json['role']);
    image = ModelParsers.toStringParser(json['image']);
    points = ModelParsers.toNumParser(json['points']);
    fullname = ModelParsers.toStringParser(json['fullname']);
    dob = ModelParsers.toStringParser(json['dob']);
    country = ModelParsers.toStringParser(json['country']);
    battingstyle = ModelParsers.toStringParser(json['battingstyle']);
    bowlingstyle = ModelParsers.toStringParser(json['bowlingstyle']);
    isDeleted = ModelParsers.toBoolParser(json['is_deleted']);
    createdAt = ModelParsers.toStringParser(json['createdAt']);
    updatedAt = ModelParsers.toStringParser(json['updatedAt']);
  }
}
