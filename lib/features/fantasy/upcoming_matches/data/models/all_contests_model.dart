import 'package:Dream247/core/utils/model_parsers.dart';

class AllNewContestResponseModel {
  String? id;
  String? name;
  String? subTitle;
  String? image;
  String? type;
  String? catid;
  bool? isPromoCodeContest;
  String? contestCat;
  String? challengeId;
  int? entryfee;
  num? winAmount;
  num? maximumUser;
  int? joinedusers;
  List<UserTeams>? userTeams;
  String? contestType;
  String? amountType;
  num? winningPercentage;
  int? isBonus;
  int? bonusPercentage;
  String? pricecardType;
  int? minimumUser;
  int? confirmedChallenge;
  int? multiEntry;
  int? teamLimit;
  String? cType;
  int? isPrivate;
  String? winningpriceAndPrize;
  int? discountFee;
  List<Matchpricecards>? matchpricecards;
  bool? isselected;
  String? refercode;
  String? matchchallengeid;
  int? totalJoinedcontest;
  int? totalTeams;
  num? totalwinners;
  String? flexibleContest;
  int? conditionalContest;
  String? mandatoryContest;
  String? textNote;
  PriceCards? pricesCards;
  String? bonusType;
  int? pdfDownloadStatus;
  String? status;
  String? megaStatus;
  bool? compress;
  List<Extrapricecard>? extrapricecard;
  String? teamType;

  AllNewContestResponseModel({
    this.id,
    this.name,
    this.subTitle,
    this.image,
    this.type,
    this.catid,
    this.isPromoCodeContest,
    this.contestCat,
    this.challengeId,
    this.entryfee,
    this.winAmount,
    this.maximumUser,
    this.joinedusers,
    this.userTeams,
    this.contestType,
    this.amountType,
    this.winningPercentage,
    this.isBonus,
    this.bonusPercentage,
    this.pricecardType,
    this.minimumUser,
    this.confirmedChallenge,
    this.multiEntry,
    this.teamLimit,
    this.cType,
    this.isPrivate,
    this.winningpriceAndPrize,
    this.discountFee,
    this.matchpricecards,
    this.isselected,
    this.refercode,
    this.matchchallengeid,
    this.totalJoinedcontest,
    this.totalTeams,
    this.totalwinners,
    this.flexibleContest,
    this.conditionalContest,
    this.mandatoryContest,
    this.textNote,
    this.pricesCards,
    this.bonusType,
    this.pdfDownloadStatus,
    this.status,
    this.megaStatus,
    this.compress,
    this.extrapricecard,
    this.teamType,
  });

