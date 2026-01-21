import 'package:unified_dream247/features/fantasy/core/utils/model_parsers.dart';

class WinnersModel {
  String? id;
  int? totalWin;
  String? matchkey;
  String? fantasyType;
  String? seriesName;
  String? matchchallengeid;
  String? startDate;
  String? teamAName;
  String? teamAShortName;
  String? teamAImage;
  String? teamBName;
  String? teamBShortName;
  String? teamBImage;
  List<WinnersMatchchallenges>? matchchallenges;
  String? joinId;
  List<WinContestData>? winContestData;
  int? firstContesWinAmount;
  String? convertedStartDate;

  WinnersModel({
    this.id,
    this.totalWin,
    this.matchkey,
    this.fantasyType,
    this.seriesName,
    this.matchchallengeid,
    this.startDate,
    this.teamAName,
    this.teamAShortName,
    this.teamAImage,
    this.teamBName,
    this.teamBShortName,
    this.teamBImage,
    this.matchchallenges,
    this.joinId,
    this.winContestData,
    this.firstContesWinAmount,
    this.convertedStartDate,
  });

  WinnersModel.fromJson(Map<String, dynamic> json) {
    id = ModelParsers.toStringParser(json['_id']);
    totalWin = ModelParsers.toIntParser(json['totalWin']);
    matchkey = ModelParsers.toStringParser(json['matchkey']);
    fantasyType = ModelParsers.toStringParser(json['fantasyType']);
    seriesName = ModelParsers.toStringParser(json['seriesName']);
    matchchallengeid = ModelParsers.toStringParser(json['matchchallengeid']);
    startDate = ModelParsers.toStringParser(json['startDate']);
    teamAName = ModelParsers.toStringParser(json['teamAName']);
    teamAShortName = ModelParsers.toStringParser(json['teamAShortName']);
    teamAImage = ModelParsers.toStringParser(json['teamAImage']);
    teamBName = ModelParsers.toStringParser(json['teamBName']);
    teamBShortName = ModelParsers.toStringParser(json['teamBShortName']);
    teamBImage = ModelParsers.toStringParser(json['teamBImage']);
    matchchallenges = json['matchchallenges'] == null
        ? null
        : (json['matchchallenges'] as List)
            .map((e) => WinnersMatchchallenges.fromJson(e))
            .toList();
    joinId = ModelParsers.toStringParser(json['joinId']);
    winContestData = json['firstcontestData'] == null
        ? null
        : (json['firstcontestData'] as List)
            .map((e) => WinContestData.fromJson(e))
            .toList();
    firstContesWinAmount = ModelParsers.toIntParser(
      json['firstContesWinAmount'],
    );
    convertedStartDate = ModelParsers.toStringParser(
      json['convertedStartDate'],
    );
  }
}

class WinContestData {
  String? id;
  String? joinId;
  String? userId;
  num? points;
  int? rank;
  String? userImage;
  String? userTeamName;
  String? username;
  String? state;
  num? amount;
  String? prize;

  WinContestData({
    this.id,
    this.joinId,
    this.userId,
    this.points,
    this.rank,
    this.userImage,
    this.userTeamName,
    this.username,
    this.state,
    this.amount,
    this.prize,
  });

  WinContestData.fromJson(Map<String, dynamic> json) {
    id = ModelParsers.toStringParser(json['_id']);
    joinId = ModelParsers.toStringParser(json['joinId']);
    userId = ModelParsers.toStringParser(json['userId']);
    points = ModelParsers.toNumParser(json['points']);
    rank = ModelParsers.toIntParser(json['rank']);
    userImage = ModelParsers.toStringParser(json['userImage']);
    userTeamName = ModelParsers.toStringParser(json['userTeamName']);
    username = ModelParsers.toStringParser(json['username']);
    state = ModelParsers.toStringParser(json['state']);
    amount = ModelParsers.toNumParser(json['amount']);
    prize = ModelParsers.toStringParser(json['prize']);
  }
}

class WinnersMatchchallenges {
  String? id;
  String? challengeId;
  String? matchkey;
  String? fantasyType;
  int? winAmount;
  String? contestName;
  String? isRecent;
  int? joinedusers;

  WinnersMatchchallenges({
    this.id,
    this.challengeId,
    this.matchkey,
    this.fantasyType,
    this.winAmount,
    this.contestName,
    this.isRecent,
    this.joinedusers,
  });

  WinnersMatchchallenges.fromJson(Map<String, dynamic> json) {
    id = ModelParsers.toStringParser(json['_id']);
    challengeId = ModelParsers.toStringParser(json['challenge_id']);
    matchkey = ModelParsers.toStringParser(json['matchkey']);
    fantasyType = ModelParsers.toStringParser(json['fantasy_type']);
    winAmount = ModelParsers.toIntParser(json['win_amount']);
    contestName = ModelParsers.toStringParser(json['contest_name']);
    isRecent = ModelParsers.toStringParser(json['is_recent']);
    joinedusers = ModelParsers.toIntParser(json['joinedusers']);
  }
}
