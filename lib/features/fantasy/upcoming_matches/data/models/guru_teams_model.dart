import 'package:unified_dream247/features/fantasy/core/utils/model_parsers.dart';

class GuruTeamsModel {
  num? status;
  String? userid;
  num? teamnumber;
  String? jointeamid;
  num? countCopied;
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
  num? team1Count;
  String? captainId;
  String? vicecaptainId;
  num? team2Count;
  num? batsmancount;
  num? bowlercount;
  num? wicketKeeperCount;
  num? allroundercount;
  num? totalTeams;
  num? totalJoinedcontest;
  num? totalpoints;
  String? team1Id;
  String? team2Id;
  List<int>? guruTeamNumber;
  String? team;
  String? userImage;
  List<Player>? player;

  GuruTeamsModel(
      {this.status,
      this.userid,
      this.teamnumber,
      this.jointeamid,
      this.countCopied,
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
      this.guruTeamNumber,
      this.team,
      this.userImage,
      this.player,});

  GuruTeamsModel.fromJson(Map<String, dynamic> json) {
    status = ModelParsers.toNumParser(json['status']);
    userid = ModelParsers.toStringParser(json['userid']);
    teamnumber = ModelParsers.toNumParser(json['teamnumber']);
    jointeamid = ModelParsers.toStringParser(json['jointeamid']);
    countCopied = ModelParsers.toNumParser(json['count_copied']);
    team1Name = ModelParsers.toStringParser(json['team1_name']);
    team2Name = ModelParsers.toStringParser(json['team2_name']);
    playerType = ModelParsers.toStringParser(json['player_type']);
    captain = ModelParsers.toStringParser(json['captain']);
    vicecaptain = ModelParsers.toStringParser(json['vicecaptain']);
    captainimage = ModelParsers.toStringParser(json['captainimage']);
    vicecaptainimage = ModelParsers.toStringParser(json['vicecaptainimage']);
    captainimage1 = ModelParsers.toStringParser(json['captainimage1']);
    vicecaptainimage1 = ModelParsers.toStringParser(json['vicecaptainimage1']);
    isSelected = ModelParsers.toBoolParser(json['isSelected']);
    captinName = ModelParsers.toStringParser(json['captin_name']);
    viceCaptainName = ModelParsers.toStringParser(json['viceCaptain_name']);
    team1Count = ModelParsers.toNumParser(json['team1count']);
    captainId = ModelParsers.toStringParser(json['captain_id']);
    vicecaptainId = ModelParsers.toStringParser(json['vicecaptain_id']);
    team2Count = ModelParsers.toNumParser(json['team2count']);
    batsmancount = ModelParsers.toNumParser(json['batsmancount']);
    bowlercount = ModelParsers.toNumParser(json['bowlercount']);
    wicketKeeperCount = ModelParsers.toNumParser(json['wicketKeeperCount']);
    allroundercount = ModelParsers.toNumParser(json['allroundercount']);
    totalTeams = ModelParsers.toNumParser(json['total_teams']);
    totalJoinedcontest = ModelParsers.toNumParser(json['total_joinedcontest']);
    totalpoints = ModelParsers.toNumParser(json['totalpoints']);
    team1Id = ModelParsers.toStringParser(json['team1Id']);
    team2Id = ModelParsers.toStringParser(json['team2Id']);
    guruTeamNumber = json['guruTeamNumber'] == null
        ? null
        : List<int>.from(json['guruTeamNumber']);
    team = ModelParsers.toStringParser(json['team']);
    userImage = ModelParsers.toStringParser(json['userImage']);
    player = json['player'] == null
        ? null
        : (json['player'] as List).map((e) => Player.fromJson(e)).toList();
  }
}

class Player {
  String? id;
  String? playerimg;
  String? team;
  String? name;
  String? role;
  num? credit;
  num? playingstatus;
  String? image1;
  num? captain;
  num? vicecaptain;

  Player(
      {this.id,
      this.playerimg,
      this.team,
      this.name,
      this.role,
      this.credit,
      this.playingstatus,
      this.image1,
      this.captain,
      this.vicecaptain,});

  Player.fromJson(Map<String, dynamic> json) {
    id = ModelParsers.toStringParser(json['id']);
    playerimg = ModelParsers.toStringParser(json['playerimg']);
    team = ModelParsers.toStringParser(json['team']);
    name = ModelParsers.toStringParser(json['name']);
    role = ModelParsers.toStringParser(json['role']);
    credit = ModelParsers.toNumParser(json['credit']);
    playingstatus = ModelParsers.toNumParser(json['playingstatus']);
    image1 = ModelParsers.toStringParser(json['image1']);
    captain = ModelParsers.toNumParser(json['captain']);
    vicecaptain = ModelParsers.toNumParser(json['vicecaptain']);
  }
}