  AllNewContestResponseModel.fromJson(Map<String, dynamic> json) {
    id = ModelParsers.toStringParser(json["_id"]);
    name = ModelParsers.toStringParser(json["name"]);
    subTitle = ModelParsers.toStringParser(json["sub_title"]);
    image = ModelParsers.toStringParser(json["image"]);
    type = ModelParsers.toStringParser(json["type"]);
    catid = ModelParsers.toStringParser(json["catid"]);
    isPromoCodeContest = ModelParsers.toBoolParser(
      json["is_PromoCode_Contest"],
    );
    contestCat = ModelParsers.toStringParser(json["contest_cat"]);
    challengeId = ModelParsers.toStringParser(json["challenge_id"]);
    entryfee = ModelParsers.toIntParser(json["entryfee"]);
    winAmount = ModelParsers.toNumParser(json["win_amount"]);
    maximumUser = ModelParsers.toNumParser(json["maximum_user"]);
    joinedusers = ModelParsers.toIntParser(json["joinedusers"]);
    contestType = ModelParsers.toStringParser(json["contest_type"]);
    amountType = ModelParsers.toStringParser(json["amount_type"]);
    winningPercentage = ModelParsers.toNumParser(json["winning_percentage"]);
    isBonus = ModelParsers.toIntParser(json["is_bonus"]);
    bonusPercentage = ModelParsers.toIntParser(json["bonus_percentage"]);
    pricecardType = ModelParsers.toStringParser(json["pricecard_type"]);
    minimumUser = ModelParsers.toIntParser(json["minimum_user"]);
    confirmedChallenge = ModelParsers.toIntParser(json["confirmed_challenge"]);
    multiEntry = ModelParsers.toIntParser(json["multi_entry"]);
    teamLimit = ModelParsers.toIntParser(json["team_limit"]);
    cType = ModelParsers.toStringParser(json["c_type"]);
    isPrivate = ModelParsers.toIntParser(json["is_private"]);
    winningpriceAndPrize = ModelParsers.toStringParser(
      json["WinningpriceAndPrize"],
    );
    discountFee = ModelParsers.toIntParser(json["discount_fee"]);
    matchpricecards = json["matchpricecard"] == null
        ? []
        : List<Matchpricecards>.from(
            json["matchpricecard"]!.map((x) => Matchpricecards.fromJson(x)),
          );
    userTeams = json["userTeams"] == null
        ? null
        : (json["userTeams"] as List)
            .map((e) => UserTeams.fromJson(e))
            .toList();
    isselected = ModelParsers.toBoolParser(json["isselected"]);
    refercode = ModelParsers.toStringParser(json["refercode"]);
    matchchallengeid = ModelParsers.toStringParser(json["matchchallengeid"]);
    totalJoinedcontest = ModelParsers.toIntParser(json["total_joinedcontest"]);
    totalTeams = ModelParsers.toIntParser(json["total_teams"]);
    totalwinners = ModelParsers.toNumParser(json["totalwinners"]);
    flexibleContest = ModelParsers.toStringParser(json["flexible_contest"]);
    conditionalContest = ModelParsers.toIntParser(json["conditional_contest"]);
    mandatoryContest = ModelParsers.toStringParser(json["mandatoryContest"]);
    textNote = ModelParsers.toStringParser(json["textNote"]);
    pricesCards = json["price_card"] == null
        ? null
        : PriceCards.fromJson(json["price_card"]);
    bonusType = ModelParsers.toStringParser(json["bonus_type"]);
    pdfDownloadStatus = ModelParsers.toIntParser(json["pdfDownloadStatus"]);
    status = ModelParsers.toStringParser(json["status"]);
    megaStatus = ModelParsers.toStringParser(json["mega_status"]);
    compress = ModelParsers.toBoolParser(json["compress"]);
    extrapricecard = json['extrapricecard'] == null
        ? null
        : List<Extrapricecard>.from(
            json["extrapricecard"]!.map((x) => Extrapricecard.fromJson(x)),
          );
    teamType = ModelParsers.toStringParser(json["team_type_name"]);
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
  int? amount;

  UserTeams({
    this.id,
    this.teamId,
    this.captain,
    this.vicecaptain,
    this.points,
    this.teamnumber,
    this.rank,
    this.amount,
  });

  UserTeams.fromJson(Map<String, dynamic> json) {
    id = ModelParsers.toStringParser(json["_id"]);
    teamId = ModelParsers.toStringParser(json["teamId"]);
    captain = ModelParsers.toStringParser(json["captain"]);
    vicecaptain = ModelParsers.toStringParser(json["vicecaptain"]);
    points = ModelParsers.toNumParser(json["points"]);
    teamnumber = ModelParsers.toIntParser(json["teamnumber"]);
    rank = ModelParsers.toIntParser(json["rank"]);
    amount = ModelParsers.toIntParser(json["amount"]);
  }
}

class Matchpricecards {
  String? id;
  String? winners;
  num? total;
  num? price;
  String? giftType;
  String? image;
  String? startPosition;
  String? amountType;
  int? minPosition;
  int? maxPosition;

  Matchpricecards({
    this.id,
    this.winners,
    this.total,
    this.price,
    this.giftType,
    this.image,
    this.startPosition,
    this.amountType,
    this.minPosition,
    this.maxPosition,
  });

  factory Matchpricecards.fromJson(Map<String, dynamic> json) =>
      Matchpricecards(
        id: ModelParsers.toStringParser(json["id"]),
        winners: ModelParsers.toStringParser(json["winners"]),
        total: ModelParsers.toNumParser(json["total"]),
        price: ModelParsers.toNumParser(json["price"]),
        giftType: ModelParsers.toStringParser(json["gift_type"]),
        image: ModelParsers.toStringParser(json["image"]),
        startPosition: ModelParsers.toStringParser(json["start_position"]),
        amountType: ModelParsers.toStringParser(json["amount_type"]),
        minPosition: ModelParsers.toIntParser(json["min_position"]),
        maxPosition: ModelParsers.toIntParser(json["max_position"]),
      );
}

extension MatchpricecardsCopyWith on Matchpricecards {
  Matchpricecards copyWith({
    String? id,
    String? winners,
    num? total,
    num? price,
    String? giftType,
    String? image,
    String? startPosition,
    String? amountType,
    int? minPosition,
    int? maxPosition,
  }) {
    return Matchpricecards(
      id: id ?? this.id,
      winners: winners ?? this.winners,
      total: total ?? this.total,
      price: price ?? this.price,
      giftType: giftType ?? this.giftType,
      image: image ?? this.image,
      startPosition: startPosition ?? this.startPosition,
      amountType: amountType ?? this.amountType,
      minPosition: minPosition ?? this.minPosition,
      maxPosition: maxPosition ?? this.maxPosition,
    );
  }
}

class PriceCards {
  String? total;
  String? giftType;
  String? price;
  String? image;

