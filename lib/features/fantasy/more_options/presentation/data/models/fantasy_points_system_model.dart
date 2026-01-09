import 'package:Dream247/core/utils/model_parsers.dart';

class FantasyPointsSystemModel {
  bool? success;
  String? message;
  bool? status;
  List<FantasyPointsSystemData>? data;

  FantasyPointsSystemModel(
      {this.success, this.message, this.status, this.data});

  FantasyPointsSystemModel.fromJson(Map<String, dynamic> json) {
    success = ModelParsers.toBoolParser(json["success"]);
    message = ModelParsers.toStringParser(json["message"]);
    status = ModelParsers.toBoolParser(json["status"]);
    data = json["data"] == null
        ? null
        : (json["data"] as List)
            .map((e) => FantasyPointsSystemData.fromJson(e))
            .toList();
  }
}

class FantasyPointsSystemData {
  String? formatName;
  List<Format>? format;

  FantasyPointsSystemData({this.formatName, this.format});

  FantasyPointsSystemData.fromJson(Map<String, dynamic> json) {
    formatName = ModelParsers.toStringParser(json["format_name"]);
    format = json["Format"] == null
        ? null
        : (json["Format"] as List).map((e) => Format.fromJson(e)).toList();
  }
}

class Format {
  String? id;
  String? formatName;
  String? roleName;
  List<PointsSystemActions>? actions;
  List<Rules>? rules;
  bool? expended = false;

  Format({this.id, this.formatName, this.roleName, this.actions, this.rules});

  Format.fromJson(Map<String, dynamic> json) {
    id = ModelParsers.toStringParser(json["_id"]);
    formatName = ModelParsers.toStringParser(json["format_name"]);
    roleName = ModelParsers.toStringParser(json["role_name"]);
    actions = json["actions"] == null
        ? null
        : (json["actions"] as List)
            .map((e) => PointsSystemActions.fromJson(e))
            .toList();
    rules = json["rules"] == null
        ? null
        : (json["rules"] as List).map((e) => Rules.fromJson(e)).toList();
  }
}

class Rules {
  String? point;
  String? id;

  Rules({this.point, this.id});

  Rules.fromJson(Map<String, dynamic> json) {
    point = ModelParsers.toStringParser(json["point"]);
    id = ModelParsers.toStringParser(json["_id"]);
  }
}

class PointsSystemActions {
  String? type;
  int? value;
  String? id;

  PointsSystemActions({this.type, this.value, this.id});

  PointsSystemActions.fromJson(Map<String, dynamic> json) {
    type = ModelParsers.toStringParser(json["type"]);
    value = ModelParsers.toIntParser(json["value"]);
    id = ModelParsers.toStringParser(json["_id"]);
  }
}
