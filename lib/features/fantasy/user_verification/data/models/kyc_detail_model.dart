import 'package:Dream247/core/utils/model_parsers.dart';

class KycDetailsModel {
  String? id;
  String? email;
  int? mobile;
  Aadharcard? aadharcard;
  Bank? bank;
  Pancard? pancard;
  int? emailVerify;
  int? mobileVerify;
  int? aadharVerify;
  int? panVerify;
  int? bankVerify;

  KycDetailsModel({
    this.id,
    this.email,
    this.mobile,
    this.aadharcard,
    this.bank,
    this.pancard,
    this.emailVerify,
    this.mobileVerify,
    this.aadharVerify,
    this.panVerify,
    this.bankVerify,
  });

  factory KycDetailsModel.fromJson(Map<String, dynamic> json) =>
      KycDetailsModel(
        id: ModelParsers.toStringParser(json["_id"]),
        email: ModelParsers.toStringParser(json["email"]),
        mobile: ModelParsers.toIntParser(json["mobile"]),
        aadharcard: json["aadharcard"] == null
            ? null
            : Aadharcard.fromJson(json["aadharcard"]),
        bank: json["bank"] == null ? null : Bank.fromJson(json["bank"]),
        pancard:
            json["pancard"] == null ? null : Pancard.fromJson(json["pancard"]),
        emailVerify: ModelParsers.toIntParser(json["email_verify"]),
        mobileVerify: ModelParsers.toIntParser(json["mobile_verify"]),
        aadharVerify: ModelParsers.toIntParser(json["aadhar_verify"]),
        panVerify: ModelParsers.toIntParser(json["pan_verify"]),
        bankVerify: ModelParsers.toIntParser(json["bank_verify"]),
      );
}

class Aadharcard {
  String? aadharName;
  String? aadharNumber;
  String? state;
  String? frontimage;
  String? aadharDob;
  List<dynamic>? image;
  int? status;
  String? pincode;
  String? gender;
  String? city;
  String? address;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool? manualKyc;
  DailyLimit? dailyLimit;
  String? id;

  Aadharcard({
    this.aadharName,
    this.aadharNumber,
    this.state,
    this.frontimage,
    this.aadharDob,
    this.image,
    this.status,
    this.pincode,
    this.gender,
    this.city,
    this.address,
    this.createdAt,
    this.updatedAt,
    this.manualKyc,
    this.dailyLimit,
    this.id,
  });

  factory Aadharcard.fromJson(Map<String, dynamic> json) => Aadharcard(
        aadharName: ModelParsers.toStringParser(json["aadhar_name"]),
        aadharNumber: ModelParsers.toStringParser(json["aadhar_number"]),
        state: ModelParsers.toStringParser(json["state"]),
        frontimage: ModelParsers.toStringParser(json["frontimage"]),
        aadharDob: ModelParsers.toStringParser(json["aadhar_dob"]),
        image: json["image"] == null
            ? []
            : List<dynamic>.from(json["image"]!.map((x) => x)),
        status: ModelParsers.toIntParser(json["status"]),
        pincode: ModelParsers.toStringParser(json["pincode"]),
        gender: ModelParsers.toStringParser(json["gender"]),
        city: ModelParsers.toStringParser(json["city"]),
        address: ModelParsers.toStringParser(json["address"]),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        manualKyc: ModelParsers.toBoolParser(json["manualKyc"]),
        dailyLimit: json["dailyLimit"] == null
            ? null
            : DailyLimit.fromJson(json["dailyLimit"]),
        id: ModelParsers.toStringParser(json["_id"]),
      );
}

class DailyLimit {
  int? count;
  String? lastAttemptDate;

  DailyLimit({
    this.count,
    this.lastAttemptDate,
  });

  factory DailyLimit.fromJson(Map<String, dynamic> json) => DailyLimit(
        count: ModelParsers.toIntParser(json["count"]),
        lastAttemptDate: ModelParsers.toStringParser(json["lastAttemptDate"]),
      );
}

class Bank {
  String? accountholder;
  String? accno;
  String? ifsc;
  String? bankname;
  String? bankbranch;
  int? status;
  String? comment;
  String? type;
  String? city;
  DateTime? createdAt;
  DateTime? updatedAt;
  DailyLimit? dailyLimit;
  String? id;

  Bank({
    this.accountholder,
    this.accno,
    this.ifsc,
    this.bankname,
    this.bankbranch,
    this.status,
    this.comment,
    this.type,
    this.city,
    this.createdAt,
    this.updatedAt,
    this.dailyLimit,
    this.id,
  });

  factory Bank.fromJson(Map<String, dynamic> json) => Bank(
        accountholder: ModelParsers.toStringParser(json["accountholder"]),
        accno: ModelParsers.toStringParser(json["accno"]),
        ifsc: ModelParsers.toStringParser(json["ifsc"]),
        bankname: ModelParsers.toStringParser(json["bankname"]),
        bankbranch: ModelParsers.toStringParser(json["bankbranch"]),
        status: ModelParsers.toIntParser(json["status"]),
        comment: ModelParsers.toStringParser(json["comment"]),
        type: ModelParsers.toStringParser(json["type"]),
        city: ModelParsers.toStringParser(json["city"]),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        dailyLimit: json["dailyLimit"] == null
            ? null
            : DailyLimit.fromJson(json["dailyLimit"]),
        id: json["_id"],
      );
}

class Pancard {
  String? panName;
  String? panNumber;
  int? status;
  String? comment;
  DateTime? createdAt;
  DateTime? updatedAt;
  DailyLimit? dailyLimit;
  String? id;

  Pancard({
    this.panName,
    this.panNumber,
    this.status,
    this.comment,
    this.createdAt,
    this.updatedAt,
    this.dailyLimit,
    this.id,
  });

  factory Pancard.fromJson(Map<String, dynamic> json) => Pancard(
        panName: ModelParsers.toStringParser(json["pan_name"]),
        panNumber: ModelParsers.toStringParser(json["pan_number"]),
        status: ModelParsers.toIntParser(json["status"]),
        comment: ModelParsers.toStringParser(json["comment"]),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        dailyLimit: json["dailyLimit"] == null
            ? null
            : DailyLimit.fromJson(json["dailyLimit"]),
        id: ModelParsers.toStringParser(json["_id"]),
      );
}