  PriceCards({this.total, this.giftType, this.price, this.image});

  factory PriceCards.fromJson(Map<String, dynamic> json) => PriceCards(
        total: ModelParsers.toStringParser(json["total"]),
        giftType: ModelParsers.toStringParser(json["gift_type"]),
        price: ModelParsers.toStringParser(json["price"]),
        image: ModelParsers.toStringParser(json["image"]),
      );
}

class Extrapricecard {
  String? challengersId;
  String? matchkey;
  String? prizeName;
  num? price;
  num? rank;
  String? type;
  String? description;
  String? sId;
  String? createdAt;
  String? updatedAt;

  Extrapricecard({
    this.challengersId,
    this.matchkey,
    this.prizeName,
    this.price,
    this.rank,
    this.type,
    this.description,
    this.sId,
    this.createdAt,
    this.updatedAt,
  });

  Extrapricecard.fromJson(Map<String, dynamic> json) {
    challengersId = ModelParsers.toStringParser(json['challengersId']);
    matchkey = ModelParsers.toStringParser(json['matchkey']);
    prizeName = ModelParsers.toStringParser(json['prize_name']);
    price = ModelParsers.toNumParser(json['price']);
    rank = ModelParsers.toNumParser(json['rank']);
    type = ModelParsers.toStringParser(json['type']);
    description = ModelParsers.toStringParser(json['description']);
    sId = ModelParsers.toStringParser(json['_id']);
    createdAt = ModelParsers.toStringParser(json['createdAt']);
    updatedAt = ModelParsers.toStringParser(json['updatedAt']);
  }
}

class AllContestResponseModel {
  String? id;
  String? datumFantasyType;
  String? name;
  String? subTitle;
  int? order;
  String? image;
  int? tblOrder;
  String? hasLeaderBoard;
  bool? megaStatus;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? contestCat;
  String? matchChallengeId;
  String? fantasyType;
  String? type;
  bool? isPromoCodeContest;
  String? challengeId;
  String? matchkey;
  int? entryfee;
  num? winAmount;
  num? maximumUser;
  num? joinedusers;
  String? contestType;
  num? winningPercentage;
  int? isBonus;
  int? bonusPercentage;
  String? bonusType;
  int? confirmedChallenge;
  int? multiEntry;
  int? teamLimit;
  int? isPrivate;
  int? discountFee;
  PriceCards? priceCard;
  num? totalwinners;
  String? flexibleContest;
  int? conditionalContest;
  String? mandatoryContest;
  String? textNote;
  bool? isselected;
  String? refercode;
  int? totalJoinedcontest;
  int? totalTeams;
  bool? compress;
  List<UserTeams>? userTeams;
  List<Matchpricecards>? matchpricecard;
  List<PriceCards>? matchpricecards;
  List<Extrapricecard>? extrapricecard;
  String? teamType;

  AllContestResponseModel({
    this.id,
    this.datumFantasyType,
    this.name,
    this.subTitle,
    this.order,
    this.image,
    this.tblOrder,
    this.hasLeaderBoard,
    this.megaStatus,
    this.createdAt,
    this.updatedAt,
    this.contestCat,
    this.matchChallengeId,
    this.fantasyType,
    this.type,
    this.isPromoCodeContest,
    this.challengeId,
    this.matchkey,
    this.entryfee,
    this.winAmount,
    this.maximumUser,
    this.joinedusers,
    this.contestType,
    this.winningPercentage,
    this.isBonus,
    this.bonusPercentage,
    this.bonusType,
    this.confirmedChallenge,
    this.multiEntry,
    this.teamLimit,
    this.isPrivate,
    this.discountFee,
    this.priceCard,
    this.totalwinners,
    this.flexibleContest,
    this.conditionalContest,
    this.mandatoryContest,
    this.textNote,
    this.isselected,
    this.refercode,
    this.totalJoinedcontest,
    this.totalTeams,
    this.userTeams,
    this.compress,
    this.matchpricecard,
    this.matchpricecards,
    this.extrapricecard,
    this.teamType,
  });

