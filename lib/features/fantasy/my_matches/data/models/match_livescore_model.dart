import 'package:unified_dream247/features/fantasy/core/utils/model_parsers.dart';

class MatchLiveScoreModel {
  String? id;
  String? matchkey;
  List<Teams>? teams;
  String? statusNote;
  Teama? teama;
  Teama? teamb;

  MatchLiveScoreModel(
      {this.id,
      this.matchkey,
      this.teams,
      this.statusNote,
      this.teama,
      this.teamb,});

  MatchLiveScoreModel.fromJson(Map<String, dynamic> json) {
    id = ModelParsers.toStringParser(json['_id']);
    matchkey = ModelParsers.toStringParser(json['matchkey']);
    teams = json['teams'] == null
        ? null
        : (json['teams'] as List).map((e) => Teams.fromJson(e)).toList();
    statusNote = ModelParsers.toStringParser(json['status_note']);
    teama = json['teama'] == null ? null : Teama.fromJson(json['teama']);
    teamb = json['teamb'] == null ? null : Teama.fromJson(json['teamb']);
  }
}

class Teams {
  int? tid;
  String? title;
  String? abbr;
  String? altName;
  String? type;
  String? thumbUrl;
  String? logoUrl;
  String? country;
  String? sex;
  String? scoresFull;
  String? scores;
  String? overs;

  Teams(
      {this.tid,
      this.title,
      this.abbr,
      this.altName,
      this.type,
      this.thumbUrl,
      this.logoUrl,
      this.country,
      this.sex,
      this.scoresFull,
      this.scores,
      this.overs,});

  Teams.fromJson(Map<String, dynamic> json) {
    tid = ModelParsers.toIntParser(json['tid']);
    title = ModelParsers.toStringParser(json['title']);
    abbr = ModelParsers.toStringParser(json['abbr']);
    altName = ModelParsers.toStringParser(json['alt_name']);
    type = ModelParsers.toStringParser(json['type']);
    thumbUrl = ModelParsers.toStringParser(json['thumb_url']);
    logoUrl = ModelParsers.toStringParser(json['logo_url']);
    country = ModelParsers.toStringParser(json['country']);
    sex = ModelParsers.toStringParser(json['sex']);
    scoresFull = ModelParsers.toStringParser(json['scores_full']);
    scores = ModelParsers.toStringParser(json['scores']);
    overs = ModelParsers.toStringParser(json['overs']);
  }
}

class Teama {
  int? teamId;
  String? name;
  String? shortName;
  String? logoUrl;
  String? thumbUrl;
  String? scoresFull;
  String? scores;
  String? overs;

  Teama({
    this.teamId,
    this.name,
    this.shortName,
    this.logoUrl,
    this.thumbUrl,
    this.scoresFull,
    this.scores,
    this.overs,
  });

  factory Teama.fromJson(Map<String, dynamic> json) => Teama(
        teamId: ModelParsers.toIntParser(json['team_id']),
        name: ModelParsers.toStringParser(json['name']),
        shortName: ModelParsers.toStringParser(json['short_name']),
        logoUrl: ModelParsers.toStringParser(json['logo_url']),
        thumbUrl: ModelParsers.toStringParser(json['thumb_url']),
        scoresFull: ModelParsers.toStringParser(json['scores_full']),
        scores: ModelParsers.toStringParser(json['scores']),
        overs: ModelParsers.toStringParser(json['overs']),
      );
}
