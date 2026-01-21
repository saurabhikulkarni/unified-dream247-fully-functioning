import 'package:unified_dream247/features/fantasy/core/utils/model_parsers.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/all_contests_model.dart';

class JoinedContestResponseModel {
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
  String? plus;
  String? amountType;
  String? giftImage;
  String? giftType;
  String? prizeName;
  int? totalTeams;
  String? flexibleContest;
  int? totalJoinedcontest;

  JoinedContestResponseModel(
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
      this.plus,
      this.amountType,
      this.giftImage,
      this.giftType,
      this.prizeName,
      this.totalTeams,
      this.totalJoinedcontest,
      this.flexibleContest,});

  JoinedContestResponseModel.fromJson(Map<String, dynamic> json) {
    userrank = ModelParsers.toIntParser(json['userrank']);
    userpoints = ModelParsers.toNumParser(json['userpoints']);
    userteamnumber = ModelParsers.toIntParser(json['userteamnumber']);
    winAmountStr = ModelParsers.toStringParser(json['win_amount_str']);
    jointeamid = ModelParsers.toStringParser(json['jointeamid']);
    joinedleaugeId = ModelParsers.toStringParser(json['joinedleaugeId']);
    matchchallengeid = ModelParsers.toStringParser(json['matchchallengeid']);
    id = ModelParsers.toStringParser(json['_id']);
    matchkey = ModelParsers.toStringParser(json['matchkey']);
    isRecent = ModelParsers.toBoolParser(json['is_recent']);
    expertName = ModelParsers.toStringParser(json['expert_name']);
    isExpert = ModelParsers.toIntParser(json['is_expert']);
    image = ModelParsers.toStringParser(json['image']);
    subscriptionFee = ModelParsers.toIntParser(json['subscription_fee']);
    discountFee = ModelParsers.toIntParser(json['discount_fee']);
    endDate = ModelParsers.toStringParser(json['endDate']);
    startDate = ModelParsers.toStringParser(json['startDate']);
    refercode = ModelParsers.toStringParser(json['refercode']);
    winningpriceAndPrize =
        ModelParsers.toStringParser(json['WinningpriceAndPrize']);
    contestName = ModelParsers.toStringParser(json['contest_name']);
    winAmount = ModelParsers.toNumParser(json['win_amount']);
    isPrivate = ModelParsers.toIntParser(json['is_private']);
    isBonus = ModelParsers.toIntParser(json['is_bonus']);
    bonusPercentage = ModelParsers.toIntParser(json['bonus_percentage']);
    winningPercentage = ModelParsers.toIntParser(json['winning_percentage']);
    contestType = ModelParsers.toStringParser(json['contest_type']);
    confirmedChallenge = ModelParsers.toIntParser(json['confirmed_challenge']);
    multiEntry = ModelParsers.toIntParser(json['multi_entry']);
    joinedusers = ModelParsers.toIntParser(json['joinedusers']);
    entryfee = ModelParsers.toIntParser(json['entryfee']);
    pricecardType = ModelParsers.toStringParser(json['pricecard_type']);
    maximumUser = ModelParsers.toIntParser(json['maximum_user']);
    matchFinalstatus = ModelParsers.toStringParser(json['matchFinalstatus']);
    matchChallengeStatus =
        ModelParsers.toStringParser(json['matchChallengeStatus']);
    totalwinning = ModelParsers.toStringParser(json['totalwinning']);
    isselected = ModelParsers.toBoolParser(json['isselected']);
    totalwinners = ModelParsers.toIntParser(json['totalwinners']);
    matchpricecards = json['matchpricecards'] == null
        ? null
        : (json['matchpricecards'] as List)
            .map((e) => Matchpricecards.fromJson(e))
            .toList();
    pricecardstatus = ModelParsers.toIntParser(json['pricecardstatus']);
    userTeams = json['userTeams'] == null
        ? null
        : (json['userTeams'] as List)
            .map((e) => UserTeams.fromJson(e))
            .toList();
    teamLimit = ModelParsers.toIntParser(json['team_limit']);
    plus = ModelParsers.toStringParser(json['plus']);
    amountType = ModelParsers.toStringParser(json['amount_type']);
    giftImage = ModelParsers.toStringParser(json['gift_image']);
    giftType = ModelParsers.toStringParser(json['gift_type']);
    prizeName = ModelParsers.toStringParser(json['prize_name']);
    totalTeams = ModelParsers.toIntParser(json['total_teams']);
    flexibleContest = ModelParsers.toStringParser(json['flexible_contest']);
    totalJoinedcontest = ModelParsers.toIntParser(json['total_joinedcontest']);
  }
}

class UserTeams {
  String? id;
  String? teamId;
  String? captain;
  String? vicecaptain;
  num? points;
  int? teamnumber;
  int? rank;
  num? amount;

  UserTeams(
      {this.id,
      this.teamId,
      this.captain,
      this.vicecaptain,
      this.points,
      this.teamnumber,
      this.rank,
      this.amount,});

  UserTeams.fromJson(Map<String, dynamic> json) {
    id = ModelParsers.toStringParser(json['_id']);
    teamId = ModelParsers.toStringParser(json['teamId']);
    captain = ModelParsers.toStringParser(json['captain']);
    vicecaptain = ModelParsers.toStringParser(json['vicecaptain']);
    points = ModelParsers.toNumParser(json['points']);
    teamnumber = ModelParsers.toIntParser(json['teamnumber']);
    rank = ModelParsers.toIntParser(json['rank']);
    amount = ModelParsers.toNumParser(json['amount']);
  }
}
