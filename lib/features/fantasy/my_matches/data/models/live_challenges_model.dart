import 'package:unified_dream247/features/fantasy/core/utils/model_parsers.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/all_contests_model.dart';

class LiveChallengesModel {
  bool? success;
  String? message;
  bool? status;
  List<LiveChallengesData>? data;
  int? totalJoinedcontest;
  num? totalinvestment;
  num? totalwon;

  LiveChallengesModel(
      {this.success,
      this.message,
      this.status,
      this.data,
      this.totalJoinedcontest,
      this.totalinvestment,
      this.totalwon});

  LiveChallengesModel.fromJson(Map<String, dynamic> json) {
    success = ModelParsers.toBoolParser(json["success"]);
    message = ModelParsers.toStringParser(json["message"]);
    status = ModelParsers.toBoolParser(json["status"]);
    totalJoinedcontest =
        ModelParsers.toIntParser(json["total_joined_contests"]);
    data = json["data"] == null
        ? null
        : (json["data"] as List)
            .map((e) => LiveChallengesData.fromJson(e))
            .toList();
    totalinvestment = ModelParsers.toNumParser(json["totalinvestment"]);
    totalwon = ModelParsers.toNumParser(json["totalwon"]);
  }
}

class LiveChallengesData {
  int? userrank;
  num? userpoints;
  int? userteamnumber;
  String? winAmountStr;
  String? jointeamid;
  String? joinedleaugeId;
  String? matchchallengeid;
  String? id;
  String? matchkey;
  bool? isRecent;
  String? expertName;
  int? isExpert;
  String? image;
  int? subscriptionFee;
  int? discountFee;
  String? endDate;
  String? startDate;
  String? refercode;
  String? winningpriceAndPrize;
  String? contestName;
  num? winAmount;
  int? isPrivate;
  int? isBonus;
  int? bonusPercentage;
  int? winningPercentage;
  String? contestType;
  int? confirmedChallenge;
  int? multiEntry;
  int? joinedusers;
  int? entryfee;
  String? pricecardType;
  int? maximumUser;
  String? matchFinalstatus;
  String? matchChallengeStatus;
  String? totalwinning;
  bool? isselected;
  int? totalwinners;
  List<Matchpricecards>? matchpricecards;
  int? pricecardstatus;
  List<UserTeams>? userTeams;
  int? teamLimit;
  String? amountType;
  String? giftImage;
  String? giftType;
  String? prizeName;
  bool? isPromoCodeContest;
  int? totalTeams;
  String? flexibleContest;
  int? totalJoinedcontest;
  List<Extrapricecard>? extrapricecard;

  LiveChallengesData(
      {this.userrank,
      this.userpoints,
      this.userteamnumber,
      this.winAmountStr,
      this.jointeamid,
      this.joinedleaugeId,
      this.matchchallengeid,
      this.id,
      this.matchkey,
      this.isRecent,
      this.expertName,
      this.isExpert,
      this.image,
      this.subscriptionFee,
      this.discountFee,
      this.endDate,
      this.startDate,
      this.refercode,
      this.winningpriceAndPrize,
      this.contestName,
      this.winAmount,
      this.isPrivate,
      this.isBonus,
      this.bonusPercentage,
      this.winningPercentage,
      this.contestType,
      this.confirmedChallenge,
      this.multiEntry,
      this.joinedusers,
      this.entryfee,
      this.pricecardType,
      this.maximumUser,
      this.matchFinalstatus,
      this.matchChallengeStatus,
      this.totalwinning,
      this.isselected,
      this.totalwinners,
      this.matchpricecards,
      this.pricecardstatus,
      this.userTeams,
      this.teamLimit,
      this.amountType,
      this.giftImage,
      this.giftType,
      this.prizeName,
      this.isPromoCodeContest,
      this.totalTeams,
      this.totalJoinedcontest,
      this.flexibleContest,
      this.extrapricecard});

