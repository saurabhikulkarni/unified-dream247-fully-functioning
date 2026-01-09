import 'package:unified_dream247/features/fantasy/core/utils/model_parsers.dart';
import 'package:unified_dream247/features/fantasy/features/landing/data/models/games_get_set.dart';

class AppVersionResponse {
  int? version;
  int? maintenance;
  int? maintenanceIos;
  String? point;
  String? appstatus;
  int? androidversion;
  int? iosVersion;
  String? referurl;
  String? apkname;
  String? androidappurl;
  String? refermessage;
  String? contestsharemessage;
  int? minwithdraw;
  int? maxwithdraw;
  int? referBonus;
  int? signupBonus;
  int? minadd;
  int? disableWithdraw;
  String? supportmobile;
  String? supportemail;
  String? updationmessage;
  List<GamesGetSet>? games;
  PaymentGatewayMethod? androidpaymentgateway;
  PaymentGatewayMethod? iospaymentgateway;
  String? s3Folder;
  int? seriesLeaderboard;
  int? investmentLeaderboard;
  int? privateContest;
  int? guruTeam;
  int? tds;
  bool? myJoinedContest;
  bool? transactionDetails;
  num? p2pCashback;
  num? winningDepositCashback;
  bool? verificationOnJoinContest;
  bool? viewcompletedmatches;
  Transfer? selftransfer;
  Transfer? ptoptransfer;
  String? pdfUrl;
  bool? cricketgame;
  bool? dualgame;
  int? flexibleContest;
  bool? applyForGuru;
  String? playerJsonUrl;
  int? gst;

  AppVersionResponse({
    this.version,
    this.maintenance,
    this.maintenanceIos,
    this.point,
    this.appstatus,
    this.androidversion,
    this.iosVersion,
    this.referurl,
    this.apkname,
    this.androidappurl,
    this.refermessage,
    this.contestsharemessage,
    this.minwithdraw,
    this.maxwithdraw,
    this.referBonus,
    this.signupBonus,
    this.minadd,
    this.supportmobile,
    this.supportemail,
    this.updationmessage,
    this.games,
    this.disableWithdraw,
    this.s3Folder,
    this.seriesLeaderboard,
    this.investmentLeaderboard,
    this.privateContest,
    this.guruTeam,
    this.tds,
    this.myJoinedContest,
    this.transactionDetails,
    this.p2pCashback,
    this.winningDepositCashback,
    this.verificationOnJoinContest,
    this.viewcompletedmatches,
    this.androidpaymentgateway,
    this.iospaymentgateway,
    this.selftransfer,
    this.ptoptransfer,
    this.pdfUrl,
    this.cricketgame,
    this.dualgame,
    this.flexibleContest,
    this.applyForGuru,
    this.playerJsonUrl,
    this.gst,
  });

