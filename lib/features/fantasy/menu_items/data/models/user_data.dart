import 'package:Dream247/core/utils/model_parsers.dart';

class UserFullDetailsResponse {
  String? id;
  String? username;
  String? name;
  int? mobile;
  String? email;
  int? promoterVerify;
  int? pincode;
  String? address;
  String? dob;
  String? dayOfBirth;
  String? monthOfBirth;
  String? yearOfBirth;
  String? gender;
  String? image;
  String? activationStatus;
  String? state;
  String? city;
  String? team;
  int? teamfreeze;
  String? referCode;
  String? totalbalance;
  String? totalwon;
  String? totalbonus;
  String? totalExtraCash;
  String? totalCoin;
  String? totalticket;
  String? totalpasses;
  num? level;
  num? nextLevel;
  num? walletamaount;
  int? verified;
  int? downloadapk;
  int? emailfreeze;
  int? mobilefreeze;
  int? mobileVerified;
  int? emailVerified;
  int? panVerified;
  int? bankVerified;
  int? aadharVerified;
  int? statefreeze;
  int? dobfreeze;
  int? totalrefers;
  num? totalwinning;
  int? totalchallenges;
  int? totalmatches;
  int? totalseries;
  bool? teamNameUpdateStatus;
  String? joiningDate;
  bool? isPromoterBlocked;

  UserFullDetailsResponse({
    this.id,
    this.username,
    this.name,
    this.joiningDate,
    this.mobile,
    this.email,
    this.promoterVerify,
    this.isPromoterBlocked,
    this.pincode,
    this.address,
    this.dob,
    this.dayOfBirth,
    this.monthOfBirth,
    this.yearOfBirth,
    this.gender,
    this.image,
    this.activationStatus,
    this.state,
    this.city,
    this.team,
    this.teamfreeze,
    this.referCode,
    this.totalbalance,
    this.totalwon,
    this.totalbonus,
    this.totalExtraCash,
    this.totalCoin,
    this.totalticket,
    this.totalpasses,
    this.level,
    this.nextLevel,
    this.walletamaount,
    this.verified,
    this.downloadapk,
    this.emailfreeze,
    this.mobilefreeze,
    this.mobileVerified,
    this.emailVerified,
    this.panVerified,
    this.bankVerified,
    this.aadharVerified,
    this.statefreeze,
    this.dobfreeze,
    this.totalrefers,
    this.totalwinning,
    this.totalchallenges,
    this.totalmatches,
    this.totalseries,
    this.teamNameUpdateStatus,
  });