  LiveChallengesData.fromJson(Map<String, dynamic> json) {
    userrank = ModelParsers.toIntParser(json["userrank"]);
    userpoints = ModelParsers.toNumParser(json["userpoints"]);
    userteamnumber = ModelParsers.toIntParser(json["userteamnumber"]);
    winAmountStr = ModelParsers.toStringParser(json["win_amount_str"]);
    jointeamid = ModelParsers.toStringParser(json["jointeamid"]);
    joinedleaugeId = ModelParsers.toStringParser(json["joinedleaugeId"]);
    matchchallengeid = ModelParsers.toStringParser(json["matchchallengeid"]);
    id = ModelParsers.toStringParser(json["_id"]);
    matchkey = ModelParsers.toStringParser(json["matchkey"]);
    isRecent = ModelParsers.toBoolParser(json["is_recent"]);
    expertName = ModelParsers.toStringParser(json["expert_name"]);
    isExpert = ModelParsers.toIntParser(json["is_expert"]);
    image = ModelParsers.toStringParser(json["image"]);
    subscriptionFee = ModelParsers.toIntParser(json["subscription_fee"]);
    discountFee = ModelParsers.toIntParser(json["discountFee"]);
    endDate = ModelParsers.toStringParser(json["endDate"]);
    startDate = ModelParsers.toStringParser(json["startDate"]);
    refercode = ModelParsers.toStringParser(json["refercode"]);
    winningpriceAndPrize =
        ModelParsers.toStringParser(json["WinningpriceAndPrize"]);
    contestName = ModelParsers.toStringParser(json["contest_name"]);
    winAmount = ModelParsers.toNumParser(json["winAmount"]);
    isPrivate = ModelParsers.toIntParser(json["isPrivate"]);
    isBonus = ModelParsers.toIntParser(json["isBonus"]);
    bonusPercentage = ModelParsers.toIntParser(json["bonusPercentage"]);
    winningPercentage = ModelParsers.toIntParser(json["winningPercentage"]);
    contestType = ModelParsers.toStringParser(json["contestType"]);
    confirmedChallenge = ModelParsers.toIntParser(json["confirmedChallenge"]);
    multiEntry = ModelParsers.toIntParser(json["multiEntry"]);
    joinedusers = ModelParsers.toIntParser(json["joinedusers"]);
    entryfee = ModelParsers.toIntParser(json["entryfee"]);
    pricecardType = ModelParsers.toStringParser(json["pricecard_type"]);
    maximumUser = ModelParsers.toIntParser(json["maximumUser"]);
    matchFinalstatus = ModelParsers.toStringParser(json["matchFinalstatus"]);
    matchChallengeStatus =
        ModelParsers.toStringParser(json["matchChallengeStatus"]);
    totalwinning = ModelParsers.toStringParser(json["totalwinning"]);
    isselected = ModelParsers.toBoolParser(json["isselected"]);
    totalwinners = ModelParsers.toIntParser(json["totalwinners"]);
    matchpricecards = json["matchpricecards"] == null
        ? null
        : (json["matchpricecards"] as List)
            .map((e) => Matchpricecards.fromJson(e))
            .toList();
    pricecardstatus = ModelParsers.toIntParser(json["pricecardstatus"]);
    userTeams = json["userTeams"] == null
        ? null
        : (json["userTeams"] as List)
            .map((e) => UserTeams.fromJson(e))
            .toList();
    amountType = ModelParsers.toStringParser(json["amount_type"]);
    giftImage = ModelParsers.toStringParser(json["gift_image"]);
    giftType = ModelParsers.toStringParser(json["gift_type"]);
    prizeName = ModelParsers.toStringParser(json["prize_name"]);
    flexibleContest = ModelParsers.toStringParser(json["flexibleContest"]);
    teamLimit = ModelParsers.toIntParser(json["teamLimit"]);
    isPromoCodeContest = ModelParsers.toBoolParser(json["isPromoCodeContest"]);
    totalTeams = ModelParsers.toIntParser(json["totalTeams"]);
    totalJoinedcontest = ModelParsers.toIntParser(json["totalJoinedcontest"]);
    extrapricecard = json['extrapricecard'] == null
        ? null
        : List<Extrapricecard>.from(
            json["extrapricecard"]!.map((x) => Extrapricecard.fromJson(x)));
  }
}

class UserTeams {
  String? id;
  num? points;
  int? getcurrentrank;
  String? challengeid;
  String? matchkey;
  bool? lastUpdate;
  int? teamnumber;
  String? userno;
  String? userjoinid;
  String? userid;
  String? jointeamid;
  String? teamname;
  int? joinNumber;
  String? image;
  String? playerType;
  String? winingamount;
  String? contestWinningType;

  UserTeams({
    this.id,
    this.points,
    this.getcurrentrank,
    this.challengeid,
    this.matchkey,
    this.lastUpdate,
    this.teamnumber,
    this.userno,
    this.userjoinid,
    this.userid,
    this.jointeamid,
    this.teamname,
    this.joinNumber,
    this.image,
    this.playerType,
    this.winingamount,
    this.contestWinningType,
  });

  factory UserTeams.fromJson(Map<String, dynamic> json) => UserTeams(
        id: json["_id"],
        points: json["points"],
        getcurrentrank: json["getcurrentrank"],
        challengeid: json["challengeid"],
        matchkey: json["matchkey"],
        lastUpdate: json["lastUpdate"],
        teamnumber: json["teamnumber"],
        userno: json["userno"],
        userjoinid: json["userjoinid"],
        userid: json["userid"],
        jointeamid: json["jointeamid"],
        teamname: json["teamname"],
        joinNumber: json["joinNumber"],
        image: json["image"],
        playerType: json["player_type"],
        winingamount: json["winingamount"],
        contestWinningType: json["contest_winning_type"],
      );
}