  AppVersionResponse.fromJson(Map<String, dynamic> json) {
    version = ModelParsers.toIntParser(json['version']);
    maintenance = ModelParsers.toIntParser(json['maintenance']);
    maintenanceIos = ModelParsers.toIntParser(json["iOSmaintenance"]);
    point = ModelParsers.toStringParser(json['point']);
    appstatus = ModelParsers.toStringParser(json['appstatus']);
    androidversion = ModelParsers.toIntParser(json['androidversion']);
    iosVersion = ModelParsers.toIntParser(json['iOSversion']);
    referurl = ModelParsers.toStringParser(json['referurl']);
    apkname = ModelParsers.toStringParser(json['apkname']);
    androidappurl = ModelParsers.toStringParser(json['androidappurl']);
    refermessage = ModelParsers.toStringParser(json['refermessage']);
    contestsharemessage = ModelParsers.toStringParser(
      json['contestsharemessage'],
    );
    minwithdraw = ModelParsers.toIntParser(json['minwithdraw']);
    maxwithdraw = ModelParsers.toIntParser(json['maxwithdraw']);
    referBonus = ModelParsers.toIntParser(json['refer_bonus']);
    signupBonus = ModelParsers.toIntParser(json['signup_bonus']);
    minadd = ModelParsers.toIntParser(json['minadd']);
    supportmobile = ModelParsers.toStringParser(json['supportmobile']);
    supportemail = ModelParsers.toStringParser(json['supportemail']);
    updationmessage = ModelParsers.toStringParser(json['updationmessage']);
    disableWithdraw = ModelParsers.toIntParser(json['disableWithdraw']);
    s3Folder = ModelParsers.toStringParser(json["s3Folder"]);
    if (json['games'] != null) {
      games = <GamesGetSet>[];
      json['games'].forEach((v) {
        games!.add(GamesGetSet.fromJson(v));
      });
    }
    seriesLeaderboard = ModelParsers.toIntParser(json["seriesLeaderboard"]);
    investmentLeaderboard = ModelParsers.toIntParser(
      json["investmentLeaderboard"],
    );
    privateContest = ModelParsers.toIntParser(json["privateContest"]);
    guruTeam = ModelParsers.toIntParser(json["guruTeam"]);
    tds = ModelParsers.toIntParser(json["tds"]);
    myJoinedContest = ModelParsers.toBoolParser(json["myjoinedContest"]);
    transactionDetails = ModelParsers.toBoolParser(json["transactionDetails"]);
    p2pCashback = ModelParsers.toNumParser(json["p_to_p"]);
    winningDepositCashback = ModelParsers.toNumParser(
      json["winning_to_deposit"],
    );
    verificationOnJoinContest = ModelParsers.toBoolParser(
      json["verificationOnJoinContest"],
    );
    viewcompletedmatches = ModelParsers.toBoolParser(
      json["viewcompletedmatches"],
    );
    androidpaymentgateway = json["androidpaymentgateway"] == null
        ? null
        : PaymentGatewayMethod.fromJson(json["androidpaymentgateway"]);
    iospaymentgateway = json["iospaymentgateway"] == null
        ? null
        : PaymentGatewayMethod.fromJson(json["iospaymentgateway"]);
    selftransfer = json["selftransfer"] == null
        ? null
        : Transfer.fromJson(json["selftransfer"]);
    ptoptransfer = json["ptoptransfer"] == null
        ? null
        : Transfer.fromJson(json["ptoptransfer"]);
    pdfUrl = ModelParsers.toStringParser(json["pdfUrl"]);
    cricketgame = ModelParsers.toBoolParser(json["cricketgame"]);
    dualgame = ModelParsers.toBoolParser(json["dualgame"]);
    flexibleContest = ModelParsers.toIntParser(json["flexibleContest"]);
    applyForGuru = ModelParsers.toBoolParser(json["applyForGuru"]);
    playerJsonUrl = ModelParsers.toStringParser(json["playerJsonUrl"]);
    gst = ModelParsers.toIntParser(json["gst"]);
  }
}

class PaymentGatewayMethod {
  PayLimits? isSabPaisa;
  PayLimits? isRazorPay;
  PayLimits? isCashFree;
  PayLimits? isPhonePe;
  PayLimits? isYesBank;
  PayLimits? isPaySprint;

  PaymentGatewayMethod({
    this.isSabPaisa,
    this.isRazorPay,
    this.isCashFree,
    this.isPhonePe,
    this.isYesBank,
    this.isPaySprint,
  });

  factory PaymentGatewayMethod.fromJson(Map<String, dynamic> json) =>
      PaymentGatewayMethod(
        isSabPaisa: json["isSabPaisa"] == null
            ? null
            : PayLimits.fromJson(json["isSabPaisa"]),
        isRazorPay: json["isRazorPay"] == null
            ? null
            : PayLimits.fromJson(json["isRazorPay"]),
        isCashFree: json["isCashFree"] == null
            ? null
            : PayLimits.fromJson(json["isCashFree"]),
        isPhonePe: json["isPhonePe"] == null
            ? null
            : PayLimits.fromJson(json["isPhonePe"]),
        isYesBank: json["isYesBank"] == null
            ? null
            : PayLimits.fromJson(json["isYesBank"]),
        isPaySprint: json["isPaySprint"] == null
            ? null
            : PayLimits.fromJson(json["isPaySprint"]),
      );
}

class PayLimits {
  bool? status;
  String? min;
  String? max;

  PayLimits({this.status, this.min, this.max});

  factory PayLimits.fromJson(Map<String, dynamic> json) => PayLimits(
        status: ModelParsers.toBoolParser(json["status"]),
        min: ModelParsers.toStringParser(json["min"]),
        max: ModelParsers.toStringParser(json["max"]),
      );
}

class Transfer {
  bool? status;
  int? min;
  int? max;

  Transfer({this.status, this.min, this.max});

  factory Transfer.fromJson(Map<String, dynamic> json) => Transfer(
        status: ModelParsers.toBoolParser(json["status"]),
        min: ModelParsers.toIntParser(json["min"]),
        max: ModelParsers.toIntParser(json["max"]),
      );
}