  factory UserFullDetailsResponse.fromJson(Map<String, dynamic> json) =>
      UserFullDetailsResponse(
        id: ModelParsers.toStringParser(json["id"]),
        username: ModelParsers.toStringParser(json["username"]),
        name: ModelParsers.toStringParser(json["name"]),
        joiningDate: ModelParsers.toStringParser(json["joining_date"]),
        mobile: ModelParsers.toIntParser(json["mobile"]),
        email: ModelParsers.toStringParser(json["email"]),
        promoterVerify: ModelParsers.toIntParser(json["promoter_verify"]),
        isPromoterBlocked: ModelParsers.toBoolParser(json["isPromoterBlocked"]),
        pincode: ModelParsers.toIntParser(json["pincode"]),
        address: ModelParsers.toStringParser(json["address"]),
        dob: ModelParsers.toStringParser(json["dob"]),
        dayOfBirth: ModelParsers.toStringParser(json["DayOfBirth"]),
        monthOfBirth: ModelParsers.toStringParser(json["MonthOfBirth"]),
        yearOfBirth: ModelParsers.toStringParser(json["YearOfBirth"]),
        gender: ModelParsers.toStringParser(json["gender"]),
        image: ModelParsers.toStringParser(json["image"]),
        activationStatus:
            ModelParsers.toStringParser(json["activation_status"]),
        state: ModelParsers.toStringParser(json["state"]),
        city: ModelParsers.toStringParser(json["city"]),
        team: ModelParsers.toStringParser(json["team"]),
        teamfreeze: ModelParsers.toIntParser(json["teamfreeze"]),
        referCode: ModelParsers.toStringParser(json["signupReward"]),
        totalbalance: ModelParsers.toStringParser(json["totalbalance"]),
        totalwon: ModelParsers.toStringParser(json["totalwon"]),
        totalbonus: ModelParsers.toStringParser(json["totalbonus"]),
        totalExtraCash: ModelParsers.toStringParser(json["totalExtraCash"]),
        totalCoin: ModelParsers.toStringParser(json["totalCoin"]),
        totalticket: ModelParsers.toStringParser(json["totalticket"]),
        totalpasses: ModelParsers.toStringParser(json["totalpasses"]),
        level: ModelParsers.toNumParser(json["level"]),
        nextLevel: ModelParsers.toNumParser(json["nextLevel"]),
        walletamaount: ModelParsers.toNumParser(json["walletamaount"]),
        verified: ModelParsers.toIntParser(json["verified"]),
        downloadapk: ModelParsers.toIntParser(json["downloadapk"]),
        emailfreeze: ModelParsers.toIntParser(json["emailfreeze"]),
        mobilefreeze: ModelParsers.toIntParser(json["mobilefreeze"]),
        mobileVerified: ModelParsers.toIntParser(json["mobileVerified"]),
        emailVerified: ModelParsers.toIntParser(json["emailVerified"]),
        panVerified: ModelParsers.toIntParser(json["PanVerified"]),
        bankVerified: ModelParsers.toIntParser(json["BankVerified"]),
        aadharVerified: ModelParsers.toIntParser(json["AadharVerified"]),
        statefreeze: ModelParsers.toIntParser(json["statefreeze"]),
        dobfreeze: ModelParsers.toIntParser(json["dobfreeze"]),
        totalrefers: ModelParsers.toIntParser(json["totalrefers"]),
        totalwinning: ModelParsers.toNumParser(json["totalwinning"]),
        totalchallenges: ModelParsers.toIntParser(json["totalchallenges"]),
        totalmatches: ModelParsers.toIntParser(json["totalmatches"]),
        totalseries: ModelParsers.toIntParser(json["totalseries"]),
        teamNameUpdateStatus:
            ModelParsers.toBoolParser(json["teamNameUpdateStatus"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "name": name,
        "joining_date": joiningDate.toString(),
        "mobile": mobile,
        "email": email,
        "promoter_verify": promoterVerify,
        "isPromoterBlocked": isPromoterBlocked,
        "pincode": pincode,
        "address": address,
        "dob": dob,
        "DayOfBirth": dayOfBirth,
        "MonthOfBirth": monthOfBirth,
        "YearOfBirth": yearOfBirth,
        "gender": gender,
        "image": image,
        "activation_status": activationStatus,
        "state": state,
        "city": city,
        "team": team,
        "teamfreeze": teamfreeze,
        "refer_code": referCode,
        "totalbalance": totalbalance,
        "totalwon": totalwon,
        "totalbonus": totalbonus,
        "totalExtraCash": totalExtraCash,
        "totalCoin": totalCoin,
        "totalticket": totalticket,
        "totalpasses": totalpasses,
        "level": level,
        "nextLevel": nextLevel,
        "walletamaount": walletamaount,
        "verified": verified,
        "downloadapk": downloadapk,
        "emailfreeze": emailfreeze,
        "mobilefreeze": mobilefreeze,
        "mobileVerified": mobileVerified,
        "emailVerified": emailVerified,
        "PanVerified": panVerified,
        "BankVerified": bankVerified,
        "AadharVerified": aadharVerified,
        "statefreeze": statefreeze,
        "dobfreeze": dobfreeze,
        "totalrefers": totalrefers,
        "totalwinning": totalwinning,
        "totalchallenges": totalchallenges,
        "totalmatches": totalmatches,
        "totalseries": totalseries,
        "teamNameUpdateStatus": teamNameUpdateStatus,
      };
}