  factory AllContestResponseModel.fromJson(
    Map<String, dynamic> json,
  ) =>
      AllContestResponseModel(
        id: ModelParsers.toStringParser(json["_id"]),
        datumFantasyType: ModelParsers.toStringParser(json["fantasy_type"]),
        name: ModelParsers.toStringParser(json["name"]),
        subTitle: ModelParsers.toStringParser(json["sub_title"]),
        order: ModelParsers.toIntParser(json["Order"]),
        image: ModelParsers.toStringParser(json["image"]),
        tblOrder: ModelParsers.toIntParser(json["tbl_order"]),
        hasLeaderBoard: ModelParsers.toStringParser(json["has_leaderBoard"]),
        megaStatus: ModelParsers.toBoolParser(json["megaStatus"]),
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        contestCat: ModelParsers.toStringParser(json["contest_cat"]),
        matchChallengeId: ModelParsers.toStringParser(json["id"]),
        fantasyType: ModelParsers.toStringParser(json["fantasyType"]),
        type: ModelParsers.toStringParser(json["type"]),
        isPromoCodeContest:
            ModelParsers.toBoolParser(json["isPromoCodeContest"]),
        challengeId: ModelParsers.toStringParser(json["challengeId"]),
        matchkey: ModelParsers.toStringParser(json["matchkey"]),
        entryfee: ModelParsers.toIntParser(json["entryfee"]),
        winAmount: ModelParsers.toNumParser(json["winAmount"]),
        maximumUser: ModelParsers.toNumParser(json["maximumUser"]),
        joinedusers: ModelParsers.toNumParser(json["joinedusers"]),
        contestType: ModelParsers.toStringParser(json["contestType"]),
        winningPercentage: ModelParsers.toNumParser(json["winningPercentage"]),
        isBonus: ModelParsers.toIntParser(json["isBonus"]),
        bonusPercentage: ModelParsers.toIntParser(json["bonusPercentage"]),
        bonusType: ModelParsers.toStringParser(json["bonus_type"]),
        confirmedChallenge:
            ModelParsers.toIntParser(json["confirmedChallenge"]),
        multiEntry: ModelParsers.toIntParser(json["multiEntry"]),
        teamLimit: ModelParsers.toIntParser(json["teamLimit"]),
        isPrivate: ModelParsers.toIntParser(json["isPrivate"]),
        discountFee: ModelParsers.toIntParser(json["discountFee"]),
        priceCard: json["price_card"] != null
            ? PriceCards.fromJson(json["price_card"])
            : (json["matchpricecards"] != null &&
                    json["matchpricecards"] is List &&
                    json["matchpricecards"].isNotEmpty)
                ? PriceCards.fromJson(json["matchpricecards"][0])
                : null,
        totalwinners: ModelParsers.toNumParser(json["totalwinners"]),
        flexibleContest: ModelParsers.toStringParser(json["flexibleContest"]),
        conditionalContest:
            ModelParsers.toIntParser(json["conditionalContest"]),
        mandatoryContest: ModelParsers.toStringParser(json["mandatoryContest"]),
        textNote: ModelParsers.toStringParser(json["textNote"]),
        isselected: ModelParsers.toBoolParser(json["isselected"]),
        refercode: ModelParsers.toStringParser(json["refercode"]),
        totalJoinedcontest:
            ModelParsers.toIntParser(json["totalJoinedcontest"]),
        totalTeams: ModelParsers.toIntParser(json["totalTeams"]),
        compress: ModelParsers.toBoolParser(json["compress"]),
        matchpricecards: json["matchpricecards"] == null
            ? []
            : (json["matchpricecards"] is List)
                ? List<PriceCards>.from(
                    json["matchpricecards"].map((x) => PriceCards.fromJson(x)),
                  )
                : [PriceCards.fromJson(json["matchpricecards"])],
        matchpricecard: json["matchpricecard"] == null
            ? []
            : (json["matchpricecard"] is List)
                ? List<Matchpricecards>.from(
                    json["matchpricecard"]
                        .map((x) => Matchpricecards.fromJson(x)),
                  )
                : [Matchpricecards.fromJson(json["matchpricecard"])],
        userTeams: json["userTeams"] == null
            ? null
            : (json["userTeams"] as List)
                .map((e) => UserTeams.fromJson(e))
                .toList(),
        extrapricecard: json['extrapricecard'] == null
            ? null
            : List<Extrapricecard>.from(
                json["extrapricecard"]!.map((x) => Extrapricecard.fromJson(x)),
              ),
        teamType: ModelParsers.toStringParser(json["team_type_name"]),
      );
}
